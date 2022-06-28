To build the project

1. set ```GOPATH=/tmp/epaxos``` 
2. ```GO111MODULE=off```
3. ```cd src/server; go build -o server . ; cd ../.. ; cd src/master; go build -o master . ; cd ../.. ; cd src/client; go build -o client . ; cd ../..```

To run the 3 replica expiement

1. ```./server  -port 7070 -maddr localhost --addr localhost -exec  -dreply [-e]```
2. ```./server  -port 7071 -maddr localhost --addr localhost -exec  -dreply [-e]```
3. ```./server  -port 7072 -maddr localhost --addr localhost -exec  -dreply [-e]```

4. ```./master  -N 3```

5. ```./client -maddr localhost -w 50  -c 50 [-l] -arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 0```
6. ```./client -maddr localhost -w 50  -c 50 [-l] -arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 1```
7. ```./client -maddr localhost -w 50  -c 50 -[l]-arrivalRate "${arrival}" -clientBatchSize 50 -clientTimeout 60 -defaultReplica 2```