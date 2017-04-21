# Dockerfile
# start from official mongo image
FROM mysql

RUN apt-get update && apt-get install -y libgearman-dev g++
# install consul agent
#ADD https://releases.hashicorp.com/consul/0.7.5/consul_0.7.5_linux_386.zip /tmp/consul.zip
ADD consul /bin/consul
RUN chmod +x /bin/consul && \
    mkdir -p /data/consul /etc/consul.d

# copy service and check definition, as we wrote them earlier
ADD mongo.json /etc/consul.d/service.json

# Install goreman - foreman clone written in Go language

# copy startup script
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#add http://launchpad.net/gearman-mysql-udf/trunk/0.5/+download/gearman-mysql-udf-0.5.tar.gz /
ADD https://launchpad.net/gearman-mysql-udf/trunk/0.6/+download/gearman-mysql-udf-0.6.tar.gz /
RUN apt-get install -y libmysqlclient-dev make
RUN tar -zxvf gearman-mysql-udf-0.6.tar.gz && cd gearman-mysql-udf-0.6 && \
./configure --with-mysql=/usr/bin/mysql_config --libdir=/usr/lib/mysql/plugin/ && make && make install


# launch both mongo server and consul agent
#CMD ["/usr/bin/supervisord"]
#COPY docker-entrypoint.sh /usr/local/bin/
#RUN rm /entrypoint.sh
#RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
EXPOSE 3306
#ENTRYPOINT ["/entrypoint.sh"]
ADD start.sh /usr/local/bin/container-start
ENTRYPOINT ["container-start"]

#EXPOSE 3306
CMD ["mysqld"]

