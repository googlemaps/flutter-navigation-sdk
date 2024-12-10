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

// Determines the initial visibility of the navigation UI on map initialization.
enum NavigationUIEnabledPreference {
  // Navigation UI gets enabled if the navigation
  // session has already been successfully started.
  case automatic
  /// Navigation UI is disabled.
  case disabled
}

struct MapConfiguration {
  // MapView related configurations
  var cameraPosition: GMSCameraPosition?
  var mapType: GMSMapViewType
  var compassEnabled: Bool
  var rotateGesturesEnabled: Bool
  var scrollGesturesEnabled: Bool
  var tiltGesturesEnabled: Bool
  var zoomGesturesEnabled: Bool
  var scrollGesturesEnabledDuringRotateOrZoom: Bool
  var cameraTargetBounds: GMSCoordinateBounds?
  var minZoomPreference: Float?
  var maxZoomPreference: Float?
  var padding: UIEdgeInsets?
}

extension MapConfiguration {
  // Applies the configuration to the given GMSMapView.
  //
  // - Parameter to: The GMSMapView to configure.
  func apply(to mapView: GMSMapView) {
    mapView.mapType = mapType
    mapView.settings.compassButton = compassEnabled
    mapView.settings.rotateGestures = rotateGesturesEnabled
    mapView.settings.scrollGestures = scrollGesturesEnabled
    mapView.settings.tiltGestures = tiltGesturesEnabled
    mapView.settings.zoomGestures = zoomGesturesEnabled
    mapView.settings
      .allowScrollGesturesDuringRotateOrZoom = scrollGesturesEnabledDuringRotateOrZoom
    mapView.cameraTargetBounds = cameraTargetBounds
    mapView.setMinZoom(
      minZoomPreference ?? kGMSMinZoomLevel,
      maxZoom: maxZoomPreference ?? kGMSMaxZoomLevel
    )
    if let padding {
      mapView.padding = padding
    }
  }

  // Applies the configuration to the given
  //
  // - Parameter to: The GMSMapView to configure.GMSMapViewOptions.
  // - Parameter withFrame: view frame as CGRect.
  func apply(to mapViewOptions: GMSMapViewOptions, withFrame frame: CGRect) {
    mapViewOptions.camera = cameraPosition
    mapViewOptions.frame = frame
  }

  // Applies camera position from the configuration to the given GMSMapView.
  //
  // - Parameter to: The GMSMapView to configure.
  func applyCameraPosition(to mapView: GMSMapView) {
    guard let cameraPosition else { return }
    mapView.camera = cameraPosition
  }
}
