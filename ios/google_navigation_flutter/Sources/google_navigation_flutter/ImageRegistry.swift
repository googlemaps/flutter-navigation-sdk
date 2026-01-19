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

import Flutter
import UIKit

enum GoogleMapsImageRegistryError: Error {
  case imageDecodingFailed
}

class ImageRegistry {
  var registeredImages: [String: RegisteredImage] = [:]

  func registerBitmapImage(
    imageId: String, bytes: Data, imagePixelRatio: Double, width: Double?,
    height: Double?
  ) throws -> ImageDescriptorDto {
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

    registeredImages[imageId] =
      RegisteredImage(
        imageId: imageId,
        image: image,
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height,
        type: .regular
      )
    return ImageDescriptorDto(
      registeredImageId: imageId,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height,
      type: RegisteredImageTypeDto.regular
    )
  }

  func registerManeuverImage(
    imageId: String, image: UIImage, imagePixelRatio: Double, width: Double?,
    height: Double?
  ) throws -> ImageDescriptorDto {
    registeredImages[imageId] =
      RegisteredImage(
        imageId: imageId,
        image: image,
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height,
        type: .maneuver
      )
    return ImageDescriptorDto(
      registeredImageId: imageId,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height,
      type: .maneuver
    )
  }

  func registerLaneImage(
    imageId: String, image: UIImage, imagePixelRatio: Double, width: Double?,
    height: Double?
  ) throws -> ImageDescriptorDto {
    registeredImages[imageId] =
      RegisteredImage(
        imageId: imageId,
        image: image,
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height,
        type: .lanes
      )
    return ImageDescriptorDto(
      registeredImageId: imageId,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height,
      type: .lanes
    )
  }

  func findRegisteredImage(imageId: String) -> RegisteredImage? {
    registeredImages[imageId]
  }

  func unregisterImage(imageId: String) {
    registeredImages.removeValue(forKey: imageId)
  }

  func clearRegisteredImages(filter: RegisteredImageTypeDto?) {
    guard let filter else {
      registeredImages.removeAll()
      return
    }
    registeredImages = registeredImages.filter { (_, image) in
      image.type != Convert.registeredImageType(type: filter)
    }
  }

  func getRegisteredImageData(imageDescriptor: ImageDescriptorDto) throws
    -> FlutterStandardTypedData?
  {
    guard
      let data = findRegisteredImage(imageId: imageDescriptor.registeredImageId ?? "")?.image
        .pngData()
    else {
      return nil
    }
    return FlutterStandardTypedData(bytes: data)
  }
}
