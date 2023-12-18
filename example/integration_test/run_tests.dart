// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:io';
import 'package:pub_semver/pub_semver.dart';

// List of files to test
final List<String> files = <String>[
  'integration_test/initialization_test.dart',
  'integration_test/session_test.dart',
  'integration_test/navigation_test.dart',
  'integration_test/navigation_ui_test.dart',
  'integration_test/camera_test.dart',
  'integration_test/map_test.dart',
  'integration_test/event_listener_test.dart',
  'integration_test/marker_polygon_polyline_circle_test.dart'
];

/// Runs patrol integration tests in specified order.
///
/// Usage:
/// dart run_tests.dart
void main(List<String> arguments) async {
  final VersionConstraint patrolVersionConstraint =
      VersionConstraint.parse('>=2.4.0 <2.5.0');

  if (!await checkPatrolVersion(patrolVersionConstraint)) {
    stderr.writeln(
        'patrol_cli matching version constraints $patrolVersionConstraint is required.');
    exit(1);
  }

  final List<String> patrolArguments = <String>['test', '-t', files.join(',')];

  // Pass command line arguments to patrol.
  patrolArguments.addAll(arguments);

  final Process process = await Process.start(
    'patrol',
    patrolArguments,
    runInShell: true,
  );

  // Stream stdout to console.
  process.stdout.transform(utf8.decoder).listen((String data) {
    stdout.write(data);
  });

  // Stream stderr to console.
  process.stderr.transform(utf8.decoder).listen((String data) {
    stderr.write(data);
  });

  final int exitCode = await process.exitCode;
  if (exitCode != 0) {
    exit(exitCode); // Exit with the same exit code as the patrol command.
  }
}

Future<bool> checkPatrolVersion(
    VersionConstraint patrolVersionConstraint) async {
  final ProcessResult result =
      await Process.run('patrol', <String>['--version'], runInShell: true);
  final String output = result.stdout as String;
  final RegExpMatch? match =
      RegExp(r'patrol_cli v(\d+\.\d+\.\d+)').firstMatch(output);

  if (match != null) {
    final Version version = Version.parse(match.group(1)!);
    return version.allowsAny(patrolVersionConstraint);
  }

  return false;
}
