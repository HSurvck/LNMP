#!/bin/bash

test -f /usr/bin/ftp || yum install ftp -y ;test -f /etc/init.d/vsftpd || yum install vsftpd -y

echo "local_root=/centos" >> /etc/vsftpd/vsftpd.conf