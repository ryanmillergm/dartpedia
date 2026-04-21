import 'dart:async';

import 'package:command_runner/command_runner.dart';
import 'package:test/test.dart';

class PrettyEchoTestCommand extends Command {
  PrettyEchoTestCommand() {
    addFlag(
      'blue-only',
      abbr: 'b',
      help: 'When true, the echoed text will all be blue.',
    );
  }

  @override
  String get name => 'echo';

  @override
  bool get requiresArgument => true;

  @override
  String get description => 'Print input, but colorful.';

  @override
  String? get help =>
      'echos a String provided as an argument with ANSI coloring,';

  @override
  String? get valueHelp => 'STRING';

  @override
  FutureOr<String> run(ArgResults arg) {
    if (arg.commandArg == null) {
      throw ArgumentException(
        'This argument requires one positional argument',
        name,
      );
    }

    final List<String> prettyWords = [];
    final words = arg.commandArg!.split(' ');
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      switch (i % 3) {
        case 0:
          prettyWords.add(word.titleText);
        case 1:
          prettyWords.add(word.instructionText);
        case 2:
          prettyWords.add(word.errorText);
      }
    }

    return prettyWords.join(' ');
  }
}

void main() {
  group('CommandRunner', () {
    test('parses the example echo command and captures its flag', () {
      final runner = CommandRunner()..addCommand(PrettyEchoTestCommand());

      final results = runner.parse(['echo', 'hello world', '--blue-only']);

      expect(results.command?.name, 'echo');
      expect(results.commandArg, 'hello world');
      expect(results.flag('blue-only'), isTrue);
    });

    test('runs the example echo command and emits formatted output', () async {
      final output = <String>[];
      final runner =
          CommandRunner(onOutput: output.add)..addCommand(PrettyEchoTestCommand());

      await runner.run(['echo', 'hello world']);

      expect(output, hasLength(1));
      expect(output.single, contains('hello'));
      expect(output.single, contains('world'));
      expect(output.single, contains(ansiEscapeLiteral));
    });

    test('throws when the example echo command is missing its argument', () {
      final runner = CommandRunner()..addCommand(PrettyEchoTestCommand());

      expect(
        () => runner.parse(['echo']),
        returnsNormally,
      );

      expect(
        () => resultsRunWithoutArgument(runner),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

Future<void> resultsRunWithoutArgument(CommandRunner runner) async {
  await runner.run(['echo']);
}
