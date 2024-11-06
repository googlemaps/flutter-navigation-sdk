/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.maps.flutter.navigation

class GoogleMapsImageRegistryMessageHandler(private val imageRegistry: ImageRegistry) :
  ImageRegistryApi {
  override fun registerBitmapImage(
    imageId: String,
    bytes: ByteArray,
    imagePixelRatio: Double,
    width: Double?,
    height: Double?,
  ): ImageDescriptorDto {
    return imageRegistry.registerBitmapImage(imageId, bytes, imagePixelRatio, width, height)
  }

  override fun unregisterImage(imageDescriptor: ImageDescriptorDto) {
    imageDescriptor.registeredImageId?.let { imageRegistry.unregisterImage(it) }
  }

  override fun clearRegisteredImages() {
    imageRegistry.clearRegisteredImages()
  }

  override fun getRegisteredImages(): List<ImageDescriptorDto> {
    return imageRegistry.registeredImages.map { Convert.registeredImageToImageDescriptorDto(it) }
  }
}
