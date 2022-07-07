# A simple test that tests epaxos by sending client requests
arrival=$1
algo=$2
leader=$3

GOPATH=/home/pasindu/Documents/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server epaxos_server; cd ../.. ;  cd src/client ; go build -o client .; mv client epaxos_client; cd ../.. ; GO111MODULE=on


server_path="src/server/epaxos_server"
ctl_path="src/client/epaxos_client"
master_path="src/master/epaxos_master"
output_path="logs/"

rm -r ${output_path}; mkdir ${output_path}

pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_master 

echo "Killed previously running instances"

nohup ./${master_path} -N 3 >${output_path}1.log &

nohup ./${server_path} -port 7070 -maddr localhost --addr localhost -exec  -dreply "${algo}" >${output_path}2.log &
nohup ./${server_path} -port 7071 -maddr localhost --addr localhost -exec  -dreply "${algo}" >${output_path}3.log &
nohup ./${server_path} -port 7072 -maddr localhost --addr localhost -exec  -dreply "${algo}" >${output_path}4.log &
 
sleep 10
 
echo "Started master and 3 servers"

nohup ./${ctl_path} -name 5  -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 0 -logFilePath ${output_path}  "${leader}" >${output_path}5.log &
nohup ./${ctl_path} -name 6  -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 1 -logFilePath ${output_path}  "${leader}" >${output_path}6.log &
      ./${ctl_path} -name 7  -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 2 -logFilePath ${output_path}  "${leader}" >${output_path}7.log

sleep 10

echo "finished running clients"

pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_master 

echo "Killed instances"

echo "Finish test"