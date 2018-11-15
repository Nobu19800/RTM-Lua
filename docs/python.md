# OpenRTM-aist Python 2.0(開発中)のインストール

OpenRTM-aist 1.0系付属のDataPort.idlはOiLでは読み込めないため、OpenRTM-aist 2.0付属のDataPort.idlが必要になります。

corba_cdr対応版では他のIDLファイルを改変することでDataPort.idlの読み込みを可能にしていますが、通常版はOpenRTM-aist 1.2以前、およびOpenRTM.NETと通信することができません。

ただ、開発中のOpenRTM-aist 2.0とは通信できるため、Python版のOpenRTM-aist 2.0(開発中)のインストール方法を説明します。



まずOpenRTM-aistをインストーラーでインストールしてください。
次に[TortoiseSVN](https://ja.osdn.net/projects/tortoisesvn/)等で以下からOpenRTM-aist Python版 2.0のソースコードを入手します。

* http://svn.openrtm.org/OpenRTM-aist-Python/trunk/OpenRTM-aist-Python/

<!--
setup.pyの以下の部分を変更します。


<pre>
#pkg_data_files_win32 = [("Scripts", ['OpenRTM_aist/utils/rtcd/rtcd_python.exe'])]
pkg_data_files_win32 = []
</pre>
-->

OpenRTM-aist Python版 2.0のソースコードのディレクトリに移動して以下のコマンドを実行すると、インストーラーでインストールしたOpenRTM-aistを上書きします。

※パスに日本語が含まれている場合に失敗することがあります。その場合はディレクトリを変更してコマンドを実行してください。

※上書きするファイルよりも元のファイルの方が新しい場合に上書きされないことがあります。その場合は、`C:\Python27\Lib\site-packages\OpenRTM_aist`以下のファイルを削除してからインストールしてください。

<pre>
python setup.py build
python setup.py install
</pre>
