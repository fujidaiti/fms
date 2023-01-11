import 'package:fms/src/common/types.dart';
import 'package:fms/src/repository_info.dart';

// example url:
// ${baseUrl}/10k/materialsymbolsrounded/10k_wght700gradN25fill1_40px.svg
String symbolFileUrl(MaterialSymbol symbol) {
  final name = symbol.name.toSnakeCase();
  final style = _style[symbol.theme.style]!;
  final fill = _fill[symbol.theme.fill]!;
  final weight = _weight[symbol.theme.weight]!;
  final grade = _grade[symbol.theme.grade]!;
  final size = _size[symbol.theme.size]!;
  final filename = [name, '$weight$grade$fill', '$size.svg']
      .where((s) => s.isNotEmpty)
      .join('_');
  return '${repositoryInfo.baseUrl}/$name/$style/$filename';
}

const _style = {
  Style.outlined: 'materialsymbolsoutlined',
  Style.rounded: 'materialsymbolsrounded',
  Style.sharp: 'materialsymbolssharp',
};

const _fill = {
  FillAxis.filled: 'fill1',
  FillAxis.notFilled: '',
};

const _weight = {
  WeightAxis.w100: 'wght100',
  WeightAxis.w200: 'wght200',
  WeightAxis.w300: 'wght300',
  WeightAxis.w400: '',
  WeightAxis.w500: 'wght500',
  WeightAxis.w600: 'wght600',
  WeightAxis.w700: 'wght700',
};

const _grade = {
  GradeAxis.gN25: 'gradN25',
  GradeAxis.g0: '',
  GradeAxis.g200: 'grad200',
};

const _size = {
  SizeAxis.s20: '20px',
  SizeAxis.s24: '24px',
  SizeAxis.s40: '40px',
  SizeAxis.s48: '48px',
};
