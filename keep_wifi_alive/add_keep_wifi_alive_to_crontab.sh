#!/usr/bin/bash
# Wifi がダウンしないよう、定期的にデフォルトゲートウェイに ping する処理を crontab に追加する
# crontab の設定内容を取得 
crontab -l > crontab.org
grep keep_wifi_alive crontab.org
if [ $? = 0 ]; then
    # 既に処理が追加されているので、何もしないで終了
    echo "already crontab entry exists."
else
    # crontab に設定を追加する
    echo "add keepalive entry to crontab."
    # 現状の設定を取得
    cp crontab.org crontab.edit
    # デフォルトゲートウェイに ping するスクリプトの起動を追記
    echo "*/10 * * * * ~/keep_wifi_alive.sh" >> crontab.edit
    # 追記した内容で crontab を更新
    crontab crontab.edit
    # 設定状態を確認
    crontab -l
    #sudo service cron restart
fi
rm crontab.*
