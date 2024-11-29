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

extension GMSPolyline {
  static let polylineKey = "polylineId"
  func setPolylineId(_ id: String) {
    userData = [Self.polylineKey: id]
  }

  func getPolylineId() -> String {
    (userData as? [String: String])?[Self.polylineKey] ?? ""
  }

  /// Update [GMSPolyline] instance with values from pigeon polyline class
  func update(from pigeonPolyline: PolylineDto) {
    if let points = pigeonPolyline.options.points?.compactMap({ $0 }) {
      let path = GMSMutablePath()
      for point in points {
        path.addLatitude(point.latitude, longitude: point.longitude)
      }
      self.path = path
    }
    isTappable = pigeonPolyline.options.clickable ?? isTappable
    geodesic = pigeonPolyline.options.geodesic ?? geodesic
    if let strokeColor = pigeonPolyline.options.strokeColor {
      self.strokeColor = UIColor(from: strokeColor)
    }
    strokeWidth = pigeonPolyline.options.strokeWidth ?? strokeWidth
    if let zIndex = pigeonPolyline.options.zIndex {
      self.zIndex = Int32(zIndex)
    }
    spans = pigeonPolyline.options
      .spans
      .map {
        if let solidColor = $0?.style.solidColor {
          return GMSStyleSpan(
            style: .solidColor(UIColor(from: solidColor)),
            segments: $0?.length ?? 1
          )
        } else if
          let fromColor = $0?.style.fromColor,
          let toColor = $0?.style.toColor {
          return GMSStyleSpan(
            style: .gradient(
              from: UIColor(from: fromColor),
              to: UIColor(from: toColor)
            ),
            segments: $0?.length ?? 1
          )
        }
        return nil
      }
      .compactMap { $0 }
  }

  func toPigeonPolyline() -> PolylineDto {
    let options = PolylineOptionsDto(
      points: path?.toLatLngDtos(),
      clickable: isTappable,
      geodesic: geodesic,
      strokeColor: strokeColor.toRgb(),
      strokeWidth: strokeWidth,
      visible: map != nil,
      zIndex: Double(zIndex),
      spans: (spans?.map { $0.toPigeonStyleSpan() }) ?? []
    )
    return PolylineDto(polylineId: getPolylineId(), options: options)
  }
}

private extension GMSStyleSpan {
  func toPigeonStyleSpan() -> StyleSpanDto {
    StyleSpanDto(
      length: segments,
      style: .init() // Maybe hold the color values locally. For now ignored.
    )
  }
}
