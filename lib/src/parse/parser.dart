import 'dart:io';

import 'package:fms/src/common/error.dart';
import 'package:fms/src/common/io.dart' as io;
import 'package:fms/src/common/types.dart';
import 'package:fms/src/parse/yaml.dart';
import 'package:fms/src/utils/fpdart_utils.dart';
import 'package:fpdart/fpdart.dart';

typedef _Result<T> = Either<ParseErr, T>;

typedef _Ok<T> = Right<ParseErr, T>;

typedef _Err<T> = Left<ParseErr, T>;

ParseErr _foldErrors(Iterable<ParseErr> errors) =>
    errors.fold(ParseErr(''), (prev, curr) => prev.merge(curr));

extension _YamlNodeUtils on YamlNode {
  _Result<U> matchValue<T, U>(Map<T, U> cases) {
    return Option<T>.safeCast(value)
        .flatMap(cases.lookup)
        .toEither(() => ParseErr('Expected one of ${[...cases.keys]}', span));
  }

  _Result<T> matchType<T>({
    _Result<T> Function(YamlStr)? yamlStr,
    _Result<T> Function(YamlMap)? yamlMap,
  }) {
    final node = this;
    if (node is YamlStr && yamlStr != null) return yamlStr(node);
    if (node is YamlMap && yamlMap != null) return yamlMap(node);
    final expectedTypes = {
      'a String value': yamlStr,
      'a Dictionary': yamlMap,
    }.entries.where((e) => e.value != null).map((e) => e.key).join(' or ');
    return _Err(ParseErr('Expected $expectedTypes', node.span));
  }
}

extension _YamlMapUtils on YamlMap {
  _Result<YamlNode> getNode(Object key) {
    return lookup(key)
        .toEither(() => ParseErr('"$key" section is required!', span));
  }
}

_Result<String> _parseFilePath(YamlNode node) => node.matchType(
      // TODO; do more strict validation
      yamlStr: (node) => _Ok(node.value),
    );

_Result<DartIdentifier> _parseIdentifier(YamlNode node) =>
    node.matchType(yamlStr: (node) {
      return DartIdentifier.parse(node.value).toEither(
        () => ParseErr('Expected a Dart identifier', node.span),
      );
    });

_Result<SymbolName> _parseSymbolName(YamlNode node) {
  return node.matchType(
    yamlStr: (node) => SymbolName.parse(node.value).toEither(
      () => ParseErr(
        'Invalid symbol name. See available names here: https://fonts.google.com/icons',
        node.span,
      ),
    ),
  );
}

TaskEither<Err, Config> parseConfigYaml(
  File configFile,
) =>
    io.readFileAsString(configFile).flatMap(loadYaml).chainEither(_parseConfig);

_Result<Theme> _parseTheme(Theme defaultTheme, YamlNode node) => node.matchType(
      yamlMap: (node) {
        final style = node['style']
            .map(_parseStyle)
            .getOrElse(() => _Ok(defaultTheme.style));
        final fill = node['fill']
            .map(_parseFill)
            .getOrElse(() => _Ok(defaultTheme.fill));
        final grade = node['grade']
            .map(_parseGrade)
            .getOrElse(() => _Ok(defaultTheme.grade));
        final weight = node['weight']
            .map(_parseWeight)
            .getOrElse(() => _Ok(defaultTheme.weight));
        final size = node['size']
            .map(_parseSize)
            .getOrElse(() => _Ok(defaultTheme.size));

        return Theme.new
            .applyEithers(style, fill, weight, grade, size)
            .mapLeft(_foldErrors);
      },
    );

_Result<Style> _parseStyle(YamlNode node) {
  return node.matchValue(const {
    'rounded': Style.rounded,
    'outlined': Style.outlined,
    'sharp': Style.sharp,
  });
}

_Result<FillAxis> _parseFill(YamlNode node) {
  return node.matchValue(const {
    true: FillAxis.filled,
    false: FillAxis.notFilled,
  });
}

_Result<WeightAxis> _parseWeight(YamlNode node) {
  return node.matchValue(const {
    100: WeightAxis.w100,
    200: WeightAxis.w200,
    300: WeightAxis.w300,
    400: WeightAxis.w400,
    500: WeightAxis.w500,
    600: WeightAxis.w600,
    700: WeightAxis.w700,
  });
}

_Result<GradeAxis> _parseGrade(YamlNode node) {
  return node.matchValue(const {
    -25: GradeAxis.gN25,
    0: GradeAxis.g0,
    200: GradeAxis.g200,
  });
}

_Result<SizeAxis> _parseSize(YamlNode node) {
  return node.matchValue(const {
    '20px': SizeAxis.s20,
    '24px': SizeAxis.s24,
    '40px': SizeAxis.s40,
    '48px': SizeAxis.s48,
  });
}

_Result<MaterialSymbol> _parseSymbol(Theme defaultTheme, YamlNode node) {
  return node.matchType(
    yamlStr: (node) {
      return _parseSymbolName(node).map(
        (name) => MaterialSymbol(name, defaultTheme),
      );
    },
    yamlMap: (node) {
      final theme = _parseTheme(defaultTheme, node);
      final name = node.getNode('name').flatMap(_parseSymbolName);
      return MaterialSymbol.new.applyEithers(name, theme).mapLeft(_foldErrors);
    },
  );
}

_Result<SymbolInstance> _parseSymbolInstance(
    Theme defaultTheme, YamlEntry entry) {
  final identifier = _parseIdentifier(entry.key);
  final symbol = _parseSymbol(defaultTheme, entry.value);
  return SymbolInstance.new
      .applyEithers(identifier, symbol)
      .mapLeft(_foldErrors);
}

_Result<List<SymbolInstance>> _parseSymbols(
        Theme defaultTheme, YamlNode node) =>
    node.matchType(
      yamlMap: (node) {
        final instances =
            node.entries.map(_parseSymbolInstance.curry(defaultTheme)).toList();
        final error = _foldErrors(instances.leftsEither());
        return !error.isEmpty ? _Err(error) : _Ok(instances.rightsEither());
      },
    );

_Result<OutputLocation> _parseOutputLocation(YamlNode node) =>
    node.matchType(yamlMap: (node) {
      final flutter = node.getNode('flutter').flatMap(_parseFilePath);
      final font = node.getNode('font').flatMap(_parseFilePath);
      return OutputLocation.new
          .applyEithers(flutter, font)
          .mapLeft(_foldErrors);
    });

Either<ParseErr, Config> _parseConfig(YamlNode node) => node.matchType(
      yamlMap: (node) {
        final familyName = node.getNode('family').flatMap(_parseIdentifier);
        final output = node.getNode('output').flatMap(_parseOutputLocation);

        final theme = node
            .lookup('default')
            .map(_parseTheme.curry(Theme.defaultTheme))
            .getOrElse(() => _Ok(Theme.defaultTheme));

        final symbols = node.getNode('symbols').flatMap(
            _parseSymbols.curry(theme.toNullable() ?? Theme.defaultTheme));

        final createConfig = (
          Theme _,
          DartIdentifier familyName,
          OutputLocation output,
          List<SymbolInstance> symbols,
        ) =>
            Config(familyName, output, symbols);

        return createConfig
            .applyEithers(theme, familyName, output, symbols)
            .mapLeft(_foldErrors);
      },
    );
