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

import Foundation
import GoogleMaps
import GoogleNavigation

/// Options for configuring CarPlay map views.
/// Contains only settings relevant for CarPlay views.
public struct AutoMapViewOptions {
  /// The initial camera position for the map view.
  public let cameraPosition: GMSCameraPosition?

  /// Cloud-based map ID for custom styling.
  public let mapId: String?

  /// The type of map to display.
  public let mapType: GMSMapViewType?

  /// The color scheme for the map.
  public let mapColorScheme: UIUserInterfaceStyle?

  /// Forces night mode regardless of system settings.
  public let forceNightMode: GMSNavigationLightingMode?

  public init(
    cameraPosition: GMSCameraPosition? = nil, mapId: String? = nil, mapType: GMSMapViewType? = nil,
    mapColorScheme: UIUserInterfaceStyle? = nil, forceNightMode: GMSNavigationLightingMode? = nil
  ) {
    self.cameraPosition = cameraPosition
    self.mapId = mapId
    self.mapType = mapType
    self.mapColorScheme = mapColorScheme
    self.forceNightMode = forceNightMode
  }
}
