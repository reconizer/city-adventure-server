#!/bin/bash

sudo mkdir /var/apps/gameinn -p
sudo chown ubuntu /var/apps/gameinn
sudo chgrp ubuntu /var/apps/gameinn

tar -xf /tmp/content/gameinn.tar.gz -C /var/apps/gameinn/

sudo chown ubuntu /var/apps/gameinn -R
sudo chgrp ubuntu /var/apps/gameinn -R
