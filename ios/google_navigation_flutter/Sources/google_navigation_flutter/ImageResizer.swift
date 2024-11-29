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

enum ImageResizer {
  static func resize(image: UIImage, width: CGFloat) -> UIImage {
    let height = (width / image.size.width) * image.size.height
    return resize(image: image, size: CGSize(width: width, height: height))
  }

  static func resize(image: UIImage, height: CGFloat) -> UIImage {
    let width = (height / image.size.height) * image.size.width
    return resize(image: image, size: CGSize(width: width, height: height))
  }

  static func resize(image: UIImage, size: CGSize) -> UIImage {
    // Check if scaling is needed
    guard abs((image.size.width * image.scale) - size.width) > 0 ||
      abs((image.size.height * image.scale) - size.height) > 0 else {
      return image
    }

    if abs(image.size.width / image.size.height - size.width / size.height) < 1e-2 {
      // Scaled image has close to same aspect ratio,
      // updating image scale instead of resizing image.
      let scale = (image.scale * ((image.size.width * image.scale) / size.width))
      return UIImage(cgImage: image.cgImage!, scale: scale, orientation: image.imageOrientation)
    } else {
      UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
      image.draw(in: CGRect(origin: .zero, size: size))
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return newImage!
    }
  }
}
