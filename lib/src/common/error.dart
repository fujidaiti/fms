import 'package:source_span/source_span.dart';

abstract class Err {}

class ParseErr extends Err {
  final String message;

  ParseErr(String message, [SourceSpan? span])
      : message = span?.message(message, color: true) ?? message;

  ParseErr merge(ParseErr err) => ParseErr('$message\n${err.message}');

  bool get isEmpty => message.isEmpty;
}

class IOErr extends Err {
  final Object error;
  final StackTrace stacktrace;

  IOErr(this.error, this.stacktrace);
}
