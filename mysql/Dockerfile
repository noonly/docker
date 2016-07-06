# Dockerfile
# start from official mongo image
FROM mysql

RUN apt-get update && apt-get install -y unzip supervisor
# install consul agent
ADD consul_0.6.4_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && \
    unzip /tmp/consul.zip&& \
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} && \
    rm /tmp/consul.zip

# copy service and check definition, as we wrote them earlier
ADD mongo.json /etc/consul.d/mongo.json

# Install goreman - foreman clone written in Go language

# copy startup script
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# launch both mongo server and consul agent
CMD ["/usr/bin/supervisord"]
