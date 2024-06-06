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
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import '../../google_navigation_flutter.dart';

/// Encapsulates the initial configuration required to initialize the navigation map view.
///
/// This class is used to specify various map and navigation settings at the time of map initialization.
/// Example:
/// ```dart
/// final settings = NavigationViewInitializationOptions(
///   mapOptions: MapOptions(
///     cameraPosition: CameraPosition(
///       target: LatLng(37.4219999,-122.0840575),
///       zoom: 14.4746,
///     ),
///     mapType: MapType.normal,
///     compassEnabled: true,
///     // ... other parameters
///   )
/// );
/// ```
/// {@category Navigation View}
@immutable
class NavigationViewInitializationOptions {
  /// Creates a new instance of [NavigationViewInitializationOptions] with the given initial
  /// parameters to configure the navigation view.
  const NavigationViewInitializationOptions({
    required this.layoutDirection,
    required this.mapOptions,
    required this.navigationViewOptions,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// The initial map options for the map view.
  final MapOptions mapOptions;

  /// The initial navigation options for the navigation view.
  final NavigationViewOptions navigationViewOptions;

  /// A direction in which text flows on the widget.
  final TextDirection layoutDirection;

  /// Specifies the gestures to be forwarded to the `PlatformView` for processing.
  ///
  /// It allows the customization of gesture handling within the navigation view by
  /// designating which gestures should be claimed by the platform view. By default,
  /// it's an empty set, implying no gestures will be forwarded.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
}

/// Encapsulates the initial configuration required to initialize the google map view.
///
/// This class is used to specify various map settings at the time of map initialization.
/// Example:
/// ```dart
/// final settings = MapOptions(
///   cameraPosition: CameraPosition(
///     target: LatLng(37.4219999,-122.0840575),
///     zoom: 14.4746,
///   ),
///   mapType: MapType.normal,
///   compassEnabled: true,
///   // ... other parameters
/// );
/// ```
/// {@category Navigation View}
@immutable
class MapOptions {
  /// Creates a new instance of [MapOptions] with the given initial
  /// parameters to configure the map view.
  const MapOptions({
    required this.cameraPosition,
    required this.mapType,
    required this.compassEnabled,
    required this.rotateGesturesEnabled,
    required this.scrollGesturesEnabled,
    required this.tiltGesturesEnabled,
    required this.zoomGesturesEnabled,
    required this.scrollGesturesEnabledDuringRotateOrZoom,
    required this.mapToolbarEnabled,
    required this.minZoomPreference,
    required this.maxZoomPreference,
    required this.zoomControlsEnabled,
    required this.cameraTargetBounds,
  }) : assert(
            minZoomPreference == null ||
                maxZoomPreference == null ||
                minZoomPreference <= maxZoomPreference,
            'minZoomPreference must be less than or equal to maxZoomPreference.');

  /// The initial positioning of the camera in the map view.
  final CameraPosition cameraPosition;

  /// The type of map to display, specified using [MapType] enum values.
  final MapType mapType;

  /// Specifies whether the compass should be enabled.
  final bool compassEnabled;

  /// Specifies whether rotate gestures should be enabled.
  final bool rotateGesturesEnabled;

  /// Specifies whether scroll gestures should be enabled.
  final bool scrollGesturesEnabled;

  /// Specifies whether tilt gestures should be enabled.
  final bool tiltGesturesEnabled;

  /// Specifies whether zoom gestures should be enabled.
  final bool zoomGesturesEnabled;

  /// Specifies whether scroll gestures during rotate or zoom should be enabled.
  final bool scrollGesturesEnabledDuringRotateOrZoom;

  /// Specifies whether the mapToolbar should be enabled. Only applicable on Android.
  final bool mapToolbarEnabled;

  /// Specifies a preferred lower bound for camera zoom.
  ///
  /// Null value means unbounded.
  final double? minZoomPreference;

  /// Specifies a preferred upper bound for camera zoom.
  ///
  /// Null value means unbounded.
  final double? maxZoomPreference;

  /// Specifies whether the zoom controls should be enabled. Only applicable on Android.
  final bool zoomControlsEnabled;

  /// Specifies a bounds to constrain the camera target, so that when users scroll and pan the map,
  /// the camera target does not move outside these bounds.
  final LatLngBounds? cameraTargetBounds;
}

/// Determines the initial visibility of the navigation UI on map initialization.
/// {@category Navigation View}
enum NavigationUIEnabledPreference {
  /// Navigation UI gets enabled if the navigation
  /// session has already been successfully started.
  automatic,

  /// Navigation UI is disabled.
  disabled,
}

/// Encapsulates the initial configuration required to initialize the navigation view.
///
/// This class is used to specify various map settings at the time of map initialization.
/// {@category Navigation View}
@immutable
class NavigationViewOptions {
  /// Creates a new instance of [NavigationViewOptions] with the given initial
  /// parameters to configure the navigation view.
  const NavigationViewOptions({
    this.navigationUIEnabledPreference =
        NavigationUIEnabledPreference.automatic,
  });

  /// Determines the initial visibility of the navigation UI on map initialization.
  ///
  /// If not set, by default set to [NavigationUIEnabledPreference.automatic], meaning
  /// the navigation UI gets enabled if the navigation
  /// session has already been successfully started.
  ///
  /// If set to [NavigationUIEnabledPreference.disabled], navigation view
  /// initially displays a classic map view.
  final NavigationUIEnabledPreference navigationUIEnabledPreference;
}
