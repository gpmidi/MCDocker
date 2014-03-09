FROM ubuntu:13.04
MAINTAINER Paulson McIntyre, paul+mcdocker@gpmidi.net

RUN groupadd --gid 1000 mcservers \
  && useradd --home-dir "/var/lib/minecraft" -m --gid 1000 --uid 1000 mcservers

# Do an initial update
RUN apt-get update
RUN apt-get dist-upgrade -y
ONBUILD RUN apt-get update
ONBUILD RUN apt-get dist-upgrade -y


# Stuff pip will require
RUN apt-get install -y \
  build-essential git python python-dev \
  python-setuptools python-pip wget curl libssl-dev \
  openjdk-7-jre-headless rdiff-backup python-openssl \
  logrotate cron man daemontools-run daemontools
  
# Stuff to uninstall for real releases
RUN apt-get install -y \
  openssh-server vim screen 

VOLUME ["/var/lib/minecraft","/var/log"]

RUN mkdir -p /var/log/daemontools \
  && chmod 700 /var/log/daemontools/ \
  && chown -R root:root /var/log/daemontools \
  && echo "Done with making mc dir"

RUN  mkdir -p /var/lib/minecraft/jars /var/lib/minecraft/backups \
     /var/lib/minecraft/instances} \
  && chmod -R 700 /var/lib/minecraft \
  && chown -R 1000:1000 /var/lib/minecraft \
  && echo "Done with making mc dir"

# Various configs
ADD ./ /usr/share/minecraft/    
RUN  mkdir -p /var/lib/minecraft/.ssh/ \
  && cp /usr/share/minecraft/DockerFiles/authorized_keys /var/lib/minecraft/.ssh/authorized_keys \
  && chmod -R 700 /var/lib/minecraft \
  && chown -R 1000:1000 /var/lib/minecraft \
  && echo "Done with making mc .ssh home dir"
  
#RUN cd /usr/share/minecraft/ \
#  && /usr/bin/python /usr/share/minecraft/setup.py install

#RUN apt-get remove -y \
#  build-essential openssh-server vim

RUN mkdir -p /var/lib/minecraft/jars \
  && wget -O /var/lib/minecraft/jars/minecraft_server.1.7.4.jar \
    http://www.minecraft.net/download/minecraft_server.jar?v=`date | sed "s/[^a-zA-Z0-9]/_/g"` \
  && chown 1000:1000 /var/lib/minecraft/jars/ \
  && chmod 755 /var/lib/minecraft/jars/ \    
  && echo "Updated server"

USER mcservers
EXPOSE 22 25565
CMD ["/usr/bin/svscanboot"]

