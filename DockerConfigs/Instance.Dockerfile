FROM ubuntu:13.04
MAINTAINER Paulson McIntyre, paul+mcdocker@gpmidi.net

RUN groupadd --gid 1000 mcservers \
  && useradd --home-dir "/var/lib/minecraft" -m --gid 1000 --uid 1000 mcservers

# Do an initial update
RUN apt-get update
RUN apt-get dist-upgrade -y

# Stuff pip will require
RUN apt-get install -y \
  build-essential git python python-dev \
  python-setuptools python-pip wget curl libssl-dev \
  openjdk-7-jre-headless rdiff-backup python-openssl \
  supervisor logrotate cron man 
  
# Stuff to uninstall for real releases
RUN apt-get install -y \
  openssh-server vim screen 

RUN mkdir -p /var/log/supervisor \
  && chmod 700 /var/log/supervisor/ \
  && chown -R root:root /var/log/supervisor

# TODO: Move wget to ONBUILD
# Various configs
ADD ./ /usr/share/minecraft/    
RUN  cp -a /usr/share/minecraft/supervisord.d/*.conf /etc/supervisor/conf.d/ \
  && cp -a /usr/share/minecraft/supervisord.conf /etc/supervisor/ \
  && cp -a /usr/share/minecraft/logrotate.d/*.conf /etc/logrotate.d/ \
  && cp -a /usr/share/minecraft/scripts/minecraftDocker /etc/init.d/minecraft \
  && mkdir -p /var/run/sshd /root/.ssh /var/lib/minecraftBackups \
  && chmod -R 755 /var/run/sshd /etc/init.d/minecraft /etc/supervisor/ \
  && chmod 700 /root/.ssh \
  && cp -a /usr/share/minecraft/authorized_keys /root/.ssh/authorized_keys \
  && chmod -R 755 /var/lib/minecraft/ \
  && chmod 400 /root/.ssh/authorized_keys \
  && chown -R root:root /etc/supervisor/ /root/.ssh/authorized_keys /usr/share/minecraft \
  && chown -R 1000.1000 /var/lib/minecraft /var/lib/minecraftBackups \
  && chmod -R 755 /var/lib/minecraft /usr/share/minecraft /var/lib/minecraftBackups \
  && echo "Done with many cmds"
  
RUN cd /usr/share/minecraft/ \
  && /usr/bin/python /usr/share/minecraft/setup.py install

#RUN apt-get remove -y \
#  build-essential openssh-server vim

ONBUILD RUN mkdir -p /usr/share/minecraft/servers \
  && chown root:root /usr/share/minecraft/servers \
  && chmod 755 /usr/share/minecraft/servers \
  && wget \
    -O /usr/share/minecraft/servers/minecraft_server.jar \
    http://www.minecraft.net/download/minecraft_server.jar?v=`date | sed "s/[^a-zA-Z0-9]/_/g"`
  && echo "Updated server"
  
ONBUILD RUN ln -s /usr/share/minecraft/servers/minecraft_server.1.7.4.jar \
  /var/lib/minecraft/minecraft_server.jar

EXPOSE 22 9001 25565
VOLUME ["/var/lib/minecraft","/var/lib/minecraftBackups"]
CMD ["supervisord", "--nodaemon", "--logfile=/var/log/supervisor/supervisord.log", "--loglevel=warn", "--logfile_maxbytes=1GB", "--logfile_backups=0"]

