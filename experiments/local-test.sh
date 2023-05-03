# A test that tests epaxos by sending client requests
arrival=$1
algo=$2
batchSize=$3
batchTime=$4
leaderTimeout=$5
pipeline=$6
leader=$7
window=$8

server_path="bin/epaxos_server"
ctl_path="bin/epaxos_client"
master_path="bin/epaxos_master"
output_path="logs/"

# rm -r bin/; mkdir bin ; GOPATH=/home/pasindu/Documents/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master /home/pasindu/Documents/epaxos/bin/epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server /home/pasindu/Documents/epaxos/bin/epaxos_server; cd ../.. ; cd src/client ; go build -o client .; mv client /home/pasindu/Documents/epaxos/bin/epaxos_client; cd ../.. ; GO111MODULE=on

rm -r ${output_path}; mkdir ${output_path}

pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_master 
pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_master

echo "Killed previously running instances"

nohup ./${master_path} -N 5 -leaderTimeout "${leaderTimeout}" >${output_path}1.log &

nohup ./${server_path} -port 7070 -maddr localhost --addr localhost -exec  -dreply "${algo}" -batchSize "${batchSize}" -batchTime "${batchTime}" -pipeline "${pipeline}" >${output_path}2.log &
nohup ./${server_path} -port 7071 -maddr localhost --addr localhost -exec  -dreply "${algo}" -batchSize "${batchSize}" -batchTime "${batchTime}" -pipeline "${pipeline}" >${output_path}3.log &
nohup ./${server_path} -port 7072 -maddr localhost --addr localhost -exec  -dreply "${algo}" -batchSize "${batchSize}" -batchTime "${batchTime}" -pipeline "${pipeline}" >${output_path}4.log &
nohup ./${server_path} -port 7073 -maddr localhost --addr localhost -exec  -dreply "${algo}" -batchSize "${batchSize}" -batchTime "${batchTime}" -pipeline "${pipeline}" >${output_path}5.log &
nohup ./${server_path} -port 7074 -maddr localhost --addr localhost -exec  -dreply "${algo}" -batchSize "${batchSize}" -batchTime "${batchTime}" -pipeline "${pipeline}" >${output_path}6.log &

sleep 10
 
echo "Started master and 5 servers"

nohup ./${ctl_path} -name 7   -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -testDuration 60 -defaultReplica 0 -logFilePath ${output_path}  "${leader}" -leaderTimeout "${leaderTimeout}" -window "${window}">${output_path}7.log  &
nohup ./${ctl_path} -name 8   -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -testDuration 60 -defaultReplica 1 -logFilePath ${output_path}  "${leader}" -leaderTimeout "${leaderTimeout}" -window "${window}">${output_path}8.log  &
nohup ./${ctl_path} -name 9   -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -testDuration 60 -defaultReplica 2 -logFilePath ${output_path}  "${leader}" -leaderTimeout "${leaderTimeout}" -window "${window}">${output_path}9.log  &
nohup ./${ctl_path} -name 10  -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -testDuration 60 -defaultReplica 3 -logFilePath ${output_path}  "${leader}" -leaderTimeout "${leaderTimeout}" -window "${window}">${output_path}10.log &
nohup ./${ctl_path} -name 11  -maddr localhost -w 50  -c 50 -arrivalRate "${arrival}" -clientBatchSize 50 -testDuration 60 -defaultReplica 4 -logFilePath ${output_path}  "${leader}" -leaderTimeout "${leaderTimeout}" -window "${window}">${output_path}11.log &

sleep 130

echo "finished running clients"

pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_server; pkill epaxos_master
pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client; pkill epaxos_client;

echo "Killed instances"


echo "Finish test"