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

extension GMSPolygon {
  static let polygonKey = "polygonId"

  func setPolygonId(_ id: String) {
    userData = [Self.polygonKey: id]
  }

  func getPolygonId() -> String {
    (userData as? [String: String])?[Self.polygonKey] ?? ""
  }

  /// Update [GMSPolygon] instance with values from pigeon polygon class
  func update(from pigeonPolygon: PolygonDto) {
    let newPath = GMSMutablePath()
    pigeonPolygon.options.points.compactMap { $0 }.forEach { point in
      newPath.addLatitude(point.latitude, longitude: point.longitude)
    }
    path = newPath

    let paths = pigeonPolygon.options.holes.compactMap { $0 }.map { hole in
      let path = GMSMutablePath()
      hole.points.compactMap { $0 }.forEach { point in
        path.addLatitude(point.latitude, longitude: point.longitude)
      }
      return path
    }
    holes = paths

    isTappable = pigeonPolygon.options.clickable
    fillColor = UIColor(from: pigeonPolygon.options.fillColor)
    geodesic = pigeonPolygon.options.geodesic
    strokeColor = UIColor(from: pigeonPolygon.options.strokeColor)
    strokeWidth = pigeonPolygon.options.strokeWidth
    zIndex = Int32(pigeonPolygon.options.zIndex)
  }

  func toPigeonPolygon() -> PolygonDto {
    let options = PolygonOptionsDto(
      points: path?.toLatLngDtos() ?? [],
      holes: holes?.map { PolygonHoleDto(points: $0.toLatLngDtos()) } ?? [],
      clickable: isTappable,
      fillColor: fillColor?.toRgb() ?? UIColor.black.toRgb()!,
      geodesic: geodesic,
      strokeColor: strokeColor?.toRgb() ?? UIColor.black.toRgb()!,
      strokeWidth: strokeWidth,
      visible: map != nil,
      zIndex: Double(zIndex)
    )
    return PolygonDto(polygonId: getPolygonId(), options: options)
  }
}
