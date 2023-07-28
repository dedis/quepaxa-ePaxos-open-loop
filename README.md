This repository implements Paxos and EPaxos with configurable batching and pipelining

This repository is a fork from ```https://github.com/efficient/epaxos```. All rights belong to the original authors of EPaxos

To build the project, run

```
GOPATH=/home/username/epaxos
GO111MODULE=off
cd src/master
go build -o master .
mv master /home/username/epaxos/bin/epaxos_master
cd ../..
cd src/server
go build -o server .
mv server /home/username/epaxos/bin/epaxos_server
cd ../..
cd src/client
go build -o client .
mv client /home/username/epaxos/bin/epaxos_client
cd ../..
GO111MODULE=on
```