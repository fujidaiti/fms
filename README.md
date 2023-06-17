**⚠️ Notice - Jun. 17, 2023**

This package has a critical problem that won't be fixed. I DO recommend to using [material_symbols_icons](https://github.com/timmaffett/material_symbols_icons) by @timmaffett instead, which is 100% compatible with the official API that will be released in a future release of Flutter. See [#3](https://github.com/fujidaiti/fms/issues/3#issuecomment-1595543721) for more information.

# fms (Flutter-Material-Symbols)

[English](https://github.com/fujidaiti/fms/blob/master/README.md)|[日本語](https://github.com/fujidaiti/fms/blob/master/resources/README.jp.md)

[![Pub Version](https://img.shields.io/pub/v/fms)](https://pub.dev/packages/fms)

[![cover](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fm3%2Fimages%2Fl1dshu8o-adjustable_attributes_1.gif?alt=media&token=3e4384c6-b15a-4654-8250-ae61f38f8533)](https://m3.material.io/styles/icons/overview#8a94b4ec-c2c5-4dc7-b392-9f89b75904bd)



An simple CLI tool that brings Google's [Material Symbols](https://m3.material.io/styles/icons/overview) to your Flutter projects. It generates an icon font and its wrapper class from a single configuration file.



## Motivation

In the latest version of MaterialDesign, [Material3](https://m3.material.io), [Material Symbols](https://m3.material.io/styles/icons/overview) was introduced in place of [Material Icons](https://m2.material.io/design/iconography/system-icons.html). However, flutter does not yet support Material Symbols officially. Although they are [being supported](https://github.com/flutter/flutter/issues/102560), it will be some time before being bundled in the stable version.

Fortunately, Material Symbols is OSS and all the resources are [available on Github](https://github.com/google/material-design-icons). You can also see a list of available symbols on [their official website](https://fonts.google.com/icons). You can incorporate Material Symbols into your flutter project right away by downloading the SVG files of the symbols you need from the website.

On the other hand, Material Icons are provided in flutter framework as `Icons` class and we can use them as easily and type-safty as `Icons.home`. How can we achieve the same thing with Material Symbols? First download the SVGs, convert them to a font file, then create a corresponding Dart wrapper class, and.... Yes, this is a very tedious process.

With **fms (flutter-material-symbols)** you can automatically generate these files from a single configuration file. There is no need to download and manage resources manually.



### Why "generate"?

Why does fms take the trouble to generate font files instead of providing a class like `Icons` ? Material symbols has 2400+ icons and they are all customizable with 5 parameters. In addition, each parameter has at least 2 possible values. Therefore It is obvious that the number of possible combinations of the symbols and the parameters is enormous. If we create a class wchich provides all the variants of symbols as static member variables, a huge font file that contains all variant data must be included in the package. That's inpractical. Instead, fms generates a font file that contians only as much data as you needed.


## Index

- [fms (Flutter-Material-Symbols)](#fms-flutter-material-symbols)
  - [Motivation](#motivation)
    - [Why "generate"?](#why-generate)
  - [Index](#index)
  - [Preface](#preface)
  - [Install](#install)
  - [Getting started](#getting-started)
  - [How to use](#how-to-use)
    - [Syntax of configuration file](#syntax-of-configuration-file)
      - [Family Name](#family-name)
      - [Output destinations](#output-destinations)
      - [Define symbol instances](#define-symbol-instances)
      - [Overrides default parameters](#overrides-default-parameters)
    - [Commands](#commands)
      - [build](#build)
        - [Generate multiple icon fonts](#generate-multiple-icon-fonts)
      - [clean](#clean)
  - [Contribution](#contribution)


## Preface

One of the main functions of this package is heavily based on the following packages:

- [fantasticon](https://github.com/tancredi/fantasticon)
  A node.js package that converts multiple SVG files into a single icon font. It is used to generate an icon fonts from SVGs of symbols. Therefore,  node.js of version 11 or later must be enabled.
- [icon_font_generator](https://github.com/ScerIO/icon_font_generator)
  Wrapper library for fantasticon's Dart. It is used to generate icon font wrapper classes.



## Install

You can install fms from [Pub.dev](https://pub.dev/packages/fms) using `pub` command.

```shell
$ flutter pub add --dev fms
```

Make sure that node.js of version 11 or later is installed.

```shell
$ node --version   
v18.12.1
```



## Getting started

1. Write a configuration file

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

   

2. Generate an Icon font and its wrapper class

   The following command generates an icon font in `assets/my_symbols.ttf` and its wrapper class in `lib/src/my_symbols.dart`.

   ```shell
   $ flutter pub run fms build my_symbols.yaml
   ```

   

3. Add generated icon font to your Flutter project

   Add the information of the generated font to `pubspec.yaml` so that Flutter can use it. Don't forget to specify the font file as an asset in the `assets:` section if you put them somewhere other than `lib/` (e.g. `assets/`).

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



4. Use generated icons

   You can use the icons in Dart code via `MySymbols` class which is defined in generated `my_symbols.dart`.

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



### Syntax of configuration file

A configuration file is written in YAML. One configuration file corresponds to one icon font and its wrapper class, respectively.

A configuration file consists of the following four sections:

```yaml
family: ... # Family name
output: ... # Output destinations
symbols: ... # Define symbol instances
default: ... # Overrides default parameters（optional）
```



#### Family Name

In `family:` section, specify the family name of an icon font to be generated.

```yaml
family: MySymbols
```

This is also used as the name of the wrapper class, so it must be an appropriate identifier in Dart (usually UpperCamelCase). Therefore names that begin with a number, or contain special characters, or spaces cannot be used, as shown below:

- `10Symbols` 
- `MySymbols#1`
- `My Symbols`



#### Output destinations

The output destinations for a generated icon font and its wrapper class is specified in `output:` section.

```yaml
output:
  flutter: lib/src/my_symbols.dart # Wrapper class
  font: assets/my_symbols.ttf # Icon font
```



#### Define symbol instances

In `symbols:` section, you can define symbol instances: the instances of the symbols you want to use. A symbol instance is a set of the name of a symbol and its parameters. Every instance also has a unique identifier within the family.

- Symbol Name

  Every symbol has a unique name (e.g. `Home`, `Calendar Month`). Available symbol names can be found in the [official gallery site](https://fonts.google.com/icons). Be careful about case, whitespaces, etc. (e.g. `calendarMonth` is wrong,  `Calendar Month` is correct).
  
- Parameters

  Material Symbols are [variable fonts](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Fonts/Variable_Fonts_Guide). Each symbol can be customized by adjusting five parameters. See the [offcial site](https://fonts.google.com/icons) to see how each parameter works.
  
- Identifier
  
  Each instance also has an identifier which is unique in thier family. This will be the variable name of the generated wrapper class, so it must be an appropriate identifier for Dart. fms supports both snake_case and lowerCamelCase, but the two styles cannot be mixed in a family. 



Let's start with a simple example. The following snippet defines an instance of `Home` symbol and name it as `home`. The symbol name is specified in the `name:` section.

```yaml
symbols:
  home: # Identifier
    name: Home # Symbol name
```

Next, customize symbols with parameters. Material Symbols supports five parameters: **style**, **weight axis**, **fill axis**, **grade axis**, and **optical-size axis**.

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

The possible values for each parameter section are as follows:

|PARAMETER| SECTION |               POSSIBLE VALUES               |
|:---------| :----------- | :----------------------------- |
|Style|   `style:`   | `outlined`, `rounded`, `sharp` |
|Weight axis|  `weight:`   |   `100`, `200`, ... , `700`    |
|Fill axis|   `fill:`    |         `true`, `false`         |
|Grade Axis|   `grade:`   |        `-25`, `0`, `200`        |
|Optical-size axis|   `size:`    |  `20px`, `24px`, `40px`, `48px`  |

All of the parameters are optional and may be omitted. Parameters whose value is not specified will have the default values. The default values are `style: outlined`、`weight: 400`、`fill: false`、`grade: 0`、`size: 48px`, respectively. The following is an example of creating two different `Home` symbols (`home` and `home_selected`) to be used for tabs of [NavigationBar](https://api.flutter.dev/flutter/material/NavigationBar-class.html).

```yaml
symbols:
  home: # Equivalent to "fill: false"
    name: Home
  home_selected:
    name: Home
    fill: true
```

The `name:` section can also be omitted if none of the parameters are specified. In such a case, the identifier and symbol name should be written in key-value format. The above example can be rewritten in abbreviated form as follows:

```yaml
symbols:
  home: Home # "name:" section is ommited
  home_selected:
    name: Home
    fill: true
```



####  Overrides default parameters

Use `default:` section to overrides the default value of each parameter. The values specified here will be used as the new default parameters. For example, to change the default value of style from `outlined` to `rounded` and the default value of `weight axis` from `400` to `500`, write the following.

```yaml
default:
  style: rounded
  weight: 500
```

The `default:` section is optional and can be omitted.



### Commands

fms has 2 subcommands: `build` and `clean`.

#### build

Use `build` to generate an icon font and its wrapper class from a configuration file. Node.js is required for the command to work. If you do not have it, please install it first.

```shell
$ flutter pub run fms build your_config_file.yaml
```

Available options are:

- `--prefer-camel-case`

  Use lowerCamelCase for identifiers of symbol instances instead of snake_case.

- `-f`, `--force`

  Download resource files even if the cache is available.

- `--use-yarn`

  Use `yarn` as a node.js package manager instead of `npm`.

- `-v`,`--verbose`

  Display detailed processing information.



##### Generate multiple icon fonts

One configuration file corresponds to one icon font and its wrapper class respectively. If you want to generate multiple icon fonts, write multiple configuration files too. Make sure that the family names must be unique within your project.

You can pass multiple configuration files to build` command, so there is no need to call the command multiple times.

```shell
$ flutter pub run fms first_symbols.yaml second_symbols.yaml
```



#### clean

Downloaded SVG files are cached in `<project_root>/.dart_tool/`. Use the `clean` to delete them.

```shell
$ flutter pub run fms clean
```



## Contribution

Any kind of contribution is welcome. Suggestions for my english are also helpful to improve the quality of the document.
