#!/bin/bash
#server
mkdir -p /application/yum/centos6.9/x86_64/

test -f /usr/bin/createrepo || yum -y install createrepo

createrepo -pdo /application/yum/centos6.9/x86_64/ /application/yum/centos6.9/x86_64/ && \
cd /application/yum/centos6.9/x86_64/ && \
python -m SimpleHTTPSever 80 &>/dev/null &

sed -i 's#keepcache=0#keepcache=1#g' /etc/yum.conf

#client
cd /etc/yum.repos.d && cat prow.repo <<EOF
[prow]
name=prow
baseurl=http://10.0.0.61
enable=1
gpgcheck=0
EOF

sed -i '33a\enabled=0' /etc/yum.conf
sed -i '25a\enabled=0' /etc/yum.conf
sed -i '17a\enabled=0' /etc/yum.conf

yum clean all && yum --enablerepo=prow --disablerepo=base,extras,updates,epel list


