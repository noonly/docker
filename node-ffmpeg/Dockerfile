FROM node

#ADD sources.list /etc/apt/sources.list
#ADD resolv.conf /etc/resolv.conf
RUN apt-get update && \
apt-get install -y libmp3lame-dev libx264-dev yasm && \
wget http://ffmpeg.org/releases/ffmpeg-3.2.4.tar.bz2 && \
wget http://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.5.tar.gz
RUN tar -zxf fdk-aac-0.1.5.tar.gz && rm fdk-aac-0.1.5.tar.gz
RUN cd fdk-aac-0.1.5 && ./configure --prefix=/usr --disable-static && make && make install && cd ..
RUN tar -jxf ffmpeg-3.2.4.tar.bz2 && rm ffmpeg-3.2.4.tar.bz2
#COPY ./sources.list /etc/apt/sources.list
#RUN apt-get update
RUN cd ./ffmpeg-3.2.4 && \
        ./configure \
        --enable-gpl \
        --enable-libx264 \
        --enable-libmp3lame \
        --enable-nonfree \
        --enable-libfdk-aac &&\
        make && make install


ADD consul /bin/consul
RUN chmod +x /bin/consul && \
    mkdir -p /data/consul /etc/consul.d

# copy service and check definition, as we wrote them earlier
ADD service.json /etc/consul.d/service.json



ADD start.sh /usr/local/bin/container-start
ENTRYPOINT ["container-start"]

CMD ["node"]

