#! /bin/bash
if [ ];then
sudo apt-get install dnsmasq
sudo mkdir -p /etc/dnsmasq.d/
echo "server=/consul/127.0.0.1#8600" | sudo tee -a /etc/dnsmasq.d/10-consul
fi

wget http://apache.fayea.com/tomcat/tomcat-8/v8.5.4/bin/apache-tomcat-8.5.4.zip
read -p "How match tomcat do you want to startup[>=1]?" c
while [ "_$c" != "_0" ]
do
	unzip apache-tomcat-8.5.4.tar.gz tomcat"_$c"
	sed -i "s/Connector port=\"8080\"/Connector port=\"880$c\"/g" ./tomcat"_$c"/config/server.xml #`grep -tl ./tomcat"_$c"/config/server.xml`
	c=$(($c-1))
done

if [ ];then
wget https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
unzip consul_0.6.4_linux_amd64.zip
sudo mkdir -p /etc/consul.d

sudo nohup consul agent -join 10.0.0.7 -data-dir /tmp -config-dir /etc/consul.d &

fi