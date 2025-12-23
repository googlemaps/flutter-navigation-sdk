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

enum RegisteredImageType: Int {
  /// Default type used when custom bitmaps are uploaded to registry
  case regular = 0
  /// Maneuver icon generated from NavInfo data
  case maneuverIcon = 1
}

struct RegisteredImage {
  let imageId: String
  let image: UIImage
  let imagePixelRatio: Double
  let width: Double?
  let height: Double?
  let type: RegisteredImageType

  func toImageDescriptorDto() -> ImageDescriptorDto {
    ImageDescriptorDto(
      registeredImageId: imageId,
      imagePixelRatio: imagePixelRatio,
      width: width,
      height: height,
      type: {
        switch type {
        case .regular:
          return .regular
        case .maneuverIcon:
          return .maneuverIcon
        }
      }()
    )
  }
}
