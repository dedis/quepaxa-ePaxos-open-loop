#EPaxos

To build the project

```GOPATH=/home/xxx/xxx/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server epaxos_server; cd ../.. ;  cd src/client ; go build -o client .; mv client epaxos_client; cd ../.. ; GO111MODULE=on```

To run the 3 replica experiment please refer to ```experiments/local-consensus-epaxos-test.sh```