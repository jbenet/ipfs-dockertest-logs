# log7

- completes first (tiny) file transfer
- server_1 does not finish adding file ("dockertest> added rand file" not found)
")
- client_1 (correctly stuck waiting for server to add the file...)
- server_1 ipfs add just triggers nothing... (need more logs?)
- looking at [dht-provides](dht-provides) we can see that the server DOES provide 4 blocks (1 for tiny file, 3 for rand file):
- server_1 fails to provide other 187/191 blocks
- server_1 fails to PutProvider to client_1
- server_1 and client_1 did finish dialing
- client_1 returns failure for handleFindPeer

### Veredict: server_1 fails to provide all blocks.

Not clear why server_1 gets stuck. it abruptly stops providing.
Possible that it stops after it fails to PutProvide to client_1
client_1 returns failure for handleFindPeer (see way below)


## Notes

- completes first (tiny) file transfer
- server_1 does not finish adding file ("dockertest> added rand file" not found)
")
- client_1 (correctly stuck waiting for server to add the file...)

note how client_1 correctly moves on to "waiting for server to add the file"
note how "server_1 | dockertest> added rand file" is not there.

```
% cat full | grep dockertest
Attaching to dockertest_bootstrap_1, dockertest_data_1, dockertest_server_1, dockertest_client_1
server_1    | dockertest> starting server daemon
client_1    | dockertest> starting client daemon
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
...
```


- looking at [dht-provides](dht-provides) we can see that the server DOES provide 4 blocks (1 for tiny file, 3 for rand file):


```
QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf // tiny file
QmUkvCzaYhRyZ57d7eN6S22z8U1GZ5XXTVkvWrCks9gLe6 // must be rand file ?
QmQzksKm2NLB66ryuxxuzdgqeVLGLBhEB1q9GKPbvHTBhU
QmcBBgTXTDgRwYpafPZwe838fRWR7sDB5EEVuAXsihZ2Ke
```

```
% cat dht-provide | grep putProvider
server_1    | 2015-01-03 15:12:10.349092 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.454937 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmUkvCzaYhRyZ57d7eN6S22z8U1GZ5XXTVkvWrCks9gLe6 ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.480445 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmQzksKm2NLB66ryuxxuzdgqeVLGLBhEB1q9GKPbvHTBhU ([/ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021])
server_1    | 2015-01-03 15:12:10.501322 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcBBgTXTDgRwYpafPZwe838fRWR7sDB5EEVuAXsihZ2Ke ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
client_1    | 2015-01-03 15:12:12.455402 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.19/tcp/4031 /ip6/fe80::42:acff:fe11:213/tcp/4031 /ip4/172.17.2.19/udp/4032/utp /ip6/fe80::42:acff:fe11:213/udp/4032/utp])
client_1    | 2015-01-03 15:12:12.456781 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> putProvider: <peer.ID Qmbtc2> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip6/fe80::42:acff:fe11:213/tcp/4031 /ip4/172.17.2.19/udp/4032/utp /ip6/fe80::42:acff:fe11:213/udp/4032/utp /ip4/172.17.2.19/tcp/4031])
```

- server_1 fails to provide other 187/191 blocks

Note that randfile is big enough for 191 blocks. (See [data readme](../data))
But server stops adding providers. Server dht output below.
It announces it is provider for 4 blocks right away (same _second_, 15:12:10)
But then just stops. So, something is getting stuck-- not clear what.
I suspect bitswap. dont have enough logs to know-- adding some.


- server_1 fails to PutProvider to client_1

```
server_1    | 2015-01-03 15:12:10.501322 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcBBgTXTDgRwYpafPZwe838fRWR7sDB5EEVuAXsihZ2Ke ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.510570 DEBUG dht prefixlog.go:107: PEERS CLOSER -- worker for: <peer.ID QmNXuB> (1 closer peers)
server_1    | 2015-01-03 15:12:10.510846 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.510678 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.510918 DEBUG dht prefixlog.go:107: PEERS CLOSER -- worker for: <peer.ID QmNXuB> added <peer.ID Qmbtc3> ([/ip6/fe80::42:acff:fe11:213/udp/4032/utp /ip4/172.17.2.19/tcp/4031 /ip6/fe80::42:acff:fe11:213/tcp/4031 /ip4/172.17.2.19/udp/4032/utp])
server_1    | 2015-01-03 15:12:10.511037 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.511099 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511156 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511208 DEBUG dht prefixlog.go:107: running worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511267 INFO dht prefixlog.go:116: worker for: <peer.ID Qmbtc3> -- not connected. dial start
server_1    | 2015-01-03 15:12:10.553566 INFO dht prefixlog.go:116: worker for: <peer.ID Qmbtc3> -- not connected. dial success!
server_1    | 2015-01-03 15:12:10.553632 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.566594 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID Qmbtc3> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.566785 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.566915 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:12:12.416915 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
```

