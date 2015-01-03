# log8

- does not complete first (tiny) file transfer
- server_1 finishes adding itself as provider of
- client_1 correctly identifies server_1 as provider
- client_1 sends its wantlist to server_1
- but server_1 doesnt even get it!
- server_1's mux doesnt even see the dht stream being opened
- client_1's bitswap DOES try to send (open a stream)
- client_1 dagservice correctly times out after 1 minute.

Other:

- `15:19:39.238012` server_1 registers dht handler at
- `15:19:42.377747` server_1 and client_1 connect (finish handshake)
- `15:19:43.523480` client_1 attempts to open stream to server_1

FOUND IT! though the client_1 dialing server_1 handshake finishes, the `Network.dial` log is not there:


```
// should see this, but isnt there:
network for <peer.ID Qmbtc2> finished dialing <peer.ID Qmbtc3>
```

So when the client tries to open a stream, the open just hangs-- it's stuck connecting. What could it be?

We also see
```
// newSecureConn handshake finishes
server_1    | 2015-01-03 15:19:42.376950 DEBUG conn prefixlog.go:107: newSecureConn: <peer.ID Qmbtc2> to <peer.ID Qmbtc3> handshake success!
client_1    | 2015-01-03 15:19:42.379548 DEBUG conn prefixlog.go:107: newSecureConn: <peer.ID Qmbtc3> to <peer.ID Qmbtc2> handshake success!

// net/identify sends listen addrs
server_1    | 2015-01-03 15:19:42.396598 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/identify
// NO corresponding client_1 net/mux prefixlog.go:116: muxer handle protocol: /ipfs/identify

15:19:42.397849 DEBUG net/identify prefixlog.go:107: <peer.ID Qmbtc2> sent listen addrs to <peer.ID Qmbtc3>
// NO corresponding <peer.ID Qmbtc3> sent listen addrs to <peer.ID Qmbtc2>

// net/identify DOES NOT receive listen addrs (neither... odd, at least Qmbtc2 should receive from Qmbtc3)
// NO <peer.ID Qmbtc2> received listen addrs for <peer.ID Qmbtc3>
// NO <peer.ID Qmbtc3> received listen addrs for <peer.ID Qmbtc2>
```

### Veredict: Qmbtc2 should receive addrs from Qmbtc3. Somehow it's not. the transport may be broken.
(whyrusleeping thinks it may be utp. not clear what network the stream is being opened on)

