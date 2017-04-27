#!/bin/bash
set -e;

tags='"script","node"'
join="consul.service.dc1.consul"
node=""
file=""
dc=""
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
	if [ "_$key" = "_-run" ]; then
                #echo "node = $p"
                file=$p
        fi
	if [ "_$key" = "_-dc" ]; then
                #echo "node = $p"
                dc="-dc $p"
        fi
	if [ "_$key" = "_-tags" ]; then
                #echo "node = $p"
                tags=`echo $p | sed "s/,/\",\"/g" | sed "s/^/\"/g" |  sed "s/$/\"/g"`
        fi
        key=$p
done;


if [ "_$node" = "_" ]; then
	node=`hostname`	
#	echo ""
fi
echo '{"service":{"name":"'$node'","tags":['$tags'],"port":3000,"check":{"name":"status","tcp":"localhost:3000","interval":"30s"}}} ' > /etc/consul.d/service.json

echo $@ > /tmp/123
echo "consul"
/bin/sh -c "nohup consul agent -join $join -data-dir /data/consul -config-dir /etc/consul.d $dc &"
echo "node"
node $file
