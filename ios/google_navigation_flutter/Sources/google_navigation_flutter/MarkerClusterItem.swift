// Copyright 2026 Google LLC
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
import GoogleMapsUtils

/// Wrapper class that makes a marker compatible with the clustering library.
/// Implements GMUClusterItem protocol required by GMUClusterManager.
class MarkerClusterItem: NSObject, GMUClusterItem {
  let markerId: String
  let clusterManagerId: String
  private var markerDto: MarkerDto
  var registeredImage: RegisteredImage?
  var consumeTapEvents: Bool

  var position: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: markerDto.options.position.latitude,
      longitude: markerDto.options.position.longitude
    )
  }

  init(
    markerId: String,
    clusterManagerId: String,
    markerDto: MarkerDto,
    registeredImage: RegisteredImage?,
    consumeTapEvents: Bool
  ) {
    self.markerId = markerId
    self.clusterManagerId = clusterManagerId
    self.markerDto = markerDto
    self.registeredImage = registeredImage
    self.consumeTapEvents = consumeTapEvents
    super.init()
  }

  /// Returns the marker data transfer object.
  func getMarkerDto() -> MarkerDto {
    markerDto
  }

  /// Updates the marker options.
  func updateMarkerOptions(
    newMarkerDto: MarkerDto,
    newRegisteredImage: RegisteredImage?,
    newConsumeTapEvents: Bool
  ) {
    markerDto = newMarkerDto
    registeredImage = newRegisteredImage
    consumeTapEvents = newConsumeTapEvents
  }
}
