#!/bin/bash

test -f /usr/sbin/ntpdate || yum -y install ntpdate
echo "*/5 * * * * /usr/sbin/ntpdate 172.16.1.61 >/dev/null 2>&1" > /var/spool/cron/root
sed -i "21a\server 172.16.1.61 perfer" /etc/ntp.conf

test -f /usr/bin/rsync || yum install rsync -y

egrep "^rsync.*/sbin/nologin" /etc/passwd || useradd rsync -s /sbin/nologin

test -f /etc/init.d/rpcbind || yum install -y rpcbind ; test -f /etc/init.d/nfs || yum install -y nfs-utils

BackupDir=/backup                     # [backup] path=$BackupDir
DataDir=/data                         # [data] path = $DataDir
PassWordFile=/etc/rsync.password      # secrets file = $PassWordDir
PassWord=oldboy123                    # echo "$PassWord" > /etc/rsync.password

test -d $BackupDir || mkdir $BackupDir -p ;chown -R rsync.rsync $BackupDir

test -d $DataDir || mkdir $DataDir -p ;chown -R nfsnobody.nfsnobody $DataDir

echo "rsync_backup:$PassWord" > $PassWordFile && chmod 600 $PassWordFile

cat > /etc/rsyncd.conf <<EOF
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
secrets file = \$PassWordDir

[backup]
uid = rsync				
gid = rsync
comment = "backup dir by oldboy"
path = $BackupDir
[data]
uid = nfsnobody
gid = nfsnobody
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

#nfs rpc keepalived

cat >>/etc/exports << EOF
/data 172.16.1.0/24(rw,sync,all_squash)
EOF

/etc/init.d/rpcbind restart

chkconfig rpcbind on

/etc/init.d/nfs restart

chkconfig nfs on

test -f /etc/init.d/keepalived || yum install -y keepalived

cat > /server/scripts/check_web.sh <<EOF
#!/bin/bash

if [ \`ps -ef |grep -c n[f]s\` -lt 2 ]
	then
	/etc/init.d/keepalived stop
fi

EOF

cat > /etc/keepalived/keepalived.conf <<EOF
global_defs {
   router_id backup
}
vrrp_script check_web {
script "/server/scripts/check_web.sh"
interval 2
weight 2
}
vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 66
    priority 50
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
