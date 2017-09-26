#!/bin/bash

test -f /etc/init.d/rpcbind || yum install -y rpcbind ;test -f /etc/init.d/nfs || yum install -y nfs-utils

cat >>/etc/exports << EOF
/data 172.16.1.0/24(rw,sync,no_all_squash,root_squash)
EOF

for i in wordpress dedecms discuz
do
mkdir -p /data/$i
done

chown -R nfsnobody.nfsnobody /data && chmod 1777 /data/*

/etc/init.d/rpcbind restart

chkconfig rpcbind on

/etc/init.d/nfs restart

chkconfig nfs on

yum install inotify-tools -y

test -f /usr/bin/rsync || yum install rsync -y

test -d /backup || mkdir /backup

PassWord=oldboy123
PassWordDir=/etc/rsync.password

echo "$PassWord" > $PassWordDir && chmod 600 $PassWordDir

cat > /etc/init.d/inotify <<EOF
# chkconfig: 2345 99 99
# description:
inotifywait -mrq /data --format '%w%f' -e create,delete,close_write,moved_to|\
while read line
do
	rsync -az --delete /data/ rsync_backup@172.16.1.41::data --password-file=/etc/rsync.password
done &
EOF

chmod +x /etc/init.d/inotify && \
chkconfig --add inotify && \
chkconfig inotify on && \
/etc/init.d/inotify

mkdir -p /server/scripts && cat > /server/scripts/backup_nfs.sh <<EOF
#!/bin/bash

Backup_Dir="/backup"
Host_IP=\`hostname -i\`
Date_Info=\`date +%F_%w -d "-1day"\`

# create backup dir
mkdir -p \$Backup_Dir/\$Host_IP

# backup info compress
cd / && \\
tar zchf \$Backup_Dir/\$Host_IP/sys_backup_\${Date_Info}.tar.gz var/spool/cron/root etc/rc.local server/scripts etc/sysconfig/iptables

# check data info, create finger file
cd \$Backup_Dir && \\
find ./ -type f -name "*_\${Date_Info}.tar.gz" | \\
xargs md5sum >\$Backup_Dir/\$Host_IP/finger.txt

# push backup data to backup server
rsync -az \$Backup_Dir/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password

# delete 7 day ago
find \$Backup_Dir/ -type f -name "*.tar.gz" -mtime +7 -delete
EOF


