Установка:

https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+on+Red+Hat+distributions

sudo su
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install jenkins
service jenkins start

Настройка:

(пользователь сборщик проекта должен быть ec2-user, в противном случае не сможим закидывать файлы из phpStorm, так же возможны другие проблемы с правами)

//сновной конфиг (можно сменить порт, linux user, linux group)

sed 's/JENKINS_USER="jenkins"/JENKINS_USER="ec2-user"/g' /etc/sysconfig/jenkins > /tmp/jenkins.txt && yes | cp -Rf /tmp/jenkins.txt /etc/sysconfig/jenkins && echo "\n"

sed 's/JENKINS_GROUP="jenkins"/JENKINS_GROUP="ec2-user"/g' /etc/sysconfig/jenkins > /tmp/jenkins.txt && yes | cp -Rf /tmp/jenkins.txt /etc/sysconfig/jenkins && echo "\n"

// при смене пользователя

chown -R ec2-user:ec2-user /var/lib/jenkins
chown -R ec2-user:ec2-user /var/log/jenkins
chown -R ec2-user:ec2-user /var/cache/jenkins

Перезагрузка:

/etc/init.d/jenkins restart or systemctl restart jenkins

Первый вход:
При первом входе потребуется ввести пароль администратора дженкинс
Данный пароль генерится автоматически и находится в файле:
/var/lib/jenkins/secrets/initialAdminPassword

Сброс пароля (КРАЙНЕ НЕ РЕКОМЕНДУЕТСЯ - только если согласовать с руководством, так как):

Если по своему паролю не войти!!!

nano /var/lib/jenkins/config.xml

// отключаем систему авторизации

// изменяем значение  <useSecurity>true</useSecurity>

// на  <useSecurity>false</useSecurity>

service jenkins reload

// делаем все что нужно (к примеру заводим новых пользователей) и возвращаем все назад



Переустановка дженкинс:

При переустановке мы можем получить ошибку следующего вида:

Error downloading packages:
jenkins-2.171-1.1.noarch: Errno 256 No more mirrors to try.

Значит у нас закешировался устаревший репозиторий. Нужно выполнить следующие команды:

# rm -rf /etc/yum.repos.d/jenkins.repo
# rm -fr /var/cache/yum/*
# yum clean all
После этого нужно будет с чистого листа установить дженкинс.

Перенос дженкинса на поддомен и установка SSL сертификата:

Создадим конфиг для jenkins
touch /etc/nginx/sites_enabled/jenkins.conf

Со следующим содержимым (в качестве примера использан домен jenkins-reviews.devmegabonus.com):

server {

    listen 80;

    location ~ ^/(.well-known/acme-challenge/.*)$ {

        proxy_pass http://127.0.0.1:9999/$1;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header Host $http_host;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    }



    server_name www.jenkins-reviews.devmegabonus.com jenkins-reviews.devmegabonus.com;

    if ($access = 0){

        return 403;

    }

#    error_page 500 501 502 503 504 /50x.html;



    rewrite ^(.*) https://jenkins-reviews.devmegabonus.com$1 permanent;

}



server {

   server_name jenkins-reviews.devmegabonus.com;



   listen 443 ssl; # managed by Certbot

   ssl_certificate /etc/letsencrypt/live/jenkins-reviews.devmegabonus.com/fullchain.pem;

   ssl_certificate_key  /etc/letsencrypt/live/jenkins-reviews.devmegabonus.com/privkey.pem;



   # Improve HTTPS performance with session resumption

   ssl_session_cache shared:SSL:10m;

   ssl_session_timeout 5m;



   # Enable server-side protection against BEAST attacks

   ssl_prefer_server_ciphers on;

   ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;





   # Disable SSLv3

   ssl_protocols TLSv1 TLSv1.1 TLSv1.2;



   # Diffie-Hellman parameter for DHE ciphersuites

   # $ sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

   ssl_dhparam /etc/ssl/certs/dhparam.pem;



   # Enable HSTS (https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security)

   add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";



   # Enable OCSP stapling (http://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox)

   ssl_stapling on;

   ssl_stapling_verify on;

   ssl_trusted_certificate /etc/letsencrypt/live/jenkins-reviews.devmegabonus.com/fullchain.pem;

   resolver 8.8.8.8 8.8.4.4 valid=300s;

   resolver_timeout 5s;

    location / {

        proxy_set_header    Host $host;

        proxy_set_header    X-Real-IP $remote_addr;

        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header    X-Forwarded-Proto $scheme;



        proxy_pass http://127.0.0.1:8080;

        proxy_read_timeout 90;



        proxy_redirect http://127.0.0.1:8080 https://jenkins-reviews.devmegabonus.com;

    }

}

Временно отключаем 443 порт, и редирект на 403 порт и все опции связанные с SSL.
Настраиваем для сертификат для поддомена:
Let’s Encrypt on CentOS 6.5 (red hat) - установка/возобновление SSL сертификата

Убираем комменты c 403 порта и SSL параметров.

в файле конфигурации дженкинса
sudo nano /etc/sysconfig/jenkins
Изменяем содержимое параметра JENKINS_ARGS (в самом конце) на:
JENKINS_ARGS="–httpListenAddress=127.0.0.1"

Перезагружаем дженкинс
service jenkins restart

Установка и настройка дополнений (https://habr.com/ru/post/80110/)
1 - Ставим плагины в Jenkins

java -jar jenkins-cli.jar -s http://localhost:8080 -auth <ИМЯ ПОЛЬЗОВАТЕЛЯ>:<ТОКЕН ПОЛЬЗОВАТЕЛЯ (генерится в настройках пользователя)> install-plugin checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations warnings xunit

1.1. - при возникновении ошибки

Unable to access jarfile jenkins-cli.jar
решение тут https://stackoverflow.com/questions/17579554/how-to-resolve-the-error-unable-to-access-jarfile-jenkins-cli-jar/17680175

2 - Добавить в корневую деррикторию проекта файл сборки Ant + composer.json + папка build (сборка настроена на структуру проекст в папке project)


build.xml
composer.json
build.zip

3 - в настройках Jenkins включить представление описания  в html



4 - добавить в описание проекта код

{code}

<div>
<a href='ws/build/pdepend/overview-pyramid.svg'><img src="ws/build/pdepend/overview-pyramid.svg" type="image/svg+xml" width="600px"/></a>

<a href='ws/build/pdepend/dependencies.svg'><img src="ws/build/pdepend/dependencies.svg" type="image/svg+xml" width="600px" /></a>
</div>
<div>

<a href="https://habr.com/ru/post/80110/">Как это понимать </a>
</div>

{code}

5 - настроить composer install для composer.json в корне проекта

6 - настраиваем phpUnit следующим образом:

cd project
# unit tests
./vendor/bin/phpunit -d display_errors=On -d memory_limit=-1 --log-junit ../build/logs/junit.xml --coverage-crap4j ../build/logs/crap4j.xml

(не забываем добавить послесборочную операцию phpUnit и указать актуальный путь к артефакту phpunit /build/logs/junit.xml)

7 - добавляем последний шаг сборки проекта из под Ant (все артефакты по анализу кода будут собраны на этом этапе)



8 - включаем анализ артефактов
