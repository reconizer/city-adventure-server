#! /bin/bash

app_name="app"
key_path="$KEY_PATH"
server="ubuntu@ec2-34-241-151-89.eu-west-1.compute.amazonaws.com"

cd "$(dirname ${BASH_SOURCE[0]})"

rm ./_build/prod/ -rf
rm /tmp/app -rf

MIX_ENV=prod mix release

mv ./_build/prod/rel/"$app_name" /tmp

cd "/tmp"

tar -zcf "$app_name".tar.gz "$app_name"

scp -i "$key_path" /tmp/"$app_name".tar.gz $server:/home/ubuntu/"$app_name".tar.gz
ssh -t -i "$key_path" "$server" << EOF
  cd /home/ubuntu

  rm /var/apps/"$app_name"_old
  mv /var/apps/"$app_name" /var/apps/"$app_name"_old

  sudo mkdir /var/apps/"$app_name" -p
  sudo chown ubuntu /var/apps/"$app_name" -R
  sudo chgrp ubuntu /var/apps/"$app_name" -R

  tar -xf /home/ubuntu/"$app_name".tar.gz -C /var/apps/

  sudo chown ubuntu /var/apps/"$app_name" -R
  sudo chgrp ubuntu /var/apps/"$app_name" -R

  rm -rf /home/ubuntu/"$app_name".tar.gz

  /var/apps/"$app_name"/bin/"$app_name" migrate && sudo systemctl restart "$app_name"

  exit
EOF