import 'package:cli_util/cli_logging.dart';

Logger _logger = Logger.standard();

Logger get logger => _logger;

void initGlobalLogger(bool verbose) {
  _logger = verbose ? Logger.verbose() : Logger.standard();
}
