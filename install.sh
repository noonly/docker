#! /bin/bash

if [ `uname -v | awk '{print $1}'` == '#40~14.04.1-Ubuntu' ]; then
	echo "You will be install docker engine ..."
else
	read -p "Your server OS version may be not support for install Docker. Do you continue? [y/n]" tmp
fi
if [ "_$tmp" != "_y" ]; then
	echo "Installation canceled."
	exit 0
fi
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

sudo apt-get update

sudo apt-get purge lxc-docker

apt-cache policy docker-engine

sudo apt-get install -y linux-image-generic-lts-trusty

sudo apt-get update

sudo apt-get install -y docker-engine

read -p "Whether you need settings bridge network[y/n]: " tmp

if [ "_$tmp" == "_y" ]; then
	
tmp=""

while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please input eth name: " tmp

done

eth=$tmp

tmp=""

while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please input ip address: " tmp

done

address=$tmp

tmp=""

while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please input netmask: " tmp

done

netmask=$tmp

tmp=""

while [ "_$tmp" == '_' ]
do
        #echo ""
        #echo "invalid container name! please retry!!!"
        read -p "Please input gateway: " tmp

done

gateway=$tmp


echo "auto $eth" | sudo tee -a /etc/network/interfaces
echo "iface $eth inet manual" | sudo tee -a /etc/network/interfaces
echo "auto br0" | sudo tee -a /etc/network/interfaces
echo "face br0 inet static"  | sudo tee -a /etc/network/interfaces
echo "address $address/$netmask" | sudo tee -a /etc/network/interfaces
echo "gateway $getway" | sudo tee -a /etc/network/interfaces
echo "bridge_ports $eth" | sudo tee -a /etc/network/interfaces
echo "bridge_stp off" | sudo tee -a /etc/network/interfaces

fi

echo "DOCKER_OPTS=\"-b=br0 --fixed-cidr='$address/28'\"" | sudo tee -a /etc/default/docker
