#!/bin/bash

if pgrep /var/apps/app/releases/0.1.0/app.sh -f > /dev/null 2>&1
then
    sudo service app restart
else
    sudo service app start
fi
