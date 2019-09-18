FROM php:7.2-fpm

MAINTAINER "Tiago Sampaio <tiago@tiagosampaio.com>"

ENV MAGE_DIR=/var/www/html/magento2 \
    USE_SHARED_WEBROOT=1 \
    SHARED_CODE_PATH=$MAGE_DIR \
    WEBROOT_PATH=$MAGE_DIR \
    MAGENTO_ENABLE_SYNC_MARKER=0 \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_DATABASE=magento \
    MYSQL_USER=magento \
    MYSQL_PASSWORD=magento \
    MAGENTO_DOMAIN=dev.magento2.com \
    MAGENTO_ADMIN_FRONTNAME=admin \
    MAGENTO_ADMIN_FIRSTNAME=admin \
    MAGENTO_ADMIN_LASTNAME=admin \
    MAGENTO_ADMIN_EMAIL=admin@example.com \
    MAGENTO_ADMIN_USER=admin \
    MAGENTO_ADMIN_PASSWORD=admin123 \
    MAGENTO_LANGUAGE=en_US \
    MAGENTO_CURRENCY=USD \
    MAGENTO_TIMEZONE=America/Sao_Paulo \
    MAGENTO_USE_REWRITES=1 \
    UNISON_VERSION=2.51.2

RUN apt-get update && apt-get install -y \
    libmcrypt-dev \
    libicu-dev \
    libxml2-dev libxslt1-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    default-mysql-client \
    ocaml \
    expect \
    apt-utils \
    sudo \
    cron \
    curl \
    unzip \
    wget \
    supervisor \
    procps \
    vim \
        && echo "syntax on" >> ~/.vimrc \
        && echo "filetype plugin indent on" >> ~/.vimrc \
        && echo "set number" >> ~/.vimrc \
        && echo "set laststatus=2" >> ~/.vimrc \
        && echo "set ruler" >> ~/.vimrc \
        && echo "set term=xterm-256color" >> ~/.vimrc \
        && echo "alias ll=\"ls -lah\"" >> ~/.bashrc \
        && echo "alias m2=\"php bin/magento\"" >> ~/.bashrc \
    && echo "export UNISON=/root/magento2/.unison" >> ~/.bashrc

# Install Unison
RUN curl -L "https://github.com/bcpierce00/unison/archive/v$UNISON_VERSION.tar.gz" | tar zxv -C /tmp && \
                 cd /tmp/unison-$UNISON_VERSION && \
                 sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c && \
                 make && \
                 cp src/unison src/unison-fsmonitor /usr/local/bin && \
                 cd /root && rm -rf /tmp/unison-$UNISON_VERSION

# Install PHP required libs
RUN apt-get install -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install -j$(nproc) intl xsl gd zip pdo_mysql opcache soap bcmath json iconv \
    && pecl install xdebug && docker-php-ext-enable xdebug \
        && echo "xdebug.remote_enable=1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_port=9000" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_connect_back=0" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.remote_host=127.0.0.1" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.idekey=PHPSTORM" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && echo "xdebug.max_nesting_level=1000" >> $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && sed -i -e 's/^zend_extension/\;zend_extension/g' $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini \
        && chmod 666 $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini

# Entrypoint
ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh

# PHP config
ADD conf/php.ini $PHP_INI_DIR/conf.d/zzz-docker.ini

# Unison script
ADD conf/unison/unison.sh            /usr/local/bin/unison.sh
ADD conf/unison/check-unison.sh      /usr/local/bin/check-unison.sh
ADD conf/unison/.unison/magento2.prf /root/magento2/.unison/magento2.prf
RUN chmod +x /usr/local/bin/unison.sh && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/check-unison.sh

# supervisord config
ADD conf/supervisord.conf /etc/supervisord.conf

#EXPOSE 80 22 5000 44100 9000
WORKDIR $MAGE_DIR

# Add Scripts directory
ADD scripts/ /usr/local/bin/

RUN chmod +x /usr/local/bin/* \
    && mkdir -p $MAGE_DIR \
    && chown -R www-data: $MAGE_DIR \
    && chmod -R g+s $MAGE_DIR

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
