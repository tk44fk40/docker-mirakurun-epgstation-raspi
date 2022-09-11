#!/usr/bin/bash
# デフォルトゲートウェイへ ping する
gateway=$(ip route show | grep default | grep wlan0 | cut -f 3 -d ' ')
ping -c 2 -I wlan0 $gateway > /var/tmp/keep_wifi_alive.log
