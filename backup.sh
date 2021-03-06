#!/bin/bash
test -f /usr/bin/rsync || yum install rsync -y

egrep "^rsync.*/sbin/nologin" /etc/passwd || useradd rsync -s /sbin/nologin

BackupDir=/backup                     # [backup] path=$BackupDir
DataDir=/data                         # [data] path = $DataDir
PassWordFile=/etc/rsync.password      # secrets file = $PassWordDir
PassWord=oldboy123                    # echo "$PassWord" > /etc/rsync.password

test -d $BackupDir || mkdir $BackupDir -p ;chown -R rsync.rsync $BackupDir

test -d $DataDir || mkdir $DataDir -p ;chown -R rsync.rsync $DataDir

echo "rsync_backup:$PassWord" > $PassWordFile && chmod 600 $PassWordFile

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
secrets file = $PassWordFile

[backup]
comment = "backup dir by oldboy"
path = $BackupDir
[data]
comment = 'inotifywait + rsync'
path = $DataDir
EOF

test -f /etc/init.d/xinetd || yum install xinetd -y

sed -i '6s#yes#no#g' /etc/xinetd.d/rsync && /etc/init.d/xinetd restart

chkconfig xinetd on

cat >> /etc/mail.rc <<EOF
set from=17611165711@163.com
set smtp=smtp.163.com
set smtp-auth-user=17611165711@163.com
set smtp-auth-password=h1116j
set smtp-auth=login"
EOF

mkdir -p /server/scripts && cat > /server/scripts/backup_server.sh <<EOF
#!/bin/bash

# check data info
cd /backup
find /backup/ -type f -name "finger.txt"| \\
xargs md5sum -c >/tmp/check_info.txt

# send mail to sa
mail -s "check_info" 1337173414@qq.com < /tmp/check_info.txt

# delete 180 day ago, but save everyweek 1
find /backup/ -type f -mtime +180 ! -name "*_1.tar.gz" -delete
EOF


