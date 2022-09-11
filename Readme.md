# docker-mirakurun-epgstation

[Mirakurun](https://github.com/Chinachu/Mirakurun) + [EPGStation](https://github.com/l3tnun/EPGStation) をforkしてして Raspberry Pi 4 Model B (4GB)で利用できるようにした Docker コンテナ

## 前提条件

- Raspberry Pi 4 Model B (4GB)
- Docker, docker-compose がインストールされていること
- ホスト上の pcscd は停止する
- チューナーのドライバが適切にインストールされていること

## インストール手順

```sh
sudo curl -sf https://raw.githubusercontent.com/tk44fk40/docker-mirakurun-epgstation-raspi/v2/setup.sh | sh -s
cd docker-mirakurun-epgstation
```

#チャンネル設定
vim mirakurun/conf/channels.yml

#コメントアウトされている restart や user の設定を適宜変更する
vim docker-compose.yml
```

## 起動

```sh
sudo docker-compose up -d
```

## チャンネルスキャン地上波のみ(取得漏れが出る場合もあるので注意)

```sh
curl -X PUT "http://localhost:40772/api/config/channels/scan"
```

mirakurun の EPG 更新を待ってからブラウザで http://DockerHostIP:8888 へアクセスし動作を確認する

## 停止

```sh
sudo docker-compose down
```

## 更新

```sh
# mirakurunとdbを更新
sudo docker-compose pull
# epgstationを更新
sudo docker-compose build --pull
# 最新のイメージを元に起動
sudo docker-compose up -d
```

## 設定

### Mirakurun

* ポート番号: 40772

### EPGStation

* ポート番号: 8888
* ポート番号: 8889

### 各種ファイル保存先

* 録画データ

```./recorded```

* サムネイル

```./epgstation/thumbnail```

* 予約情報と HLS 配信時の一時ファイル

```./epgstation/data```

* EPGStation 設定ファイル

```./epgstation/config```

* EPGStation のログ

```./epgstation/logs```

## v1からの移行について

[docs/migration.md](docs/migration.md)を参照

## Wifi のキープアライブ処理について

暫く Wifi 経由の通信を行わないと Wifi のインタフェース wlan0 がダウンする（省電力設定のためと思われる）ため、
定期的（10分）にデフォルトゲートウェイへ wlan0 経由で ping する処理を cron で実行するためのスクリプトを、ホームディレクトリに配置（シンボリックリンク）するようにしている。

この設定は setup.sh の以下の行で行われる。

```sh
ln keep_wifi_alive/keep_wifi_alive.sh ~/keep_wifi_alive.sh
keep_wifi_alive/add_keep_wifi_alive_to_crontab.sh
```

Wifi を運用しない場合は、当該 cron 処理を削除したいかもしれない。
その場合は、
一旦 setup.sh を取得して当該行を削除してから実行するか、
インストール後に crontab から当該処理を削除することで対応できる。

- crontab から当該処理を削除する方法

  * 無条件に全ての処理を削除する場合

    ```sh
    crontab -r
    ```

  * crontab を編集する場合

    ```sh
    crontab -e
    ```

    以下の行を削除して保存する。

    ```
    */10 * * * * ~/keep_wifi_alive.sh
    ```


