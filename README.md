# LanSend

## Overview

LanSendはUDPを使ってLAN内、別PCのWindowerにsendを送信します。

settings.xmlに下記ルール通りにプレイヤー名、アカウント名、ホスト名を記載してください。  
記載のないプレイヤーでの挙動を保証しません。

プレイヤー名は使用しているプレイヤーの名前を入れてください。  
アカウント名は任意の文字列で構いませんが、同じアカウントのプレイヤー同士は同じアカウント名にしてください。  
ホスト名には各プレイヤーを操作しているPCのホスト名を入れてください。

起動後初めてのプレイヤーログイン時にUDPを開きます。  
初ログイン時に、記載の無いプレイヤーだった場合、UDPが開きません、リロードしてください。  
同じホスト名のアカウントが複数あった場合、先に記載してあるアカウントの初ログイン時にUDPを開きます。

UDPが開かれていないと失敗し、sendがロードされていないと動作しません。  

```
/console lansend [プレイヤー名] [コマンド]
```

## settings.xml

```xml
<?xml version="1.1" ?>
<settings>
    <global>
        <port>12345</port>
        <players>
            <p1>
                <name>Xxxx</name>
                <acc>AAA</acc>
                <host>nnnn</host>
            </p1>
            <p2>
                <name>Yyyy</name>
                <acc>BBB</acc>
                <host>mmmm</host>
            </p2>
            <p3>
                <name>Zzzz</name>
                <acc>CCC</acc>
                <host>mmmm</host>
            </p3>
            <p4>
                <name>Oooo</name>
                <acc>CCC</acc>
                <host>mmmm</host>
            </p4>
        </players>
    </global>
</settings>
```
