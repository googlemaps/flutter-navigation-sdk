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

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

/// Test-specific implementation of GoogleMapsNavigationPlatform.
///
/// This implementation uses a simple mock widget instead of AndroidView/UiKitView,
/// allowing tests to run without platform-specific dependencies and ensuring
/// callbacks are invoked synchronously.
class TestGoogleMapsNavigationPlatform extends GoogleMapsNavigationPlatform {
  /// Creates a TestGoogleMapsNavigationPlatform.
  TestGoogleMapsNavigationPlatform(
    NavigationSessionAPIImpl navigationSessionAPI,
    MapViewAPIImpl viewAPI,
    AutoMapViewAPIImpl autoAPI,
    ImageRegistryAPIImpl imageRegistryAPI,
  ) : super(navigationSessionAPI, viewAPI, imageRegistryAPI, autoAPI);

  /// Counter for generating unique view IDs in tests
  static int _nextViewId = 1;

  /// The most recently created view ID
  /// Useful for tests to get the view ID without searching the widget tree
  static int? get lastCreatedViewId => _lastCreatedViewId;
  static int? _lastCreatedViewId;

  @override
  Widget buildMapView({
    required MapViewInitializationOptions initializationOptions,
    required PlatformViewCreatedCallback onPlatformViewCreated,
    required MapReadyCallback onMapReady,
  }) {
    return _buildMockView(
      mapViewType: MapViewType.map,
      initializationOptions: initializationOptions,
      onPlatformViewCreated: onPlatformViewCreated,
      onMapReady: onMapReady,
    );
  }

  @override
  Widget buildNavigationView({
    required MapViewInitializationOptions initializationOptions,
    required PlatformViewCreatedCallback onPlatformViewCreated,
    required MapReadyCallback onMapReady,
  }) {
    return _buildMockView(
      mapViewType: MapViewType.navigation,
      initializationOptions: initializationOptions,
      onPlatformViewCreated: onPlatformViewCreated,
      onMapReady: onMapReady,
    );
  }

  Widget _buildMockView({
    required MapViewType mapViewType,
    required MapViewInitializationOptions initializationOptions,
    required PlatformViewCreatedCallback onPlatformViewCreated,
    required MapReadyCallback onMapReady,
  }) {
    // Initialize method channel for view communication if needed.
    viewAPI.ensureViewAPISetUp();

    // Build creation params (even though we don't use them in mock this conversion call is tested)
    viewAPI.buildPlatformViewCreationOptions(
      mapViewType,
      initializationOptions,
    );

    // Return a mock widget that simulates the platform view lifecycle
    return _MockPlatformView(
      onPlatformViewCreated: onPlatformViewCreated,
      onMapReady: onMapReady,
    );
  }

  @override
  @visibleForTesting
  void enableDebugInspection() {
    // No-op for testing
  }
}

/// Mock platform view widget that simulates platform view lifecycle.
///
/// This widget synchronously calls the platform view created and map ready
/// callbacks during the build phase, avoiding the asynchronous complexity
/// of real platform views.
class _MockPlatformView extends StatefulWidget {
  const _MockPlatformView({
    required this.onPlatformViewCreated,
    required this.onMapReady,
  });

  final PlatformViewCreatedCallback onPlatformViewCreated;
  final MapReadyCallback onMapReady;

  @override
  State<_MockPlatformView> createState() => _MockPlatformViewState();
}

class _MockPlatformViewState extends State<_MockPlatformView> {
  late int _viewId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewId = TestGoogleMapsNavigationPlatform._nextViewId++;
    // Store this as the last created view ID so tests can access it
    TestGoogleMapsNavigationPlatform._lastCreatedViewId = _viewId;

    // Call callbacks after this frame to simulate platform view lifecycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialized) {
        _initialized = true;
        widget.onPlatformViewCreated(_viewId);
        widget.onMapReady(_viewId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return a simple container to represent the platform view
    // Store the viewId in the widget key so tests can access it
    return Container(
      key: ValueKey<int>(_viewId),
      color: const Color(0xFFE0E0E0),
      child: Center(child: Text('Mock Map View $_viewId')),
    );
  }
}

/// Test-specific implementation of NavigationSessionAPI
class TestNavigationSessionAPIImpl extends NavigationSessionAPIImpl {
  @override
  Future<void> allowBackgroundLocationUpdates(bool allow) async {
    // No-op for testing
  }
}
