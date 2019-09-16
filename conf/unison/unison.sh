#!/usr/bin/env bash

# Run in foreground to warmup
/usr/local/bin/unison magento2

# Run unison server
/usr/local/bin/unison -repeat=watch magento2 > /root/magento2/custom_unison.log 2>&1 &
