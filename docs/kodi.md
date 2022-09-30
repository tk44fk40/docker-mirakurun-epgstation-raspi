# Kodi 連携設定の例

- Kodi
## 録画再生

- EPGStation 公式リポジトリのドキュメント
    - [Kodi との連携について](https://github.com/l3tnun/EPGStation/blob/master/doc/kodi.md)

### 手順

1. Kodi のリモートコントロールを有効にする

    Kodi 側で以下の通り設定

    - `設定 ⇒ サービス ⇒ コントロール`
    - `HTTPを介したリモートコントロールを許可` を ON
    - `認証が必要` を ON
    - `ユーザー名` : kodi
    - `パスワード` : kodi
    - `このシステムのアプリケーションからリモートコントロールを許可する` を ON
    - `他のシステムのアプリケーションからリモートコントロールを許可する` を ON

2. EPGStatoin の config.yml に設定を追加

    ```yaml
    kodiHosts:
        - name: kodi
        - host: http://<Kodiのアドレス>:8080
        - user: kodi
        - pass: kodi
    ```

3. Kodi に [plugin.video.epgstation](https://github.com/l3tnun/plugin.video.epgstation) をインストール

    - [plugin.video.epgstation](https://github.com/l3tnun/plugin.video.epgstation) から ZIP をダウンロード
        - plugin.video.epgstatoin-2.zip
        - 普通にダウンロードフォルダにダウンロードしておく
    - `設定 ⇒ アドオン ⇒ zipファイルからインストール`
    - ホームフォルダ > Downloads を開く
    - plugin.video.epgstatoin-2.zip を選択（ビデオアドオンに EPGStation がインストールされる）
    - `設定 ⇒ アドオン ⇒ Myアドオン ⇒ ビデオアドオン ⇒ EPGStation`
    - `EPGStation` の画面で `設定` を開く
        - `EPGStation URL` に以下のアドレスを設定
            ```
            http://<EPGStationのアドレス>:8888
            ```

4. Kodi に IPTV Simple Client をインストール

    - `設定 ⇒ アドオン ⇒ 検索`
    -  ⇒ IPTV と入力して検索
    -  ⇒ 一覧から `PVRクライアント - PVR IPTV Simple Cilent` を選択
    -  ⇒ インストールする
    - `設定 ⇒ アドオン ⇒ Myアドオン ⇒ PVRクライアント`
    - `PVR IPTV Simple Cilent` を選択
    - `PVR IPTV Simple Cilent` の画面で `設定` を開く
        - `設定 ⇒ 一般`
            - `M3U playlist URL` に以下のアドレスを設定
                ```
                http://<EPGStationのアドレス>:8888/api/iptv/channel.m3u8?mode=0
                ```
        - `設定 ⇒ EPG`
            - XMLTV URL に以下のアドレスを設定
                ```
                http://<EPGStationのアドレス>:8888/api/iptv/epg.xml
                ```
