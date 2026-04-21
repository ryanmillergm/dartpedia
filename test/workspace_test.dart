import 'dart:io';
import 'dart:convert';

import 'package:test/test.dart';

void main() {
  const packages = <String>['cli', 'command_runner', 'wikipedia'];

  group('workspace package tests', () {
    for (final package in packages) {
      test('$package passes dart test', () async {
        final process = await Process.start(
          'dart',
          ['test', '-r', 'expanded'],
          workingDirectory: package,
          runInShell: true,
        );

        final stdoutBuffer = StringBuffer();
        final stderrBuffer = StringBuffer();

        final stdoutDone = process.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
              stdoutBuffer.writeln(line);
              stdout.writeln('[$package] $line');
            });

        final stderrDone = process.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
              stderrBuffer.writeln(line);
              stderr.writeln('[$package] $line');
            });

        final exitCode = await process.exitCode;
        await Future.wait([stdoutDone, stderrDone]);

        expect(
          exitCode,
          0,
          reason:
              'Package "$package" failed.\n'
              'stdout:\n${stdoutBuffer.toString().trim()}\n\n'
              'stderr:\n${stderrBuffer.toString().trim()}',
        );
      });
    }
  });
}
