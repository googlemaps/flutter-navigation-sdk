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

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../google_maps_navigation.dart';
import 'google_maps_navigation_platform_interface.dart';
import 'inspector/inspector_ios.dart';
import 'inspector/inspector_platform.dart';
import 'method_channel/method_channel.dart';

/// Google Maps Navigation Platform iOS specific functionalities.
/// @nodoc
class GoogleMapsNavigationIOS extends GoogleMapsNavigationPlatform
    with
        CommonNavigationSessionAPI,
        CommonNavigationViewAPI,
        CommonImageRegistryAPI {
  /// Registers the iOS implementation of GoogleMapsNavigationPlatform.
  static void registerWith() {
    GoogleMapsNavigationPlatform.instance = GoogleMapsNavigationIOS();
  }

  @override
  Widget buildView(
      {required NavigationViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady}) {
    // Initialize method channel for view communication if needed.
    ensureViewAPISetUp();

    // This is used in the platform side to register the platform view.
    const String viewType = 'google_maps_navigation';

    // Build creation params used to initialize navigation view with initial parameters
    final NavigationViewCreationOptionsDto creationParams =
        buildNavigationViewCreationOptions(initializationOptions);

    return UiKitView(
      viewType: viewType,
      creationParams: creationParams.encode(),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int viewId) async {
        // Wait map to be ready before calling [onMapReady] callback
        await awaitMapReady(viewId: viewId);
        onMapReady(viewId);
      },
      gestureRecognizers: initializationOptions.gestureRecognizers,
      layoutDirection: initializationOptions.layoutDirection,
    );
  }

  @override
  @visibleForTesting
  void enableDebugInspection() {
    GoogleNavigationInspectorPlatform.instance = GoogleNavigationInspectorIOS();
  }
}
