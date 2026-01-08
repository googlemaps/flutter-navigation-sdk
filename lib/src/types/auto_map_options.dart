// Copyright 2024 Google LLC
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

import 'types.dart';

/// Configuration options for Android Auto and CarPlay map views.
///
/// This class contains only the settings relevant for Auto and CarPlay views,
/// excluding gesture controls and other UI elements that are handled by the system.
class AutoMapOptions {
  /// Creates map options for Android Auto and CarPlay views.
  ///
  /// [cameraPosition] - The initial positioning of the camera in the map view.
  /// [mapId] - Cloud-based map ID for custom styling.
  /// [mapType] - The type of map to display (normal, satellite, terrain, hybrid).
  /// [mapColorScheme] - The color scheme for the map (light, dark, or follow system).
  /// [forceNightMode] - Forces night mode (dark theme) regardless of system settings.
  const AutoMapOptions({
    this.cameraPosition,
    this.mapId,
    this.mapType,
    this.mapColorScheme,
    this.forceNightMode,
  });

  /// The initial positioning of the camera in the map view.
  ///
  /// Specifies the initial camera position (target location, zoom level, bearing, and tilt)
  /// when the map view is created.
  final CameraPosition? cameraPosition;

  /// Cloud-based map ID for custom styling.
  ///
  /// You can create map IDs in the Google Cloud Console to customize
  /// the appearance of your map with custom styles.
  final String? mapId;

  /// The type of map to display.
  ///
  /// Defaults to [MapType.normal] if not specified.
  final MapType? mapType;

  /// The color scheme for the map.
  ///
  /// Defaults to [MapColorScheme.followSystem] if not specified,
  /// which automatically switches between light and dark based on system settings.
  final MapColorScheme? mapColorScheme;

  /// Forces night mode (dark theme) for the map.
  ///
  /// This is different from [mapColorScheme]:
  /// - [mapColorScheme] affects the overall map appearance (roads, labels, etc.)
  /// - [forceNightMode] forces the dark theme regardless of system or time settings
  ///
  /// Use [NavigationForceNightMode.auto] to automatically switch based on time of day.
  final NavigationForceNightMode? forceNightMode;
}
