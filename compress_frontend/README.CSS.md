# Сжатие js / css
**а) обновим библиотеки NodeJs и NPM**
`sudo su`
- проверяем версии node и npm

`node -v`

`npm -v`

- убиваем старые версии

`yum remove npm`

`yum remove node`

`cd /tmp`

- ставим nvm

`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash`

`nvm install node`

- проверяем новые версии node и npm

`node -v`

`npm -v`

**б). Установим пакеты NPM необходимые для сжатия css и js файлов**

ставить будем локально относительно проекта, так что ставим из каталога проекта



`/var/www/project`

`cd /var/www/project`

`sudo su`

`npm install node-cron gulp gulp-uglify pump gulp-rename gulp-cssmin`



**в). установим диспечер процессов PM2  http://pm2.keymetrics.io/**

- выполнить в консоли:

`npm install pm2 -g`



- требуется для запуска скрипта js

- исполняет роль daemon(а) следящего за статусом скрипта

- при падении скрипта следит за его перезапуском

- обладает удобным интерфейсом отслеживания запущенных скриптов, потребления ими памяти и т.д. ( cmd: pm2 monit )

мониторинг запущенных в pm2 скриптов в соответствии с описанием на http://pm2.keymetrics.io/ или по команде:

`pm2 monit`


**г). напишем скрипт минифицирующий наши файлы npm-cron.js (файл в репозитории)**

**д). запуск скрипта отвечающего за пережатие файлов**

тут я наткнулся на не очень приятную вещь,  CRON не может запустить команду gulp, именно поэтому в скрипте использован модуль node-cron



`sudo su`

`cd /var/www/project`

`pm2 start npm-cron.js`

#смотрим что у нас все работает

`pm2 monit`
