# Dockerfile for a dev web server with PHP/Apache

FROM php:8.2-apache-bookworm

# GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications
RUN apt-get -y update && apt-get install -y wget gnupg

# install Node.js on Ubuntu or Debian
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Gitlab-Runner
RUN curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN tar vxf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
RUN cp wkhtmltox/bin/wk* /usr/local/bin/

# Other dependencies for PHP 8. Add any missing ones from configure script
RUN rm /etc/apt/preferences.d/no-debian-php && \
apt-get -y update && apt-get install -y \
git \
zip \
unzip \
nodejs \
mcrypt \
zlib1g-dev \
libgmp-dev \
libfontconfig1 \
libxrender1 \
libxml2-dev \
libxslt-dev \
php-soap \
yarn \
gitlab-runner \
libz-dev libzip-dev \
nano \
libfontconfig1 \
libxrender1 \
libwebp-dev \
libjpeg62-turbo-dev \
libpng-dev \
libfreetype6-dev \
zlib1g-dev \
libicu-dev \
php-exif \
exiftool \
g++

# Exif - PHP
RUN docker-php-ext-configure exif \
&& docker-php-ext-install exif \
&& docker-php-ext-enable exif

# GD - PHP
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN docker-php-ext-install gd

# XSL - PHP
RUN docker-php-ext-configure xsl \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap zip gd xsl intl \
&& docker-php-ext-install -j$(nproc) gmp opcache

# PECL makes it easy to create shared PHP extensions.
RUN pecl install apcu \
&& docker-php-ext-install -j$(nproc) pdo_mysql \
&& docker-php-ext-install soap zip xsl intl \
&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h \
&& docker-php-ext-install -j$(nproc) gmp opcache

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Python3 => pip
RUN apt install -y python3-pip python3-dev libffi-dev
ENV PATH=~/.local/bin:$PATH
RUN pip3 install --upgrade pip

# Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli -y

# WeasyPrint
RUN apt-get install -y python3-cffi libpango-1.0-0 libpangoft2-1.0-0 libcairo2-dev libpangocairo-1.0-0
RUN pip install weasyprint==52.5
RUN ln  /usr/local/bin/weasyprint /usr/bin

# XDebug
RUN yes | pecl install xdebug \
	&& echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

# Xdebug_state
COPY xdebug_state.sh /usr/bin/xdebug_state
RUN chmod +x /usr/bin/xdebug_state

# Creation dossier sessions
RUN mkdir -p /var/lib/php/sessions && chown -R www-data.www-data /var/lib/php/sessions
# Creation dossier symfony
RUN mkdir -p /tmp/symfony && chown -R www-data.www-data /tmp/symfony

RUN a2enmod rewrite

RUN mkdir /root/.ssh

RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf
