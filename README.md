#EPaxos

To build the project

```GOPATH=/home/xxx/xxx/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server epaxos_server; cd ../.. ;  cd src/client ; go build -o client .; mv client epaxos_client; cd ../.. ; GO111MODULE=on```

To run the 3 replica experiment please refer to ```experiments/local-consensus-epaxos-test.sh```

Remote repositories

Asynchronous consensus repo    : https://github.com/PasinduTennage/async-consensus

Modified Rabia repo		: https://github.com/PasinduTennage/rabia

Modified Epaxos repo		: https://github.com/PasinduTennage/epaxos

Experiments repo		: https://github.com/PasinduTennage/async_consensus_experiments
