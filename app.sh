#! /bin/bash
PWD=`pwd`
while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please settings tomcat webapps path (etc. /var/lib/git/): " tmp
        echo ""
	if [ "_$tmp" == "_" ]; then
		tmp="/var/lib/git/"
	fi
	if [ ! -d "$tmp" ]; then

        	echo "invalid path! please retry!!!"
                tmp=""
        fi

done

path=$tmp
tmp=""
#project=""
while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        #read -p "Please settings tomcat webapps path (etc. /var/lib/git/): " tmp
        #echo ""
	i=0
        for folder in `ls $path`
        do
		if [ -d $path"/"$folder"/WebRoot" ]; then
			project[$i]=$path"/"$folder"/WebRoot"				
			projectname[$i]=$folder
			echo "$i."$folder
			i=$(($i+1))
		fi
		#if [ folder ]
        done
	if [ $i -gt 0 ]; then
#		if [ $i -gt 1 ]; then
			echo "$i.Select all"
			projectname[$i]="all"
#		fi
		read -p "Please select one option for startup [0-$i]: " tmp
	else 
		echo "No project for discovery."
		#tmp="__"
		exit
	fi

done

#echo ${projectname[$tmp]}
ip=$CONSUL_IP
if [ "_$ip" != '_' ]; then


	read -p "Do you want to use $ip as consul server address? [y/n]: " y

	if [ "_$y" != "_y" ]; then
		ip=""
	fi

fi
while [ "_$ip" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please input consul master ip address: " ip


done

export CONSUL_IP=$ip

if [ "_${projectname[$tmp]}" == '_all' ]; then
	echo "Starting all...."
	j=0;
	for pro in $project 
	do

		if [ "_${projectname[$tmp]}" != '_all' ]; then
			docker run -d --name "node-"${projectname[$j]} --env CONSUL_HOST=$ip \
--hostname tomcat-"node-${projectname[$j]}" -v project[$j]:/project \
-v $PWD/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
-v /etc/localtime:/etc/localtime:ro \
-v $PWD/tomcat/${projectname[$j]}.json:/etc/consul.d/${projectname[$j]}.json noonly/tomcat-debug	
		fi
	j=$(($j+1))
	done

else
echo "Starting container: ${projectname[$tmp]}"


docker run -d --name "node-"${projectname[$tmp]} --env CONSUL_HOST=$ip \
--hostname tomcat-"node-${projectname[$tmp]}" -v ${project[$tmp]}:/project \
-v $PWD/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
-v /etc/localtime:/etc/localtime:ro \
-v $PWD/tomcat/${projectname[$tmp]}.json:/etc/consul.d/${projectname[$tmp]}.json noonly/tomcat-debug
fi

