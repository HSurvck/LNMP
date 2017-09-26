#!/bin/bash

test -f /usr/bin/ruby || yum -y install ruby ; test -f /usr/bin/gem ||yum -y install rubygems ; test -f /usr/lib64/libruby.so || yum -y install ruby-devel

gem source -a http://mirrors.aliyun.com/rubygems/ -r http://rubygems.org/

gem install json -v 1.7.7

gem install cabin -v 0.6

gem install backports -v 2.6.2

gem install arr-pm -v 0.0.9

gem install clamp -v 0.6

gem install fpm -v 1.3.3

mkdir /server/tools/ -p

sed -i 's#keepcache=0#keepcache=1#g' /etc/yum.conf

find /var/cache/ -type f -name '*rpm' -delete

yum install pcre pcre-devel openssl openssl-devel -y

find /var/cache/ -type f -name '*rpm'|xargs cp -t /tmp/

cd /tmp/ && tar zcf nginx_yum.tar.gz *.rpm

useradd www -M -s /sbin/nologin 

cd /server/tools/ && test -f nginx-1.10.3.tar.gz || \
wget --tries=0 http://nginx.org/download/nginx-1.10.3.tar.gz && \
tar xf nginx-1.10.3.tar.gz

cd nginx-1.10.3 && ./configure --prefix=/application/nginx-1.10.3 --user=www --group=www --with-http_ssl_module --with-http_stub_status_module 

make && make install

cd && ln -s /application/nginx-1.10.3/ /application/nginx

mkdir /server/scripts -p
cd /server/scripts/

cat >> nginx_rpm.sh <<EOF
#!/bin/bash
useradd nginx -M -s /sbin/nologin
ln -s /application/nginx-1.10.3/ /application/nginx
EOF

#cat > after_remove.sh <<EOF
##!/bin/bash
#rm -rf /usr/local/nginx
#rm -f /etc/rc.d/init.d/nginx
#EOF

fpm -s dir -t rpm -n nginx -v 1.10.3 -d 'pcre,pcre-devel,openssl,openssl-devel' --post-install /server/scripts/nginx_rpm.sh -f /application/nginx-1.10.3/




