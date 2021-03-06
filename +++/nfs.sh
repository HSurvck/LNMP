#!/bin/bash

test -f /usr/sbin/ntpdate || yum -y install ntpdate
echo "*/5 * * * * /usr/sbin/ntpdate 172.16.1.61 >/dev/null 2>&1" > /var/spool/cron/root
sed -i "21a\server 172.16.1.61 prefer" /etc/ntp.conf

test -f /etc/init.d/rpcbind || yum install -y rpcbind ;test -f /etc/init.d/nfs || yum install -y nfs-utils

cat >>/etc/exports << EOF
/data 172.16.1.0/24(rw,sync,all_squash)
EOF

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

for i in wordpress dedecms discuz
do
mkdir -p /data/$i
done

chown -R nfsnobody.nfsnobody /data

/etc/init.d/rpcbind restart

chkconfig rpcbind on

/etc/init.d/nfs restart

chkconfig nfs on

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

#keepalived

test -f /etc/init.d/keepalived || yum install -y keepalived

mkdir -p /server/scripts && cat > /server/scripts/check_web.sh <<EOF
#!/bin/bash

if [ \`ps -ef |grep -c n[f]s\` -lt 2 ]
	then
	/etc/init.d/keepalived stop
fi

EOF

cat > /etc/keepalived/keepalived.conf <<EOF
global_defs {
   router_id nfs
}
vrrp_instance VI_1 {
    state MASTER
    interface eth1
    virtual_router_id 66
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        172.16.1.35/24 dev eth1 label eth1:1
    }
	track_script {
		check_web
	}
}
EOF

echo "/etc/init.d/keepalived start">> /etc/rc.local && /etc/init.d/keepalived start

#cat > /server/scripts/start_keepalived.sh <<EOF
##!/bin/bash
#
#while true
#do
#	test [ \`ps -ef |grep -c [n]ginx\` -gt 1 ] && /etc/init.d/keepalived start
#done &
#EOF
#
#echo "/bin/bash /server/scripts/start_keepalived.sh" >> /etc/rc.local && /bin/bash /server/scripts/start_keepalived.sh
