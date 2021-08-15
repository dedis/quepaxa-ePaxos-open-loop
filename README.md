## Testing Epaxos and Paxos in Cloudlab
### Experiment Setup
1. 3 server machines
2. 1 client machine

### Switching Between Paxos  and EPaxos 
#### Paxos
Do `git checkout paxos-no-batching` to get the setup we used to get the results for Paxos  in Table 1. Then, follow the instructions down below.
#### EPaxos
Do `git checkout epaxos-no-batching` to get the setup we used to get the results for EPaxos  in Table 1. Then, follow the instructions down below.

### Installation (***For Each Machine***)
1. Make sure Rabia is properly installed. Follow the instructions in the repo. This step is critical as it provides the go binary and python3.8 needed for testing.
2. SSH into each of the VMs and do the following inside `~/go/src`:
    1. ```git clone https://github.com/rabia-consensus/epaxos.git && cd epaxos```
    4. ```. compile.sh```
    5. After compiling, you should see
       </br>
       ```Built Master```
       </br>
       ```Built Server```
       </br>
       ```Built Client```

### Configure Machines

#### Find the Experiment Network IP Address of each Machine
1. First, find the description of your machine by looking for a `<node>` tag with the attribute `client_id=<your_machine_name>`.2. Inside the node tag, look for `<interface>`, and inside it you should see an `<ip/>` tag. The attribute `address` will give you the machine's experiment network ip.
2. The address likely has the format `10.10.1.x`.
3. ![Identifying Master Server IP Screenshot](./README-images/Identifying%20Master%20Server%20IP.png)

#### Modify Each Machine's Execution Script
Inside ```epaxos.sh```, configure the experimental network IP address of all server machines, client machines, and the specific address of the server machine that will be the master.

### Run
1. Finally, run ```. epaxos.sh > run.txt``` on your master machine.
2. If all works correctly, you should see n client logs inside the /logs directory in your master machine.
3. For throughput/latency analysis, run:
    1. ```python3.8 analysis.py ./logs```
    
