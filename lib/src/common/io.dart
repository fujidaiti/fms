import 'dart:io';
import 'dart:typed_data';

import 'package:fms/src/common/cache.dart';
import 'package:fms/src/common/error.dart';
import 'package:fpdart/fpdart.dart';

TaskEither<Err, File> saveBytes(File location, Uint8List bytes) =>
    TaskEither.tryCatch(
      () async => location.writeAsBytes(bytes),
      (error, _) => IOErr((error as FileSystemException).message),
    );

TaskEither<Err, Directory> createTempDir() {
  return TaskEither.tryCatch(
    () async {
      if (!await appCache.exists()) await appCache.create();
      return await appCache.createTemp();
    },
    (error, _) => IOErr('$error'),
  );
}

TaskEither<Err, Unit> deleteDir(Directory dir) {
  return TaskEither.tryCatch(
    () async => dir.delete(recursive: true).then((_) => unit),
    (error, _) => IOErr('$error'),
  );
}

TaskEither<Err, String> readFileAsString(File file) {
  return TaskEither.tryCatch(
    () async => file.readAsString(),
    (error, _) => IOErr('$error'),
  );
}