[must construct additional log statements](https://www.youtube.com/watch?v=C5e6eG6bXAQ)


## Notes:

- server_1 finishes adding itself as provider of QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf

```
% cat dht-provide | grep server_1
server_1    | 2015-01-03 15:19:42.209103 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf ([/ip4/172.17.2.33/tcp/4021 /ip6/fe80::42:acff:fe11:221/tcp/4021 /ip4/172.17.2.33/udp/4022/utp /ip6/fe80::42:acff:fe11:221/udp/4022/utp])
server_1    | 2015-01-03 15:19:42.306188 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc2> putProvider: <peer.ID QmNXuB> for QmZPgWZQCCeSdYMBdwmnC9uDcjBkhrZZU8C3QgecvTh85Y ([/ip4/172.17.2.33/tcp/4021 /ip6/fe80::42:acff:fe11:221/tcp/4021 /ip4/172.17.2.33/udp/4022/utp /ip6/fe80::42:acff:fe11:221/udp/4022/utp])
```

- client_1 correctly identifies server_1 as provider

(found Qmbtc2. ignore `FindProviders Query error: routing: not found` its not a real error)

```
% cat dht-provide | grep client_1
client_1    | 2015-01-03 15:19:43.499383 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> FindProviders QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf
client_1    | 2015-01-03 15:19:43.500523 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  begin
client_1    | 2015-01-03 15:19:43.518277 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  got 1 provider entries
client_1    | 2015-01-03 15:19:43.518455 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  got 1 provider entries decoded
client_1    | 2015-01-03 15:19:43.518567 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  got provider: {<peer.ID Qmbtc2> [/ip4/172.17.2.33/tcp/4021 /ip6/fe80::42:acff:fe11:221/tcp/4021 /ip4/172.17.2.33/udp/4022/utp /ip6/fe80::42:acff:fe11:221/udp/4022/utp]}
client_1    | 2015-01-03 15:19:43.519937 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  using provider: {<peer.ID Qmbtc2> [/ip4/172.17.2.33/tcp/4021 /ip6/fe80::42:acff:fe11:221/tcp/4021 /ip4/172.17.2.33/udp/4022/utp /ip6/fe80::42:acff:fe11:221/udp/4022/utp]}
client_1    | 2015-01-03 15:19:43.520478 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  got closer peers: []
client_1    | 2015-01-03 15:19:43.520582 DEBUG dht prefixlog.go:107: <peer.ID Qmbtc3> findProviders(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf).Query(<peer.ID QmNXuB>):  end
client_1    | 2015-01-03 15:19:43.522564 ERROR dht prefixlog.go:110: FindProviders Query error: routing: not found
```

- client_1 sends its wantlist to server_1
- but server_1 doesnt even get it!

(note missing `bitswap net handleNewStream from <peer.ID Qmbtc3>`)

```
% cat bitswap
bootstrap_1 | 2015-01-03 15:19:35.966375 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081f76e0 4> setting handler for protocol: /ipfs/bitswap (13)
server_1    | 2015-01-03 15:19:39.238012 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 4> setting handler for protocol: /ipfs/bitswap (13)
client_1    | 2015-01-03 15:19:40.518289 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081f93c0 4> setting handler for protocol: /ipfs/bitswap (13)
client_1    | 2015-01-03 15:19:43.493830 DEBUG blockservice blockservice.go:72: Blockservice: Searching bitswap.
client_1    | 2015-01-03 15:19:43.494168 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf) GetBlockRequestBegin
client_1    | 2015-01-03 15:19:43.498138 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(1) begin
client_1    | 2015-01-03 15:19:43.522261 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).sendWantlistMsgToPeers(1) <peer.ID Qmbtc2> sending
client_1    | 2015-01-03 15:19:43.522539 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).bitswap.sendWantlistMsgToPeer(1, <peer.ID Qmbtc2>) sending wantlist
client_1    | 2015-01-03 15:19:43.522826 DEBUG bitswap_network ipfs_impl.go:44: bitswap net SendMessage to <peer.ID Qmbtc2>
bootstrap_1 | 2015-01-03 15:19:45.969082 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID QmNXuB>).sendWantlistToProviders  begin
bootstrap_1 | 2015-01-03 15:19:45.969497 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID QmNXuB>).sendWantlistMsgToPeers(0) begin
server_1    | 2015-01-03 15:19:49.244350 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc2>).sendWantlistToProviders  begin
server_1    | 2015-01-03 15:19:49.244768 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc2>).sendWantlistMsgToPeers(0) begin
client_1    | 2015-01-03 15:20:43.496462 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).GetBlock(QmcdNXWTJeBd4fKq1vsUWhP8Uy2azPXiRcVozsNgwzP1sf) GetBlockRequestEnd
```

- server_1's mux doesnt even see the dht stream being opened

```
% cat full | grep mux | grep server_1
server_1    | 2015-01-03 15:19:39.236084 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 0> setting handler for protocol: /ipfs/identify (14)
server_1    | 2015-01-03 15:19:39.236162 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 1> setting handler for protocol: /ipfs/relay (11)
server_1    | 2015-01-03 15:19:39.237381 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 2> setting handler for protocol: /ipfs/diagnostics (17)
server_1    | 2015-01-03 15:19:39.237658 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 3> setting handler for protocol: /ipfs/dht (9)
server_1    | 2015-01-03 15:19:39.238012 DEBUG net/mux prefixlog.go:107: <Muxer 0xc2081e6dd0 4> setting handler for protocol: /ipfs/bitswap (13)
server_1    | 2015-01-03 15:19:39.270029 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/identify
server_1    | 2015-01-03 15:19:42.396598 INFO net/mux prefixlog.go:116: muxer handle protocol: /ipfs/identify
```

- client_1's bitswap DOES try to send (open a stream)

but not sure if sending. (will add logs)

```
client_1    | 2015-01-03 15:19:43.522539 DEBUG bitswap prefixlog.go:107: bitswap(<peer.ID Qmbtc3>).bitswap.sendWantlistMsgToPeer(1, <peer.ID Qmbtc2>) sending wantlist
client_1    | 2015-01-03 15:19:43.522564 ERROR dht prefixlog.go:110: FindProviders Query error: routing: not found
client_1    | 2015-01-03 15:19:43.522826 DEBUG bitswap_network ipfs_impl.go:44: bitswap net SendMessage to <peer.ID Qmbtc2>
client_1    | 2015-01-03 15:19:43.523236 DEBUG swarm2 prefixlog.go:107: [<peer.ID Qmbtc3>] network opening stream to peer [<peer.ID Qmbtc2>]
client_1    | 2015-01-03 15:19:43.523480 DEBUG swarm2 prefixlog.go:107: Swarm: NewStreamWithPeer...
```
