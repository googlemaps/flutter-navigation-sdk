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

extension GMSCircle {
  static let circleKey = "circleId"

  func setCircleId(_ id: String) {
    userData = [Self.circleKey: id]
  }

  func getCircleId() -> String {
    (userData as? [String: String])?[Self.circleKey] ?? ""
  }

  /// Update [GMSCircle] instance with values from pigeon circle class
  func update(from pigeonCircle: CircleDto) {
    position = CLLocationCoordinate2D(
      latitude: pigeonCircle.options.position.latitude,
      longitude: pigeonCircle.options.position.longitude
    )
    radius = pigeonCircle.options.radius
    strokeColor = UIColor(from: pigeonCircle.options.strokeColor)
    strokeWidth = pigeonCircle.options.strokeWidth
    fillColor = UIColor(from: pigeonCircle.options.fillColor)
    isTappable = pigeonCircle.options.clickable
    zIndex = Int32(pigeonCircle.options.zIndex)
  }

  func toPigeonCircle() -> CircleDto {
    let options = CircleOptionsDto(
      position: LatLngDto(latitude: position.latitude, longitude: position.longitude),
      radius: radius,
      strokeWidth: strokeWidth,
      strokeColor: strokeColor?.toRgb() ?? UIColor.black.toRgb()!,
      strokePattern: [],
      fillColor: fillColor?.toRgb() ?? UIColor.black.toRgb()!,
      zIndex: Double(zIndex),
      visible: map != nil,
      clickable: isTappable
    )
    return CircleDto(circleId: getCircleId(), options: options)
  }
}
