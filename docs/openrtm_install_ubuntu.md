# OpenRTM-aistのインストール手順(Ubuntu)

このページではUbuntuでのOpenRTM-aistのインストール手順を説明します。

以下のコマンドでgit、Git LFSをインストールします。

<pre>
$ sudo apt install git
$ curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
$ sudo apt-get install git-lfs
</pre>

依存パッケージをインストールします。

<pre>
$ sudo apt-get install gcc g++ make python-yaml
$ sudo apt-get install libomniorb4-dev omniidl omniorb-nameserver
$ sudo apt-get install python-omniorb-omg omniidl-python
$ sudo apt-get install cmake doxygen
$ sudo apt-get install default-jdk
</pre>

Ubuntu 18.04の場合はOpenJDK8をインストールしてJavaのバージョンを切り替えます。
<pre>
$ sudo add-apt-repository ppa:openjdk-r/ppa
$ sudo apt-get update
$ sudo apt-get install openjdk-8-jdk
$ sudo update-alternatives --config java
</pre>

