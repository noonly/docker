# Dockerfile
# start from official mongo image
FROM redis

# install consul agent
ADD consul /bin/consul
ADD redis.conf /usr/local/etc/redis/redis.conf
RUN cd /bin && \
    chmod +x /bin/consul && \
    mkdir -p /data/consul /etc/consul.d
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json
ADD redis.conf.1 /slave
ADD redis.conf /master
#ADD 10-consul /etc/dnsmasq.d/10-consul
#COPY dnsmasq.conf /etc/dnsmasq.conf

# Install goreman - foreman clone written in Go language

# copy startup script
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#ADD start.sh /start.sh
#EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
EXPOSE 6379
#VOLUME /
WORKDIR /
# launch both mongo server and consul agent
#CMD ["/usr/bin/supervisord"]
COPY start.sh /usr/local/bin/container-start
ENTRYPOINT ["container-start","redis-server"]
