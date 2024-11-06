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

import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker

/** Class that controls single [Marker] instance */
class MarkerController(
  val marker: Marker,
  val markerId: String,
  consumeTapEvents: Boolean,
  anchorU: Float,
  anchorV: Float,
  infoWindowAnchorU: Float,
  infoWindowAnchorV: Float,
  registeredImage: RegisteredImage?,
) : MarkerOptionsSink {
  var consumeTapEvents: Boolean = consumeTapEvents
    private set

  // Anchors cannot be read out from the [Marker] instance so store these here for now.
  var anchorU: Float = anchorU
    private set

  var anchorV: Float = anchorV
    private set

  var infoWindowAnchorU: Float = infoWindowAnchorU
    private set

  var infoWindowAnchorV: Float = infoWindowAnchorV
    private set

  var registeredImage: RegisteredImage? = registeredImage
    private set

  override fun setAlpha(alpha: Float) {
    marker.alpha = alpha
  }

  override fun setAnchor(u: Float, v: Float) {
    anchorU = u
    anchorV = v
    marker.setAnchor(u, v)
  }

  override fun setDraggable(draggable: Boolean) {
    marker.isDraggable = draggable
  }

  override fun setFlat(flat: Boolean) {
    marker.isFlat = flat
  }

  override fun setConsumeTapEvents(consumeTapEvents: Boolean) {
    this.consumeTapEvents = consumeTapEvents
  }

  override fun setInfoWindowAnchor(u: Float, v: Float) {
    infoWindowAnchorU = u
    infoWindowAnchorV = v
    marker.setInfoWindowAnchor(u, v)
  }

  override fun setTitle(title: String?) {
    marker.title = title
  }

  override fun setSnippet(snippet: String?) {
    marker.snippet = snippet
  }

  override fun setPosition(position: LatLng) {
    marker.position = position
  }

  override fun setRotation(rotation: Float) {
    marker.rotation = rotation
  }

  override fun setVisible(visible: Boolean) {
    marker.isVisible = visible
  }

  override fun setZIndex(zIndex: Float) {
    marker.zIndex = zIndex
  }

  fun remove() {
    marker.remove()
  }

  override fun setIcon(registeredImage: RegisteredImage?) {
    this.registeredImage = registeredImage
    if (registeredImage != null) {
      marker.setIcon(registeredImage.bitmapDescriptor)
    } else {
      marker.setIcon(null)
    }
  }
}
