package main

import (
	"bufio"
	"flag"
	"fmt"
	"genericsmrproto"
	"log"
	"masterproto"
	"math"
	"math/rand"
	"net"
	"net/rpc"
	"os"
	"runtime"
	"state"
	"strconv"
	"sync"
	"time"

	"github.com/montanaflynn/stats"
)

const CLIENT_TIMEOUT = 2000000 // client side timeout in seconds

/*
	input variables
*/

var masterAddr *string = flag.String("maddr", "", "Master address. Defaults to localhost")
var masterPort *int = flag.Int("mport", 7087, "Master port.  Defaults to 7087.")
var writes *int = flag.Int("w", 100, "Percentage of updates (writes). Defaults to 100%.")
var leader *bool = flag.Bool("l", false, "EPaxos (no leader: false). Paxos: true.")
var procs *int = flag.Int("p", 8, "GOMAXPROCS. Defaults to 2")
var conflicts *int = flag.Int("c", 0, "Percentage of conflicts. Defaults to 0%")
var arrivalRate *int = flag.Int("arrivalRate", 1000, "Arrival Rate in requests per second. Defaults to 1000")
var clientBatchSize *int = flag.Int("clientBatchSize", 50, "client batch size")
var testDuration *int = flag.Int("testDuration", 60, "test duration in seconds")
var leaderTimeout *int = flag.Int("leaderTimeout", 20000, "leader timeout in micro seconds")
var defaultReplica *int = flag.Int("defaultReplica", 0, "default replica for Epaxos")
var window *int = flag.Int("window", 1000, "number of outstanding client batches")
var logFilePath *string = flag.String("logFilePath", "logs/", "log file path")
var name *string = flag.String("name", "4", "unique client name")

/*
	A clients sends one or more requests (i.e., DB read or write operations) at a time, we note down the send time and
	receive time in the following data structure
*/

type CmdLog struct {
	SendTime    time.Time     // the send time of this client command
	ReceiveTime time.Time     // the receive time of client  command
	Duration    time.Duration // the calculated latency of this command (ReceiveTime - SendTime)
	Sent        bool          // whether this slot is sent or not
}

/*
	A EPaxos client
*/

type Client struct {
	N                        int      // number of replicas
	CommandLog               []CmdLog // command log
	SentSoFar, ReceivedSoFar int

	arrivalRate     int        // requests per second poisson rate as specified
	arrivalTimeChan chan int64 // channel which stores the new arrival times
	arrivalChan     chan bool  // channel that triggers new open loop requests

	servers []net.Conn      // replica connections
	readers []*bufio.Reader // replica readers
	writers []*bufio.Writer // replica writers

	master     *rpc.Client // master/controller
	leader     int         // current leader index
	receivChan chan *genericsmrproto.ProposeReplyTS

	name            string
	logFilePath     string
	startTime       time.Time
	window          int
	receivedCnMutex *sync.Mutex
}

/*
	Initialize a EPaxos client
*/

func ClientInit(arrivalRate int, logFilePath string, name string, window int) *Client {
	c := &Client{
		CommandLog:      make([]CmdLog, 0),
		SentSoFar:       0,
		ReceivedSoFar:   0,
		arrivalRate:     arrivalRate,
		arrivalTimeChan: make(chan int64, 1000000),
		arrivalChan:     make(chan bool, 100000),
		leader:          *defaultReplica,
		receivChan:      make(chan *genericsmrproto.ProposeReplyTS, 1000000),
		name:            name,
		logFilePath:     logFilePath,
		startTime:       time.Now(),
		window:          window,
		receivedCnMutex: &sync.Mutex{},
	}

	pid := os.Getpid()
	fmt.Printf("initialized client with process id: %v \n", pid)

	return c
}

/*
	1. connect the master, connect to the set of replicas
	2. start the response listener
	3. start the failure detector
*/
func (c *Client) Prologue() {

	runtime.GOMAXPROCS(*procs)

	master, err := rpc.DialHTTP("tcp", fmt.Sprintf("%s:%d", *masterAddr, *masterPort))

	if err != nil {
		log.Fatalf("Error connecting to master\n")
	}

	c.master = master

	rlReply := new(masterproto.GetReplicaListReply)
	err = master.Call("Master.GetReplicaList", new(masterproto.GetReplicaListArgs), rlReply)
	if err != nil {
		log.Fatalf("Error making the GetReplicaList RPC")
	}

	c.N = len(rlReply.ReplicaList)
	c.servers = make([]net.Conn, c.N)
	c.readers = make([]*bufio.Reader, c.N)
	c.writers = make([]*bufio.Writer, c.N)

	for i := 0; i < c.N; i++ {
		var err error
		c.servers[i], err = net.Dial("tcp", rlReply.ReplicaList[i])
		if err != nil {
			log.Printf("Error connecting to replica %d\n", i)
		}
		c.readers[i] = bufio.NewReader(c.servers[i])
		c.writers[i] = bufio.NewWriter(c.servers[i])
	}

	c.waitReplies(c.readers)
	c.failureDetector()
}

