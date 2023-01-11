import 'dart:io';
import 'dart:typed_data';

import 'package:fms/src/common/cache.dart';
import 'package:fms/src/common/error.dart';
import 'package:fms/src/common/io.dart' as io;
import 'package:fms/src/common/types.dart';
import 'package:fms/src/download/url.dart';
import 'package:fms/src/repository_info.dart';
import 'package:fpdart/fpdart.dart';
import 'package:internet_file/internet_file.dart';
import 'package:path/path.dart' as p;

TaskEither<Err, Iterable<File>> downloadSymbolFiles(
  List<SymbolInstance> symbolInstances,
  Directory outDir,
  bool force,
) =>
    symbolInstances.map((instance) {
      final dest = _localSymbolFile(instance.identifier, outDir);
      final url = symbolFileUrl(instance.symbol);
      return _download(url, force).flatMap(io.saveBytes.curry(dest));
    }).sequenceTaskEitherSeq();

TaskEither<Err, Uint8List> _download(String url, bool force) =>
    TaskEither.tryCatch(
      () async =>
          InternetFile.get(url, force: force, storage: LocalCacheStorage()),
      (error, _) => IOErr('$error'),
    );

File _localSymbolFile(DartIdentifier identifier, Directory workDir) {
  final filename = '${identifier.toSnakeCase()}.svg';
  return File(p.join(workDir.path, filename));
}

class LocalCacheStorage extends InternetFileStorage {
  File cacheFile(String url) => File(p.join(
        appCache.path,
        url.substring(repositoryInfo.baseUrl.length).replaceAll('/', '-'),
      ));

  @override
  Future<Uint8List?> findExist(String url, _) async {
    if (!await appCache.exists()) await appCache.create();
    final file = cacheFile(url);
    if (!await file.exists()) return null;

    return file.readAsBytes();
  }

  @override
  Future<void> save(String url, _, Uint8List bytes) async {
    final file = cacheFile(url);
    file.writeAsBytes(bytes);
  }
}
