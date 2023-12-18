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
import com.google.android.gms.maps.model.PolygonOptions

class PolygonBuilder : PolygonOptionsSink {
  private val _polygonOptions: PolygonOptions = PolygonOptions()

  fun build(): PolygonOptions {
    return _polygonOptions
  }

  override fun setFillColor(color: Int) {
    _polygonOptions.fillColor(color)
  }

  override fun setStrokeColor(color: Int) {
    _polygonOptions.strokeColor(color)
  }

  override fun setGeodesic(geodesic: Boolean) {
    _polygonOptions.geodesic(geodesic)
  }

  override fun setPoints(points: List<LatLng>) {
    _polygonOptions.addAll(points)
  }

  override fun setHoles(holes: List<List<LatLng>>) {
    holes.forEach { _polygonOptions.addHole(it) }
  }

  override fun setVisible(visible: Boolean) {
    _polygonOptions.visible(visible)
  }

  override fun setStrokeWidth(width: Float) {
    _polygonOptions.strokeWidth(width)
  }

  override fun setZIndex(zIndex: Float) {
    _polygonOptions.zIndex(zIndex)
  }

  override fun setClickable(clickable: Boolean) {
    _polygonOptions.clickable(clickable)
  }
}
