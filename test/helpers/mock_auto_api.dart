// Copyright 2025 Google LLC
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

import 'package:google_navigation_flutter/src/method_channel/auto_view_api.dart';
import 'package:google_navigation_flutter/src/method_channel/messages.g.dart';

/// Test implementation of AutoMapViewAPIImpl that allows direct event injection.
///
/// This class extends AutoMapViewAPIImpl and overrides ensureAutoViewApiSetUp
/// to create an internal instance of AutoViewEventApiImpl instead of
/// setting up the real platform channel. This allows tests to inject DTO events
/// directly and verify the complete event pipeline including DTO-to-event conversion.
class TestAutoMapViewAPIImpl extends AutoMapViewAPIImpl {
  AutoViewEventApiImpl? _testEventApi;
  bool _testEventApiSetUp = false;

  /// Provides access to the test event API for injecting DTO events.
  AutoViewEventApiImpl get testEventApi {
    if (_testEventApi == null) {
      ensureAutoViewApiSetUp();
    }
    return _testEventApi!;
  }

  @override
  void ensureAutoViewApiSetUp() {
    if (!_testEventApiSetUp) {
      // Create internal event API instance instead of setting up platform channel
      _testEventApi = AutoViewEventApiImpl(
        viewEventStreamController: autoEventStreamControllerForTesting,
      );
      // Set up the event API so it can receive events from platform
      AutoViewEventApi.setUp(_testEventApi);
      _testEventApiSetUp = true;
    }
  }
}