- last server_1 logs ([full logs here](server_1))

```
server_1    | 2015-01-03 15:12:07.406644 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081f8ec0 3> setting handler for protocol: /ipfs/dht (9)
server_1    | 2015-01-03 15:12:07.445550 DEBUG dht prefixlog.go:107: ping <peer.ID QmNXuB> start
server_1    | 2015-01-03 15:12:07.445688 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:07.452824 DEBUG dht prefixlog.go:107: ping <peer.ID QmNXuB> end (err = %!s(<nil>))
server_1    | 2015-01-03 15:12:10.345725 DEBUG dht prefixlog.go:107: Run query with 1 peers.
server_1    | 2015-01-03 15:12:10.345931 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.346015 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.346387 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.348458 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.348517 DEBUG dht prefixlog.go:107: running worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.348563 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.349092 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.364341 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID QmNXuB> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.364554 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.365269 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:12:10.443126 DEBUG dht prefixlog.go:107: Run query with 1 peers.
server_1    | 2015-01-03 15:12:10.443293 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.443556 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.444150 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.445715 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.447776 DEBUG dht prefixlog.go:107: running worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.447888 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.454937 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmUkvCzaYhRyZ57d7eN6S22z8U1GZ5XXTVkvWrCks9gLe6 ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.462353 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID QmNXuB> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.463323 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.463693 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:12:10.475578 DEBUG dht prefixlog.go:107: Run query with 1 peers.
server_1    | 2015-01-03 15:12:10.475840 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.476036 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.477477 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.477664 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.478076 DEBUG dht prefixlog.go:107: running worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.478167 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.480445 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmQzksKm2NLB66ryuxxuzdgqeVLGLBhEB1q9GKPbvHTBhU ([/ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021])
server_1    | 2015-01-03 15:12:10.487361 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID QmNXuB> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.487803 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.489772 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:12:10.495471 DEBUG dht prefixlog.go:107: Run query with 1 peers.
server_1    | 2015-01-03 15:12:10.495811 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.495902 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.496255 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.496574 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.496782 DEBUG dht prefixlog.go:107: running worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.496846 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.501322 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcBBgTXTDgRwYpafPZwe838fRWR7sDB5EEVuAXsihZ2Ke ([/ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp])
server_1    | 2015-01-03 15:12:10.510570 DEBUG dht prefixlog.go:107: PEERS CLOSER -- worker for: <peer.ID QmNXuB> (1 closer peers)
server_1    | 2015-01-03 15:12:10.510846 DEBUG dht prefixlog.go:107: adding peer to query: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.510678 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.510918 DEBUG dht prefixlog.go:107: PEERS CLOSER -- worker for: <peer.ID QmNXuB> added <peer.ID Qmbtc3> ([/ip6/fe80::42:acff:fe11:213/udp/4032/utp /ip4/172.17.2.19/tcp/4031 /ip6/fe80::42:acff:fe11:213/tcp/4031 /ip4/172.17.2.19/udp/4032/utp])
server_1    | 2015-01-03 15:12:10.511037 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.511099 DEBUG dht prefixlog.go:107: spawning worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511156 DEBUG dht prefixlog.go:107: spawned worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511208 DEBUG dht prefixlog.go:107: running worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.511267 INFO dht prefixlog.go:116: worker for: <peer.ID Qmbtc3> -- not connected. dial start
server_1    | 2015-01-03 15:12:10.553566 INFO dht prefixlog.go:116: worker for: <peer.ID Qmbtc3> -- not connected. dial success!
server_1    | 2015-01-03 15:12:10.553632 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> dht starting stream
server_1    | 2015-01-03 15:12:10.566594 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID Qmbtc3> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.566785 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.566915 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
server_1    | 2015-01-03 15:12:12.416915 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
server_1    | 2015-01-03 15:12:12.425548 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> handleGetProviders(<peer.ID Qmbtc3>, QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf):  begin
server_1    | 2015-01-03 15:12:12.425924 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> handleGetProviders(<peer.ID Qmbtc3>, QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf):  have the value. added self as provider
server_1    | 2015-01-03 15:12:12.426062 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> handleGetProviders(<peer.ID Qmbtc3>, QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf):  have 2 providers: [{<peer.ID Qmbtc2> [/ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp]} {<peer.ID Qmbtc2> [/ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021]}]
server_1    | 2015-01-03 15:12:12.426696 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> handleGetProviders(<peer.ID Qmbtc3>, QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf):  have 1 closer peers: [{<peer.ID Qmbtc2> [/ip6/fe80::42:acff:fe11:212/tcp/4021 /ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021]} {<peer.ID Qmbtc2> [/ip4/172.17.2.18/udp/4022/utp /ip6/fe80::42:acff:fe11:212/udp/4022/utp /ip4/172.17.2.18/tcp/4021 /ip6/fe80::42:acff:fe11:212/tcp/4021]}]
server_1    | 2015-01-03 15:12:12.426986 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> handleGetProviders(<peer.ID Qmbtc3>, QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf):  end
server_1    | 2015-01-03 15:12:12.456694 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
server_1    | 2015-01-03 15:12:12.457350 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> adding <peer.ID Qmbtc3> as a provider for 'QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf'
server_1    | 2015-01-03 15:12:12.457564 INFO dht prefixlog.go:116: received provider <peer.ID Qmbtc3> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf (addrs: [/ip6/fe80::42:acff:fe11:213/tcp/4031 /ip4/172.17.2.19/udp/4032/utp /ip6/fe80::42:acff:fe11:213/udp/4032/utp /ip4/172.17.2.19/tcp/4031])
server_1    | 2015-01-03 15:12:12.477927 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
server_1    | 2015-01-03 15:12:12.484231 DEBUG dht prefixlog.go:107: handleFindPeer: sending back '<peer.ID QmNXuB>'

```

