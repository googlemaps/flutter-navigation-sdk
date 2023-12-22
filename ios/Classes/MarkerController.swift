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

/// Class for controlling [GMSMarker] instance.
class MarkerController {
  let markerId: String
  let gmsMarker = GMSMarker()
  var consumeTapEvents = false
  var registeredImage: RegisteredImage?

  init(markerId: String) {
    self.markerId = markerId
  }

  private let defaultImageDto: ImageDescriptorDto = .init()

  /// Update [GMSMarker] instance with values from pigeon [MarkerDto] class
  func update(from markerDto: MarkerDto, imageRegistry: ImageRegistry) {
    gmsMarker.isDraggable = markerDto.options.draggable
    gmsMarker.isFlat = markerDto.options.flat

    // Always set to true for platform consistency.
    gmsMarker.isTappable = true

    gmsMarker.rotation = markerDto.options.rotation
    gmsMarker.title = markerDto.options.infoWindow.title
    gmsMarker.snippet = markerDto.options.infoWindow.snippet
    gmsMarker.position = CLLocationCoordinate2D(
      latitude: markerDto.options.position.latitude,
      longitude: markerDto.options.position.longitude
    )
    gmsMarker.opacity = Float(markerDto.options.alpha)
    gmsMarker.zIndex = Int32(markerDto.options.zIndex)
    gmsMarker.groundAnchor = CGPoint(x: markerDto.options.anchor.u, y: markerDto.options.anchor.v)
    gmsMarker.infoWindowAnchor = CGPoint(
      x: markerDto.options.infoWindow.anchor.u,
      y: markerDto.options.infoWindow.anchor.v
    )

    consumeTapEvents = markerDto.options.consumeTapEvents

    if let imageId = markerDto.options.icon.registeredImageId,
       let registeredImage = imageRegistry.findRegisteredImage(imageId: imageId) {
      gmsMarker.icon = registeredImage.image
      self.registeredImage = registeredImage
    } else {
      gmsMarker.icon = nil
      registeredImage = nil
    }
  }

  func toMarkerDto() -> MarkerDto {
    let options = MarkerOptionsDto(alpha: Double(gmsMarker.opacity),
                                   anchor: MarkerAnchorDto(
                                     u: gmsMarker.groundAnchor.x,
                                     v: gmsMarker.groundAnchor.y
                                   ),
                                   draggable: gmsMarker.isDraggable,
                                   flat: gmsMarker.isFlat,
                                   consumeTapEvents: consumeTapEvents,
                                   position: LatLngDto(
                                     latitude: gmsMarker.position.latitude,
                                     longitude: gmsMarker.position.longitude
                                   ),
                                   rotation: gmsMarker.rotation,
                                   infoWindow: InfoWindowDto(
                                     title: gmsMarker.title,
                                     snippet: gmsMarker.snippet,
                                     anchor: MarkerAnchorDto(
                                       u: gmsMarker.infoWindowAnchor.x,
                                       v: gmsMarker.infoWindowAnchor.y
                                     )
                                   ), visible: gmsMarker.map != nil,
                                   zIndex: Double(gmsMarker.zIndex),
                                   icon: registeredImage?.toImageDescriptorDto() ?? defaultImageDto)
    return MarkerDto(markerId: markerId,
                     options: options)
  }
}
