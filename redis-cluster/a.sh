#!/bin/sh
set -e;

join="consul.service.dc1.consul"
node=""
key=""
for p in $*;
do
	if [ "_$key" = "_-join" ]; then
        	echo "join = $p"
	fi
	if [ "_$key" = "_-node" ]; then
                echo "node = $p"
        fi
	key=$p
done;
