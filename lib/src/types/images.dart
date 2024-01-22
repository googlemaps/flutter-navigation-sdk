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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Defines an image. For marker this class can be used to set the
/// image of the marker icon.
/// {@category Image Registry}
@immutable
class ImageDescriptor {
  /// Construct [ImageDescriptor].
  const ImageDescriptor(
      {this.registeredImageId, this.imagePixelRatio, this.width, this.height});

  /// If this class represents an image from image registry, [registeredImageId] is not null.
  final String? registeredImageId;

  /// If image is bigger than it's intended display size, scale it down by this ratio.
  final double? imagePixelRatio;

  /// Image width in logical pixels.
  final double? width;

  /// Image height in logical pixels.
  final double? height;

  /// Display default image on a marker or polyline.
  static const ImageDescriptor defaultImage = ImageDescriptor();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ImageDescriptor &&
        registeredImageId == other.registeredImageId &&
        imagePixelRatio == other.imagePixelRatio &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode => Object.hash(registeredImageId.hashCode,
      imagePixelRatio.hashCode, width.hashCode, height.hashCode);
}
