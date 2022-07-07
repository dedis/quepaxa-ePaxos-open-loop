#     1. Copy binaries to remote machine

reset_directory="rm -r /home/pasindu/epaxos; mkdir /home/pasindu/epaxos"
kill_insstances="pkill server ; pkill client; pkill replica"

replica1=pasindu@dedis-140.icsil1.epfl.ch
replica1_cert="/home/pasindu/Pictures/pasindu_rsa"
replica2=pasindu@dedis-141.icsil1.epfl.ch
replica2_cert="/home/pasindu/Pictures/pasindu_rsa"
replica3=pasindu@dedis-142.icsil1.epfl.ch
replica3_cert="/home/pasindu/Pictures/pasindu_rsa"


client1=pasindu@dedis-145.icsil1.epfl.ch
client1_cert="/home/pasindu/Pictures/pasindu_rsa"
client2=pasindu@dedis-146.icsil1.epfl.ch
client2_cert="/home/pasindu/Pictures/pasindu_rsa"
client3=pasindu@dedis-147.icsil1.epfl.ch
client3_cert="/home/pasindu/Pictures/pasindu_rsa"

master=pasindu@dedis-149.icsil1.epfl.ch
master_cert="/home/pasindu/Pictures/pasindu_rsa"


local_server_path="src/master/server"
local_master_path="src/master/master"
local_client_path="src/client/client"

replica_home_path="/home/pasindu/epaxos/"

echo "Replica 1"
sshpass ssh ${replica1} -i ${replica1_cert} ${reset_directory}
sshpass ssh ${replica1} -i ${replica1_cert} ${kill_insstances}
scp -i ${replica1_cert} ${local_server_path} ${replica1}:${replica_home_path} 

echo "Replica 2"
sshpass ssh ${replica2} -i ${replica2_cert} ${reset_directory}
sshpass ssh ${replica2} -i ${replica2_cert} ${kill_insstances}
scp -i ${replica2_cert} ${local_server_path} ${replica2}:${replica_home_path} 

echo "Replica 3"
sshpass ssh ${replica3} -i ${replica3_cert} ${reset_directory}
sshpass ssh ${replica3} -i ${replica3_cert} ${kill_insstances}
scp -i ${replica3_cert} ${local_server_path} ${replica3}:${replica_home_path} 

echo "Client 1"
sshpass ssh ${client1} -i ${client1_cert} ${reset_directory}
sshpass ssh ${client1} -i ${client1_cert} ${kill_insstances}
scp -i ${client1_cert} ${local_client_path} ${client1}:${replica_home_path} 

echo "Client 2"
sshpass ssh ${client2} -i ${client2_cert} ${reset_directory}
sshpass ssh ${client2} -i ${client2_cert} ${kill_insstances}
scp -i ${client2_cert} ${local_client_path} ${client2}:${replica_home_path} 

echo "Client 3"
sshpass ssh ${client3} -i ${client3_cert} ${reset_directory}
sshpass ssh ${client3} -i ${client3_cert} ${kill_insstances}
scp -i ${client3_cert} ${local_client_path} ${client3}:${replica_home_path} 

echo "Master"
sshpass ssh ${master} -i ${master_cert} ${reset_directory}
sshpass ssh ${master} -i ${master_cert} ${kill_insstances}
scp -i ${master_cert} ${local_master_path} ${master}:${replica_home_path}

echo "setup complete"