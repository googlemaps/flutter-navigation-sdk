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
import 'package:flutter/widgets.dart';

import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../google_navigation_flutter.dart';

/// Callback signature for when a map view is ready.
///
/// `viewId` is the platform view's unique identifier.
/// @nodoc
typedef MapReadyCallback = void Function(int viewId);

/// Describes the type of Google map view to construct.
enum MapViewType {
  /// Navigation view supports navigation overlay, and current navigation session is displayed on the map.
  navigation,

  /// Classic map view, without navigation overlay.
  map,
}

/// Google Maps Navigation Platform Interface for iOS and Android implementations.
/// @nodoc
abstract class GoogleMapsNavigationPlatform extends PlatformInterface {
  /// Constructs a GoogleMapsNavigationPlatform.
  GoogleMapsNavigationPlatform(
    this.navigationSessionAPI,
    this.viewAPI,
    this.imageRegistryAPI,
    this.autoAPI,
  ) : super(token: _token);

  static final Object _token = Object();

  static GoogleMapsNavigationPlatform? _instance;

  /// The default instance of [GoogleMapsNavigationPlatform] to use.
  ///
  /// Defaults to [GoogleMapsNavigationPlatform].
  static GoogleMapsNavigationPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError('instance has not been set for the platform.');
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GoogleMapsNavigationPlatform] when
  /// they register themselves.
  static set instance(GoogleMapsNavigationPlatform instance) {
    _instance = instance;
    PlatformInterface.verifyToken(instance, _token);
  }

  final NavigationSessionAPIImpl navigationSessionAPI;
  final MapViewAPIImpl viewAPI;
  final ImageRegistryAPIImpl imageRegistryAPI;
  final AutoMapViewAPIImpl autoAPI;

  /// Builds and returns a classic GoogleMaps map view.
  ///
  /// This method is responsible for creating a navigation view with the
  /// provided [initializationOptions].
  ///
  /// The [onMapReady] callback is invoked once the platform view has been created
  /// and is ready for interaction.
  Widget buildMapView(
      {required MapViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady});

  /// Builds and returns a navigation view.
  ///
  /// This method is responsible for creating a navigation view with the
  /// provided [initializationOptions].
  ///
  /// The [onMapReady] callback is invoked once the platform view has been created
  /// and is ready for interaction.
  Widget buildNavigationView(
      {required MapViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady});

  /// Populates [GoogleNavigationInspectorPlatform.instance] to allow
  /// inspecting the platform map state.
  @visibleForTesting
  void enableDebugInspection() {
    throw UnimplementedError(
        'enableDebugInspection() has not been implemented.');
  }
}
