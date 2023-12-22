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
import com.google.android.gms.maps.model.MarkerOptions

/** Class that builds [MarkerOptions] instance */
class MarkerBuilder : MarkerOptionsSink {
  private val _markerOptions: MarkerOptions = MarkerOptions()
  var consumeTapEvents: Boolean = false
    private set

  fun build(): MarkerOptions {
    return _markerOptions
  }

  override fun setAlpha(alpha: Float) {
    _markerOptions.alpha(alpha)
  }

  override fun setAnchor(u: Float, v: Float) {
    _markerOptions.anchor(u, v)
  }

  override fun setDraggable(draggable: Boolean) {
    _markerOptions.draggable(draggable)
  }

  override fun setFlat(flat: Boolean) {
    _markerOptions.flat(flat)
  }

  override fun setConsumeTapEvents(consumeTapEvents: Boolean) {
    this.consumeTapEvents = consumeTapEvents
  }

  override fun setInfoWindowAnchor(u: Float, v: Float) {
    _markerOptions.infoWindowAnchor(u, v)
  }

  override fun setTitle(title: String?) {
    _markerOptions.title(title)
  }

  override fun setSnippet(snippet: String?) {
    _markerOptions.snippet(snippet)
  }

  override fun setPosition(position: LatLng) {
    _markerOptions.position(position)
  }

  override fun setRotation(rotation: Float) {
    _markerOptions.rotation(rotation)
  }

  override fun setVisible(visible: Boolean) {
    _markerOptions.visible(visible)
  }

  override fun setZIndex(zIndex: Float) {
    _markerOptions.zIndex(zIndex)
  }

  override fun setIcon(registeredImage: RegisteredImage?) {
    // registeredImage will be stored in the MarkerController object
    // after the marker has been created.
    if (registeredImage != null) {
      _markerOptions.icon(registeredImage.bitmapDescriptor)
    }
  }
}
