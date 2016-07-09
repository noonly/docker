#!/bin/bash
#
#author xiaole <xiaole@noonly.com>
#
#
BASEDIR=`pwd`
#read -p "Please setting the consul service discovery application master node docker container name: " tmp
invalied=""
CONTAINERNAME=""

while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Do you want to join the existing cluster:[y/n] " tmp

done

if [ "_$tmp" == '_y' ]; then
	tmp=""
	while [ "_$tmp" == '_' ]
	do
        	#echo ""
        	#echo "invalid container name! please retry!!!"
       		read -p "Please enter the IP address of any node in the cluster: " tmp
		clusterip=$tmp	

	done

fi
 
tmp=""

while [ "_$tmp" == '_' ]
do
	#echo ""
	#echo "invalid container name! please retry!!!"
	read -p "Please settings the consul master container name: " tmp
	echo ""
	for exist in $CONTAINERNAME
        do
                if [ "x$tmp" == "x$exist" ]; then

                        echo "invalid container name! please retry!!!"
                        tmp=""
                fi
        done


done
index=0
CONTAINERNAME[$index]=$tmp
echo "Your consul master container $tmp is running"
#run consul master node
if [ "_$clusterip" != "_" ]; then
	docker run -d -v /etc/localtime:/etc/localtime:ro --name $tmp --hostname $tmp progrium/consul -server --join $clusterip
else
	docker run -d -v /etc/localtime:/etc/localtime:ro --name $tmp --hostname $tmp progrium/consul -server -bootstrap

fi
#export consul master node ip address
CONSUL_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' $tmp)
tmp=""
#read -p "Please setting the redis master node docker container name: " tmp

read -p "Do you want to startup redis master server? [y/N]" y

if [ "_$y" == "_y" ]; then
	y=""
	while [ "_$tmp" == '_' ]
	do
		read -p "Please settings the redis master container name: " tmp
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

	index=$(($index+1))
	CONTAINERNAME[$index]=$tmp
	echo "Your redis master container $tmp is running"

	#run redis master server
	docker run -d -v /etc/localtime:/etc/localtime:ro -v $BASEDIR/redis/redis.conf.bak:/usr/local/etc/redis/redis.conf -v $BASEDIR/redis/service.json:/etc/consul.d/service1.json \
	--name $tmp --hostname $tmp --env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP noonly/redis
	tmp=""
fi


#read -p "Please setting the redis slave node docker container name: " tmp
read -p "Do you want to startup redis slave server? [y/N]" y

if [ "_$y" == "_y" ]; then
	y=""
	while [ "_$tmp" == '_' ]
	do
		#echo "\n"
			#echo "invalid container name! please retry!!!\n"
			read -p "Please settings the redis slave container name: " tmp
			for exist in $CONTAINERNAME
			do
			if [ "x$tmp" == "x$exist" ]; then

						echo "invalid container name! please retry!!!"
						tmp=""
			fi
			done

	done

	index=$(($index+1))
	CONTAINERNAME[$index]=$tmp

	echo "Your redis slave container $tmp is running"
	#run redis slave server
	docker run -v /etc/localtime:/etc/localtime:ro --hostname $tmp -v $BASEDIR/redis/redis.conf:/usr/local/etc/redis/redis.conf \
	--env REDISCONF=/usr/local/etc/redis/redis.conf --env CONSUL_HOST=$CONSUL_IP --name $tmp -d noonly/redis

	tmp=""
	
fi


read -p "Do you want to startup consul client server? [y/N]" y

if [ "_$y" == "_y" ]; then
	y=""
	while [ "_$tmp" == '_' ]
	do
			read -p "Please settings the consul slave container name: " tmp
			for exist in $CONTAINERNAME
			do
					if [ "x$tmp" == "x$exist" ]; then

							echo "invalid container name! please retry!!!"
							tmp=""
					fi
			done

	done

	index=$(($index+1))
	CONTAINERNAME[$index]=$tmp

	echo "Your consul slave container $tmp is running"
	#run consul client for master node
	docker run -d --name $tmp --hostname $tmp -v /etc/localtime:/etc/localtime:ro --env CONSUL_HOST=$CONSUL_IP noonly/consul

	tmp=""
fi

read -p "Do you want to startup nginx server? [y/N]" y

if [ "_$y" == "_y" ]; then
	y=""
	while [ "_$tmp" == '_' ]
	do
			read -p "Please settings the nginx server container name: " tmp
		 echo ""
			for exist in $CONTAINERNAME
			do
					if [ "x$tmp" == "x$exist" ]; then

							echo "invalid container name! please retry!!!"
							tmp=""
					fi
			done

	done

	index=$(($index+1))
	CONTAINERNAME[$index]=$tmp
	echo "Your www container $tmp is running"
	#run nginx 
	docker run -d --name $tmp --hostname $tmp -v $BASEDIR/nginx/conf.d/:/etc/nginx/conf.d/:rw -v /etc/localtime:/etc/localtime:ro --env CONSUL_HOST=$CONSUL_IP noonly/nginx


	tmp=""
fi

read -p "Do you want to startup libuser mysql server? [y/N]" y

if [ "_$y" == "_y" ]; then
	y=""
	while [ "_$tmp" == '_' ]
	do
			read -p "Please settings the mysql libuser server container name: " tmp
		 echo ""
			for exist in $CONTAINERNAME
			do
					if [ "x$tmp" == "x$exist" ]; then

							echo "invalid container name! please retry!!!"
							tmp=""
					fi
			done

	done

	index=$(($index+1))
	CONTAINERNAME[$index]=$tmp
	echo "Your libuser mysql container $tmp is running"
	#run mysql server
	docker run -d -v /var/lib/mysql/libuser/db:/var/lib/mysql -v /etc/localtime:/etc/localtime:ro -v /var/lib/mysql/libuser/mysql.json:/etc/consul.d/mysql.json \
	-e MYSQL_ROOT_PASSWORD=123456 --name $tmp --hostname $tmp -e CONSUL_HOST=$CONSUL_IP noonly/mysql
	tmp=""
fi