/*
	listen to all readers and upon receiving a response add it to the receive channel
*/

func (c *Client) waitReplies(readers []*bufio.Reader) {

	for i := 0; i < len(readers); i++ {
		go func(local_i int) {
			for true {
				reply := new(genericsmrproto.ProposeReplyTS)
				if err := reply.Unmarshal(readers[local_i]); err != nil {
					// fmt.Println("connection broken:", err)
					break
				}
				//fmt.Println(reply.Value)
				c.receivChan <- reply

			}
		}(i)
	}
}

/*
	periodically check the current leader
*/

func (c *Client) failureDetector() {
	go func() {
		for true {
			reply := new(masterproto.GetLeaderReply)
			if err := c.master.Call("Master.GetLeader", new(masterproto.GetLeaderArgs), reply); err != nil {
				//log.Fatalf("Error making the GetLeader RPC\n")
			}
			if c.leader != reply.LeaderId {
				c.leader = reply.LeaderId
				//fmt.Printf("changed the leader to %v", c.leader)
			}
			time.Sleep(time.Duration(*leaderTimeout) * time.Microsecond)
		}
	}()
}

/*
	The main body of an open-loop client.
*/

func (c *Client) OpenLoopClient() {

	c.startTime = time.Now()
	c.generateArrivalTimes()

	go func() {
		id := 0 // request number
		for true {
			numRequests := 0
			for !(numRequests == *clientBatchSize) {
				_ = <-c.arrivalChan // keep collecting new requests arrivals
				numRequests++
			}
			c.receivedCnMutex.Lock()
			if (c.SentSoFar - c.ReceivedSoFar) < c.window*(*clientBatchSize) {
				c.receivedCnMutex.Unlock()
				c.sendOneRequest(int32(id))
				id = id + *clientBatchSize
			} else {
				c.receivedCnMutex.Unlock()
			}
		}
	}()

	go func() {
		for true {
			rep := <-c.receivChan
			c.processOneReply(rep)
		}
	}()

	c.startScheduler()           // this runs in the main loop
	time.Sleep(10 * time.Second) // for inflight requests
}

/*
	until the test duration is arrived, fetch new arrivals and inform the request generator thread
*/

func (c *Client) startScheduler() {
	start := time.Now()

	for time.Now().Sub(start).Nanoseconds() < int64(*testDuration*1000*1000*1000) { // run until test completion
		nextArrivalTime := <-c.arrivalTimeChan

		for time.Now().Sub(start).Nanoseconds() < nextArrivalTime {
			// busy waiting until the time to dispatch this request arrives
		}
		c.arrivalChan <- true
	}
}

/*
	generates poisson arrival times
*/

func (c *Client) generateArrivalTimes() {
	go func() {
		lambda := float64(c.arrivalRate) / (1000.0 * 1000.0 * 1000.0) // requests per nano second
		arrivalTime := 0.0

		for true {
			// Get the next probability value from Uniform(0,1)
			p := rand.Float64()

			//Plug it into the inverse of the CDF of Exponential(_lamnbda)
			interArrivalTime := -1 * (math.Log(1.0-p) / lambda)

			// Add the inter-arrival time to the running sum
			arrivalTime = arrivalTime + interArrivalTime

			c.arrivalTimeChan <- int64(arrivalTime)
		}
	}()
}

/*
	sends a batch of requests.

*/
func (c *Client) sendOneRequest(id int32) {

	for int32(len(c.CommandLog)) <= id+int32(1000**clientBatchSize) { // create new entries
		c.CommandLog = append(c.CommandLog, CmdLog{
			SendTime:    time.Time{},
			ReceiveTime: time.Time{},
			Duration:    0,
			Sent:        false,
		})
	}

	c.SentSoFar += *clientBatchSize

	args := genericsmrproto.Propose{id, state.Command{state.PUT, 0, 0}, 0}

	for j := 0; j < *clientBatchSize; j++ {
		args.CommandId = id
		r := rand.Intn(100)
		put_i := false
		if r < *writes {
			put_i = true
		}
		if put_i {
			args.Command.Op = state.PUT
		} else {
			args.Command.Op = state.GET
		}

		r = rand.Intn(100)
		karray_i := int64(43 + id)
		if r < *conflicts {
			karray_i = 42
		}

		args.Command.K = state.Key(karray_i)
		args.Command.V = state.Value(id)
		//args.Timestamp = time.Now().UnixNano()

		cur_leader := -1

		if *leader {
			// paxos
			cur_leader = c.leader
			for cur_leader >= c.N {
				cur_leader = c.leader
			}
		} else {
			// epaxos
			cur_leader = *defaultReplica
		}

		c.writers[cur_leader].WriteByte(genericsmrproto.PROPOSE)
		args.Marshal(c.writers[cur_leader])

		//fmt.Println("Sent", id)

		c.CommandLog[id].SendTime = time.Now()
		c.CommandLog[id].Sent = true
		id++
	}
	for j := 0; j < c.N; j++ {
		c.writers[j].Flush()
	}

}

