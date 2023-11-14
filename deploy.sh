#! /bin/bash

app_name="app"
key_path="$KEY_PATH"
server="$SERVER_PATH"

cd "$(dirname ${BASH_SOURCE[0]})"

rm ./_build/prod/ -rf
rm /tmp/app -rf

MIX_ENV=prod mix release

mv ./_build/prod/rel/"$app_name" /tmp

cd "/tmp"

tar -zcvf "$app_name".tar.gz "$app_name"

scp -i "$key_path" /tmp/"$app_name".tar.gz $server:/home/ubuntu/"$app_name".tar.gz
ssh -t -i "$key_path" "$server" << EOF
  cd /home/ubuntu
  rm /var/apps/"$app_name" -rf
  mkdir -p /var/apps/"$app_name"
  tar -xf "$app_name".tar.gz
  rm /home/ubuntu/"$app_name".tar.gz
  mv "$app_name" /var/apps/
  /var/apps/"$app_name"/bin/"$app_name" migrate && sudo systemctl restart "$app_name"
  exit
EOF
