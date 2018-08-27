# 単体テスト実行手順
## luaunitのインストール

luaunitをインストールする。

<pre>
luarocks install luaunit
</pre>

## lcovtoolsのインストール

lcovtoolsをインストールする。

* [lcovtools](https://github.com/nmcveity/lcovtools)

luarocksに対応していないため、自分の環境でビルドして`lcovtools.dll`をclibsにコピーする。

## msxsl.exeの入手

以下から`msxsl.exe`を入手する。

* [msxsl.exe](https://www.microsoft.com/en-us/download/details.aspx?id=21714)

## テスト実行

`all_test.lua`を実行するとすべてのテストを実行して、`result.xml`というXML形式の解析データを出力。

<pre>
lua test/all_test.lua -v
</pre>

## HTML形式のコードカバレッジレポート出力

`lcovtools`のPythonスクリプトを適当な場所にコピーする。
以下のコマンドを実行すると、`report.xml`にコードカバレッジレポートをXML形式で出力。

<pre>
python scripts/extractlines.py lua\openrtm\*.lua > validLines.xml
python scripts/makereport.py validLines.xml result.xml report.xml -b ./
</pre>


`lcovtools`の`lua.css`、`report.xsl`を適当な場所にコピーする。
以下のコマンドで`report.html`を出力。

<pre>
msxsl report.xml report.xsl -o report.html
</pre>
