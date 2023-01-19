import 'dart:io';
import 'dart:typed_data';

import 'package:fms/src/common/cache.dart';
import 'package:fms/src/common/error.dart';
import 'package:fpdart/fpdart.dart';

TaskEither<Err, File> saveBytes(File location, Uint8List bytes) =>
    TaskEither.tryCatch(() async => location.writeAsBytes(bytes), IOErr.new);

TaskEither<Err, Directory> createTempDir() {
  return TaskEither.tryCatch(
    () async {
      if (!await appCache.exists()) await appCache.create();
      return await appCache.createTemp();
    },
    IOErr.new,
  );
}

TaskEither<Err, Unit> deleteDir(Directory dir) {
  return TaskEither.tryCatch(
    () async => dir.delete(recursive: true).then((_) => unit),
    IOErr.new,
  );
}

TaskEither<Err, String> readFileAsString(File file) {
  return TaskEither.tryCatch(
    () async => file.readAsString(),
    IOErr.new,
  );
}