- server_1 and client_1 did finish dialing

```
% cat full| grep "finished dialing"
server_1    | 2015-01-03 15:12:07.434633 DEBUG swarm2 prefixlog.go:107: network for <peer.ID Qmbtc2> finished dialing <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:07.445464 DEBUG p2p/host/basic prefixlog.go:107: host %!s(func() peer.ID=0x657e80) finished dialing <peer.ID QmNXuB>
client_1    | 2015-01-03 15:12:09.465834 DEBUG swarm2 prefixlog.go:107: network for <peer.ID Qmbtc3> finished dialing <peer.ID QmNXuB>
client_1    | 2015-01-03 15:12:09.488410 DEBUG p2p/host/basic prefixlog.go:107: host %!s(func() peer.ID=0x657e80) finished dialing <peer.ID QmNXuB>
server_1    | 2015-01-03 15:12:10.546471 DEBUG swarm2 prefixlog.go:107: network for <peer.ID Qmbtc2> finished dialing <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.553495 DEBUG p2p/host/basic prefixlog.go:107: host %!s(func() peer.ID=0x657e80) finished dialing <peer.ID Qmbtc3>
```

- client_1 returns failure for handleFindPeer


```
client_1    | 2015-01-03 15:12:10.558277 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/dht
client_1    | 2015-01-03 15:12:10.559897 WARNING dht prefixlog.go:125: handleFindPeer: could not find anything.
server_1    | 2015-01-03 15:12:10.566594 DEBUG dht prefixlog.go:107: QUERY worker for: <peer.ID Qmbtc3> - not found, and no closer peers.
server_1    | 2015-01-03 15:12:10.566785 DEBUG dht prefixlog.go:107: completing worker for: <peer.ID Qmbtc3>
server_1    | 2015-01-03 15:12:10.566915 ERROR dht prefixlog.go:110: closestPeers query run error: routing: not found
```