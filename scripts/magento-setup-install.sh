#!/usr/bin/env sh

# Wait until MySQL is available.
sh /var/scripts/mysql-wait.sh

#Install PHP
php /var/www/html/magento2/bin/magento setup:install \
	--base-url=http://${MAGENTO_DOMAIN} \
	--db-host=database \
	--db-name=${MYSQL_DATABASE} \
	--db-user=${MYSQL_USER} \
	--db-password=${MYSQL_PASSWORD} \
	--backend-frontname=${MAGENTO_ADMIN_FRONTNAME} \
	--admin-firstname=${MAGENTO_ADMIN_FIRSTNAME} \
	--admin-lastname=${MAGENTO_ADMIN_LASTNAME} \
	--admin-email=${MAGENTO_ADMIN_EMAIL} \
	--admin-user=${MAGENTO_ADMIN_USER} \
	--admin-password=${MAGENTO_ADMIN_PASSWORD} \
	--language=${MAGENTO_LANGUAGE} \
	--currency=${MAGENTO_CURRENCY} \
	--timezone=${MAGENTO_TIMEZONE} \
	--use-rewrites=${MAGENTO_USE_REWRITES}
