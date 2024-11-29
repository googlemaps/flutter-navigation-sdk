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

enum GoogleMapsImageRegistryError: Error {
  case imageDecodingFailed
}

class ImageRegistry {
  var registeredImages: [RegisteredImage] = []

  func registerBitmapImage(imageId: String, bytes: Data, imagePixelRatio: Double, width: Double?,
                           height: Double?) throws -> ImageDescriptorDto {
    guard var image = UIImage(data: bytes, scale: imagePixelRatio) else {
      throw GoogleMapsImageRegistryError.imageDecodingFailed
    }

    if width != nil, height != nil {
      image = ImageResizer.resize(
        image: image,
        size: CGSize(width: CGFloat(width!), height: CGFloat(height!))
      )
    } else if width != nil {
      image = ImageResizer.resize(image: image, width: CGFloat(width!))
    } else if height != nil {
      image = ImageResizer.resize(image: image, height: CGFloat(height!))
    }

    registeredImages.append(RegisteredImage(
      imageId: imageId,
      image: image,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height
    ))
    return ImageDescriptorDto(
      registeredImageId: imageId,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height
    )
  }

  func findRegisteredImage(imageId: String) -> RegisteredImage? {
    registeredImages.first(where: { $0.imageId == imageId })
  }

  func unregisterImage(imageId: String) {
    registeredImages.removeAll(where: { $0.imageId == imageId })
  }

  func clearRegisteredImages() {
    registeredImages.removeAll()
  }
}
