#!/bin/sh
set -e;

join="consul.service.dc1.consul"
node=""
master=""
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
		echo '{ "service":{ "name":"'$node'", "tags":[ "database", "nosql" ],  "port":6379,  "check":{  "name":"status",  "tcp":"localhost:6379",  "interval":"30s"  }  } }' > /etc/consul.d/service.json
        fi
	if [ "_$key" = "_-rule" ]; then
                #echo "join = $p"
                master=$p
        fi
        key=$p
done;

echo "consul"
/bin/sh -c "nohup consul agent -join $join -data-dir /data/consul -config-dir /etc/consul.d &"
echo "redis"
/bin/sh -c "redis-server $master"
#echo "redis"
#/bin/sh -c "redis-server /usr/local/etc/redis/redis.conf"
