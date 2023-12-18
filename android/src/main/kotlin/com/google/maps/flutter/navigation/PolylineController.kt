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
import com.google.android.gms.maps.model.PatternItem
import com.google.android.gms.maps.model.Polyline
import com.google.android.gms.maps.model.StyleSpan

class PolylineController(val polyline: Polyline, val polylineId: String) : PolylineOptionsSink {

  override fun setStrokeColor(color: Int) {
    polyline.color = color
  }

  override fun setGeodesic(geodesic: Boolean) {
    polyline.isGeodesic = geodesic
  }

  override fun setPoints(points: List<LatLng>) {
    polyline.points = points
  }

  override fun setVisible(visible: Boolean) {
    polyline.isVisible = visible
  }

  override fun setStrokeWidth(width: Float) {
    polyline.width = width
  }

  override fun setZIndex(zIndex: Float) {
    polyline.zIndex = zIndex
  }

  override fun setClickable(clickable: Boolean) {
    polyline.isClickable = clickable
  }

  override fun setStrokeJointType(strokeJointType: Int) {
    polyline.jointType = strokeJointType
  }

  override fun setStrokePattern(strokePattern: List<PatternItem>) {
    polyline.pattern = strokePattern
  }

  override fun setSpans(spans: List<StyleSpan>) {
    polyline.spans = spans
  }

  fun remove() {
    polyline.remove()
  }
}
