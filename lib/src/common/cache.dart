import 'dart:io';

import 'package:path/path.dart' as p;

Directory _getCacheDir() {
  // Expects:
  //Plaatform.script.path == '**/.dart_tool/pub/bin/<package-name>/*.snapshot'
  final segments = Platform.script.pathSegments;
  final dartTool = segments[segments.length - 5];
  final packageName = segments[segments.length - 2];
  return Directory(p.join(dartTool, packageName));

  // final dartTool = Platform.script.resolve('../../..');
  // final packageName = p.basename(dartTool.resolve('..').path);
  // return Directory(p.join(dartTool.path, packageName));
}

// ignore: unnecessary_late
late final appCache = _getCacheDir();
