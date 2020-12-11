FROM ubuntu:20.04

LABEL maintainer="Rafael Meira <rafaelmeira@me.com>"

ENV DEBIAN_FRONTEND=noninteractive

# UPDATE AND INSTALL INITIAL PACKAGES
RUN apt-get update && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:ondrej/php -y && apt-get update

# INSTALL PACKAGES
RUN apt-get install -y \
    nginx \
    curl \
    git \
    wget \
    vim \
    cron \
    unzip \
    zip \
    libssl-dev \
    supervisor \
    php8.0-cli \
    php8.0-fpm \
    php8.0-bcmath \
    php8.0-bz2 \
    php8.0-common \
    php8.0-curl \
    php8.0-dba \
    php8.0-dev \
    php8.0-enchant \
    php8.0-gd \
    php8.0-gmp \
    php8.0-imap \
    php8.0-intl \
    php8.0-ldap \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-odbc \
    php8.0-opcache \
    php8.0-pgsql \
    php8.0-soap \
    php8.0-xml \
    php8.0-xsl \
    php8.0-zip \
    php8.0-redis

# INSTALL COMPOSER
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# COPY NGINX CONFIG
COPY nginx/mime.types /etc/nginx/mime.types
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# COPY PHP CONFIGS
COPY php/php.ini /etc/php/8.0/fpm/php.ini
COPY php/php-fpm.conf /etc/php/8.0/fpm/php-fpm.conf
COPY php/www.conf /etc/php/8.0/fpm/pool.d/www.conf
RUN mkdir /var/run/php && mkdir /var/log/php

# COPY CRONTAB CONFIGS
COPY crontabs/crontab /etc/crontab

# COPY SUPERVISOR CONFIG
COPY supervisor/supervisord.conf /etc/supervisord.conf

# CLEAN DIRECTORY AND AJUST PERMISSIONS
RUN rm -Rf /var/www/* && chmod -R 755 /var/www

# DEFINE WORKDIR
WORKDIR /var/www

# FINAL CLEAN UP 
RUN apt-get upgrade -y && apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

# EXPOSE PORTS
EXPOSE 80

# COPY SHELLSCRIPT
COPY scripts/init.sh /scripts/init.sh
RUN chmod +x /scripts/init.sh

# FINAL POINT
ENTRYPOINT ["/scripts/init.sh"]
