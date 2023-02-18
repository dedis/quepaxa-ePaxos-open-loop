import os

def run(arrival, batchSize, batchTime, leaderTimeout, pipeline):
    os.system("/bin/bash /home/pasindu/Documents/epaxos/experiments/local-consensus-epaxos-test.sh "+ str(arrival) + " "
                              + "-pa" + " "
                              + str(batchSize) + " "
                              + str(batchTime) + " "
                              + str(leaderTimeout) + " "
                              + str(pipeline) + " "
                              + "-l" + " ")
    os.system("/bin/bash /home/pasindu/Documents/epaxos/experiments/local-consensus-epaxos-test.sh "+ str(arrival) + " "
                              + "-e" + " "
                              + str(batchSize) + " "
                              + str(batchTime) + " "
                              + str(leaderTimeout) + " "
                              + str(pipeline))
# case 1
arrival=1000
batchSize=1
batchTime=1
leaderTimeout=1000000
pipeline=1
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)


# case 2
arrival=10000
batchSize=50
batchTime=50
leaderTimeout=1000000
pipeline=1
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)


# case 3
arrival=10000
batchSize=50
batchTime=50
leaderTimeout=1000000
pipeline=10
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)


# case 4
arrival=10000
batchSize=50
batchTime=50
leaderTimeout=10000
pipeline=1
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)

# case 5
arrival=10000
batchSize=50
batchTime=50
leaderTimeout=1000
pipeline=1
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)

# case 6
arrival=10000
batchSize=50
batchTime=50
leaderTimeout=100
pipeline=1
run(arrival, batchSize, batchTime, leaderTimeout, pipeline)
