#! /bin/bash

if [ ];then
sudo apt-get install dnsmasq
sudo mkdir -p /etc/dnsmasq.d/
echo "server=/consul/127.0.0.1#8600" | sudo tee -a /etc/dnsmasq.d/10-consul
fi
if [ ! -e "./apache-tomcat-8.5.4.zip" ]; then
	wget http://apache.fayea.com/tomcat/tomcat-8/v8.5.4/bin/apache-tomcat-8.5.4.zip
fi
if [ ! -d "./apache-tomcat-8.5.4" ]; then
	unzip apache-tomcat-8.5.4.zip
fi
path=`pwd`
mkdir -p "$path/config/"
c=1;
for folder in `ls ./`
do
	if [ -d $path"/"$folder"/WebRoot" ]; then
		if [ -f $path"/"$folder"/WebRoot/service.conf" ]; then
			y="y"
                        read -p "Do you want to append $folder to localhost[Y/n]?" y
                        if [ "$y" != "_y" ];then
                                continue
                        fi

			#cp $path/$folder/WebRoot/*.json $path/config/
			
			cd $path/$folder/WebRoot/
			for json in `ls *.json`
			do
				cp $json $path/config/
				sed -i "s/8080/880$c/g" $path/config/$json
			done
			cd $path
			cp -R apache-tomcat-8.5.4 tomcat"_$folder"
			sed -i "s/Connector port=\"8080\"/Connector port=\"880$c\"/g" ./tomcat"_$folder"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
			sed -i "s/Server port=\"8005\"/Server port=\"700$c\"/g" ./tomcat"_$folder"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
			sed -i "s/Connector port=\"8009\"/Connector port=\"890$c\"/g" ./tomcat"_$folder"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
			p="$path/$folder/WebRoot"
			sed -i "s#autoDeploy=\"true\">#autoDeploy=\"true\"><Context docBase=\"$p\" path=\"\" reloadable=\"true\" source=\"$p\"\/>#g" ./tomcat"_$folder"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
			c=$(($c+1))
		fi
	fi
done
if [ ]; then
c=`ls $parh/config/*.json | wc -l`
#read -p "How match tomcat do you want to startup[>=1]?" c
while [ "_$c" != "_0" ]
do
	cp -R apache-tomcat-8.5.4 tomcat"_$c"
	sed -i "s/Connector port=\"8080\"/Connector port=\"880$c\"/g" ./tomcat"_$c"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
	sed -i "s/Server port=\"8005\"/Server port=\"700$c\"/g" ./tomcat"_$c"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
	sed -i "s/Connector port=\"8009\"/Connector port=\"890$c\"/g" ./tomcat"_$c"/conf/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
	c=$(($c-1))
done
fi
y="y"
read -p "Do you want to startup consul service[Y/n]?" y
if [ "_$y" == "_y" ];then
wget https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
unzip consul_0.6.4_linux_amd64.zip
sudo mkdir -p /etc/consul.d

sudo nohup consul agent -join 10.0.0.7 -data-dir /tmp -config-dir "$parh/config/" &

sudo apt-get install dnsmasq
sudo mkdir -p /etc/dnsmasq.d/
echo "server=/consul/127.0.0.1#8600" | sudo tee -a /etc/dnsmasq.d/10-consul

fi
