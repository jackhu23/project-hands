// Project setup check for macOS, Windows and Linux.
// Run from the repo root, after `fvm install`: fvm dart run tool/setup.dart
//
// `fvm dart run` needs the pinned SDK and resolves packages before this script
// starts, so installing Flutter and running pub get happen outside it. This
// script verifies the result and is the place for future setup steps.
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main() async {
  final repoRoot = p.dirname(p.dirname(p.fromUri(Platform.script)));

  final fvmrc = await File(p.join(repoRoot, '.fvmrc')).readAsString();
  final pinned = (jsonDecode(fvmrc) as Map<String, Object?>)['flutter'];

  final result = await Process.run(
    'fvm',
    ['flutter', '--version', '--machine'],
    workingDirectory: repoRoot,
    runInShell: true, // resolves .bat/.cmd wrappers on Windows
  );
  if (result.exitCode != 0) {
    _fail('"fvm flutter --version" failed:\n${result.stderr}');
  }
  final active = (jsonDecode(
    result.stdout as String,
  ) as Map<String, Object?>)['frameworkVersion'];

  if (active != pinned) {
    _fail(
      'Flutter $active is active, but .fvmrc pins $pinned. '
      'Run `fvm install` from the repo root, then rerun this script.',
    );
  }
  stdout.writeln('Setup OK: Flutter $active (pinned in .fvmrc).');
  stdout.writeln('Run the app with: fvm flutter run');
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
