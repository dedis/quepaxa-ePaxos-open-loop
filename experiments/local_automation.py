import os

for arrival in [1000, 20000]:
    for batchSize in [1, 50, 3000]:
        for batchTime in [100, 2000]:
            for leaderTimeout in [1000, 3000, 1000000]:
                for pipeline in [1, 10, 100]:
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


