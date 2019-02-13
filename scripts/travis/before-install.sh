#!/bin/bash
set -ev

pip install --user awscli

#Don't change - seems to be required for postgres 10 
sudo sed -i -e '/local.*peer/s/postgres/all/' -e 's/peer\|md5/trust/g' /etc/postgresql/*/main/pg_hba.conf
sudo service postgresql restart
sleep 1