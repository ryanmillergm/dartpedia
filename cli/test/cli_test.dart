import 'package:cli/cli.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('cli exports', () {
    test('initFileLogger returns a named logger', () {
      final logger = initFileLogger('test');

      expect(logger, isA<Logger>());
      expect(logger.name, 'test');
    });

    test('command types can be constructed from the package export', () {
      final logger = Logger('test');

      expect(SearchCommand(logger: logger), isA<SearchCommand>());
      expect(GetArticleCommand(logger: logger), isA<GetArticleCommand>());
    });
  });
}
