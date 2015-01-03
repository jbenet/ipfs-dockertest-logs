# log6

- completes first tinyfile transfer
- server_1 completes adding tinyfile
- client_1 also provides tinyfile
- server_1 (maybe) completes adding randfile (~400 putProvider statements)
- client_1 bitswap doesnt even try sending wantlist
- content deadline exceeded (minute long deadline, so no timing problem here)
- see the last bits of output below.

### Veredict: client_1 bitswap fails to send wantlist out with second file

Not clear why. i added more logging to bitswap, but after running this test.


## Notes

- completes first tinyfile transfer

Note how client_1 moves on to `QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM`

```
% cat full | grep dockertest
Attaching to dockertest_bootstrap_1, dockertest_data_1, dockertest_server_1, dockertest_client_1
server_1    | dockertest> starting server daemon
client_1    | dockertest> starting client daemon
client_1    | dockertest> waiting for server to add the file...
server_1    | dockertest> added tiny file. hash is QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf
client_1    | dockertest> client found file with hash: QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
client_1    | dockertest> waiting for server to add the file...
server_1    | dockertest> added rand file. hash is QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM
client_1    | dockertest> client found file with hash: QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM
dockertest_client_1 exited with code 1
```

- server_1 completes adding tinyfile
- client_1 also provides tinyfile

```
% cat dht-provide | grep putProvider | grep QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf
server_1    | 2015-01-03 15:05:41.202842 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip6/fe80::42:acff:fe11:203/udp/4022/utp /ip4/172.17.2.3/tcp/4021 /ip6/fe80::42:acff:fe11:203/tcp/4021 /ip4/172.17.2.3/udp/4022/utp])
client_1    | 2015-01-03 15:05:42.611065 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.4/tcp/4031 /ip6/fe80::42:acff:fe11:204/tcp/4031 /ip4/172.17.2.4/udp/4032/utp /ip6/fe80::42:acff:fe11:204/udp/4032/utp])
client_1    | 2015-01-03 15:05:42.634946 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> putProvider: <peer.ID Qmbtc2> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.4/udp/4032/utp /ip6/fe80::42:acff:fe11:204/udp/4032/utp /ip4/172.17.2.4/tcp/4031 /ip6/fe80::42:acff:fe11:204/tcp/4031])
```

- server_1 (maybe) completes adding randfile (~400 putProvider statements)


Run:

```
cat dht-provide | grep server_1
```

- client_1 bitswap doesnt even try sending wantlist

