# Dockerfile
# start from official mongo image
FROM centurylink/mysql

RUN apt-get update && apt-get install -y unzip dnsmasq python
# install consul agent
ADD consul_0.6.4_linux_amd64.zip /tmp/consul.zip
ADD supervisor-3.3.0 /supervisor-3.3.0
ADD ez_setup.py /ez_setup.py
RUN cd /bin && \
    unzip /tmp/consul.zip&& \
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
#ADD service.json /etc/consul.d/service.json
ADD 10-consul /etc/dnsmasq.d/10-consul
ADD consul-template /bin/consul-template
COPY dnsmasq.conf /etc/dnsmasq.conf

# Install goreman - foreman clone written in Go language

# copy startup script
ADD supervisord.conf /etc/supervisord.conf
#ADD start.sh /start.sh
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
# launch both mongo server and consul agent
CMD ["/usr/local/bin/supervisord"]
