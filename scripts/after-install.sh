#!/bin/bash

sudo mkdir /var/apps/app -p
sudo chown ubuntu /var/apps/app -R
sudo chgrp ubuntu /var/apps/app -R

tar -xf /tmp/content/app.tar.gz -C /var/apps/app/

sudo chown ubuntu /var/apps/app -R
sudo chgrp ubuntu /var/apps/app -R
