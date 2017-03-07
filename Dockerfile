# Version: 1.0.0
FROM centos:centos6.6
MAINTAINER xiaozhi "xiaozhihsu@gmail.com"
RUN yum -y install gcc gcc-c++ autoconf automake make
RUN yum -y install pcre*
RUN yum -y install openssl*
RUN yum -y install initscripts
RUN yum -y install libxml2 libxml2-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel curl curl-devel php-mcrypt libmcrypt libmcrypt-devel openssl-devel gd

#install libmcrypt
RUN curl http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz  >> /usr/local/src/libmcrypt-2.5.8.tar.gz
RUN mkdir /usr/local/src/libmcrypt-2.5.8
RUN tar -xvf /usr/local/src/libmcrypt-2.5.8.tar.gz -C  /usr/local/src/
RUN cd /usr/local/src/libmcrypt-2.5.8 && ./configure && make && make install

#install nginx
RUN curl http://nginx.org/download/nginx-1.7.8.tar.gz >> /usr/local/src/nginx-1.7.8.tar.gz
RUN mkdir /usr/local/src/nginx-1.7.8
RUN tar -xvf  /usr/local/src/nginx-1.7.8.tar.gz -C /usr/local/src/
RUN cd /usr/local/src/nginx-1.7.8 && ./configure --prefix=/usr/local/nginx-1.7.8 \
--with-http_ssl_module --with-http_spdy_module \
--with-http_stub_status_module --with-pcre &&  make && make install
RUN mv /usr/local/nginx-1.7.8/conf/nginx.conf /usr/local/nginx-1.7.8/conf/nginx.conf.bak
ADD nginx.conf /usr/local/nginx-1.7.8/conf/nginx.conf

#install mysql
RUN groupadd mysql
RUN useradd -g mysql mysql
RUN mkdir /data
RUN mkdir /data/mysql5.5
RUN mkdir /usr/local/mysql5.5
RUN chmod 777 /data/mysql5.5
RUN chown -R mysql:mysql /usr/local/mysql5.5
RUN yum -y install cmake ncurses-devel bison
RUN curl  http://mirrors.sohu.com/mysql/MySQL-5.5/mysql-5.5.54.tar.gz  >> /usr/local/src/mysql-5.5.54.tar.gz
RUN mkdir /usr/local/src/mysql-5.5.54
RUN tar -xvf /usr/local/src/mysql-5.5.54.tar.gz -C /usr/local/src/
RUN cd /usr/local/src/mysql-5.5.54 && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql5.5 -DMYSQL_DATADIR=/data/mysql5.5 -DSYSCONFDIR=/etc \
&& make && make install
RUN rm -rf /etc/my.cnf
RUN ln -s /usr/local/mysql5.5/my.cnf /etc/my.cnf

RUN cd /usr/local/mysql5.5/scripts && ./mysql_install_db --user=mysql --basedir=/usr/local/mysql5.5 --datadir=/data/mysql5.5/

#add mysqld to boot
RUN cp /usr/local/mysql5.5/support-files/mysql.server /etc/init.d/mysqld
RUN chkconfig mysqld on


#install php5.5
RUN curl http://cn.php.net/distributions/php-5.5.38.tar.gz  >> /usr/local/src/php-5.5.38.tar.gz
RUN mkdir /usr/local/src/php-5.5.38
RUN tar -xvf /usr/local/src/php-5.5.38.tar.gz -C /usr/local/src/
RUN cd /usr/local/src/php-5.5.38 && ./configure --prefix=/usr/local/php5.5 --with-config-file-path=/usr/local/php5.5/etc --with-mysql --with-mysqli --with-pdo_mysql  --with-gd --with-iconv --with-zlib --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-pear --with-gettext --enable-session --with-mcrypt --with-curl --with-libxml-dir=/usr/lib64  --with-jpeg-dir --with-freetype-dir \
&& make && make install
RUN cp /usr/local/php5.5/etc/php-fpm.conf.default /usr/local/php5.5/etc/php-fpm.conf

#set phpinfo page for test
RUN mkdir /www/
RUN echo '<?php phpinfo(); ?>' >> /www/index.php

#add to PHP TO PATH
ENV PATH "$PATH:$HOME/bin:/usr/local/php5.5/bin"

#install supervisor
RUN yum -y install python-setuptools
RUN easy_install pip
RUN pip install supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
