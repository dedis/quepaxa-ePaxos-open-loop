arrival=$1

remote_server_path="/epaxos/epaxos_server"
remote_master_path="/epaxos/epaxos_master"
remote_client_path="/epaxos/epaxos_client"

output_path="logs/"
remote_log_path="/home/pasindu/epaxos/"

replica1=pasindu@dedis-140.icsil1.epfl.ch
replica1_cert="/home/pasindu/Pictures/pasindu_rsa"
replica2=pasindu@dedis-141.icsil1.epfl.ch
replica2_cert="/home/pasindu/Pictures/pasindu_rsa"
replica3=pasindu@dedis-142.icsil1.epfl.ch
replica3_cert="/home/pasindu/Pictures/pasindu_rsa"
#replica4=pasindu@dedis-143.icsil1.epfl.ch
#replica4_cert="/home/pasindu/Pictures/pasindu_rsa"
#replica5=pasindu@dedis-144.icsil1.epfl.ch
#replica5_cert="/home/pasindu/Pictures/pasindu_rsa"

client1=pasindu@dedis-145.icsil1.epfl.ch
client1_cert="/home/pasindu/Pictures/pasindu_rsa"
client2=pasindu@dedis-146.icsil1.epfl.ch
client2_cert="/home/pasindu/Pictures/pasindu_rsa"
client3=pasindu@dedis-147.icsil1.epfl.ch
client3_cert="/home/pasindu/Pictures/pasindu_rsa"
#client4=pasindu@dedis-148.icsil1.epfl.ch
#client4_cert="/home/pasindu/Pictures/pasindu_rsa"
#client5=pasindu@dedis-149.icsil1.epfl.ch
#client5_cert="/home/pasindu/Pictures/pasindu_rsa"

master=pasindu@dedis-149.icsil1.epfl.ch
master_cert="/home/pasindu/Pictures/pasindu_rsa"

rm ${output_path}1.log
rm ${output_path}2.log
rm ${output_path}3.log
rm ${output_path}4.log
rm ${output_path}5.log
rm ${output_path}6.log
rm ${output_path}7.log

echo "Removed old log files"

kill_command="pkill epaxos_master ; pkill epaxos_server; pkill epaxos_client"

sshpass ssh -i ${replica1_cert} ${replica1} "${kill_command}"
sshpass ssh -i ${replica2_cert} ${replica2} "${kill_command}"
sshpass ssh -i ${replica3_cert} ${replica3} "${kill_command}"

sshpass ssh -i ${client1_cert} ${client1} "${kill_command}"
sshpass ssh -i ${client2_cert} ${client2} "${kill_command}"
sshpass ssh -i ${client3_cert} ${client3} "${kill_command}"

sshpass ssh -i ${master_cert} ${master} "${kill_command}"

echo "killed previous running instances"

sleep 5

echo "starting replicas"

nohup sshpass ssh -i ${replica1_cert} -n -f ${replica1} ".${remote_server_path}  -port 7070 -maddr 10.156.33.149 --addr 10.156.33.140 -exec  -dreply -e" >${output_path}2.log &
nohup sshpass ssh -i ${replica2_cert} -n -f ${replica2} ".${remote_server_path}  -port 7071 -maddr 10.156.33.149 --addr 10.156.33.141 -exec  -dreply -e" >${output_path}3.log &
nohup sshpass ssh -i ${replica3_cert} -n -f ${replica3} ".${remote_server_path}  -port 7072 -maddr 10.156.33.149 --addr 10.156.33.142 -exec  -dreply -e" >${output_path}4.log &

sleep 5

nohup sshpass ssh -i ${master_cert} -n -f ${master} ".${remote_master_path} -N 3 " >${output_path}1.log &

sleep 5

echo "Starting client[s]"

nohup sshpass ssh -i ${client1_cert} ${client1} ".${remote_client_path} -name 5   -maddr 10.156.33.149 -w 50  -c 50 -arrivalRate ${arrival} -clientBatchSize 100 -clientTimeout 60 -defaultReplica 0 -logFilePath ${remote_log_path}" >${output_path}5.log &
nohup sshpass ssh -i ${client2_cert} ${client2} ".${remote_client_path} -name 6   -maddr 10.156.33.149 -w 50  -c 50 -arrivalRate ${arrival} -clientBatchSize 100 -clientTimeout 60 -defaultReplica 1 -logFilePath ${remote_log_path}" >${output_path}6.log &
      sshpass ssh -i ${client3_cert} ${client3} ".${remote_client_path} -name 7   -maddr 10.156.33.149 -w 50  -c 50 -arrivalRate ${arrival} -clientBatchSize 100 -clientTimeout 60 -defaultReplica 2 -logFilePath ${remote_log_path}" >${output_path}7.log

sleep 10

echo "Completed Client[s]"

sleep 50

scp -i ${client1_cert} ${client1}:${remote_log_path}5.txt ${output_path}5.txt
scp -i ${client2_cert} ${client2}:${remote_log_path}6.txt ${output_path}6.txt
scp -i ${client3_cert} ${client3}:${remote_log_path}7.txt ${output_path}7.txt


dst_directory="/home/pasindu/Desktop/Test/epaxos/${arrival}/"
mkdir -p "${dst_directory}"
cp -r ${output_path} "${dst_directory}"

sshpass ssh -i ${replica1_cert} ${replica1} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "
sshpass ssh -i ${replica2_cert} ${replica2} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "
sshpass ssh -i ${replica3_cert} ${replica3} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "

sshpass ssh -i ${client1_cert} ${client1} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "
sshpass ssh -i ${client2_cert} ${client2} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "
sshpass ssh -i ${client3_cert} ${client3} "pkill epaxos_server;pkill  epaxos_client; pkill epaxos_master;  "

sshpass ssh -i ${master_cert} ${master} "pkill epaxos_server; epaxos_client; pkill epaxos_master;  "

echo "killed  instances"

echo "Finish test"
