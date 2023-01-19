import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fms/src/common/io.dart' as io;
import 'package:fms/src/common/logger.dart';
import 'package:fms/src/common/types.dart';
import 'package:fms/src/download/download.dart';
import 'package:fms/src/common/error.dart';
import 'package:fms/src/parse/parser.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fms/src/icon_font_generator.dart' as icon_font_generator;

class BuildCommand extends Command {
  @override
  final String name = 'build';

  @override
  final String description =
      'Generates icon-font and its wrapper class from configuration file(s)';

  @override
  String get invocation => '${super.invocation} [configuration *.yaml(s)...]';

  BuildCommand() {
    argParser
      ..addFlag(
        'prefer-camel-case',
        help:
            'Use camelCase instead of snake_case for variable names  in output Dart classes',
        negatable: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Download icon files even if its cache is available',
        negatable: false,
      )
      ..addFlag(
        'use-yarn',
        help: 'Use yarn instead of npm',
        negatable: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Display detailed processing information',
        negatable: false,
      );
  }

  @override
  void run() async {
    final force = argResults!['force'] as bool;
    final useCamelCase = argResults!['prefer-camel-case'] as bool;
    final useYarn = argResults!['use-yarn'] as bool;
    final verbose = argResults!['verbose'] as bool;
    final configFilePaths = argResults!.rest;

    initGlobalLogger(verbose);

    if (configFilePaths.isEmpty) {
      throw UsageException(
        'Specify at least one configuration file!',
        'Usage: $invocation',
      );
    }

    final build = (File config) {
      return _build(force, useCamelCase, useYarn, config)
          .mapLeft(_showError.curry(config));
    };

    await configFilePaths
        .map(File.new)
        .map(build)
        .sequenceTaskEitherSeq()
        .run();
  }
}

TaskEither<Err, Unit> _build(
  bool force,
  bool useCamelCase,
  bool useYarn,
  File configFile,
) {
  return parseConfigYaml(configFile).flatMap(
    (config) => io.createTempDir().flatMap(
          (tmpDir) => downloadSymbolFiles(config.symbolInstances, tmpDir, force)
              .flatMap((_) => _generate(config, tmpDir, useCamelCase, useYarn))
              .flatMap((_) => io.deleteDir(tmpDir)),
        ),
  );
}

TaskEither<Err, void> _generate(
  Config config,
  Directory targetDir,
  bool useCamelCase,
  bool useYarn,
) =>
    TaskEither.tryCatch(
      () async => icon_font_generator.main([
        '--from',
        targetDir.path,
        '--out-font',
        config.outputLocation.font,
        '--out-flutter',
        config.outputLocation.flutter,
        '--class-name',
        config.familyName.value,
        if (useCamelCase) ...[
          '--naming-strategy',
          'camel',
        ],
        if (useYarn) 'yarn',
      ]),
      IOErr.new,
    );

void _showError(File file, Err error) {
  if (error is ParseErr) {
    logger.stderr('Failed to parse the configuration file: ${file.path}');
    logger.stderr('Try correcting errors and run again.');
    logger.stderr(error.message);
  } else if (error is IOErr) {
    logger.stderr('Someting went wrong while processing ${file.path}!');
    logger.stderr('${error.error}');
    logger.trace('${error.stacktrace}');
    if (!logger.isVerbose) {
      logger.stderr(
          'Try run again with --verbose option to see more detailed information.');
    }
  }
}
