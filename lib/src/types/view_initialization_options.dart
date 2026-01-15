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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

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
/// {@category Map View}
@immutable
class MapViewInitializationOptions {
  /// Creates a new instance of [MapViewInitializationOptions ] with the given initial
  /// parameters to configure the navigation view.
  const MapViewInitializationOptions({
    required this.layoutDirection,
    required this.mapOptions,
    this.navigationViewOptions,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  });

  /// The initial map options for the map view.
  final MapOptions mapOptions;

  /// The initial navigation options for the navigation view.
  final NavigationViewOptions? navigationViewOptions;

  /// A direction in which text flows on the widget.
  final TextDirection layoutDirection;

  /// Specifies the gestures to be forwarded to the `PlatformView` for processing.
  ///
  /// It allows the customization of gesture handling within the navigation view by
  /// designating which gestures should be claimed by the platform view. By default,
  /// it's an empty set, implying no gestures will be forwarded.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  @override
  String toString() =>
      'MapViewInitializationOptions('
      'layoutDirection: $layoutDirection, '
      'mapOptions: $mapOptions, '
      'navigationViewOptions: $navigationViewOptions, '
      'gestureRecognizers: $gestureRecognizers'
      ')';
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
/// {@category Map View}
@immutable
class MapOptions {
  /// Creates a new instance of [MapOptions] with the given initial
  /// parameters to configure the map view.
  const MapOptions({
    this.cameraPosition = const CameraPosition(),
    this.mapType = MapType.normal,
    this.compassEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.scrollGesturesEnabledDuringRotateOrZoom = true,
    this.mapToolbarEnabled = true,
    this.minZoomPreference,
    this.maxZoomPreference,
    this.zoomControlsEnabled = true,
    this.cameraTargetBounds,
    this.padding,
    this.mapId,
    this.mapColorScheme = MapColorScheme.followSystem,
  }) : assert(
         minZoomPreference == null ||
             maxZoomPreference == null ||
             minZoomPreference <= maxZoomPreference,
         'minZoomPreference must be less than or equal to maxZoomPreference.',
       );

  /// The initial positioning of the camera in the map view.
  final CameraPosition cameraPosition;

  /// The type of map to display, specified using [MapType] enum values.
  final MapType mapType;

  /// Specifies whether the compass should be enabled.
  ///
  /// The compass is an icon on the map that indicates the direction of north on the map.
  /// If enabled, it is only shown when the camera is tilted or rotated away from
  /// its default orientation (tilt of 0 and a bearing of 0).
  ///
  /// By default, the compass is enabled.
  final bool compassEnabled;

  /// Specifies whether rotate gestures should be enabled.
  ///
  /// If enabled, users can use a two-finger rotate gesture to rotate the camera.
  /// If disabled, users cannot rotate the camera via gestures.
  /// This setting doesn't restrict the user from tapping the compass icon to reset the camera orientation,
  /// nor does it restrict programmatic movements and animation of the camera.
  ///
  /// By default, the rotation gestures are enabled.
  final bool rotateGesturesEnabled;

  /// Specifies whether scroll gestures should be enabled.
  ///
  /// By default, the scroll gestures are enabled.
  final bool scrollGesturesEnabled;

  /// Specifies whether tilt gestures should be enabled.
  ///
  /// By default, the tilt gestures are enabled.
  final bool tiltGesturesEnabled;

  /// Specifies whether zoom gestures should be enabled.
  ///
  /// By default, the zoom gestures enabled.
  final bool zoomGesturesEnabled;

  /// Specifies whether scroll gestures during rotate or zoom should be enabled.
  ///
  /// If enabled, users can swipe to pan the camera. If disabled, swiping has no effect.
  /// This setting doesn't restrict programmatic movement and animation of the camera.
  ///
  /// By default, the zoom gestures enabled.
  final bool scrollGesturesEnabledDuringRotateOrZoom;

  /// Specifies whether the mapToolbar should be enabled. Only applicable on Android.
  ///
  /// If enabled, and the Map Toolbar can be shown in the current context,
  /// users will see a bar with various context-dependent actions.
  ///
  /// By default, the Map Toolbar is enabled.
  final bool mapToolbarEnabled;

  /// Specifies a preferred lower bound for camera zoom.
  ///
  /// Null value means unbounded.
  final double? minZoomPreference;

  /// Specifies a preferred lower bound for camera zoom.
  ///
  /// Null value means unbounded.
  /// Null by default (not limited).
  final double? maxZoomPreference;

