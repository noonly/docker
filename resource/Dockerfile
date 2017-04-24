# Dockerfile
# start from official mongo image
FROM nginx

ADD consul /bin/consul
RUN cd /bin && \
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} 
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json
#ADD https://github.com/openresty/lua-nginx-module/archive/v0.10.6rc1.zip /
#ADD https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.zip /
#ADD http://oss.aliyuncs.com/aliyunecs/onekey/nginx/nginx-1.4.4.tar.gz /
ADD localtime /etc/localtime
ADD timezone /etc/timezone
# Install goreman - foreman clone written in Go language

# copy startup script
#ADD start.sh /start.sh
# launch both mongo server and consul agent
#CMD ["supervisord"]
COPY start.sh /usr/local/bin/container-start
ENTRYPOINT ["container-start"]
#consul agent -join $CONSUL_HOST -data-dir /data/consul -config-dir /etc/consul.d
