#!/bin/bash

yum -y install gcc automake autoconf libtool make

yum install gcc gcc-c++

yum install -y pcre-devel openssl-devel

egrep "^www.*/sbin/nologin$" /etc/passwd || useradd -s /sbin/nologin -M www

mkdir -p /server/tools && cd /server/tools

tar xf nginx-1.10.3.tar.gz

cd nginx-1.10.3

./configure --prefix=/application/nginx-1.10.3 --user=www --group=www --with-http_ssl_module --with-http_stub_status_module 

make && make install

cd && ln -s /application/nginx-1.10.3/ /application/nginx

echo "/application/nginx/sbin/nginx" >> /etc/rc.local

/application/nginx/sbin/nginx

wget --tries=0 -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo

yum install -y zlib libjpeg freetype libpng gd curl zlib-devel libxml2-devel libjpeg-devel freetype-devel libpng-devel gd-devel curl-devel libjpeg-turbo-devel libcurl-devel libxslt-devel

yum -y install libmcrypt-devel mhash mcrypt libiconv-devel

cd /server/tools/ && \
tar xf php-5.5.32.tar.gz

cd php-5.5.32 &&  touch ext/phar/phar.phar

./configure \
--prefix=/application/php-5.5.32 \
--enable-mysqlnd \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--with-gettext \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--enable-short-tags \
--enable-static \
--with-xsl \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-opcache=no  \
--enable-ftp
#--with-openssl[=Dir]
make && make install

cd && ln -s /application/php-5.5.32/ /application/php

cd /server/tools/php-5.5.32 && cp php.ini-production /application/php/lib/php.ini

cd /application/php/etc/ && cp php-fpm.conf.default php-fpm.conf

echo "/application/php/sbin/php-fpm" >> /etc/rc.local && /application/php/sbin/php-fpm

AppDir=/application/nginx         #106 108
ConfDir=/application/nginx/conf   #112

for Web in www blog bbs
do
mkdir ${AppDir}/html/${Web} -p

echo "${Web} `hostname`" > ${AppDir}/html/${Web}/index.html

done

cat > ${ConfDir}/nginx.conf <<EOF
worker_processes  3;
events {
	worker_connections  1024;
}
http {
	include       mime.types;
	default_type  application/octet-stream;
	sendfile        on;
	keepalive_timeout  65;
	server {
		listen       80;
		server_name  blog.etiantian.org;
		location / {
			root   html/blog;
			index  index.php index.html;
		}
		location ~* .*\.(php|php5)?$ {
			root html/blog;
			fastcgi_pass  127.0.0.1:9000;
			fastcgi_index index.php;
			include fastcgi.conf;
		}
	}
	server {
		listen       80;
		server_name  www.etiantian.org;
		location / {
			root   html/www;
			index  index.php index.html;
		}
		location ~* .*\.(php|php5)?$ {
			root html/www;
			fastcgi_pass  127.0.0.1:9000;
			fastcgi_index index.php;
			include fastcgi.conf;
		}
	}
	server {
		listen       80;
		server_name  bbs.etiantian.org;
		location / {
			root   html/bbs;
			index  index.php index.html;
		}
		location ~* .*\.(php|php5)?$ {
			root html/bbs;
			fastcgi_pass  127.0.0.1:9000;
			fastcgi_index index.php;
			include fastcgi.conf;
		}
	}
	server {
		listen       80;
		server_name  status.etiantian.org;
		location / {
		stub_status on;
		access_log   off;
		}
	}
}
EOF

/application/nginx/sbin/nginx -t && \
/application/nginx/sbin/nginx -s reload

#nfs_web

Ip=172.16.1.31

yum install -y nfs-utils

yum install -y rpcbind

/etc/init.d/rpcbind restart && \
/etc/init.d/nfs restart

chkconfig nfs on

mount -t nfs ${Ip}:/data/wordpress ${AppDir}/html/blog/wp-content/uploads
mount -t nfs ${Ip}:/data/dedecms ${AppDir}/html/www/uploads
mount -t nfs ${Ip}:/data/discuz ${AppDir}/html/bbs/data/attachment

cat >> /etc/rc.local <<EOF
mount -t nfs ${Ip}:/data/wordpress ${AppDir}/html/blog/wp-content/uploads
mount -t nfs ${Ip}:/data/dedecms ${AppDir}/html/www/uploads
mount -t nfs ${Ip}:/data/discuz ${AppDir}/html/bbs/data/attachment
EOF

df -h


#backup_web

test -f /usr/bin/rsync || yum install rsync -y

test -d /backup || mkdir /backup

PassWord=oldboy123
PassWordDir=/etc/rsync.password

echo "$PassWord" > $PassWordDir && chmod 600 $PassWordDir

mkdir /server/scripts/ -p && cat > /server/scripts/backup_web.sh <<EOF
#!/bin/bash

Backup_Dir="/backup"
Host_IP=\`hostname -i\`
Date_Info=\`date +%F_%w -d "-1day"\`

# create backup dir
mkdir -p \$Backup_Dir/\$Host_IP

# backup info compress
cd / && \\
tar zchf \$Backup_Dir/\$Host_IP/sys_backup_\${Date_Info}.tar.gz var/spool/cron/root etc/rc.local server/scripts etc/sysconfig/iptables && \\
tar zchf \$Backup_Dir/\$Host_IP/www_backup__\${Date_Info}.tar.gz application/nginx/html/www/ && \\
tar zchf \$Backup_Dir/\$Host_IP/bbs_backup__\${Date_Info}.tar.gz application/nginx/html/bbs/ && \\
tar zchf \$Backup_Dir/\$Host_IP/blog_backup__\${Date_Info}.tar.gz application/nginx/html/blog/ && \\
tar zchf \$Backup_Dir/\$Host_IP/logs_backup__\${Date_Info}.tar.gz application/nginx/logs/

# check data info, create finger file
cd \$Backup_Dir &&\
find ./ -type f -name "*_\${Date_Info}.tar.gz"|\
xargs md5sum >\$Backup_Dir/\$Host_IP/finger.txt

# push backup data to backup server
rsync -az \$Backup_Dir/ rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password

# delete 7 day ago
find \$Backup_Dir/ -type f -name "*.tar.gz" -mtime +7 -delete
EOF
