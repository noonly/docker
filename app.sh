#! /bin/bash
PWD=`pwd`

workpath=`cat .local 2> /dev/null`
if [ "_$workpath" == "_" ]; then
	workpath="/var/lib/git/"
fi
while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please settings tomcat webapps path (default: $workpath): " tmp
	if [ "_$tmp" == "_" ]; then
		tmp=$workpath
	fi
	if [ ! -d "$tmp" ]; then
        	echo "invalid path! please retry!!!"
            tmp=""
        fi

done

path=$tmp
echo "$path" > .local 2> /dev/null
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
if [ "_$ip" == "_" ]; then
	ip=`cat .ip 2> /dev/null`
fi
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

		echo "$ip" > .ip
done

export CONSUL_IP=$ip
#--hostname tomcat-"node-${projectname[$j]}" 
if [ "_${projectname[$tmp]}" == '_all' ]; then
	echo "Starting all...."
	j=0;
	for pro in ${project[@]}; 
	do
	n="node-${projectname[$j]}"
read -p "Please input ${projectname[$j]} project container name (default: node-${projectname[$j]}):" n
		echo "${projectname[$j]} starting"
		if [ "_${projectname[$j]}" != '_all' ]; then
			#$echo "${projectname[$j]} starting"
			docker run -d --name "node-${projectname[$j]}" --hostname "node-${projectname[$j]}" --env CONSUL_HOST=$ip \
-v $pro:/project \
-v $PWD/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
-v /etc/localtime:/etc/localtime:ro \
 noonly/tomcat-debug	
		fi
	j=$(($j+1))
	done

else
n="node-${projectname[$tmp]}"
read -p "Please input ${projectname[$tmp]} project container name (default: node-${projectname[$tmp]}):" n
echo "Starting container: ${projectname[$tmp]}"

#--hostname tomcat-"node-${projectname[$tmp]}"

docker run -d --name "node-${projectname[$tmp]}" --hostname "node-${projectname[$tmp]}" --env CONSUL_HOST=$ip \
-v ${project[$tmp]}:/project \
-v $PWD/tomcat/server.xml:/usr/local/tomcat/conf/server.xml \
-v /etc/localtime:/etc/localtime:ro \
noonly/tomcat-debug
fi

