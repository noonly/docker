#!/bin/bash
BASEDIR=`pwd`
#read -p "Please setting the consul service discovery application master node docker container name: " tmp
invalied=""
CONTAINERNAME=""
while [ "_$tmp" == '_' ]
do
	#echo ""
	#echo "invalid container name! please retry!!!"
	read -p "Please setting the consul service discovery application master node docker container name: " tmp
	echo ""
	for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done


done

CONTAINERNAME[0]=$tmp
echo "Your consul master container $tmp is running"
#run consul master node
docker run -d --name $tmp --hostname $tmp progrium/consul -server -bootstrap
#export consul master node ip address
CONSUL_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $tmp)
tmp=""
#read -p "Please setting the redis master node docker container name: " tmp

while [ "_$tmp" == '_' ]
do
	read -p "Please setting the redis master node docker container name: " tmp
	echo ""
	 for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done

        #echo "invalid container name! please retry!!!\n"
	#read -p "Please setting the redis master node docker container name: " tmp
done

CONTAINERNAME[1]=$tmp
echo "Your redis master container $tmp is running"

#run redis master server
docker run -d  -v $BASEDIR/redis/redis.conf.bak:/usr/local/etc/redis/redis.conf -v $BASEDIR/redis/service.json:/etc/consul.d/service1.json \
--name $tmp --hostname $tmp --env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP noonly/redis


tmp=""
#read -p "Please setting the redis slave node docker container name: " tmp

while [ "_$tmp" == '_' ]
do
	#echo "\n"
        #echo "invalid container name! please retry!!!\n"
        read -p "Please setting the redis slave node docker container name: " tmp
	echo ""
        for exist in $CONTAINERNAME
        do
		if [ "x$tmp" == "x$exist" ]; then

                	echo "invalid container name! please retry!!!"
                	tmp=""
		fi
        done

done

CONTAINERNAME[2]=$tmp

echo "Your redis slave container $tmp is running"
#run redis slave server
docker run --link redis-master:redis-master --hostname $tmp -v $BASEDIR/redis/redis.conf:/usr/local/etc/redis/redis.conf \
--env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP --name $tmp -d noonly/redis

tmp=""

while [ "_$tmp" == '_' ]
do
        read -p "Please setting the consul slave node docker container name: " tmp
	 echo ""
        for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done

done

CONTAINERNAME[3]=$tmp

echo "Your consul slave container $tmp is running"
#run consul client for master node
docker run -d --name $tmp --hostname $tmp --env CONSUL_HOST=$CONSUL_IP noonly/consul

tmp=""

while [ "_$tmp" == '_' ]
do
        read -p "Please setting the nginx server docker container name: " tmp
	 echo ""
        for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done

done

CONTAINERNAME[4]=$tmp
echo "Your www container $tmp is running"
#run nginx 
docker run -d --name $tmp --hostname $tmp -v $BASEDIR/nginx/conf.d/:/etc/nginx/conf.d/:rw --env CONSUL_HOST=$CONSUL_IP noonly/nginx


tmp=""

while [ "_$tmp" == '_' ]
do
        read -p "Please setting the mysql server node docker container name: " tmp
	 echo ""
        for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done

done

CONTAINERNAME[5]=$tmp
echo "Your libuser mysql container $tmp is running"
#run mysql server
docker run -d -v /var/lib/mysql/libuser/db:/var/lib/mysql -v /var/lib/mysql/libuser/mysql.json:/etc/consul.d/mysql.json \
-e MYSQL_ROOT_PASSWORD=123456 --name $tmp --hostname $tmp -e CONSUL_HOST=$CONSUL_IP noonly/mysql
