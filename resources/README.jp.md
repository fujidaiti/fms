# fms (Flutter-Material-Symbols)

[English](https://github.com/fujidaiti/fms/blob/master/README.md)|[日本語](https://github.com/fujidaiti/fms/blob/master/resources/README.jp.md)

![Pub Version](https://img.shields.io/pub/v/fms)

[![cover](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fm3%2Fimages%2Fl1dshu8o-adjustable_attributes_1.gif?alt=media&token=3e4384c6-b15a-4654-8250-ae61f38f8533)](https://m3.material.io/styles/icons/overview#8a94b4ec-c2c5-4dc7-b392-9f89b75904bd)

Googleの[Material Symbols](https://m3.material.io/styles/icons/overview)をFlutterプロジェクトで簡単に利用できるようにするCLIツールです。設定ファイルからアイコンフォントとそのラッパークラスを生成します。


## Motivation

MaterialDesignの最新版である[Material3](https://m3.material.io)では、これまでの[Material Icons](https://m2.material.io/design/iconography/system-icons.html)に代わり[Material Symbols](https://m3.material.io/styles/icons/overview)が新たに導入されました。しかし、現在のところFlutterはまだ公式にMaterial Symbolsをサポートしていません。[対応中](https://github.com/flutter/flutter/issues/102560)ではあるものの、Stableバージョンに導入されるのはまだ先になりそうです。

幸いなことにMaterial SymbolsはOSSであり、全てのリソースがGithub上で[公開](https://github.com/google/material-design-icons)されています。また[公式サイト](https://fonts.google.com/icons)では利用可能なシンボルの一覧を見ることができます。必要なシンボルのSVGファイルをここからダウンロードすれば今すぐにMaterial SymbolsをFlutterをプロジェクトに組み込むことが可能です。

一方でMaterial Iconsは[`Icons`クラス](https://api.flutter.dev/flutter/material/Icons-class.html)としてFlutter Frameworkから提供されており、`Icons.home`のように簡単に、タイプセーフに利用することができます。Material Symbolsで同じことを実現するにいはどうしたら良いでしょう？まずSVGをダウンロードし、それらをフォントファイルをに変換、そして対応するDartのラッパークラスを作成して…。はい、これは大変面倒な作業です。

**fms (Flutter-Material-Symbols)**を使えば１つの設定ファイルからこれらのファイルを自動で生成することができます。リソースのダウンロード・管理を手動でする必要はありません。


## Index

- [fms (Flutter-Material-Symbols)](#fms-flutter-material-symbols)
  - [Motivation](#motivation)
  - [Index](#index)
  - [Preface](#preface)
  - [Install](#install)
  - [Getting started](#getting-started)
  - [How to use](#how-to-use)
    - [設定ファイルの書き方](#設定ファイルの書き方)
      - [ファミリー名](#ファミリー名)
      - [出力先の設定](#出力先の設定)
      - [シンボルインスタンスの定義](#シンボルインスタンスの定義)
      - [デフォルトパラメータのオーバーライド](#デフォルトパラメータのオーバーライド)
    - [コマンド](#コマンド)
      - [build](#build)
        - [複数のアイコンフォントを生成する](#複数のアイコンフォントを生成する)
      - [clean](#clean)
  - [Future works](#future-works)


## Preface

このパッケージの主要な機能の1つは以下のパッケージを利用して実現されています。

- [fantasticon](https://github.com/tancredi/fantasticon)

  複数のSVGファイルを1つのアイコンフォントに変換するNode.jsパッケージです。シンボルのSVGからアイコンフォントを生成するのに使用してます。そのためバージョン11以降の[Node.js](https://nodejs.org/en/download/)が有効になってる必要があります。

- [icon_font_generator](https://github.com/ScerIO/icon_font_generator)

  `fantasticon`のDart向けラッパーライブラリです。アイコンフォントのラッパークラスを生成するために使用しています。



## Install

`pub`コマンドで[Pub.dev](https://pub.dev/packages/fms)からインストールできます。

```shell
$ flutter pub add --dev fms
```

また、バージョン11以降のNode.jsがインストールされていることも確認してください。

```shell
$ node --version   
v18.12.1
```



## Getting started

1. 設定ファイルを書く

   ```yaml
   # project_root/my_symbols.yaml
   
   family: MySymbols
   
   output:
     flutter: lib/src/my_symbols.dart
     font: assets/my_symbols.ttf
   
   symbols:
     home: Home
     home_selected:
       name: Home
       fill: true
   ```

   

2. アイコンフォントとラッパークラスを生成

   以下のコマンドで`assets/my_symbols.ttf`にアイコンフォントが、`lib/src/my_symbols.dart`にラッパークラスがそれぞれ作成されます。

   ```shell
   $ flutter pub run fms build my_symbols.yaml
   ```

   

3. アイコンフォントの情報を`pubspec.yaml`に追加

   生成された`my_symbols.ttf`をFlutterが認識できるようにします。フォントファイルを`lib/`以外の場所（例えば`assets/`）に置く場合は`assets:`セクションで[アセットに追加する](https://docs.flutter.dev/development/ui/assets-and-images#specifying-assets)ことも忘れないでください。

   ```yaml
   ...
   
   flutter:
     assets:
       - assets/
     fonts:
       - family: MySymbols
         fonts:
           - asset: assets/my_symbols.ttf
   ```



4. 生成されたアイコンを使う

   各アイコンは`my_symbols.dart`で定義された`MySymbols`クラスから利用できます。

   ```dart
   import 'package:your_package/src/my_symbols.dart';
   import 'package:flutter/material.dart';
   
   Widget homeNaviDest() {
     return NavigationDestination({
       icon: const Icon(MySymbols.home),
       selectedIcon: const Icon(MySymbols.home_selected),
     });
   }
   ```

   

## How to use



### 設定ファイルの書き方

`fms`の設定ファイルはYAMLで記述します。１つの設定ファイルが1つのアイコンフォント、ラッパークラスにそれぞれ対応します。



設定ファイルは以下の４つのセクションから構成されています。

```yaml
family: ... # ファミリー名
output: ... # 出力先の設定
symbols: ... # シンボルインスタンスの定義
default: ... # デフォルトパラメータのオーバーライド（optional）
```



#### ファミリー名

`family:`セクションでは生成されるアイコンフォントのファミリー名を指定します。

```yaml
family: MySymbols
```

これはラッパークラスの名前にも使用されるため、Dartのクラス名として適切なものである必要があります（通常はUpperCamelCase）。したがって以下のように数字から始まる名前、特殊文字やスペースの入った名前は使用できません。

- `10Symbols` 
- `MySymbols#1`
- `My Symbols`



#### 出力先の設定

生成されるアイコンフォントとラッパークラスの出力先は`output:`セクションで指定します。

```yaml
output:
  flutter: lib/src/my_symbols.dart # Dartファイル
  font: assets/my_symbols.ttf # フォントファイル
```



#### シンボルインスタンスの定義

`symbols:`セクションでは使用したいシンボルのインスタンス（シンボルインスタンス）を定義します。シンボルインスタンスとはシンボル名と5つのパラメータの組です。また全てのインスタンスはファミリー内で一意な識別子を持ちます。



- シンボル名

  全てのシンボルには一意な名前が付けられています（例：`Home`、`Calendar Month`）。利用可能なシンボル名は公式の[ギャラリーサイト](https://fonts.google.com/icons)で確認できます。大文字や小文字、空白の有無など表記揺れに注意してください（例：`calendarMonth`は間違い、正しくは`Calendar Month`）。

  

- パラメータ

  Material Symbolsは[可変フォント](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Fonts/Variable_Fonts_Guide)です。各シンボルは[5つのパラメータ](https://m3.material.io/styles/icons/overview#4463117e-084c-40e3-ba99-83ddf2faba30)を持っており、これらを調整することで様々なバリエーションのシンボルを作成することができます。各パラメータがどのように作用するかは[ここ](https://fonts.google.com/icons)で確認してください。

  

- 識別子

  定義したシンボルインスタンスをFlutterプロジェクト内で参照するための識別子です。この識別子は生成されるラッパークラスの変数名になるため、Dartの識別子として適切なものである必要があります。`fms`ではsnake_caseとlowerCamelCaseがサポートされていますが、2つのスタイルを混在させることはできません。また識別子はファミリー内で一意でなければなりません。



まずはパラメータを指定しないシンプルな例を示します。ここでは`Home`シンボルのインスタンスを定義し`home`という識別子を割り当てています。シンボル名は`name:`セクションで指定します。

```yaml
symbols:
  home: # 識別子
    name: Home # シンボル名
```

次はパラメータを指定してみましょう。Material Symbolsでは**style**、**weight axis**、**fill axis**、**grade axis**、**optical-size axis**という5つのパラメータがサポートされています。

```yaml
symbols:
  home:
    name: Home
    style: outlined # style
    weight: 400 # weight axis
    fill: false # fill axis
    grade: 0 # grade axis
    size: 48px # optical-size axis
```

各パラメータセクションで指定可能な値は以下の通りです：

|パラメータ| セクション |               値               |
|:---------| :----------- | :----------------------------- |
|Style|   `style:`   | `outlined`, `rounded`, `sharp` |
|Weight axis|  `weight:`   |   `100`, `200`, ... , `700`    |
|Fill axis|   `fill:`    |         `true`, `false`         |
|Grade Axis|   `grade:`   |        `-25`, `0`, `200`        |
|Optical-size axis|   `size:`    |  `20px`, `24px`, `40px`, `48px`  |

全てのパラメータは任意であり、省略可能です。指定がないパラメータにはデフォルトの値が設定されます。デフォルト値はそれぞれ`style: outlined`、`weight: 400`、`fill: false`、`grade: 0`、`size: 48px`です。以下は[NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html)のタブに使用する2種類の`Home`シンボル（`home`と`home_selected`）を作成する例です。

```yaml
symbols:
  home: # "fill: false"を指定した時と等価
    name: Home
  home_selected:
    name: Home
    fill: true
```

また、パラメータを1つも指定しない場合は`name:`セクションも省略することができます。その場合はkey-value形式で識別子とシンボル名を記述してください。上記の例を省略形で書き直すと次のようになります。

```yaml
symbols:
  home: Home # 省略形
  home_selected:
    name: Home
    fill: true
```



####  デフォルトパラメータのオーバーライド

各パラメータのデフォルト値を変更したい時は`default:`セクションを利用してください。ここで指定したパラメータは新しいデフォルト値として使用されます。例えはstyleのデフォルト値を`outlined`から`rounded`に、weight axisのデフォルト値を`400`から`500`にそれぞれ変更したい場合は次のように書きます。

```yaml
default:
  style: rounded
  weight: 500
```

`default:`セクションは任意であり省略可能です。



### コマンド

fmsには`build`、`clean`という2つのサブコマンドがあります。

#### build

設定ファイルからアイコンフォントとそのラッパークラスを生成するには`build`コマンドを使用します。コマンドの動作にはNode.jsが必要ですので、ない場合は先にインストールしてください。

```shell
$ flutter pub run fms build your_config_file.yaml
```

利用可能なオプションは次の通りです。

- `--prefer-camel-case`

  シンボルインスタンスの識別子をlowerCamelCaseにします。指定がなければsnake_caseになります。

- `-f`, `--force`

  キャッシュを無視してファイルをダウンロードします。

- `--use-yarn`

  Node.jsのパッケージマネージャとして`yarn`を使用します。指定がなければ`npm`が使用されます。

  

##### 複数のアイコンフォントを生成する

1つの設定ファイルから1つのアイコンフォントが生成されます。複数種類のアイコンフォントを生成したい場合は設定ファイルもその数だけ用意してください。この時ファミリー名が重複しないように気を付けてください。

`build`コマンドには設定ファイルを複数指定できるので、何度もコマンドを呼び出す必要はありません。

```shell
$ flutter pub run fms first_symbols.yaml second_symbols.yaml
```



#### clean

ダウンロードしたシンボルのSVGファイルは`.dart_tool/`内にキャッシュされます。これらを削除する場合は`clean`コマンドを使用してください。

```shell
$ flutter pub run fms clean
```



## Future works

- [ ] `verbose`オプションを実装する
- [ ] リモートのリポジトリの代わりに、`clone`したローカルのリポジトリを使用するオプション（オフラインでも利用できるように）
- [ ] YAMLのアンカー、エイリアス等に対応する
- [ ] `pub global activate`でグローバルインストールした場合でもキャッシュがちゃんと働くか確認する
- [ ] テストを書く
- [ ] 英語のREADME.mdを用意する
