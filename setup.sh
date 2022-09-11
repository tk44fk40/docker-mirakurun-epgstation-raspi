#!/bin/sh

git clone https://github.com/tk44fk40/docker-mirakurun-epgstation-raspi.git
cd docker-mirakurun-epgstation-raspi
cp docker-compose-sample.yml docker-compose.yml
cp epgstation/config/enc.template.js epgstation/config/enc.js
cp epgstation/config/enc_rpi.template.js epgstation/config/enc_rpi.js
cp epgstation/config/config.yml.template epgstation/config/config.yml
cp epgstation/config/operatorLogConfig.sample.yml epgstation/config/operatorLogConfig.yml
cp epgstation/config/epgUpdaterLogConfig.sample.yml epgstation/config/epgUpdaterLogConfig.yml
cp epgstation/config/serviceLogConfig.sample.yml epgstation/config/serviceLogConfig.yml
ln keep_wifi_alive/keep_wifi_alive.sh ~/keep_wifi_alive.sh
keep_wifi_alive/add_keep_wifi_alive_to_crontab.sh
sudo docker-compose run --rm -e SETUP=true mirakurun
