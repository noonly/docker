# Dockerfile
# start from official mongo image
FROM ubuntu

RUN apt-get update && apt-get install -y gcc make libpcre3-dev libssl-dev unzip dnsmasq python-pip
# install consul agent
RUN pip install Django
ADD http://nginx.org/download/nginx-0.7.69.tar.gz /
ADD https://github.com/vkholodkov/nginx-upload-module/archive/2.2.zip /
ADD consul_0.6.4_linux_amd64.zip /tmp/consul.zip
ADD supervisor-3.3.0 /supervisor-3.3.0
ADD ez_setup.py /ez_setup.py
RUN cd / && \
tar zxvf nginx-0.7.69.tar.gz && \
unzip 2.2.zip && \
cd nginx-0.7.69 && \
./configure --add-module=/nginx-upload-module-2.2/ && make && make install && \
cd / && django-admin.py startproject upload && cd upload && python manage.py startapp uploadapp
ADD urls.py /upload/upload/urls.py
ADD views.py /upload/uploadapp/
RUN cd /bin && \
    unzip /tmp/consul.zip && \
    chmod +x /bin/consul && \
    mkdir -p {/data/consul,/etc/consul.d} && \
    rm /tmp/consul.zip && \
    cd / && python ez_setup.py && \
    cd /supervisor-3.3.0 && python setup.py install && \
    rm -Rf /supervisor-3.3.0 /ez_setup.py /setuptools-23.0.0.zip && \
rm -rf /nginx-upload-module-2.2 /nginx-0.7.69.tar.gz /setuptools-24.0.3.zip 2.2.zip /nginx-0.7.69
#RUN echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#RUN echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#RUN echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json
ADD 10-consul /etc/dnsmasq.d/10-consul
#ADD consul-template /bin/consul-template
COPY dnsmasq.conf /etc/dnsmasq.conf
ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD upload.html /usr/local/nginx/html/upload.html
# Install goreman - foreman clone written in Go language

# copy startup script
ADD supervisord.conf /etc/supervisord.conf
#ADD start.sh /start.sh
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53/udp
# launch both mongo server and consul agent
CMD ["/usr/local/bin/supervisord"]
