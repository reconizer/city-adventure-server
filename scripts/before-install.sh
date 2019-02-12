#!/bin/bash

mkdir -p /var/apps/
sudo chown ubuntu /var/apps -R
sudo chgrp ubuntu /var/apps -R

date="`date +%Y.%m.%d_%H.%M.%S`"
mv /var/apps/app /var/apps/app_$date
