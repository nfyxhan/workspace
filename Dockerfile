FROM centos:7

ENV LANG=zh_CN.utf8

ENV BASH_RC=/etc/bashrc

WORKDIR /home/workspace

ADD ./hack ./hack
ADD yum.repos.d/* /etc/yum.repos.d/
ADD bin bin

RUN sh install.sh
