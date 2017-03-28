FROM centos:7
MAINTAINER hidetomo

# create user
RUN echo "root:root" | chpasswd
RUN useradd hidetomo
RUN echo "hidetomo:hogehoge" | chpasswd

# init yum
RUN yum -y update
RUN yum -y install initscripts

# sudo
RUN yum -y install sudo
RUN echo "hidetomo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# change dir
WORKDIR /home/hidetomo

# ssh
RUN sudo yum -y install openssh-server openssh-clients
RUN sudo echo "RSAAuthentication yes" >> /etc/ssh/sshd_config
RUN sudo echo "PubKeyAuthentication yes" >> /etc/ssh/sshd_config
# RUN sed -i -e '/^HostKey/s/^/# /g' /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_ed25519_key
RUN mkdir -p .ssh
RUN chown hidetomo:hidetomo .ssh
RUN chmod 700 .ssh
COPY authorized_keys .ssh/authorized_keys
RUN chown hidetomo:hidetomo .ssh/authorized_keys
RUN chmod 600 .ssh/authorized_keys
EXPOSE 22

# ssh key
COPY id_rsa .ssh/id_rsa
RUN chown hidetomo:hidetomo .ssh/id_rsa

# vim
RUN sudo yum -y install vim
COPY vimrc_simple .vimrc

# share
RUN mkdir share
VOLUME share

# common yum
RUN sudo yum -y install less wget bzip2 gcc git svn

# mongo
COPY mongodb.repo /etc/yum.repos.d/mongodb.repo
RUN sudo yum -y install mongodb-org
RUN mkdir mongo
RUN chown hidetomo:hidetomo mongo
RUN mkdir mongo/db
RUN chown hidetomo:hidetomo mongo/db
# CMD ["sudo systemctl start mongod"]
RUN export LC_ALL=C; /usr/bin/mongod --dbpath mongo/db > mongo/log 2>&1 &

# preinstall
# RUN sudo yum -y install anaconda
RUN wget -O /home/hidetomo/Anaconda3.sh https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh
RUN sudo yum -y install graphviz
RUN mkdir works
RUN chown hidetomo:hidetomo works
COPY install_base.sh install_base.sh
COPY install_sdk.sh install_sdk.sh

# start
# CMD ["sudo systemctl start sshd.service"]
CMD ["/usr/sbin/sshd", "-D"]
