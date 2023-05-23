This repo implements Paxos and EPaxos with configurable batching and pipelining

This repo is a fork from ```https://github.com/efficient/epaxos```. All rights beling to the original authors of EPaxos

To build the project, run

```GOPATH=/home/pasindu/Documents/epaxos; GO111MODULE=off; cd src/master ; go build -o master .; mv master /home/pasindu/Documents/epaxos/bin/epaxos_master; cd ../.. ; cd src/server ; go build -o server .; mv server /home/pasindu/Documents/epaxos/bin/epaxos_server; cd ../.. ;  cd src/client ; go build -o client .; mv client /home/pasindu/Documents/epaxos/bin/epaxos_client; cd ../.. ; GO111MODULE=on```