  /// Specifies whether the zoom controls should be enabled. Only applicable on Android.
  ///
  /// By default, the zoom controls are enabled.
  final bool zoomControlsEnabled;

  /// Specifies a bounds to constrain the camera target, so that when users scroll and pan the map,
  /// the camera target does not move outside these bounds.
  ///
  /// Null by default (unbounded).
  final LatLngBounds? cameraTargetBounds;

  /// Specifies the initial padding for the map view.
  ///
  /// Null by default (no padding).
  final EdgeInsets? padding;

  /// The map ID for cloud-based map styling.
  ///
  /// A map ID is a unique identifier that represents a single map instance.
  /// This value can only be set at map initialization and cannot be changed afterwards.
  /// Map IDs are created in Google Cloud Console and can be used to configure
  /// advanced features like cloud-based map styling.
  ///
  /// See https://developers.google.com/maps/documentation/get-map-id
  /// for more information about map IDs and how to create them.
  ///
  /// Null by default (no map ID).
  final String? mapId;

  /// The map color scheme mode for the map view.
  ///
  /// Controls whether the map should use light, dark, or system-following color
  /// scheme. This setting affects the map tiles and basic map styling.
  ///
  /// **Important:** For navigation views, this setting only controls the map
  /// tile colors when navigation UI is **disabled**. When navigation UI is
  /// enabled, use [NavigationViewOptions.forceNightMode] to control both the
  /// navigation UI and map tile colors.
  ///
  /// For map-only views (GoogleMapsMapView), this setting always controls the
  /// map tile colors.
  ///
  /// Defaults to [MapColorScheme.followSystem].
  final MapColorScheme mapColorScheme;

  @override
  String toString() =>
      'MapOptions('
      'cameraPosition: $cameraPosition, '
      'mapType: $mapType, '
      'compassEnabled: $compassEnabled, '
      'rotateGesturesEnabled: $rotateGesturesEnabled, '
      'scrollGesturesEnabled: $scrollGesturesEnabled, '
      'tiltGesturesEnabled: $tiltGesturesEnabled, '
      'zoomGesturesEnabled: $zoomGesturesEnabled, '
      'scrollGesturesEnabledDuringRotateOrZoom: $scrollGesturesEnabledDuringRotateOrZoom, '
      'mapToolbarEnabled: $mapToolbarEnabled, '
      'minZoomPreference: $minZoomPreference, '
      'maxZoomPreference: $maxZoomPreference, '
      'zoomControlsEnabled: $zoomControlsEnabled, '
      'cameraTargetBounds: $cameraTargetBounds, '
      'padding: $padding, '
      'mapId: $mapId, '
      'mapColorScheme: $mapColorScheme'
      ')';
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
    this.forceNightMode = NavigationForceNightMode.auto,
    this.androidStylingOptions,
    this.iosStylingOptions,
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

  /// Controls the navigation night mode for Navigation UI and map tiles.
  ///
  /// **When navigation UI is enabled:** This setting controls both the
  /// navigation UI elements (turn-by-turn guidance, route preview, etc.) and
  /// the map tile colors. The [MapOptions.mapColorScheme] setting is ignored
  /// in this case.
  ///
  /// **When navigation UI is disabled:** This setting has no effect. Use
  /// [MapOptions.mapColorScheme] to control the map tile colors instead.
  ///
  /// Defaults to [NavigationForceNightMode.auto], which lets the SDK automatically
  /// determine day or night mode based on time and location.
  final NavigationForceNightMode forceNightMode;

  /// Styling options for the navigation UI on Android.
  ///
  /// These options control the appearance of the navigation header and footer,
  /// including colors and text sizes. Only applicable on Android platform.
  /// If null, platform defaults will be used.
  final AndroidNavigationStylingOptions? androidStylingOptions;

  /// Styling options for the navigation UI on iOS.
  ///
  /// These options control the appearance of the navigation header,
  /// including background colors and text colors. Only applicable on iOS platform.
  /// If null, platform defaults will be used.
  final IOSNavigationStylingOptions? iosStylingOptions;

  @override
  String toString() =>
      'NavigationViewOptions('
      'navigationUIEnabledPreference: $navigationUIEnabledPreference, '
      'forceNightMode: $forceNightMode, '
      'androidStylingOptions: $androidStylingOptions, '
      'iosStylingOptions: $iosStylingOptions'
      ')';
}
