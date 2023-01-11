import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fms/fms.dart';

Future<void> main(List<String> args) async {
  final r = CommandRunner(
    'fms',
    "Brings Google's Material symbols to your flutter project.",
  )
    ..addCommand(BuildCommand())
    ..addCommand(CleanCommand());

  await r.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print('${error.message}\n');
    print(error.usage);
    exit(64); // Exit code 64 indicates a usage error.
  });

  // TODO; Return an appropriate code
  exit(0);
}
