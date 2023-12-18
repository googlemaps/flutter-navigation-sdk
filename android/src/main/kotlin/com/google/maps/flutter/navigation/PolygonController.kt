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
import com.google.android.gms.maps.model.Polygon

class PolygonController(val polygon: Polygon, val polygonId: String) : PolygonOptionsSink {
  override fun setFillColor(color: Int) {
    polygon.fillColor = color
  }

  override fun setStrokeColor(color: Int) {
    polygon.strokeColor = color
  }

  override fun setGeodesic(geodesic: Boolean) {
    polygon.isGeodesic = geodesic
  }

  override fun setPoints(points: List<LatLng>) {
    polygon.points = points
  }

  override fun setHoles(holes: List<List<LatLng>>) {
    polygon.holes = holes
  }

  override fun setVisible(visible: Boolean) {
    polygon.isVisible = visible
  }

  override fun setStrokeWidth(width: Float) {
    polygon.strokeWidth = width
  }

  override fun setZIndex(zIndex: Float) {
    polygon.zIndex = zIndex
  }

  override fun setClickable(clickable: Boolean) {
    polygon.isClickable = clickable
  }

  fun remove() {
    polygon.remove()
  }
}
