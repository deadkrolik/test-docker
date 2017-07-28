FROM ubuntu:xenial
MAINTAINER Andreev Pavel

ENV DEBIAN_FRONTEND noninteractive

RUN PACKAGES_TO_INSTALL="sudo curl git cron vim zip php7.0-dev composer php-xdebug php7.0-mbstring php7.0-bcmath php7.0-curl php7.0-fpm nginx supervisor php7.0-mysql php7.0-mongodb openssh-server mc" && \
    apt-get update && \
    apt-get install -y $PACKAGES_TO_INSTALL

RUN curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash && \
    apt-get install -y php7.0-phalcon

# ssh
RUN mkdir /var/run/sshd
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# configure NGINX as non-daemon
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# configure php-fpm as non-daemon
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf

# add a phpinfo script for INFO purposes
RUN echo "<?php phpinfo();" >> /var/www/html/index.php

# NGINX mountable directories for config and logs
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]

# NGINX mountable directory for apps
VOLUME ["/var/www"]

# copy config file for Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# backup default default config for NGINX
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# copy local defualt config file for NGINX
COPY nginx-site.conf /etc/nginx/sites-available/default

# php7.0-fpm will not start if this directory does not exist
RUN mkdir /run/php

# NGINX ports
EXPOSE 80 443 22

CMD ["/usr/bin/supervisord"]
