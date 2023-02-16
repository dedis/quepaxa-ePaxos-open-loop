This repo implements Paxos and EPaxos

To build the project

```GOPATH=/home/pasindu/Documents/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master /home/pasindu/Documents/epaxos/bin/epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server /home/pasindu/Documents/epaxos/bin/epaxos_server; cd ../.. ;  cd src/client ; go build -o client .; mv client /home/pasindu/Documents/epaxos/bin/epaxos_client; cd ../.. ; GO111MODULE=on```