- копирование потока вывода в буфер обмена

`yum install xclip`

`alias "c=xclip"`
`alias "v=xclip -o"`

Terminal 1:<br>
`pwd | c`

Terminal 2:<br>
`cd `v` https://stackoverflow.com/questions/5130968/how-can-i-copy-the-output-of-a-command-directly-into-my-clipboard`

- вставить в файл из буфера<br>
`cat > file_name`

- мониторинг соединений с сервером<br>
`watch -n1 ‘ss -tan | awk ‘\’‘{print $1}‘\’' | sort |  uniq -c’`

- вывод списка папок с размерами <br>
`du -chs .[!.]* * | sort -h`