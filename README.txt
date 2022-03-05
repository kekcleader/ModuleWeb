How to write a simple web site in Oberon.

# Setting up Apache2 + CGI + Free Oberon

1. Use [Free Oberon](https://free.oberon.org/en)
   to compile `ModuleWeb`
   (and possibly rename the executable to `index.exe`).
2. Create `/var/www/moduleweb`.
3. Put executable file `index.exe` there
   or create a symbolic link:
   `ln -s /var/www/moduleweb/index.exe ~/FreeOberon/bin/ModuleWeb`
4. Set correct access to files and directories.
5. In `/etc/hosts` write `127.0.0.1 moduleweb.cccp`.
6. Switch on the modules Apache2: `a2enmod rewrite`, `a2enmod cgi`.
7. Create `/etc/apache2/sites-available/moduleweb.conf`
   (see the contents in a separate file).
8. Enable the site: `a2ensite moduleweb` and restart Apache.
9. Open in a browser http://moduleweb.cccp

=======

Как написать простой сайт на Обероне.

# Настройка Apache2 + CGI + Free Oberon

1. С помощью [Free Oberon](https://free.oberon.org)
   скомпилировать `ModuleWeb`
   (и, возможно, переименовать исполнимый файл в `index.exe`).
2. Создать `/var/www/moduleweb`.
3. Поместить туда исполнимый файл `index.exe`
   или создать символическую ссылку:
   `ln -s /var/www/moduleweb/index.exe ~/FreeOberon/bin/ModuleWeb`
4. Установить правильные доступы к файлам и каталогам.
5. В `/etc/hosts` прописать `127.0.0.1 moduleweb.cccp`
6. Включить модули Apache2: `a2enmod rewrite`, `a2enmod cgi`
7. Создать `/etc/apache2/sites-available/moduleweb.conf`
   (см. содержимое в отдельном файле).
8. Включить сайт: `a2ensite moduleweb` и перезагрузить Apache.
9. Открыть в обозревателе http://moduleweb.cccp
