#!/bin/bash

yum -y install gcc automake autoconf libtool make

yum install gcc gcc-c++

yum install -y pcre-devel openssl-devel

egrep "^www.*/sbin/nologin$" /etc/passwd || useradd -s /sbin/nologin -M www

mkdir -p /server/tools && cd /server/tools

wget --tries=0 http://nginx.org/download/nginx-1.10.3.tar.gz

tar xf nginx-1.10.3.tar.gz

cd nginx-1.10.3

./configure --prefix=/application/nginx-1.10.3/  --user=www --group=www --with-http_ssl_module --with-http_stub_status_module 

make && make install

cd && ln -s /application/nginx-1.10.3/ /application/nginx

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
	upstream web_01 {
		server 10.0.0.8:80;
	}
    server {
        listen       80;
        server_name blog.etiantian.org;
        location / {
            root   html;
            proxy_pass http://web_01;
            proxy_set_header Host ssss;
            proxy_set_header X-Forwarded-For xxxxxx;
        }
	}
}
EOF

sed -i 's#ssss#$host#g' /application/nginx/conf/nginx.conf && sed -i 's#xxxxxx#$remote_addr#g' /application/nginx/conf/nginx.conf

echo "/application/nginx/sbin/nginx" >> /etc/rc.local

/application/nginx/sbin/nginx -t && /application/nginx/sbin/nginx
