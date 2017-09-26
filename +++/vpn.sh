#!/bin/bash

sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf && sysctl -p

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo && yum -y install pptpd

echo -e "localip 10.0.0.61\remoteip 172.16.0.200-250,172.16.0.245" >> /etc/pptpd.conf

sed -i '1a\admin * 123456 *' /etc/ppp/chap-secrets

echo "/etc/init.d/pptpd start" >> /etc/rc.local && /etc/init.d/pptpd start