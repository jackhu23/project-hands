// One-command project setup for macOS, Windows and Linux.
// Usage (from the repo root): fvm dart run tool/setup.dart
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main() async {
  final repoRoot = p.dirname(p.dirname(p.fromUri(Platform.script)));

  await _run('fvm', ['install'], repoRoot); // installs the version in .fvmrc
  await _run('fvm', ['flutter', 'pub', 'get'], repoRoot);

  stdout.writeln('\nSetup complete. Run the app with: fvm flutter run');
}

Future<void> _run(String executable, List<String> args, String cwd) async {
  stdout.writeln('> $executable ${args.join(' ')}');
  final process = await Process.start(
    executable,
    args,
    workingDirectory: cwd,
    runInShell: true, // resolves .bat/.cmd wrappers on Windows
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    stderr.writeln('"$executable ${args.join(' ')}" failed (exit $exitCode).');
    exit(exitCode);
  }
}
