#!/bin/sh
set -e;

join="consul.service.dc1.consul"
node=""
key=""
for p in $*;
do
        if [ "_$key" = "_-join" ]; then
                #echo "join = $p"
                join=$p
        fi
        if [ "_$key" = "_-node" ]; then
                #echo "node = $p"
                node=$p
        fi
        key=$p
done;

if [ "_$node" = "_" ]; then
	node=`hostname`        
fi

echo '{  "service":{ "name":"'$node'", "tags":[ "web", "nginx" ], "port":80, "check":{ "name":"status", "tcp":"localhost:80", "interval":"30s" }  } }' > /etc/consul.d/service.json

echo "consul"
nohup consul agent -data-dir=/data/consul -config-dir=/etc/consul.d -join $join &
echo "nginx"
nginx -g "daemon off;"

