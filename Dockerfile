FROM php:7.2-fpm

MAINTAINER "Tiago Sampaio <tiago@tiagosampaio.com>"

# Add Scripts directory
ADD scripts/ /var/scripts/

RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    libicu-dev \
    libxml2-dev libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    default-mysql-client \
    ocaml \
    expect \
    apt-utils \
    sudo \
    cron \
    curl \
    unzip \
    wget \
    vim \
        && echo "syntax on" >> ~/.vimrc \
        && echo "filetype plugin indent on" >> ~/.vimrc \
        && echo "set number" >> ~/.vimrc \
        && echo "set laststatus=2" >> ~/.vimrc \
        && echo "set ruler" >> ~/.vimrc \
        && echo "set term=xterm-256color" >> ~/.vimrc \
        && echo "alias ll=\"ls -lah\"" >> ~/.bashrc \
        && echo "alias m2=\"php bin/magento\"" >> ~/.bashrc

RUN apt-get install -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-install -j$(nproc) intl xsl gd zip pdo_mysql opcache soap bcmath json iconv \
    && pecl install xdebug && docker-php-ext-enable xdebug \
        && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_host=127.0.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.max_nesting_level=1000" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
        && chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# PHP config
ADD conf/php.ini /usr/local/etc/php/conf.d/zzz-docker.ini

#EXPOSE 80 22 5000 44100 9000
WORKDIR /var/www/html/magento2

RUN mkdir -p /var/www/html/magento2 \
    && chown -R www-data: /var/www/html/magento2 \
    && chmod -R g+s /var/www/html/magento2

USER root

#ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]