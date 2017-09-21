mkdir -p /server/tools && cd /server/tools && \
wget --tries=0 https://files.phpmyadmin.net/phpMyAdmin/4.7.4/phpMyAdmin-4.7.4-all-languages.zip && \
unzip phpMyAdmin-4.7.4-all-languages.zip -d /application/nginx/html/www/ && \
cd /application/nginx/html/www/ && mv phpMyAdmin-4.7.4-all-languages phpmyadmin

sed -i "39d ; 38a\$cfg['PmaAbsoluteUri'] = '//www.etiantian.org/phpmyadmin';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php
sed -i "94d ; 93a\$cfg['blowfish_secret'] = '1116';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php
sed -i "117d ; 116a\$cfg['Servers'][\$i]['host'] = '10.0.0.51';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php
sed -i "124d ; 123a\$cfg['Servers'][\$i]['port'] = '3306';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php
sed -i "248d ; 247a\$cfg['Servers'][\$i]['user'] = 'prow';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php
sed -i "255d ; 254a\$cfg['Servers'][\$i]['password'] = '123456';" /application/nginx/html/www/phpmyadmin/libraries/config.default.php

#  39 $cfg['PmaAbsoluteUri'] = '';
#  94 $cfg['blowfish_secret'] = '';
# 117 $cfg['Servers'][$i]['host'] = 'localhost';
# 124 $cfg['Servers'][$i]['port'] = '';
# 234 $cfg['Servers'][$i]['auth_type'] = 'cookie';
# 248 $cfg['Servers'][$i]['user'] = 'root';
# 255 $cfg['Servers'][$i]['password'] = '';