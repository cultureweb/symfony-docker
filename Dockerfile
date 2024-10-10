# Dockerfile for building a CakePHP application

FROM php:8.2-apache-bookworm

# Met à jour le système et installe les dépendances de base
RUN apt-get -y update && apt-get install -y \
    wget \
    git \
    zip \
    unzip \
    nano \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libxml2-dev \
    zlib1g-dev \
    libicu-dev  # Ajout de libicu-dev pour l'extension intl

# Crée un utilisateur 'deployer' avec un répertoire personnel
RUN useradd -m deployer

# Installation de Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Installation des extensions PHP requises pour CakePHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql

# Installation de l'extension intl
RUN apt-get install -y libicu-dev \
    && docker-php-ext-install intl

# Configuration d'Apache
RUN a2enmod rewrite

# Mise à jour du DocumentRoot pour CakePHP
RUN sed -i "s/DocumentRoot .*/DocumentRoot \/var\/www\/html\/public/" /etc/apache2/sites-available/000-default.conf

# Copie le code source dans le conteneur (ajuste le chemin selon ton projet)
COPY . /var/www/html/

# Change le propriétaire des fichiers à l'utilisateur 'deployer'
RUN chown -R deployer:deployer /var/www/html

# Passe à l'utilisateur 'deployer'
USER deployer

# Expose le port 80
EXPOSE 80

# Commande pour démarrer Apache
CMD ["apache2-foreground"]
