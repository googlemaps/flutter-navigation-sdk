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

import 'dart:typed_data';

import 'google_navigation_flutter_platform_interface.dart';
import 'types/types.dart';

/// Register bitmap image to image registry.
/// Returns [ImageDescriptor] that can be used to reference the bitmap when creating
/// [MarkerOptions].
/// [bitmap] is the bytes of bitmap to be registered, in PNG format.
/// Set [imagePixelRatio] if bitmap is larger tha it's intended display size.
/// For example, if image width is 64 pixels and it need's to be displayed in 32
/// logical pixel size, set [imagePixelRatio] to 2.
/// Optionally specify wanted logical pixel size with [width] or [height].
/// If only [width] or [height] is specified the other dimension is scaled
/// according to the aspect ratio of the bitmap.
///
/// Throws [ImageDecodingFailedException] if bitmap decoding fails.
/// {@category Image Registry}
Future<ImageDescriptor> registerBitmapImage(
    {required ByteData bitmap,
    double imagePixelRatio = 1.0,
    double? width,
    double? height}) {
  return GoogleMapsNavigationPlatform.instance.imageRegistryAPI
      .registerBitmapImage(
          bitmap: bitmap.buffer.asUint8List(),
          imagePixelRatio: imagePixelRatio,
          width: width,
          height: height);
}

/// Delete previously registered bitmap from image registry.
/// {@category Image Registry}
Future<void> unregisterImage(ImageDescriptor imageDescriptor) {
  return GoogleMapsNavigationPlatform.instance.imageRegistryAPI
      .unregisterImage(imageDescriptor: imageDescriptor);
}

/// Get all registered bitmaps from image registry.
/// {@category Image Registry}
Future<List<ImageDescriptor>> getRegisteredImages() {
  return GoogleMapsNavigationPlatform.instance.imageRegistryAPI
      .getRegisteredImages();
}

/// Remove all registered bitmaps from image registry.
/// {@category Image Registry}
Future<void> clearRegisteredImages() {
  return GoogleMapsNavigationPlatform.instance.imageRegistryAPI
      .clearRegisteredImages();
}

/// [registerBitmapImage] failed to decode bitmap from byte array.
/// {@category Image Registry}
class ImageDecodingFailedException implements Exception {
  /// Default constructor for [ImageDecodingFailedException].
  const ImageDecodingFailedException();
}
