#!/bin/bash

if pgrep /var/apps/gameinn/releases/0.1.0/gameinn.sh -f > /dev/null 2>&1
then
    sudo initctl restart gameinn
else
    sudo initctl start gameinn
fi
