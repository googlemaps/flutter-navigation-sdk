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

import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.google.android.gms.maps.model.BitmapDescriptorFactory

class ImageRegistry {
  val registeredImages = mutableListOf<RegisteredImage>()
  private val bitmapQueue = mutableListOf<QueuedBitmap>()

  private var isMapViewInitialized = false

  fun mapViewInitializationComplete() {
    isMapViewInitialized = true
    bitmapQueue.forEach {
      addRegisteredImage(it.imageId, it.bitmap, it.imagePixelRatio, it.width, it.height)
    }
    bitmapQueue.clear()
  }

  @Throws(FlutterError::class)
  fun registerBitmapImage(
    imageId: String,
    bytes: ByteArray,
    imagePixelRatio: Double,
    width: Double?,
    height: Double?,
  ): ImageDescriptorDto {
    val density = Resources.getSystem().displayMetrics.density
    val bitmap = createBitmap(bytes, imagePixelRatio, density, width, height)

    if (!isMapViewInitialized) {
      // BitmapDescriptor cannot me created if map view is not initialized yet.
      // Add to queue to make it later.
      bitmapQueue.add(QueuedBitmap(imageId, bitmap, imagePixelRatio, width, height))
    } else {
      addRegisteredImage(imageId, bitmap, imagePixelRatio, width, height)
    }
    return ImageDescriptorDto(imageId, imagePixelRatio, width, height)
  }

  private fun addRegisteredImage(
    imageId: String,
    bitmap: Bitmap,
    imagePixelRatio: Double,
    width: Double?,
    height: Double?,
  ) {
    val bitmapDescriptor = BitmapDescriptorFactory.fromBitmap(bitmap)
    val registeredImage = RegisteredImage(imageId, bitmapDescriptor, imagePixelRatio, width, height)
    registeredImages.add(registeredImage)
  }

  @Throws(FlutterError::class)
  private fun createBitmap(
    bytes: ByteArray,
    imagePixelRatio: Double,
    density: Float,
    width: Double?,
    height: Double?,
  ): Bitmap {
    val bitmap =
      BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        ?: throw FlutterError(
          "imageDecodingFailed",
          "Failed to decode bitmap, is the byte array valid image?",
        )
    val scaledWidth: Double
    val scaledHeight: Double

    if (width != null && height != null) {
      scaledWidth = width * density
      scaledHeight = height * density
    } else if (width != null) {
      // Calculate new height to match image aspect ratio.
      val newHeight = (width / bitmap.width) * bitmap.height
      scaledWidth = width * density
      scaledHeight = newHeight * density
    } else if (height != null) {
      // Calculate new width to match image aspect ratio.
      val newWidth = (height / bitmap.height) * bitmap.width
      scaledWidth = newWidth * density
      scaledHeight = height * density
    } else {
      // Default to imagePixelRatio if no width or height specified.
      scaledWidth = (bitmap.width / imagePixelRatio) * density
      scaledHeight = (bitmap.height / imagePixelRatio) * density
    }

    return Bitmap.createScaledBitmap(bitmap, scaledWidth.toInt(), scaledHeight.toInt(), true)
  }

  fun findRegisteredImage(imageId: String): RegisteredImage? {
    return registeredImages.firstOrNull { it.imageId == imageId }
  }

  fun unregisterImage(imageId: String) {
    registeredImages.removeAll { it.imageId == imageId }
  }

  fun clearRegisteredImages() {
    registeredImages.clear()
  }
}
