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
import GoogleNavigation

enum Convert {
  static func convertMapType(mapType: MapTypeDto) -> GMSMapViewType {
    switch mapType {
    case .none:
      return .none
    case .normal:
      return .normal
    case .satellite:
      return .satellite
    case .terrain:
      return .terrain
    case .hybrid:
      return .hybrid
    }
  }

  static func convertMapType(gmsMapType: GMSMapViewType) -> MapTypeDto {
    switch gmsMapType {
    case .none:
      return .none
    case .normal:
      return .normal
    case .satellite:
      return .satellite
    case .terrain:
      return .terrain
    case .hybrid:
      return .hybrid
    @unknown default:
      return .normal
    }
  }

  static func convertCameraPosition(position: GMSCameraPosition) -> CameraPositionDto {
    let target = LatLngDto(
      latitude: position.target.latitude,
      longitude: position.target.longitude
    )
    return CameraPositionDto(
      bearing: position.bearing,
      target: target,
      tilt: position.viewingAngle,
      zoom: Double(position.zoom)
    )
  }

  static func convertCameraPosition(position: CameraPositionDto) -> GMSCameraPosition {
    GMSCameraPosition(
      latitude: position.target.latitude,
      longitude: position.target.longitude,
      zoom: Float(position.zoom),
      bearing: position.bearing,
      viewingAngle: position.tilt
    )
  }

  static func convertLatLng(point: LatLngDto) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: point.latitude,
      longitude: point.longitude
    )
  }

  static func convertLatLngBounds(bounds: LatLngBoundsDto) -> GMSCoordinateBounds {
    GMSCoordinateBounds(
      coordinate: convertLatLng(point: bounds.northeast),
      coordinate: convertLatLng(point: bounds.southwest)
    )
  }

  static func convertLatLngBounds(bounds: GMSCoordinateBounds) -> LatLngBoundsDto {
    LatLngBoundsDto(
      southwest: LatLngDto(
        latitude: bounds.southWest.latitude,
        longitude: bounds.southWest.longitude
      ), northeast: LatLngDto(
        latitude: bounds.northEast.latitude,
        longitude: bounds.northEast.longitude
      )
    )
  }

  static func convertCameraPerspective(perspective: CameraPerspectiveDto)
    -> GMSNavigationCameraPerspective {
    switch perspective {
    case .tilted:
      return .tilted
    case .topDownHeadingUp:
      return .topDownHeadingUp
    case .topDownNorthUp:
      return .topDownNorthUp
    }
  }

  static func convertDeltaToPoint(dx: Double?, dy: Double?) -> CGPoint? {
    var point: CGPoint?
    if dx != nil, dy != nil {
      point = CGPoint(x: dx!, y: dy!)
    }
    return point
  }
}
