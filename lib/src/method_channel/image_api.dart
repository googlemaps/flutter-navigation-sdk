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

import 'package:flutter/services.dart';

import '../../google_navigation_flutter.dart';
import 'method_channel.dart';

/// @nodoc
/// CommonImageRegistryAPI handles image registry API
/// actions that are common to both iOS and Android.
class ImageRegistryAPIImpl {
  final ImageRegistryApi _imageApi = ImageRegistryApi();

  /// Keep track of image count, used to generate image ID's.
  int _imageCounter = 0;
  String _createImageId() {
    final String imageId = 'Image_$_imageCounter';
    _imageCounter += 1;
    return imageId;
  }

  /// Register bitmap to image registry.
  Future<ImageDescriptor> registerBitmapImage(
      {required Uint8List bitmap,
      required double imagePixelRatio,
      double? width,
      double? height}) async {
    final String newImageId = _createImageId();
    try {
      final ImageDescriptorDto addedImage = await _imageApi.registerBitmapImage(
          newImageId, bitmap, imagePixelRatio, width, height);
      return addedImage.toImageDescriptor();
    } on PlatformException catch (error) {
      if (error.code == 'imageDecodingFailed') {
        throw const ImageDecodingFailedException();
      } else {
        rethrow;
      }
    }
  }

  /// Delete bitmap from image registry.
  Future<void> unregisterImage({required ImageDescriptor imageDescriptor}) {
    return _imageApi.unregisterImage(imageDescriptor.toDto());
  }

  /// Get all registered bitmaps from image registry.
  Future<List<ImageDescriptor>> getRegisteredImages() async {
    final List<ImageDescriptorDto?> registeredImages =
        await _imageApi.getRegisteredImages();
    return registeredImages
        .whereType<ImageDescriptorDto>()
        .map((ImageDescriptorDto e) => e.toImageDescriptor())
        .toList();
  }

  /// Remove all registered bitmaps from image registry.
  Future<void> clearRegisteredImages() {
    return _imageApi.clearRegisteredImages();
  }
}
