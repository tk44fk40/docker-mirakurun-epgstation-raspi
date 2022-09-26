# docker-mirakurun-epgstation

[Mirakurun](https://github.com/Chinachu/Mirakurun) + [EPGStation](https://github.com/l3tnun/EPGStation) を forkしてして Raspberry Pi 4 Model B (4GB) を想定してカスタマイズした Docker コンテナ

## 前提条件

- Raspberry Pi 4 Model B (4GB)
- Ubuntu 22.04 LTS server 64-bit
- Docker, docker-compose がインストールされていること
- ホスト上の pcscd は停止する
- チューナーのドライバが適切にインストールされていること

## カスタマイズ内容

- Raspberry Pi 4 Model B に搭載されているハードウェアエンコーダを使って、ライブ視聴やエンコード等を行う
  - コーデックに <code>H264_v4l2m2m</code> を指定
  - エンコードも <code>H264_v4l2m2m</code> を使用
    - エンコード時に <code>H.264</code> ではなく <code>H264_v4l2m2m</code> を指定する
    - 画質などが気に食わない場合は通常通り <code>H.264</code> を指定すれば、CPU を使用するソフトウェアエンコードが行われる（負荷と処理時間はお察し）
  - <code>H264_v4l2m2m</code> が使えない <code>WEBM</code> や <code>MP4</code> などの Live 視聴や再生の設定は除外
    - <code>MP4</code> はいかにも行けそうだが、パイプ経由（<code>pipe:1</code>）でクライアント側に引き渡される仕様のため、再生可能となる設定の記述を見出せなかった
    - パイプ経由で <code>mp4</code> 出力するには、シークを無効にするため <code>ffmpeg</code> オプションに <code>-movflags frag_keyframe+empty_moov</code> を追加する必要があるが、<code>H264_v4l2m2m</code> で <code>-movflags frag_keyframe+empty_moov</code> オプションを指定すると、再生不可能な <code>mp4</code> が出力される
    - コーデックが通常の <code>libx264</code> ならば、<code>-movflags frag_keyframe+empty_moov</code> オプションを付けても問題ないが、 <code>libx264</code> では解像度を <code>480p</code> 程度まで下げないとリアルタイムエンコードが追いつかず、実用に耐えないため除外した
  - ハードウェアエンコードするコーデックは <code>H264_omx</code> じゃないのか？
    - <code>H264_omx</code> は Debian bullseye 以降は未対応
    - 現行の Raspberry Pi OS は bullseye
    - Ubuntu 20.04 は bullseye
    - Ubuntu 22.04 は更に新しい jammy
    - <code>H264_omx</code> を使いたい場合は、Raspberry Pi OS (Legacy) 32-bit を選択する必要がある
      - <code>H264_omx</code> と <code>H264_v4l2m2m</code> の両方でエンコードして比較したが、<code>H264_v4l2m2m</code> の方が若干速かったので敢えて <code>H264_omx</code> を選択する必要性は感じなかった
    - 本コンテナの設定は Raspberry Pi OS (Legacy) 32-bit には適合しないので注意

- ブラウザで Raspberry Pi の稼働状況（CPU稼働率など）を表示できるツール [netdata](https://www.netdata.cloud/) のコンテナを同梱
- Wifi のキープアライブ処理を追加
  - 有線 LAN で使えよって話だが、Wifi で運用したい場合もあるよね
  - Raspberry Pi の Wifi は放置しておくと省電力の為か応答しなくなる
  - 色々対処方法はあるようだが、Raspberry Pi 側からデフォルトゲートウェイアドレスに定期的に <code>ping</code> することで対応した
  - それでもたまに切れてる気がしないでもないがきっと気のせい

- ビルドする <code>ffmpeg</code> のバージョンは 5.1.1




## インストール手順

```sh
sudo curl -sf https://raw.githubusercontent.com/tk44fk40/docker-mirakurun-epgstation-raspi/v2/setup.sh | sh -s
cd docker-mirakurun-epgstation
```

#チャンネル設定
vim mirakurun/conf/channels.yml

# restart や user の設定を適宜変更する
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

- Wifi を運用しない場合は、当該 cron 処理を削除したいかもしれない。
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

## netdata について

- ブラウザで Raspberry Pi の稼働状況（CPU稼働率など）を表示できるツール
  - 公式サイト [https://www.netdata.cloud/](https://www.netdata.cloud/)
- http://<Raspberry Pi のアドレス>:19999/ にアクセスして使う
- 不要なら docker-compose.yml から当該ブロックをコメントアウトする

## Windows のカスタム URL scheme について

- 放映中番組の視聴で「外部アプリで開く」を選択し、TS の「無変換」を再生するような場合、カスタム URL scheme 未設定だと *.m3u8 ファイルがダウンロードされる
- ダウンロードされた *.m3u8 を動画プレイヤー（VLC や Media Player Classic など）で開けば当然再生（視聴）できる
- *.m3u8 をダウンロードせず、直接動画プレイヤーで再生（視聴）したい場合、カスタム URL scheme を使う
- config.yml.template.h264_v4l2m2m からコピーされる config.yml では、カスタム URL scheme <code>mpc.url</code> を設定してある

  ```
  win: mpc.url://PROTOCOL://ADDRESS
  ```

- Windows 側で URL スキームとして <code>mpc.url</code> を登録すれば、「外部アプリ」＆「無変換」の視聴時に「再生を許可の確認ポップアップ」が表示され、許可すれば *.m3u8 をダウンロードせずに直接登録した動画プレイヤーで再生（視聴）出来るようになる
- 以下、Windows 側での URL スキームの登録方法を説明する

### 1. レジストリに URL スキーム <code>mpc.url</code> を登録する

- バッチファイル <code>C:\tools\Play_by_Video_Player.bat</code> を起動する URL scheme をレジストリに登録する *.reg ファイルを作成し、実行する
  - mpc.url.reg

    ```
    Windows Registry Editor Version 5.00

    [HKEY_CLASSES_ROOT\mpc.url]
    @="URL:Media Player Classic Homecinema Protocol"
    "URL Protocol"=""

    [HKEY_CLASSES_ROOT\mpc.url\DefaultIcon]

    [HKEY_CLASSES_ROOT\mpc.url\shell]

    [HKEY_CLASSES_ROOT\mpc.url\shell\open]

    [HKEY_CLASSES_ROOT\mpc.url\shell\open\command]
    @="\"C:\\tools\\Play_by_Video_Player.bat\" \"%1\""
    ```

  - 登録した URL scheme をレジストリから削除する *.reg ファイルの例
    - 誤ってレジストリ登録してしまったら、これを使って掃除する
    - mpc.url.unreg.reg

      ```
      Windows Registry Editor Version 5.00

      [-HKEY_CLASSES_ROOT\mpc.url]
      ```

### 2. バッチファイル <code>C:\tools\Play_by_Video_Player.bat</code> を作成する

- Media Player Classic Brack Edition を起動するバッチファイルの例

    ```bat
    @echo off
    set playdata=%~1
    set player=C:\Program Files\MPC-BE x64\mpc-be64.exe
    rem 引数に、mpc.url://http://～…が渡されてくるので
    rem 11文字目（http://）から最後までを引き渡す
    start /b "" "%player%" "%playdata:~10%"
    ```

- Let's enjoy !!
