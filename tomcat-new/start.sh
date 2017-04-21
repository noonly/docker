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
        key=$p
done;

echo "consul"
/bin/sh -c "nohup consul agent -join $join -data-dir /data/consul -config-dir /project &"
echo "tomcat";
catalina.sh run
#echo "redis"
#/bin/sh -c "redis-server /usr/local/etc/redis/redis.conf"
