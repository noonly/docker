#!/bin/sh
set -e;


join="consul.service.dc1.consul"
node=""
master="a.ctml"
key=""
for p in $*;
do
        if [ "_$key" = "_-join" ]; then
                #echo "join = $p"
                join=$p
        fi
        if [ "_$key" = "_-node" ]; then
                #echo "node = $p"
                node=$p
        fi
	if [ "_$key" = "_-rule" ]; then
		master=$p
        fi
        key=$p
done;

if [ "_$node" = "_" ]; then
        node=hostname
fi

echo '{  "service":{ "name":"'$node'", "tags":[ "web", "nginx" ], "port":80, "check":{ "name":"status", "tcp":"localhost:80", "interval":"30s" }  } }' > /etc/consul.d/service.json




echo "nginx";
/usr/local/openresty/nginx/sbin/nginx
echo "consul"
nohup /bin/consul agent -data-dir=/data/consul -config-dir=/etc/consul.d -join $join &
echo "consul-template"
consul-template -consul 127.0.0.1:8500 -template /usr/local/openresty/nginx/conf/conf.d/$master:/usr/local/openresty/nginx/conf/conf.d/a.conf:"/usr/local/openresty/nginx/sbin/nginx -s reload"
#echo "$@";
#exec "$@";
