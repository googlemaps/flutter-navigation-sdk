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

import 'package:google_navigation_flutter/src/method_channel/map_view_api.dart';

/// Test implementation of MapViewAPIImpl that allows direct event injection.
///
/// This class extends MapViewAPIImpl and overrides ensureViewAPISetUp
/// to create an internal instance of ViewEventApiImpl instead of
/// setting up the real platform channel. This allows tests to inject DTO events
/// directly and verify the complete event pipeline including DTO-to-event conversion.
class TestMapViewAPIImpl extends MapViewAPIImpl {
  late ViewEventApiImpl _testEventApi;

  /// Provides access to the test event API for injecting DTO events.
  ViewEventApiImpl get testEventApi => _testEventApi;

  @override
  void ensureViewAPISetUp() {
    // Create internal event API instance instead of setting up platform channel
    _testEventApi = ViewEventApiImpl(
      viewEventStreamController: viewEventStreamControllerForTesting,
    );
  }
}
