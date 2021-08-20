# Testing EPaxos and Paxos in Cloudlab
## Experiment Setup
1. 3 server machines
2. 3 client machine

## Installation (***For Each Machine***)
1. Make sure Rabia is properly installed. Follow the instructions in the repo. This step is critical as it provides the go binary and python3.8 needed for testing.
2. SSH into each of the VMs and do the following: 
    1. `cd ~/go/src`
    2. ```git clone https://github.com/zhouaea/epaxos.git && cd epaxos```
    3. `git checkout paxos-no-batching`
    4. ```. compile.sh```
    5. After compiling, you should see
       </br>
       ```Built Master```
       </br>
       ```Built Server```
       </br>
       ```Built Client```

## Switching Between Paxos and EPaxos Configurations 
For your convenience, we have created branches preloaded with the configurations we used for each experiment mentioned in the paper. 

In each machine, `git checkout` into your desired branch. Compile go binaries on each machine with `. compile.sh`. Then, follow the instructions below, starting from *Configure Machines*.
### For Table 1
#### Table 1 Paxos
`git checkout paxos-no-batching`  
#### Table 1 EPaxos
`git checkout epaxos-no-batching` 
### For Figure 4
#### Figure 4 Paxos
`git checkout paxos-batching`  
#### Figure 4 EPaxos
`git checkout epaxos-batching`
### For Varying Data Size
#### Paxos 256B Data Size
`git checkout paxos-batching-data-size-256B`
#### EPaxos 256B Data Size
`git checkout epaxos-batching-data-size-256B`

## Configure Machines

### Find the Experiment Network IP Address of each Machine
1. First, find the description of your machine by looking for a `<node>` tag with the attribute `client_id=<your_machine_name>`.
2. Inside the node tag, look for `<interface>`, and inside it you should see an `<ip/>` tag. The attribute `address` will give you the machine's experiment network ip.
3. The address likely has the format `10.10.1.x`.
![Identifying Master Server IP Screenshot](./README-images/Identifying%20Master%20Server%20IP.png)

### Modify Each Machine's Execution Script
Inside `base-profile.sh` in each machine, configure the experimental network IP address of all server machines in the `ServerIps` array, client machines in the `ClientIps` array, and the server machine that will be the leader in the `MasterIP` variable.

## Run
1. Finally, run `. runPaxos.sh` or `. runEPaxos.sh` (depending on the branch) on your master machine only. You should see a relatively constant flow of messages in your terminal.
   1. Some of our results, namely those done for *Figure 4* or *Varying Data Size*, require multiple experiments to be run with a varying number of clients. For these experiments, we provide 9 profiles, where `profile0.sh` runs 20 clients, while `profile8.sh` runs 500 clients. To change which profile is being executed, change the first line of either `runPaxos.sh` or `runEPaxos.sh` on **each machine** to execute your desired profile. By default, `profile0.sh` will be executed. 
2. If all works correctly, there will be n client logs inside the /logs directory in your master machine.
3. For throughput/latency analysis, run:
    1. ```python3.8 analysis.py ./logs```
    2. If you get the error below, you didn't supply `./logs` as an argument
       ```bash
       Traceback (most recent call last):
            File "analysis.py", line 164, in <module>
              infos, disconnects = analysis_epaxos_logs()
            File "analysis.py", line 100, in analysis_epaxos_logs
              params = get_experiments(argv[1])
       IndexError: list index out of range
       ```
    3. If successful, this will output a variety of different statistics. You can find the relevant statistics as `clientp50Latency: x`, `clientp99Latency: x`, `throughput: x`
.    