/*
	process on received reply
*/

func (c *Client) processOneReply(rep *genericsmrproto.ProposeReplyTS) {
	if rep.CommandId >= 0 && int(rep.CommandId) < len(c.CommandLog) {
		if c.CommandLog[rep.CommandId].Duration != time.Duration(0) {
			//panic("already received")
			return
		}

		c.CommandLog[rep.CommandId].ReceiveTime = time.Now()
		c.CommandLog[rep.CommandId].Duration = c.CommandLog[rep.CommandId].ReceiveTime.Sub(c.CommandLog[rep.CommandId].SendTime)
		c.receivedCnMutex.Lock()
		c.ReceivedSoFar += 1
		c.receivedCnMutex.Unlock()
		// fmt.Print(fmt.Sprintf("$v", rep), "\n")
	}
}

/*
	converts int[] to float64[]
*/

func (c *Client) getFloat64List(list []int64) []float64 {
	var array []float64
	for i := 0; i < len(list); i++ {
		array = append(array, float64(list[i]))
	}
	return array
}

/*
	calculate stats
*/

func (c *Client) writeToLog() {

	f, err := os.Create(c.logFilePath + c.name + ".txt") // log file
	if err != nil {
		fmt.Printf("Error creating the output log file")
		log.Fatal(err)
	}
	defer f.Close()

	var latencyList []int64 // contains the time duration spent for each successful request in micro seconds
	noResponses := 0        // number of requests for which no response was received
	totalRequests := 0      // total number of requests sent
	responses := 0          // number of responses

	for i := 0; i < len(c.CommandLog); i++ {
		if c.CommandLog[i].Sent == true { // if this slot was used before
			if c.CommandLog[i].Duration != 0 { // if we got a response
				latencyList = c.addValueNToArrayMTimes(latencyList, c.CommandLog[i].Duration.Microseconds(), 1)
				c.printRequest(i, c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds(), c.CommandLog[i].ReceiveTime.Sub(c.startTime).Microseconds(), f)
				responses++
			} else { // no response
				latencyList = c.addValueNToArrayMTimes(latencyList, CLIENT_TIMEOUT, 1)
				c.printRequest(i, c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds(), c.CommandLog[i].SendTime.Sub(c.startTime).Microseconds()+CLIENT_TIMEOUT, f)
				noResponses++
			}
			totalRequests++
		}
	}
	if (responses + noResponses) != totalRequests {
		panic("should not happen")
	}
	medianLatency, _ := stats.Median(c.getFloat64List(latencyList))
	percentile99, _ := stats.Percentile(c.getFloat64List(latencyList), 99.0) // tail latency
	throughput := float64(responses) / float64(*testDuration)
	errorRate := (noResponses) * 100 / totalRequests

	fmt.Printf("Throughput (successfully committed requests) := %v requests per second   \n", throughput)
	fmt.Printf("Median Latency := %v micro seconds per request  \n", medianLatency)
	fmt.Printf("99 pecentile latency := %v micro seconds per request  \n", percentile99)
	fmt.Printf("Error Rate := %v \n", float64(errorRate))
}

/*
	Print a client request with arrival time and end time w.r.t test start time
*/

func (c *Client) printRequest(i int, startTime int64, endTime int64, f *os.File) {
	_, _ = f.WriteString(strconv.FormatInt(int64(i), 10) + "," + strconv.Itoa(int(startTime)) + "," + strconv.Itoa(int(endTime)) + "\n")
}

/*
	Add value N to list, M times
*/

func (c *Client) addValueNToArrayMTimes(list []int64, N int64, M int) []int64 {
	for i := 0; i < M; i++ {
		list = append(list, N)
	}
	return list
}

/*
	main thread of the client
*/

func main() {
	flag.Parse()

	client := ClientInit(*arrivalRate, *logFilePath, *name, *window)

	client.Prologue()
	client.OpenLoopClient()
	client.writeToLog()

	for _, conn := range client.servers {
		if conn != nil {
			conn.Close()
		}
	}
	client.master.Close()
}
