#!/bin/sh
set -e;
echo "consul"
nohup consul agent -join consul.service.dc1.consul -data-dir /data/consul -config-dir /etc/consul.d > /tmp/log &
#echo "redis"
#/bin/sh -c "redis-server /usr/local/etc/redis/redis.conf"
echo "$@"
exec "$@"
