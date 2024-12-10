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

import Foundation
import GoogleMaps

extension Convert {
  static func convertNavigationUIEnabledPreference(preference: NavigationUIEnabledPreferenceDto?)
    -> NavigationUIEnabledPreference {
    switch preference {
    case .automatic:
      return .automatic
    case .disabled:
      return .disabled
    default:
      return .disabled
    }
  }

  static func convertMapOptions(_ mapOptions: MapOptionsDto)
    -> MapConfiguration {
    let cameraTargetBounds: GMSCoordinateBounds?
    if let bounds = mapOptions.cameraTargetBounds {
      cameraTargetBounds = convertLatLngBounds(bounds: bounds)
    } else {
      cameraTargetBounds = nil
    }

    return MapConfiguration(
      cameraPosition: convertCameraPosition(position: mapOptions.cameraPosition),
      mapType: convertMapType(mapType: mapOptions.mapType),
      compassEnabled: mapOptions.compassEnabled,
      rotateGesturesEnabled: mapOptions.rotateGesturesEnabled,
      scrollGesturesEnabled: mapOptions.scrollGesturesEnabled,
      tiltGesturesEnabled: mapOptions.tiltGesturesEnabled,
      zoomGesturesEnabled: mapOptions.zoomGesturesEnabled,
      scrollGesturesEnabledDuringRotateOrZoom: mapOptions.scrollGesturesEnabledDuringRotateOrZoom,
      cameraTargetBounds: cameraTargetBounds,
      minZoomPreference: mapOptions.minZoomPreference.map { Float($0) },
      maxZoomPreference: mapOptions.maxZoomPreference.map { Float($0) },
      padding: UIEdgeInsets(
        top: CGFloat(mapOptions.padding?.top ?? 0),
        left: CGFloat(mapOptions.padding?.left ?? 0),
        bottom: CGFloat(mapOptions.padding?.bottom ?? 0),
        right: CGFloat(mapOptions.padding?.right ?? 0)
      )
    )
  }
}
