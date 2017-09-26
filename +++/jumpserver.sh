#!/bin/bash

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

yum -y install epel-release && yum -y install git python-pip mysql-devel gcc automake autoconf python-devel vim sshpass lrzsz readline-devel