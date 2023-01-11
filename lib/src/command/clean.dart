import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:fms/src/common/cache.dart';

class CleanCommand extends Command {
  @override
  final String name = 'clean';

  @override
  final String description = 'Clear the caches.';

  @override
  void run() async {
    if (!await appCache.exists()) return;
    await appCache.delete(recursive: true);
    final logger = Logger.standard();
    logger.stdout('Removed all the cache files!');
  }
}
