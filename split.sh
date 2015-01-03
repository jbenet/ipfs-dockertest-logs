#!/bin/sh
cat full | grep dht > dht
cat full | grep dht | egrep -i provide > dht-provide
cat full | grep bitswap > bitswap
