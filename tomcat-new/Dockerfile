# Dockerfile
# start from official mongo image
FROM tomcat

# install consul agent
ADD consul /bin/consul
RUN apt-get update &&  apt-get install -y supervisor &&\
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} 
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
#ADD service.json /etc/consul.d/service.json
#ADD manage.sh /manage.sh

# Install goreman - foreman clone written in Go language
ADD server.xml /usr/local/tomcat/conf/server.xml
# copy startup script
ADD supervisord.conf /etc/supervisor/supervisord.conf
#ADD start.sh /start.sh
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
# launch both mongo server and consul agent
CMD ["supervisord"]
