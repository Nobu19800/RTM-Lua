# Haikuへのインストール手順

[Haiku](https://www.haiku-os.org/)はオープンソース版BeOSを目指して開発されているデスクトップ向けOSです。

10秒程度で再起動できる、最低128MBのメモリで動作する、という非常に軽快な動作が特徴の1つです。
ディスプレイが取り付けられているロボットも世の中には少なくないので、Haikuのように軽快なデスクトップ向けOSはそれなりに需要がありそうです。

Googleが開発している組み込み向けOSのFuchsiaは、カーネルとしてZirconを採用しています。
ZirconはHaikuが採用しているNewOSと同じ人物が開発しています。
5年後にはAndroidはFuchsiaに置き換わると言われており、近い将来組み込み向けOSからLinuxカーネルが駆逐されてBeOSの流れを汲むZirconが天下を取るとか取らないとからしいです。つまりHaikuに対応するのも無駄ではありません。

## VMWareによるHaikuの仮想環境構築

VMWare上でHaiku OSを動作させる手順を説明します。

以下のページからHaiku R1/beta1のisoファイルを入手してください。

* [HAIKU](https://www.haiku-os.org/get-haiku/)

### 仮想マシンの作成

VMWareで新しい仮想マシンを作成します。

![haiku1](https://user-images.githubusercontent.com/6216077/47612351-4029fb00-dabc-11e8-888d-a9898a1dddeb.png)

インストーラ ディスク イメージ ファイルに`haiku-release-anyboot.iso`を指定して次へ進みます。

![haiku2](https://user-images.githubusercontent.com/6216077/47612372-a9117300-dabc-11e8-9669-969c052cd607.png)

ゲストOS、バージョンには`その他`を設定します。

![haiku3](https://user-images.githubusercontent.com/6216077/47612392-eece3b80-dabc-11e8-8ae7-c7be2a954a11.png)

仮想マシン名、場所は適当に設定して次へ進みます。

![haiku4](https://user-images.githubusercontent.com/6216077/47612405-11f8eb00-dabd-11e8-9d48-b6770ccdaf38.png)

ディスク最大サイズは適当に設定して次へ進んでください。

![haiku5](https://user-images.githubusercontent.com/6216077/47612414-39e84e80-dabd-11e8-9e38-918e8a56c16d.png)

インストール実行時にメモリ256MBでは厳しいため、ハードウェアのカスタマイズでメモリを増やします。
普通に起動する場合は256MBでもそれなりに軽快に動きます。

![haiku7-1](https://user-images.githubusercontent.com/6216077/47612426-7b78f980-dabd-11e8-96c8-889acc2c0546.png)
![haiku6](https://user-images.githubusercontent.com/6216077/47612429-a8c5a780-dabd-11e8-907d-552c40474d54.png)

完了を押して仮想マシン作成を実行します。

![haiku7-2](https://user-images.githubusercontent.com/6216077/47612438-d6125580-dabd-11e8-8626-f02be712d10e.png)

### Haikuのインストール

以降はHaikuでの作業になります。

言語に日本語を選択して`インストーラーを実行`ボタンを押してください。

![haiku8](https://user-images.githubusercontent.com/6216077/47612452-0e199880-dabe-11e8-8ddc-17c23907a848.png)

続けるを押してください。

![haiku9](https://user-images.githubusercontent.com/6216077/47612459-3acdb000-dabe-11e8-9524-81bc57cd4ed6.png)

以降はパーティションの初期化を行います。

![haiku10](https://user-images.githubusercontent.com/6216077/47612504-12928100-dabf-11e8-8267-946224b4c782.png)

`パーティションを設定`を押してください。

![haiku11](https://user-images.githubusercontent.com/6216077/47612512-3655c700-dabf-11e8-8a5f-2a9c4ec61cd8.png)

`/dev/disk/ata/0/master/raw`を右クリックして、`フォーマット`->`Be File System`を選択します。

![haiku12](https://user-images.githubusercontent.com/6216077/47612517-571e1c80-dabf-11e8-93e9-a7df15399c37.png)
![haiku13](https://user-images.githubusercontent.com/6216077/47612527-99dff480-dabf-11e8-8046-50dfc7a168dc.png)


ボリューム名は適当な名前に変更して初期化を実行してください。

![haiku14](https://user-images.githubusercontent.com/6216077/47612529-a95f3d80-dabf-11e8-8214-5c518811c426.png)
![haiku15](https://user-images.githubusercontent.com/6216077/47612534-cb58c000-dabf-11e8-8b95-dd7d9c157a36.png)
![haiku16](https://user-images.githubusercontent.com/6216077/47612535-dd3a6300-dabf-11e8-8bc0-73cc446affc8.png)

左上の枠をクリックして画面を消してください。

![haiku17](https://user-images.githubusercontent.com/6216077/47612539-ecb9ac00-dabf-11e8-8d3e-bf2fc3d75d17.png)

インストール先を先ほど設定したパーティションに設定して開始ボタンを押してください。

![haiku18](https://user-images.githubusercontent.com/6216077/47612541-03f89980-dac0-11e8-9283-e5f26a8ba073.png)

インストールが完了すると再起動を求められるので再起動ボタンを押して再起動してください。

![haiku19](https://user-images.githubusercontent.com/6216077/47612552-3904ec00-dac0-11e8-9186-e9fc9b34aa14.png)


以降の作業はコマンドラインで行います。
Haiku起動後、`Applications`->`Terminal`を実行してください。

![haiku24](https://user-images.githubusercontent.com/6216077/47612561-7c5f5a80-dac0-11e8-8513-ee27d1ec930f.png)



## Luaのインストール

Haiku Depotでもインストールはできますが、LuaRocksをインストールするとLua 5.3がついでにインストールされる上に、何故かlua.h等がインストールされないため、ソースコードからインストールします。

<pre>
$ wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
$ tar xf lua-5.1.5.tar.gz
$ cd lua-5.1.5
$ make bsd
$ make install INSTALL_TOP=/haiku/lua
</pre>

## LuaRocksのインストール

<pre>
$ wget http://luarocks.github.io/luarocks/releases/luarocks-3.0.3.tar.gz
$ tar xf luarocks-3.0.3.tar.gz
$ cd luarocks-3.0.3
$ ./configure --prefix=/haiku/luarocks --with-lua=/haiku/lua
$ make 
$ make install
</pre>

以下のコマンドで表示されたコマンドを実行してモジュールのパスを設定する。

<pre>
$ /haiku/luarocks/bin/luarocks path
</pre>

## OpenRTM Luaのインストール


LuaSocketはLuaRocksに登録されたパッケージがHaikuに対応していないため、以下のようにソースコードからインストールしてください。

<pre>
$ /haiku/luarocks/bin/luarocks --force remove luasocket
$ git clone https://github.com/renatomaia/luasocket
$ cd luasocket
$ /haiku/luarocks/bin/luarocks make NETWORK_DIR=/boot/system/
</pre>


後は以下のようにluarocksでopenrtmをインストールしてください。

<pre>
$ /haiku/luarocks/bin/luarocks install openrtm
</pre>






サンプルは以下のように実行する。
Windows以外のOSではエンドポイントが適切に設定されない場合があるので、`corba.endpoints`オプションを指定する。
現状Haikuでネームサーバーを起動する方法がないため、Windows等ほかのネームサーバーにRTCを登録する。もしくは、ネームサーバーには登録せずにマネージャ経由でアクセスする。

<pre>
$ git clone https://github.com/Nobu19800/RTM-Lua
$ cd RTM-Lua/samples

$ /haiku/lua/bin/lua ConfigSample.lua -o corba.endpoints:HaikuのIPアドレス -o corba.nameservers:Windows等のIPアドレス
</pre>
