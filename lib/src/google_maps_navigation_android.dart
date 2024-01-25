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

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../google_maps_navigation.dart';
import 'google_maps_navigation_platform_interface.dart';
import 'inspector/inspector_android.dart';
import 'inspector/inspector_platform.dart';
import 'method_channel/method_channel.dart';

/// Google Maps Navigation Platform Android specific functionalities.
/// @nodoc
class GoogleMapsNavigationAndroid extends GoogleMapsNavigationPlatform
    with
        CommonNavigationSessionAPI,
        CommonNavigationViewAPI,
        CommonImageRegistryAPI {
  /// Registers the Android implementation of GoogleMapsNavigationPlatform.
  static void registerWith() {
    GoogleMapsNavigationPlatform.instance = GoogleMapsNavigationAndroid();
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

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: initializationOptions.gestureRecognizers,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: initializationOptions.layoutDirection,
          creationParams: creationParams.encode(),
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(
            (int viewId) async {
              // On Android the map is initialized asyncronously.
              // Wait map to be ready before calling [onMapReady] callback
              await awaitMapReady(viewId: viewId);
              onMapReady(viewId);
            },
          )
          ..create();
      },
    );
  }

  @override
  Future<void> allowBackgroundLocationUpdates(bool allow) {
    throw UnsupportedError(
        'allowBackgroundLocationUpdates(bool allow) is iOS only function and should not be called from Android.');
  }

  @override
  @visibleForTesting
  void enableDebugInspection() {
    GoogleNavigationInspectorPlatform.instance =
        GoogleNavigationInspectorAndroid();
  }
}
