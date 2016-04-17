# LanSend

## Overview

settings.xml内に記述されたプレイヤー以外での挙動は知らないです

ホスト名がかぶった場合先頭のプレイヤーがudpを開きます

ただし、FFXI起動後、最初にそのプレイヤーでinしないと開きません、その場合はリロードしてください

また、sendがロードされていないと動作しません

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
                <host>nnnn</host>
            </p1>
            <p2>
                <name>Yyyy</name>
                <host>mmmm</host>
            </p2>
            <p3>
                <name>Zzzz</name>
                <host>mmmm</host>
            </p3>
        </players>
    </global>
</settings>
```
