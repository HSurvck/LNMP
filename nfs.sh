#!/bin/bash
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
	rsync -az --delete /data/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
done &
EOF

chmod +x /etc/init.d/inotify

/etc/init.d/inotify

chkconfig --add inotify  && chkconfig inotify on

rpm -qa nfs-utils || yum install -y nfs-utils

rpm -qa rpcbind || yum install -y rpcbind

cat >>/etc/exports << EOF
/data 172.16.1.0/24(rw,sync,no_all_squash,root_squash)
EOF

mkdir -p /data/web{01..03} && chown -R nfsnobody.nfsnobody /data

/etc/init.d/rpcbind restart

chkconfig rpcbind on

/etc/init.d/nfs restart

chkconfig nfs on



