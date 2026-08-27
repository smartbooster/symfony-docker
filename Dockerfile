#syntax=docker/dockerfile:1.4

# Versions
ARG NODE_VERSION
ARG PHP_VERSION
FROM composer/composer:2.9-bin AS composer_upstream
FROM node:${NODE_VERSION}-alpine AS node

# php-fpm + Apache httpd wired through mod_proxy_fcgi:
# same topology as the Clever Cloud production runtime (Apache2 + PHP-FPM)
FROM php:${PHP_VERSION}-fpm-alpine AS php_base

# pipefail makes `curl ... | bash` fail the build when the download fails (hadolint DL4006)
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

EXPOSE 80
WORKDIR /app

# Apache + proxy_fcgi, dev tooling, PHP extension runtime libs runtime deps
# `apk upgrade` first (alpine counterpart of the Debian dist-upgrade): the official
# php:*-alpine images are rebuilt on their own cadence and keep shipping APK packages
# already fixed upstream, which osv-scanner then reports against the base layer.
# sudo is intentional (dockle DKL-DI-0001): this image is for development only,
# production runs on Clever Cloud. Devs need it from `make ssh`.
# suexec is dropped below: setuid root binary shipped by apache2, only useful for
# CGI run as another user, which this stack never does (PHP goes through FPM).
# hadolint ignore=DL3018
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    apache2 apache2-proxy \
    bash git jq make openssh-client-default sudo unzip zip \
    icu-libs icu-data-full libzip libsodium freetype libjpeg-turbo libpng \
    libstdc++ libx11 libxrender libxext fontconfig ttf-dejavu ttf-liberation

# PHP Extensions (build deps in a virtual package removed once compiled)
# $PHPIZE_DEPS must stay unquoted: it is a space separated package list
# hadolint ignore=DL3018,SC2086
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers \
    icu-dev libzip-dev libsodium-dev freetype-dev libjpeg-turbo-dev libpng-dev zlib-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" intl opcache pdo_mysql zip sodium gd exif \
    && pecl install xdebug \
    && apk del .build-deps

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"
COPY --from=composer_upstream --link /composer /usr/bin/composer

# Symfony CLI: static Go binary via the official installer (the cloudsmith apt repo is Debian-only)
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    && symfony version

# https://docs.blackfire.io/php/integrations/php-docker (musl build)
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s "https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version" \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so "$(php -r "echo ini_get ('extension_dir');")/blackfire.so" \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

# Install wkhtmltopdf: musl build maintained by https://github.com/Surnet/docker-wkhtmltopdf
# (upstream is archived and ships no musl binary).
# Third-party image pinned by digest: its tag could be repointed at any time, and
# wkhtmltopdf is frozen since 2020 so there is nothing to gain from following the tag.
# Digest of 3.23.4-0.12.6-small, to bump manually when upgrading.
COPY --from=surnet/alpine-wkhtmltopdf@sha256:af769681859fc7305e7f98eaffc55d6b9f65e1eefa490ba15201b3f0039b4ecb /bin/wkhtmltopdf /bin/wkhtmltopdf
RUN wkhtmltopdf -V

# Install Node et Yarn
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && node -v
# yarn 1.x is frozen upstream (classic line), pinning it is safe
RUN npm install -g yarn@1.22.22 && yarn -v \
    && npm cache clean --force && rm -rf /root/.npm

# Add dev user
ARG DEV_UID=1000
RUN adduser -D -s /bin/bash -u $DEV_UID dev \
    && mkdir -p /tmp/docker_xdebug/command && chown -R $DEV_UID:$DEV_UID /tmp/docker_xdebug/command \
    && addgroup dev wheel \
    && mkdir -p /etc/sudoers.d \
    && echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
COPY --link docker/.gitconfig /home/dev/.gitconfig
COPY --link docker/.gitignore_global /home/dev/.gitignore_global

# PHP config
COPY --link docker/.bashrc /home/dev/.bashrc
COPY --link docker/php/conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY --link docker/php/conf.d/xdebug.ini $PHP_INI_DIR/conf.d/

# Apache config: same project files as before, plus a glue conf wiring PHP-FPM
# through mod_proxy_fcgi and enabling the same modules as the Debian image
# (rewrite remoteip headers, plus logio required by the %O LogFormat placeholder).
# conf.d files load alphabetically: z1 (glue/Define) before z2/z3 which consume them.
COPY --link docker/apache/apache.conf /etc/apache2/conf.d/z2-app.conf
COPY --link docker/apache/vhost.conf /etc/apache2/conf.d/z3-vhost.conf
RUN sed -i \
        -e 's|^#LoadModule rewrite_module|LoadModule rewrite_module|' \
        -e 's|^#LoadModule remoteip_module|LoadModule remoteip_module|' \
        -e 's|^#LoadModule headers_module|LoadModule headers_module|' \
        -e 's|^#LoadModule logio_module|LoadModule logio_module|' \
        /etc/apache2/httpd.conf \
    && printf '%s\n' \
        'ServerName localhost' \
        'Define APACHE_LOG_DIR /var/log/apache2' \
        'DirectoryIndex index.php index.html' \
        '<FilesMatch "\.php$">' \
        '    SetHandler "proxy:fcgi://127.0.0.1:9000"' \
        '</FilesMatch>' \
        > /etc/apache2/conf.d/z1-fpm-glue.conf \
    && mkdir -p /app/public /var/log/apache2 \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && rm -f /usr/sbin/suexec \
    && httpd -t && php-fpm -t

# Probes the servers only, never the application: no `curl -f` here on purpose, so
# an HTTP 500 or 404 still counts as healthy. Only Apache not answering or php-fpm
# not listening marks the container unhealthy, which is what we want in development.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["sh", "-c", "curl -sS -o /dev/null http://127.0.0.1:80/ && nc -z 127.0.0.1 9000"]

CMD ["sh", "-c", "php-fpm -D && exec httpd -DFOREGROUND"]
