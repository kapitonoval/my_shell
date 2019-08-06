#!/bin/bash


##############
# Установка зависимостей
##############
yum -y update
yum -y install python

yum clean all
yum -y install epel-release
yum -y update

##############
# Должен быть установлен nginx
# домен должен быть сконфигурирован в nginx на 80 порту
##############
yum -y install nginx

##############
# Установка pip
##############
yum -y install python-pip
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py
pip -V

pip install cryptography

##############
# Установка Cert Bot
##############
wget -r --no-parent -A 'epel-release-*.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/

rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm

yum-config-manager --enable epel*

yum  -y install certbot python2-certbot-nginx

##############
# Добавление задачи на автообновление в crontab из под root
##############
crontab -l > mycron
echo "39 1,13 * * * certbot renew --no-self-upgrade" >> mycron
crontab mycron
rm mycron

#установка сертификата (выбрать домен без WWW и следовать инструкциям)
certbot --nginx

