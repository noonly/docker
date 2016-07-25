# Dockerfile
# start from official mongo image
FROM ubuntu

RUN apt-get update && apt-get install -y perl gcc make unzip dnsmasq python libpcre3-dev libssl-dev supervisor
# install consul agent
ADD consul_0.6.4_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && \
    unzip /tmp/consul.zip && \
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} && \
    rm /tmp/consul.zip 
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json
ADD 10-consul /etc/dnsmasq.d/10-consul
ADD consul-template /bin/consul-template
COPY dnsmasq.conf /etc/dnsmasq.conf
#http://nginx.org/ihttps://github.com/openresty/lua-nginx-module/archive/v0.10.6rc1.zip
#ADD https://github.com/openresty/lua-nginx-module/archive/v0.10.6rc1.zip /
#ADD https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip /
#ADD http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.4.4.tar.gz /
ADD https://openresty.org/download/openresty-1.9.15.1.tar.gz /
RUN cd / && \
/usr/sbin/groupadd -f www && \
/usr/sbin/useradd -g www www && \
tar zxvf  openresty-*.tar.gz && \
rm -f openresty-*.tar.gz && \
  cd openresty-1.9.15.1 && \
#RUN cd / && unzip v0.10.6rc1.zip && tar zxvf nginx-1.4.4.tar.gz && cd nginx-1.4.4 && \
./configure --with-pcre-jit && \
make -j2 && make install && \
ln -s /etc/nginx/nginx/sbin/nginx /usr/local/bin/nginx && mkdir -p /usr/local/openresty/nginx/conf/conf.d

ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
# Install goreman - foreman clone written in Go language

# copy startup script
ADD supervisord.conf /etc/supervisord.conf
#ADD start.sh /start.sh
# launch both mongo server and consul agent
CMD ["/usr/bin/supervisord"]
