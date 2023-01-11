# fms (Flutter-Material-Symbols)

This CLI tool makes Google's [Material Symbols](https://m3.material.io/styles/icons/overview) easily available to Flutter projects. It generates icon fonts and their wrapper classes from a configuration files.



## Motivation

The latest version of MaterialDesign, [Material3](https://m3.material.io), replaces the previous [Material Icons](https://m2.material.io/design/iconography/system- icons.html) (hereafter **Icons**) and introduced [Material Symbols](https://m3.material.io/styles/icons/overview) (hereafter **Symbols**). However, currently Flutter does not yet officially support Symbols. Although [supported](https://github.com/flutter/flutter/issues/102560), it will likely be a while before they are introduced in the Stable version.

Fortunately, Symbols is OSS and all resources are [publicly available](https://github.com/google/material-design-icons) on Github. You can also see a list of available symbols on the [official website](https://fonts.google.com/icons). You can download the `*.svg` or `*.png` of the symbols you need from here and incorporate them into your Flutter project right now.

Icons, on the other hand, are provided by the Flutter Framework as the [`Icons` class](https://api.flutter.dev/flutter/material/Icons-class.html) and are as easy as `Icons.home` and They can be used for type-safety; to achieve the same thing with Symbols, you need to convert the downloaded resource into a font file and create the corresponding Dart wrapper class.... Yes, this is a very tedious process.

With `fms (Flutter-Material-Symbols)` you can automatically generate these files from a single configuration file. No need to download and manage resources manually.



## Index.



## Preface

One of the main functions of this package is realized by using the following package.

- [fantasticon](https://github.com/tancredi/fantasticon)

  A Node.js package that converts `*svg` files to icon fonts. It is used to generate icon fonts from symbol `*.svg`. Therefore, version 11 or later [Node.js](https://nodejs.org/en/download/) must be enabled.

- [icon_font_generator](https://github.com/ScerIO/icon_font_generator)

  Wrapper library for `fantasticon` Dart. It is used to generate icon font wrapper classes.



## Install

You can install it from Pub.dev with the `pub` command.

```shell
$ flutter pub add --dev fms
```

Also make sure you have version 11 or later of Node.js installed.

```shell
$ node --version   
v18.12.1
````

## Getting started

1. write a configuration file

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
   fill: true 2.
   ```
   
2. generate icon fonts and wrapper classes

   The following command will create an icon font in `assets/my_symbols.ttf` and a wrapper class in `lib/src/my_symbols.dart`.

   ``shell
   $ flutter pub run fms build my_symbols.yaml
````

   

3. add icon font information to `pubspec.yaml

   Make sure Flutter recognizes the generated `my_symbols.ttf`. If you put the font files in a location other than `lib/` (e.g. `assets/`), [add to assets] in the `assets:` section (https://docs.flutter.dev/development/ui/assets-and-images# specifying-assets).

   ``yaml
   ...
   
   flutter:
     assets:
       - assets/
     fonts:
       - family: MySymbols
         fonts:
           - asset: assets/my_symbols.ttf
   ```` 4.



4. use the generated icons

   Each icon is available from the `MySymbols` class defined in ``my_symbols.dart``.

   ``dart
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



### How to write a configuration file

The `fms` configuration file is written in YAML, one configuration file for each icon font and wrapper class.



A configuration file consists of the following four sections.

```yaml
family: ... # family name
output: ... # output destination settings
symbols: ... # define symbol instances
default: ... # override default parameters (optional)
```



#### family name

The ``family:`` section specifies the family name of the icon font to be generated.

``yaml
family: MySymbols
```

This is also used for the name of the wrapper class, so it must be an appropriate Dart class name (usually UpperCamelCase). Therefore, names starting with a number, special characters, or spaces are not allowed, such as the following.

- `10Symbols`. 
- `MySymbols#1`.
- `MySymbols` `MySymbols#2



#### Setting the output destination

The output destination for the generated icon fonts and wrapper classes is specified in the `output:` section.

```yaml
output:
  flutter: lib/src/my_symbols.dart # Dart file
  font: assets/my_symbols.ttf # font file
```



#### Defining symbol instances

The ``symbols:`` section defines the symbol instances (symbol instances) that you want to use. A symbol instance is a pair of a symbol name and five parameters. Every instance has a unique identifier within the family.



- Symbol Name

  Every symbol has a unique name (e.g., `Home`, `Calendar Month`). Available symbol names can be found on the official [gallery site](https://fonts.google.com/icons). Be careful about case, whitespace, etc. (e.g., `calendarMonth` is wrong, `Calendar Month` is correct).

  

- Parameters

  Symbols is a variable font. Each symbol has [5 parameters](https://m3.material.io/styles/icons/overview#4463117e-084c-40e3-ba99-83ddf2faba30), which can be adjusted to create various variations of Symbols can be created by adjusting these parameters. See [here](https://fonts.google.com/icons) to see how each parameter works.

  

- Identifier

  An identifier to refer to the defined symbol instance within the Flutter project. This identifier will be the variable name of the generated wrapper class, so it must be an appropriate identifier for Dart. Snake_case and lowerCamelCase are supported in `fms`, but the two styles cannot be mixed. Also, identifiers must be unique within a family.


First, here is a simple example with no parameters. Here we define an instance of the `Home` symbol and assign it the identifier `home`. The symbol name is specified in the `name:` section.

```yaml
symbols:
  home: # identifier
    name: Home # symbol name
```

Next, let's specify the parameters: Symbols supports 5 parameters: **style**, **weight axis**, **fill axis**, **grade axis**, and **optical-size axis**.

```yaml
symbols:
  home:
    name: Home
    style: outlined # style
    weight: 400 # weight axis
    fill: false # fill axis
    grade: 0 # grade axis
    size: 48px # optical-size axis
````

The possible values for each parameter section are as follows

|parameter| section |value |
|:---------| :----------- | :----------------------------- |
|Style| `style:` | `outlined`, `rounded`, `sharp` |
|Weight axis| `weight:` | `100`, `200`, ... , `700` |
|Fill axis| `fill:` | `true`, `false` |
|Grade Axis| `grade:` | `-25`, `0`, `200` |
|Optical-size axis| `size:` | `20px`, `24px`, `40px`, `48px` |

All parameters are optional and can be omitted. Parameters not specified will have default values. The default values are `style: outlined`, `weight: 400`, `fill: false`, `grade: 0`, and `size: 48px` respectively. The following is an example of creating two `Home` symbols (`home` and `home_selected ``) for use in tabs.

```yaml
symbols:
  home: # equivalent to specifying "fill: false
    name: Home
  home_selected:
    name: Home
    fill: true
If no parameters are specified, the ``name:`` section is also omitted.

The `name:` section can also be omitted if no parameters are specified. In that case, use the key-value format to describe the identifier and symbol name. The above example can be rewritten in abbreviated form as follows

```yaml
symbols:
  home: Home # abbreviation
  home_selected:
    name: Home
    fill: true
````



#### Override default parameters

Use the `default:` section to change the default value of each parameter. The parameter specified here will be used as the new default value. For example, to change the default value of style from `outlined` to `rounded` and the default value of weight axis from `400` to `500`, write the following.

```yaml
default:
  style: rounded
  weight: 500
````

The ``default:`` section is optional and can be omitted.



### Commands

fms has two subcommands, `build` and `clean`.

#### build

The `build` command is used to generate an icon font and its wrapper class from a configuration file. The command requires Node.js to work, so if you don't have it, install it first.

``shell
$ flutter pub run fms build your_config_file.yaml
```

Available options are.

- `--prefer-camel-case`.

  Prefer lowerCamelCase identifier for symbol instances. If not specified, it will be snake_case.

- `-f`, `--force`.

  Ignore the cache and download the file.

- `--use-yarn`.

  Use `-yarn` as the Node.js package manager. If not specified, `npm` will be used.

  

##### Generate multiple icon fonts

One icon font is generated from one configuration file. If you want to generate multiple types of icon fonts, prepare as many configuration files as the number of icon fonts. Be careful not to duplicate family names.

The ``build`` command allows you to specify multiple configuration files, so there is no need to call the command multiple times.

```shell
$ flutter pub run fms first_symbols.yaml second_symbols.yaml
```



#### clean

The `*.svg` files of downloaded symbols are cached in ``.dart_tool/`. To remove them, use the ``clean`` command.

``shell
$ flutter pub run fms clean
```



## Future works.

- [ ] Implement the `verbose` option.
- [ ] Option to use a `clone` local repository instead of a remote repository (for offline use).
- [ ] Support YAML anchors, aliases, etc.
- [ ] Make sure cache works properly even if you do a global install with `pub global activate`.
- [ ] Write tests
 Translated with www.DeepL.com/Translator (free version)