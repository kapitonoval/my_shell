#!/bin/bash
yum remove httpd* php*

rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

service nginx stop

yum -y install --skip-broken php71 php71-php php71-php-fpm php71-php-mysqli php71-soap php71-mysqlnd php71-xml php71-php-xml php71-xmlrpc php71-mbstring -y

echo "short_open_tag=On" >> /etc/php.ini

echo "short_open_tag=On" >> /etc/opt/remi/php71/php.ini

# добавляем в автозагрузку

chkconfig php71-php-fpm on

#сменить пользователя и группу на ec2-user
sed 's/user = apache/user = ec2-user/g'  /etc/opt/remi/php71/php-fpm.d/www.conf > t.conf && sed 's/group = apache/group = ec2-user/g'  t.conf > /etc/opt/remi/php71/php-fpm.d/www.conf
rm -f t.conf

#запуск php-fpm

service php71-php-fpm start
#скопировать конфиг /etx/nginx/sites-avaible/alibonus.conf на PROD



service nginx start
#//запуск nginx

# переустановить sphinx
cp /etc/sphinx/sphinx.conf ~/;

yum remove sphinx

yum install sphinx

cp ~/sphinx.conf /etc/sphinx/sphinx.conf

rm ~/sphinx.conf

service searchd start

indexer --rotate --config /etc/sphinx/sphinx.conf --all