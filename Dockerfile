# Dockerfile for a dev web server with PHP/Apache

FROM php:7.4-apache

# GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications
RUN apt-get -y update && apt-get install -y wget gnupg

# install Node.js on Ubuntu or Debian
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

# Other dependencies for PHP 7. Add any missing ones from configure script
# complaints, plus some LAMP needs too.
RUN rm /etc/apt/preferences.d/no-debian-php && \
apt-get -y update && apt-get install -y \
git \
zip \
unzip \
nodejs \
mcrypt \
zlib1g-dev \
libgmp-dev \
libpng-dev \
libxml2-dev \
libxrender1 \
libfontconfig1 \
libz-dev libzip-dev \
php-soap \
yarn \
nano \
vim \
libfontconfig1 \
libxrender1 \
libwebp-dev \
libjpeg62-turbo-dev \
libpng-dev \
zlib1g-dev \
libicu-dev \
g++

RUN docker-php-ext-configure gd

# PECL makes it easy to create shared PHP extensions. 
RUN pecl install apcu zlib \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap zip gd \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp opcache

# Composer is a tool for dependency management in PHP, written in PHP. It allows you to declare the libraries your project depends on and it will manage (install/update) them for you.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN yes | pecl install xdebug-2.9.8 \
	&& echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions

RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN a2enmod rewrite

RUN mkdir /root/.ssh

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf

# Xdebug is an extension for PHP, and provides a range of features to improve the PHP development experience. 
COPY xdebug_state.sh /usr/bin/xdebug_state
RUN chmod +x /usr/bin/xdebug_state

# Installing the symfony CLI Tool
RUN  wget https://get.symfony.com/cli/installer -O - | bash
RUN  mv /root/.symfony/bin/symfony /usr/local/bin/symfony

RUN apt install -y python3-pip python3-dev libffi-dev

RUN pip3 install awsebcli --upgrade --user
ENV PATH=~/.local/bin:$PATH
