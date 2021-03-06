#!/bin/bash

test -f /usr/sbin/ntpdate || yum -y install ntpdate
echo "*/5 * * * * /usr/sbin/ntpdate 172.16.1.61 >/dev/null 2>&1" > /var/spool/cron/root
sed -i "21a\server 172.16.1.61 prefer" /etc/ntp.conf

yum -y install gcc automake autoconf libtool make

yum install gcc gcc-c++

yum install -y pcre-devel openssl-devel

egrep "^www.*/sbin/nologin$" /etc/passwd || useradd -s /sbin/nologin -M www

mkdir -p /server/tools && cd /server/tools && test -f nginx-1.10.3.tar.gz || \
wget --tries=0 http://nginx.org/download/nginx-1.10.3.tar.gz && \
tar xf nginx-1.10.3.tar.gz

cd nginx-1.10.3

./configure --prefix=/application/nginx-1.10.3/  --user=www --group=www --with-http_ssl_module --with-http_stub_status_module 

make && make install

cd && ln -s /application/nginx-1.10.3/ /application/nginx

echo 'net.ipv4.ip_nonlocal_bind = 1' >>/etc/sysctl.conf && sysctl -p

cat > /application/nginx/conf/nginx.conf <<EOF
worker_processes  1;
events {
	worker_connections  1024;
}
http {
	include       mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
	upstream server_poors {
		server 10.0.0.8:80;
		server 10.0.0.7:80;
		server 10.0.0.9:80;
	}
    server {
        listen 10.0.0.3:80;
        server_name blog.etiantian.org;
        location / {
            proxy_pass http://server_poors;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-For \$remote_addr;
        }
	}
	server {
		listen 10.0.0.3:80;
		server_name www.etiantian.org;
		location / {
			proxy_pass http://server_poors;
			proxy_set_header Host \$host;
			proxy_set_header X-Forwarded-For \$remote_addr;
		}
	}
	server {
		listen 10.0.0.3:80;
		server_name bbs.etiantian.org;
		location / {
			proxy_pass http://server_poors;
			proxy_set_header Host \$host;
			proxy_set_header X-Forwarded-For \$remote_addr;
		}
	}
}
EOF

echo "/application/nginx/sbin/nginx" >> /etc/rc.local

/application/nginx/sbin/nginx -t && /application/nginx/sbin/nginx

test -f /etc/init.d/keepalived || yum install -y keepalived

mkdir -p /server/scripts && cat > /server/scripts/check_web.sh <<EOF
#!/bin/bash

test [ `ps -ef |grep -c [n]ginx` -lt 2 ] && /etc/init.d/keepalived stop

EOF

cat > /etc/keepalived/keepalived.conf <<EOF
global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id lb01
}
vrrp_script check_web {
script "/server/scripts/check_web.sh"
interval 2
weight 2
}
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.0.0.3/24 dev eth1 label eth1:1
    }
	track_script {
		check_web.sh
	}
}
vrrp_instance VI_2 {
    state MASTER
    interface eth0
    virtual_router_id 52
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        10.0.0.4/24 dev eth1 label eth1:1
    }

}
EOF

echo "/etc/init.d/keepalived start">> /etc/rc.local && /etc/init.d/keepalived start

#cat > /server/scripts/start_keepalived.sh <<EOF
##!/bin/bash
#
#while ture
#do
#	test [ `ps -ef |grep -c [n]ginx` -gt 1 ] && /etc/init.d/keepalived start
#done &
#EOF
#
#echo "/bin/bash /server/scripts/start_keepalived.sh" >> /etc/rc.local && /bin/bash /server/scripts/start_keepalived.sh