```
% cat bitswap | grep client_1
// normal init stuff
client_1    | 2015-01-03 15:05:38.409264 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081f3230 4> setting handler for protocol: /ipfs/bitswap (13)

// getting QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf -- success
client_1    | 2015-01-03 15:05:42.492424 DEBUG blockservice blockservice.go:72: Blockservice: Searching bitswap.
client_1    | 2015-01-03 15:05:42.494891 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf) GetBlockRequestBegin
client_1    | 2015-01-03 15:05:42.495875 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(1) begin
client_1    | 2015-01-03 15:05:42.541371 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(1) <peer.ID Qmbtc2> sending
client_1    | 2015-01-03 15:05:42.541483 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).bitswap.sendWantlistMsgToPeer(1, <peer.ID Qmbtc2>) sending wantlist
client_1    | 2015-01-03 15:05:42.545248 DEBUG bitswap_network ipfs_impl.go:44: bitswap net SendMessage to <peer.ID Qmbtc2>
client_1    | 2015-01-03 15:05:42.549438 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).bitswap.sendWantlistMsgToPeer(1, <peer.ID Qmbtc2>) send wantlist success
client_1    | 2015-01-03 15:05:42.568826 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/bitswap
client_1    | 2015-01-03 15:05:42.574310 DEBUG bitswap_network ipfs_impl.go:116: bitswap net handleNewStream from <peer.ID Qmbtc2>
client_1    | 2015-01-03 15:05:42.588964 DEBUG bitswap prefixlog.go:107: ReceiveMessage from <peer.ID Qmbtc2>
client_1    | 2015-01-03 15:05:42.590380 DEBUG bitswap prefixlog.go:107: engine.MessageReceived <peer.ID Qmbtc2> start
client_1    | 2015-01-03 15:05:42.590539 DEBUG engine prefixlog.go:107: bitswap.Engine.MessageReceived(<peer.ID Qmbtc2>) enter
client_1    | 2015-01-03 15:05:42.594874 DEBUG engine prefixlog.go:107: bitswap.Engine.MessageReceived(<peer.ID Qmbtc2>) got block %s %d bytes QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf 760
client_1    | 2015-01-03 15:05:42.598010 DEBUG engine prefixlog.go:107: bitswap.Engine.MessageReceived(<peer.ID Qmbtc2>) exit
client_1    | 2015-01-03 15:05:42.598099 DEBUG bitswap prefixlog.go:107: engine.MessageReceived <peer.ID Qmbtc2> done
client_1    | 2015-01-03 15:05:42.600217 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(1) end
client_1    | 2015-01-03 15:05:42.607465 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf) GetBlockRequestEnd
client_1    | 2015-01-03 15:05:42.607749 WARNING bitswap prefixlog.go:125: Received batch request for zero blocks
client_1    | 2015-01-03 15:05:42.637904 DEBUG bitswap_network ipfs_impl.go:44: bitswap net SendMessage to <peer.ID Qmbtc2>
client_1    | 2015-01-03 15:05:48.414759 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistToProviders  begin
client_1    | 2015-01-03 15:05:48.416018 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(0) begin

// getting QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM -- just expires
client_1    | 2015-01-03 15:05:52.863384 DEBUG blockservice blockservice.go:72: Blockservice: Searching bitswap.
client_1    | 2015-01-03 15:05:52.863952 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM) GetBlockRequestBegin
client_1    | 2015-01-03 15:06:52.868003 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM) GetBlockRequestEnd```
```

- content deadline exceeded (minute long deadline, so no timing problem here)

```
client_1    | 2015-01-03 15:06:38.488688 ERROR core prefixlog.go:110: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:52.868003 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM) GetBlockRequestEnd
client_1    | Error: context deadline exceeded
// it did wait a while
```

- see the last bits of output below.

```
server_1    | 2015-01-03 15:05:52.510930 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:05:52.511028 DEBUG swarm2 prefixlog.go:107: [<peer.ID Qmbtc2>] network opening stream to peer [<peer.ID Qmbtc3>]
server_1    | 2015-01-03 15:05:52.511455 DEBUG swarm2 prefixlog.go:107: Swarm: NewStreamWithPeer...
bootstrap_1 | 2015-01-03 15:05:52.512690 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
bootstrap_1 | 2015-01-03 15:05:52.515323 WARNING dht prefixlog.go:125: handleFindPeer: could not find anything.
client_1    | 2015-01-03 15:05:52.515849 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
server_1    | 2015-01-03 15:05:52.521627 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID Qmbtc3> for QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM ([/ip4/172.17.2.3/tcp/4021 /ip6/fe80::42:acff:fe11:203/tcp/4021 /ip4/172.17.2.3/udp/4022/utp /ip6/fe80::42:acff:fe11:203/udp/4022/utp])
client_1    | 2015-01-03 15:05:52.525161 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> adding <peer.ID Qmbtc2> as a provider for 'QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM'
client_1    | 2015-01-03 15:05:52.525376 INFO dht prefixlog.go:116: received provider <peer.ID Qmbtc2> for QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM (addrs: [/ip4/172.17.2.3/tcp/4021 /ip6/fe80::42:acff:fe11:203/tcp/4021 /ip4/172.17.2.3/udp/4022/utp /ip6/fe80::42:acff:fe11:203/udp/4022/utp])
client_1    | 2015-01-03 15:05:52.525547 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
client_1    | 2015-01-03 15:05:52.526368 DEBUG dht prefixlog.go:107: handleFindPeer: sending back '<peer.ID QmNXuB>'
server_1    | 2015-01-03 15:05:52.532440 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID Qmbtc3> - not found, and no closer peers.
server_1    | 2015-01-03 15:05:52.532640 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:05:52.536955 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID QmNXuB> - not found, and no closer peers.
server_1    | 2015-01-03 15:05:52.542010 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:05:52.542155 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:05:52.542411 INFO core/commands add.go:142: adding file: /data/filerand
server_1    | dockertest> added rand file. hash is QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM
client_1    | dockertest> client found file with hash: QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM
client_1    | QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM
client_1    | 2015-01-03 15:05:52.807969 INFO updates updates.go:94: go-ipfs Version: 0.1.7
client_1    | 2015-01-03 15:05:52.848507 DEBUG cmd/ipfs prefixlog.go:107: config path is /root/.go-ipfs
client_1    | 2015-01-03 15:05:52.849231 INFO cmd/ipfs prefixlog.go:116: looking for running daemon...
client_1    | 2015-01-03 15:05:52.850156 INFO cmd/ipfs prefixlog.go:116: a daemon is running...
client_1    | 2015-01-03 15:05:52.850434 DEBUG cmd/ipfs prefixlog.go:107: Calling pre-command hooks...
client_1    | 2015-01-03 15:05:52.850558 INFO cmd/ipfs prefixlog.go:116: a daemon is running...
client_1    | 2015-01-03 15:05:52.850596 DEBUG cmd/ipfs prefixlog.go:107: Calling hook: Configure Event Logger
client_1    | 2015-01-03 15:05:52.851132 INFO cmd/ipfs prefixlog.go:116: Executing command on daemon running at /ip4/127.0.0.1/tcp/5001
client_1    | 2015-01-03 15:05:52.862451 DEBUG commands/http handler.go:43: Incoming API request: /api/v0/cat?arg=QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM&encoding=json
client_1    | 2015-01-03 15:05:52.862731 DEBUG path path.go:26: Resolve: 'QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM'
client_1    | 2015-01-03 15:05:52.863119 DEBUG path path.go:48: Resolve dag get.
client_1    | 2015-01-03 15:05:52.863284 DEBUG blockservice blockservice.go:65: BlockService GetBlock: 'QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM'
client_1    | 2015-01-03 15:05:52.863384 DEBUG blockservice blockservice.go:72: Blockservice: Searching bitswap.
client_1    | 2015-01-03 15:05:52.863952 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM) GetBlockRequestBegin
bootstrap_1 | 2015-01-03 15:06:03.036329 DEBUG core prefixlog.go:107: <peer.ID QmNXuB> bootstrapping to 2 more nodes
bootstrap_1 | 2015-01-03 15:06:03.036724 ERROR core prefixlog.go:110: <peer.ID QmNXuB> bootstrap error: must bootstrap to 2 more nodes, but already connected to all candidates
bootstrap_1 | 2015-01-03 15:06:03.036907 ERROR core prefixlog.go:110: must bootstrap to 2 more nodes, but already connected to all candidates
server_1    | 2015-01-03 15:06:08.405046 DEBUG core prefixlog.go:107: <peer.ID Qmbtc2> bootstrapping to 1 more nodes
server_1    | 2015-01-03 15:06:08.413718 ERROR core prefixlog.go:110: <peer.ID Qmbtc2> bootstrap error: must bootstrap to 1 more nodes, but already connected to all candidates
server_1    | 2015-01-03 15:06:08.414781 ERROR core prefixlog.go:110: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:08.484962 DEBUG core prefixlog.go:107: <peer.ID Qmbtc3> bootstrapping to 1 more nodes
client_1    | 2015-01-03 15:06:08.485446 ERROR core prefixlog.go:110: <peer.ID Qmbtc3> bootstrap error: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:08.485519 ERROR core prefixlog.go:110: must bootstrap to 1 more nodes, but already connected to all candidates
bootstrap_1 | 2015-01-03 15:06:33.039629 DEBUG core prefixlog.go:107: <peer.ID QmNXuB> bootstrapping to 2 more nodes
bootstrap_1 | 2015-01-03 15:06:33.039989 ERROR core prefixlog.go:110: <peer.ID QmNXuB> bootstrap error: must bootstrap to 2 more nodes, but already connected to all candidates
bootstrap_1 | 2015-01-03 15:06:33.040074 ERROR core prefixlog.go:110: must bootstrap to 2 more nodes, but already connected to all candidates
server_1    | 2015-01-03 15:06:38.417326 DEBUG core prefixlog.go:107: <peer.ID Qmbtc2> bootstrapping to 1 more nodes
server_1    | 2015-01-03 15:06:38.426249 ERROR core prefixlog.go:110: <peer.ID Qmbtc2> bootstrap error: must bootstrap to 1 more nodes, but already connected to all candidates
server_1    | 2015-01-03 15:06:38.426960 ERROR core prefixlog.go:110: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:38.487364 DEBUG core prefixlog.go:107: <peer.ID Qmbtc3> bootstrapping to 1 more nodes
client_1    | 2015-01-03 15:06:38.488098 ERROR core prefixlog.go:110: <peer.ID Qmbtc3> bootstrap error: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:38.488688 ERROR core prefixlog.go:110: must bootstrap to 1 more nodes, but already connected to all candidates
client_1    | 2015-01-03 15:06:52.868003 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmRPWSeLwqsZTewUFgyVjKzbPGqokatPX3nuHggnNCvzfM) GetBlockRequestEnd
client_1    | Error: context deadline exceeded
client_1    | ipfs cat failed
server_1    | 2015-01-03 15:06:53.005265 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
bootstrap_1 | 2015-01-03 15:06:53.005421 DEBUG conn prefixlog.go:107: <peer.ID QmNXuB> closing Conn with <peer.ID >
server_1    | 2015-01-03 15:06:53.005791 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
bootstrap_1 | 2015-01-03 15:06:53.006340 DEBUG conn prefixlog.go:107: <peer.ID QmNXuB> closing Conn with <peer.ID >
server_1    | 2015-01-03 15:06:53.006281 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:06:53.006982 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:06:53.007113 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:06:53.007129 DEBUG conn prefixlog.go:107: <peer.ID Qmbtc2> closing Conn with <peer.ID Qmbtc3>
bootstrap_1 | 2015-01-03 15:06:53.007133 DEBUG conn prefixlog.go:107: <peer.ID QmNXuB> closing Conn with <peer.ID >
dockertest_client_1 exited with code 1
```
