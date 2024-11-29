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

import UIKit

extension String {
  static var empty: String { "" }
}

extension Collection {
  var isNotEmpty: Bool { !isEmpty }
}

extension UIColor {
  convenience init(from rgb: Int64) {
    let blue = rgb & 0xFF
    let green = (rgb >> 8) & 0xFF
    let red = (rgb >> 16) & 0xFF
    let alpha = (rgb >> 24) & 0xFF

    self.init(red: CGFloat(red) / 255,
              green: CGFloat(green) / 255,
              blue: CGFloat(blue) / 255,
              alpha: CGFloat(alpha) / 255)
  }

  func toRgb() -> Int64? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      let redInt = Int(red * 255.0)
      let greenInt = Int(green * 255.0)
      let blueInt = Int(blue * 255.0)
      let alphaInt = Int(alpha * 255.0)

      let rgb = (alphaInt << 24) + (redInt << 16) + (greenInt << 8) + blueInt
      return Int64(rgb)
    } else {
      return nil
    }
  }
}
