#syntax=docker/dockerfile:1.4

# Versions
ARG NODE_VERSION
ARG PHP_VERSION
FROM composer/composer:2-bin AS composer_upstream
FROM node:${NODE_VERSION} AS node
FROM php:${PHP_VERSION}-apache AS php_base

EXPOSE 80
WORKDIR /app

# Install lib utility
RUN apt-get update -qq && \
    apt-get install -qy \
    git \
    gnupg \
    libicu-dev \
    libzip-dev \
    unzip \
    zip \
    sudo \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libsodium-dev \
    zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"
COPY --from=composer_upstream --link /composer /usr/bin/composer

# PHP Extensions
RUN docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) intl opcache pdo_mysql zip sodium gd

# Install PHP Xdebug configuration, (see https://blog.eleven-labs.com/fr/debugger-avec-xdebug/)
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# https://symfony.com/download
RUN  curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' |  bash
RUN  apt install symfony-cli

# Install Node et Yarn https://stackoverflow.com/questions/44447821/how-to-create-a-docker-image-for-php-and-node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
RUN node -v

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN sudo apt-get update && apt-get install --no-install-recommends -y yarn

# Cleaning
RUN apt-get autoremove -y --purge \
    && apt-get clean \
    && rm -Rf /tmp/*

# Add dev user
RUN useradd --shell /bin/bash -u 1000 -o -c "" -m dev
RUN export HOME=/home/dev
RUN adduser dev sudo

# PHP config
COPY --link docker/.bashrc /home/dev/.bashrc
COPY --link docker/php/conf.d/app.ini $PHP_INI_DIR/conf.d/

# Apache config
COPY --link docker/apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY --link docker/apache/apache.conf /etc/apache2/conf-available/z-app.conf

# WIP Extra Dockerfile instruction
#RUN if [ -x ./dockerfile_extra.sh ]; then \
#      dockerfile_extra.sh; \
#    fi

RUN a2enmod rewrite remoteip && \
    a2enconf z-app \
