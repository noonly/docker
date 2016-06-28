#!/bin/bash
BASEDIR=`PWD`
#run consul master node
docker run -d --name master --hostname consul-master progrium/consul -server -bootstrap
#export consul master node ip address
CONSUL_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' master)

#run redis master server
docker run -d  -v $BASEDIR/redis/redis.conf.bak:/usr/local/etc/redis/redis.conf -v $BASEDIR/redis/service.json:/etc/consul.d/service1.json \
--name redis-master --hostname redis-master --env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP noonly/redis
#run redis slave server
docker run --link redis-master:redis-master --hostname redis-slave1 -v $BASEDIR/redis/redis.conf:/usr/local/etc/redis/redis.conf \
--env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP --name redis-slave1 -d noonly/redis
#run consul client for master node
docker run -d --name consul-slave1 --hostname consul-slave1 --env CONSUL_HOST=$CONSUL_IP noonly/consul
#run nginx 
docker run -d --name www --hostname www -v $BASEDIR/nginx/conf.d/:/etc/nginx/conf.d/:rw --env CONSUL_HOST=$CONSUL_IP noonly/nginx
#run mysql server
docker run -d -v /var/lib/mysql/libuser/db:/var/lib/mysql -v /var/lib/mysql/libuser/mysql.json:/etc/consul.d/mysql.json \
-e MYSQL_ROOT_PASSWORD=123456 --name mysql-libuser --hostname mysql-libuser -e CONSUL_HOST=$CONSUL_IP noonly/mysql
