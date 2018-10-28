# Haikuへのインストール手順

[Haiku](https://www.haiku-os.org/)はオープンソース版BeOSを目指して開発されているデスクトップ向けOSです。

10秒程度で再起動できる、最低128MBのメモリで動作する、という非常に軽快な動作が特徴の1つです。
ディスプレイが取り付けられているロボットも世の中には少なくないので、Haikuのように軽快なデスクトップ向けOSはそれなりに需要がありそうです。

Googleが開発している組み込み向けOSのFuchsiaは、カーネルとしてZirconを採用しています。
ZirconはHaikuが採用しているNewOSと同じ人物が開発しています。
5年後にはandroidはFuchsiaに置き換わると言われており、近い将来組み込み向けOSからLinuxカーネルが駆逐されてBeOSの流れを汲むOSが天下を取るとか取らないとからしいです。つまりHaikuに対応するのも無駄ではありません。

## VMWareによるHaikuの仮想環境構築

VMWare上でHaiku OSを動作させる手順を説明します。

## Luaのインストール

<pre>
wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
tar xf lua-5.1.5.tar.gz
cd lua-5.1.5
make bsd
make install INSTALL_TOP=/haiku/lua
</pre>

## LuaRocksのインストール

<pre>
wget http://luarocks.github.io/luarocks/releases/luarocks-3.0.3.tar.gz
tar xf luarocks-3.0.3.tar.gz
cd luarocks-3.0.3
./configure --prefix=/haiku/luarocks --with-lua=/haiku/lua
make 
make install
</pre>

以下のコマンドで表示されたコマンドを実行してモジュールのパスを設定する。

<pre>
/haiku/luarocks/bin/luarocks path
</pre>

## OpenRTM Luaのインストール



後は以下のようにluarocksでopenrtmをインストールしてください。

<pre>
/haiku/luarocks/bin/luarocks install openrtm
</pre>


LuaSocketはLuaRocksに登録されたパッケージがHaikuに対応していないため、一旦削除して以下のようにソースコードからインストールしてください。

<pre>
/haiku/luarocks/bin/luarocks --force remove luasocket
git clone https://github.com/renatomaia/luasocket
cd luasocket
/haiku/luarocks/bin/luarocks build NETWORK_DIR=/boot/system/
</pre>



サンプルは以下のように実行する。
Windows以外のOSではエンドポイントが適切に設定されない場合があるので、`corba.endpoints`オプションを指定する。
現状Haikuでネームサーバーを起動する方法がないため、Windows等ほかのネームサーバーにRTCを登録する。もしくは、ネームサーバーには登録せずにマネージャ経由でアクセスする。

<pre>
git clone https://github.com/Nobu19800/RTM-Lua
cd RTM-Lua/samples

/haiku/lua/bin/lua ConfigSample.lua -o corba.endpoints:HaikuのIPアドレス -o corba.nameservers:Windows等のIPアドレス
</pre>
