FROM php:7.2-fpm

MAINTAINER "Tiago Sampaio <tiago@tiagosampaio.com>"

# Add Scripts directory
ADD scripts/ /var/scripts/

ENV MAGE_DIR /var/www/html/magento2

ENV USE_SHARED_WEBROOT 1
ENV SHARED_CODE_PATH $MAGE_DIR
ENV WEBROOT_PATH $MAGE_DIR
ENV MAGENTO_ENABLE_SYNC_MARKER 0

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
RUN curl -L https://github.com/bcpierce00/unison/archive/v2.51.2.tar.gz | tar zxv -C /tmp && \
                 cd /tmp/unison-2.51.2 && \
                 sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c && \
                 make && \
                 cp src/unison src/unison-fsmonitor /usr/local/bin && \
                 cd /root && rm -rf /tmp/unison-2.51.2

# Install PHP required libs
RUN apt-get install -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure hash --with-mhash \
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

RUN mkdir -p $MAGE_DIR \
    && chown -R www-data: $MAGE_DIR \
    && chmod -R g+s $MAGE_DIR

USER root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
