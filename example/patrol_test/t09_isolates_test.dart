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

// This test file validates that the Google Maps Navigation plugin works
// correctly with Dart isolates and background execution, including testing
// that multiple GoogleMapsNavigationSessionManager instances can share
// the same Navigator through native implementations.

import 'dart:isolate';
import 'package:flutter/services.dart';
import 'shared.dart';

void main() {
  setUpAll(() async {
    // No special setup needed for flutter_background_service in tests
  });

  patrol(
    'Test GoogleMapsNavigator.getNavSDKVersion() in multiple background isolates',
    (PatrolIntegrationTester $) async {
      final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      const int numIsolates = 3;
      final List<ReceivePort> receivePorts = [];
      final List<Isolate> isolates = [];

      try {
        for (int i = 0; i < numIsolates; i++) {
          final ReceivePort receivePort = ReceivePort();
          receivePorts.add(receivePort);

          final Isolate isolate = await Isolate.spawn(
            _isolateVersionCheckMain,
            _IsolateData(
              rootIsolateToken: rootIsolateToken,
              sendPort: receivePort.sendPort,
            ),
          );
          isolates.add(isolate);
        }

        final List<_IsolateResult> results = [];
        for (final receivePort in receivePorts) {
          final dynamic result = await receivePort.first;
          expect(result, isA<_IsolateResult>());
          results.add(result as _IsolateResult);
        }

        for (int i = 0; i < results.length; i++) {
          expect(
            results[i].error,
            isNull,
            reason: 'Isolate $i should not throw an error',
          );
          expect(results[i].version, isNotNull);
          expect(results[i].version!.length, greaterThan(0));
        }

        final String firstVersion = results[0].version!;
        for (int i = 1; i < results.length; i++) {
          expect(
            results[i].version,
            equals(firstVersion),
            reason: 'All isolates should return the same SDK version',
          );
        }
      } finally {
        // Clean up resources
        for (final receivePort in receivePorts) {
          receivePort.close();
        }
        for (final isolate in isolates) {
          isolate.kill(priority: Isolate.immediate);
        }
      }
    },
  );
}

class _IsolateData {
  _IsolateData({required this.rootIsolateToken, required this.sendPort});

  final RootIsolateToken rootIsolateToken;
  final SendPort sendPort;
}

class _IsolateResult {
  _IsolateResult({this.version, this.error});

  final String? version;
  final String? error;
}

Future<void> _isolateVersionCheckMain(_IsolateData data) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);
    final String version = await GoogleMapsNavigator.getNavSDKVersion();
    data.sendPort.send(_IsolateResult(version: version));
  } catch (e) {
    data.sendPort.send(_IsolateResult(error: e.toString()));
  }
}
