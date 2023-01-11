import 'package:fms/src/common/error.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:yaml/yaml.dart' as yaml;

@sealed
abstract class YamlNode {
  YamlNode(this.span);
  final SourceSpan span;
  dynamic get value;

  factory YamlNode._from(yaml.YamlNode node) {
    if (node is yaml.YamlMap) return YamlMap(node);
    if (node is yaml.YamlList) throw _YamlList(node);
    final scalar = node.value;
    if (scalar is int) return YamlInt(node.span, scalar);
    if (scalar is double) return YamlFloat(node.span, scalar);
    if (scalar is String) return YamlStr(node.span, scalar);
    if (scalar is bool) return YamlBool(node.span, scalar);
    if (scalar == null) return YamlNull(node.span, null);
    throw UnimplementedError('Unsupported value: $scalar');
  }
}

class _YamlScalar<T> extends YamlNode {
  _YamlScalar(super.span, this.value);

  @override
  final T value;
}

typedef YamlInt = _YamlScalar<int>;
typedef YamlStr = _YamlScalar<String>;
typedef YamlFloat = _YamlScalar<double>;
typedef YamlBool = _YamlScalar<bool>;

// ignore: prefer_void_to_null
typedef YamlNull = _YamlScalar<Null>;

typedef YamlEntry = MapEntry<YamlNode, YamlNode>;

class YamlMap extends YamlNode {
  YamlMap(this._map) : super(_map.span);
  final yaml.YamlMap _map;

  @override
  Map get value => _map;

  Option<YamlNode> lookup(Object? key) =>
      Option.fromNullable(_map.nodes[key]).map(YamlNode._from);

  Option<YamlNode> operator [](Object? key) => lookup(key);

  Iterable<YamlEntry> get entries => _map.nodes.entries
      .map((e) => YamlEntry(YamlNode._from(e.key), YamlNode._from(e.value)));
}

class _YamlList extends YamlNode {
  _YamlList(this._list) : super(_list.span);

  final yaml.YamlList _list;

  @override
  List get value => _list;
}

TaskEither<ParseErr, YamlNode> loadYaml(
  String yamlStr,
) =>
    Either.tryCatch(
      () => YamlNode._from(yaml.loadYaml(yamlStr) as yaml.YamlNode),
      (exception, _) {
        if (exception is TypeError) {
          return ParseErr('Yaml document syntax is not supported.');
        }
        return ParseErr(
          (exception as yaml.YamlException).message,
          exception.span,
        );
      },
    ).toTaskEither();
