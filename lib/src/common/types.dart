import 'package:fms/src/repository_info.dart';
import 'package:fpdart/fpdart.dart';
import 'package:recase/recase.dart';

class Theme {
  final Style style;
  final FillAxis fill;
  final WeightAxis weight;
  final GradeAxis grade;
  final SizeAxis size;

  const Theme(
    this.style,
    this.fill,
    this.weight,
    this.grade,
    this.size,
  );

  static final defaultTheme = const Theme(
    Style.outlined,
    FillAxis.notFilled,
    WeightAxis.w400,
    GradeAxis.g0,
    SizeAxis.s48,
  );
}

class SymbolName {
  final String value;

  SymbolName._internal(this.value);

  static Option<SymbolName> parse(String value) {
    if (repositoryInfo.availableSymbolNames.contains(value)) {
      return Some(SymbolName._internal(value));
    }
    return None();
  }

  String toSnakeCase() => ReCase(value).snakeCase;

  @override
  String toString() => value;
}

class MaterialSymbol {
  final SymbolName name;
  final Theme theme;

  MaterialSymbol(
    this.name,
    this.theme,
  );
}

enum Style { outlined, rounded, sharp }

enum FillAxis { filled, notFilled }

enum WeightAxis { w100, w200, w300, w400, w500, w600, w700 }

enum GradeAxis { gN25, g0, g200 }

enum SizeAxis { s20, s24, s40, s48 }

class SymbolInstance {
  final DartIdentifier identifier;
  final MaterialSymbol symbol;

  SymbolInstance(
    this.identifier,
    this.symbol,
  );
}

class Family {
  final DartIdentifier name;
  final Theme defaultTheme;
  final List<SymbolInstance> symbolInstances;

  Family({
    required this.name,
    required this.defaultTheme,
    required this.symbolInstances,
  });
}

class DartIdentifier {
  final String value;

  DartIdentifier._internal(this.value);

  static final _regexp = RegExp(r'^[_a-zA-Z][_a-zA-Z0-9]*$');

  static Option<DartIdentifier> parse(String value) =>
      Option.tryCatch(() => _regexp.allMatches(value).first[0]!)
          .map(DartIdentifier._internal);

  @override
  String toString() => value;

  String toSnakeCase() => ReCase(value).snakeCase;
}

class OutputLocation {
  final String flutter;
  final String font;

  OutputLocation(this.flutter, this.font);
}

class Config {
  final DartIdentifier familyName;
  final OutputLocation outputLocation;
  final List<SymbolInstance> symbolInstances;

  Config(
    this.familyName,
    this.outputLocation,
    this.symbolInstances,
  );
}
