#!/bin/bash

rm -rf /var/spool/cron/root

sed -i "8d;7a\#restrict default kod nomodify notrap nopeer noquery" /etc/ntp.conf
sed -i "21a\server pool.ntp.org prefer" /etc/ntp.conf

/etc/init.d/ntpd start

chkconfig ntpd on && chkconfig --list ntpd

\rm -f /root/.ssh/id_dsa*

ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q

yum install libselinux-python -y

yum install ansible -y

for ip in 5 6 7 8 9 31 41 51
do 
   sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@172.16.1.$ip"
done

if [ $? -ne 0 ]
then

echo "LALALA~"

else

cat >> /etc/ansible/hosts <<EOF
[lb01]
172.16.1.5

[lb02]
172.16.1.6

[nfs]
172.16.1.31

[backup]
172.16.1.41

[web0102]
172.16.1.7
172.16.1.8

[web03]
172.16.1.9

[db]
172.16.1.51
EOF

ansible all -m ping

fi

