- копирование потока вывода в буфер обмена

`yum install xclip`

`alias "c=xclip"`
`alias "v=xclip -o"`

Terminal 1:
`pwd | c`

Terminal 2:
`cd `v` https://stackoverflow.com/questions/5130968/how-can-i-copy-the-output-of-a-command-directly-into-my-clipboard`

- вставить в файл из буфера
`cat > file_name`

- мониторинг соединений с сервером
`watch -n1 ‘ss -tan | awk ‘\’‘{print $1}‘\’' | sort |  uniq -c’`