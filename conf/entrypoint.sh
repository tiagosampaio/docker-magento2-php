#!/usr/bin/env bash

run_unison () {
    local status=1

    while [ $status != 0 ]; do
        unison magento2
        status=$?
    done
}

MAGE_DIR=/var/www/html/magento2

rm -rf $MAGE_DIR/status.html
rm -rf /home/magento2/magento2/status.html

#if [ -n $USE_SHARED_WEBROOT ]
#then
#    if [ $USE_SHARED_WEBROOT == "0" ]
#    then
#
#        # if using custom sources
#        if [ "$(ls -A /home/magento2/magento2)" ] && [ ! "$(ls -A $MAGE_DIR)" ]
#        then
#            echo "[IN PROGRESS] Sync Started." > $MAGE_DIR/status.html
#            sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1status.html/' /home/magento2/magento2/.htaccess
#            cp /home/magento2/magento2/.htacces $MAGE_DIR
#            chown www-data:www-data $MAGE_DIR/.htaccess
#            # service apache2 start
#
#            while [ -f /home/magento2/magento2/sync-wait ]
#            do
#                echo .
#                sleep 2
#            done
#
#            chown -R www-data:www-data $MAGE_DIR
#
#            if [ -n $CREATE_SYMLINK_EE ]
#            then
#                if [ $CREATE_SYMLINK_EE == "1" ]
#                then
#                    mkdir -p $HOST_CE_PATH
#                    ln -s $MAGE_DIR/$EE_DIRNAME $HOST_CE_PATH/$EE_DIRNAME
#                fi
#            fi
#
#            echo "[IN PROGRESS] Unison sync started" > $MAGE_DIR/status.html
#
#            run_unison
#
#            chmod +x $MAGE_DIR/bin/magento
#
#            echo "[DONE] Sync Finished" > $MAGE_DIR/status.html
#            sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1index.php/' /home/magento2/magento2/.htaccess
#            sed -i 's/^\(\s*DirectoryIndex\s*\).*$/\1index.php/' $MAGE_DIR/.htaccess
#            rm -rf $MAGE_DIR/status.html
#            rm -rf /home/magento2/magento2/status.html
#            /usr/local/bin/check-unison.sh &
#        else
#            (run_unison; /usr/local/bin/check-unison.sh) &
#        fi
#    fi
#fi

#if [ "$USE_UNISON_SYNC" == "1" ]
#then
#    sudo -u www-data sh -c '/usr/local/bin/unison -socket 5000 2>&1 >/dev/null' &
#fi

/usr/local/bin/unison.sh
supervisord -n -c /etc/supervisord.conf
