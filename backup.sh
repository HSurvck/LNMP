#!/bin/bash
test -f /usr/bin/rsync || yum install rsync -y

egrep "^rsync.*/sbin/nologin" /etc/passwd || useradd rsync -s /sbin/nologin

BackupDir=/backup                     # [backup] path=$BackupDir
PassWordDir=/etc/rsync.password       # secrets file = $PassWordDir
PassWord=oldboy123                    # echo "$PassWord" > /etc/rsync.password

cat > /etc/rsyncd.conf <<EOF
uid = rsync				
gid = rsync
use chroot = no
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
hosts allow = 172.16.1.0/24
hosts deny = 0.0.0.0/32
auth users = rsync_backup
secrets file = $PassWordDir

[backup]
comment = "backup dir by oldboy"	
path = $BackupDir	
EOF

test -d $BackupDir || mkdir $BackupDir -p ;chown -R rsync.rsync $BackupDir

echo "rsync_backup:$PassWord" > $PassWordDir && chmod 600 $PassWordDir

test -f /etc/init.d/xinetd || yum install xinetd -y

sed -i '6s#yes#no#g' /etc/xinetd.d/rsync && /etc/init.d/xinetd restart

chkconfig xinetd on
