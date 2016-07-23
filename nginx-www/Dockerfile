# Dockerfile
# start from official mongo image
FROM ubuntu

RUN apt-get update && apt-get install -y unzip dnsmasq python libpcre3-dev libssl-dev
# install consul agent
ADD consul_0.6.4_linux_amd64.zip /tmp/consul.zip
ADD supervisor-3.3.0 /supervisor-3.3.0
ADD ez_setup.py /ez_setup.py
RUN cd /bin && \
    unzip /tmp/consul.zip && \
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} && \
    rm /tmp/consul.zip && \
    cd / && python ez_setup.py && \
    cd /supervisor-3.3.0 && python setup.py install && \
    rm -Rf /supervisor-3.3.0 /ez_setup.py /setuptools-23.0.0.zip
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json
ADD 10-consul /etc/dnsmasq.d/10-consul
ADD consul-template /bin/consul-template
COPY dnsmasq.conf /etc/dnsmasq.conf
#http://nginx.org/ihttps://github.com/openresty/lua-nginx-module/archive/v0.10.6rc1.zip
ADD https://github.com/openresty/lua-nginx-module/archive/v0.10.6rc1.zip /
ADD https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip /
ADD http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.4.4.tar.gz /
RUN cd / && unzip v0.10.6rc1.zip && tar zxvf nginx-1.4.4.tar.gz && cd nginx-1.4.4 && \
./configure --user=www \
--group=www \
--prefix=/etc/nginx \
--with-http_stub_status_module \
--without-http-cache \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \ 
--with-http_ssl_module \
--add-module=../ngx_devel_kit --add-module=../lua_nginx_module \
--with-http_gzip_static_module && \

CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l) && \
make -j$CPU_NUM && make install && 

# Install goreman - foreman clone written in Go language

# copy startup script
ADD supervisord.conf /etc/supervisord.conf
#ADD start.sh /start.sh
# launch both mongo server and consul agent
CMD ["/usr/local/bin/supervisord"]
