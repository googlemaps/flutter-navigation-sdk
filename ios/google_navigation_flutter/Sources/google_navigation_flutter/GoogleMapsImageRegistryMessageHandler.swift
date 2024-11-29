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
import Foundation

class GoogleMapsImageRegistryMessageHandler: ImageRegistryApi {
  let imageRegistry: ImageRegistry

  init(imageRegistry: ImageRegistry) {
    self.imageRegistry = imageRegistry
  }

  func registerBitmapImage(imageId: String, bytes: FlutterStandardTypedData,
                           imagePixelRatio: Double,
                           width: Double?,
                           height: Double?) throws -> ImageDescriptorDto {
    try imageRegistry.registerBitmapImage(
      imageId: imageId,
      bytes: bytes.data,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height
    )
  }

  func unregisterImage(imageDescriptor: ImageDescriptorDto) throws {
    if let registeredImageId = imageDescriptor.registeredImageId {
      imageRegistry.unregisterImage(imageId: registeredImageId)
    }
  }

  func getRegisteredImages() throws -> [ImageDescriptorDto] {
    imageRegistry.registeredImages.map { $0.toImageDescriptorDto() }
  }

  func clearRegisteredImages() throws {
    imageRegistry.clearRegisteredImages()
  }
}
