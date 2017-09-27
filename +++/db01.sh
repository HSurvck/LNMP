#!/bin/bash

test -f /usr/sbin/ntpdate || yum -y install ntpdate
echo "*/5 * * * * /usr/sbin/ntpdate 172.16.1.61 >/dev/null 2>&1" > /var/spool/cron/root
sed -i "21a\server 172.16.1.61 prefer" /etc/ntp.conf

mkdir -p /application

if [ -f /server/tools/mysql-5.6.34-linux-glibc2.5-x86_64.tar.gz ]
then
	cd /server/tools/ && tar xf mysql-5.6.34-linux-glibc2.5-x86_64.tar.gz
	
	egrep "^mysql.*/sbin/nologin$" /etc/passwd || useradd -s /sbin/nologin  -M mysql

	mv /server/tools/mysql-5.6.34-*-x86_64 /application/mysql-5.6.34
	
	cd && ln -s /application/mysql-5.6.34/ /application/mysql
	
	chown -R mysql.mysql /application/mysql/data
	
	/application/mysql/scripts/mysql_install_db --basedir=/application/mysql --datadir=/application/mysql/data --user=mysql
	
	cp /application/mysql/support-files/mysql.server  /etc/init.d/mysqld
	
	chmod +x /etc/init.d/mysqld
	
	sed -i 's#/usr/local/mysql#/application/mysql#g' /application/mysql/bin/mysqld_safe /etc/init.d/mysqld
	
	cp /application/mysql/support-files/my-default.cnf /etc/my.cnf
	
	chkconfig --add mysqld && chkconfig mysqld on
	
	/etc/init.d/mysqld start
	
else

	mkdir /server/tools/ -p && cd /server/tools/
	
	wget --tries=0 ftp://ftp.jaist.ac.jp/pub/mysql/Downloads/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz && \
	tar  xf mysql-5.6.36-linux-glibc2.5-x86_64.tar.gz
	
	egrep "^mysql.*/sbin/nologin$" /etc/passwd || useradd -s /sbin/nologin  -M mysql

	mv /server/tools/mysql-5.6.36-*-x86_64 /application/mysql-5.6.36
	
	ln -s /application/mysql-5.6.36/ /application/mysql
	
	chown -R mysql.mysql /application/mysql/data
	
	/application/mysql/scripts/mysql_install_db --basedir=/application/mysql --datadir=/application/mysql/data --user=mysql
	
	cp /application/mysql/support-files/mysql.server  /etc/init.d/mysqld
	
	chmod +x /etc/init.d/mysqld
	
	sed -i 's#/usr/local/mysql#/application/mysql#g' /application/mysql/bin/mysqld_safe /etc/init.d/mysqld
	
	cp /application/mysql/support-files/my-default.cnf /etc/my.cnf
	
	chkconfig --add mysqld && chkconfig mysqld on
	
	/etc/init.d/mysqld start

fi

/application/mysql/bin/mysql -u root -e "create database wordpress;"
/application/mysql/bin/mysql -u root -e "grant all privileges on wordpress.* to 'wordpress'@'10.0.0.%' identified by '123456';"
/application/mysql/bin/mysql -u root -e "create database dedecms;"
/application/mysql/bin/mysql -u root -e "grant all privileges on dedecms.* to 'dedecms'@'10.0.0.%' identified by '123456';"
/application/mysql/bin/mysql -u root -e "create database discuz;"
/application/mysql/bin/mysql -u root -e "grant all privileges on discuz.* to 'discuz'@'10.0.0.%' identified by '123456';"
/application/mysql/bin/mysql -u root -e "grant select,delete,update,create,drop on *.* to 'prow'@'10.0.0.%' identified by '123456'"

