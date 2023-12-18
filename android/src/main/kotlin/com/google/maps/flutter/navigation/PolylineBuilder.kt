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
import com.google.android.gms.maps.model.PolylineOptions
import com.google.android.gms.maps.model.StyleSpan

class PolylineBuilder : PolylineOptionsSink {
  private val _polylineOptions: PolylineOptions = PolylineOptions()

  fun build(): PolylineOptions {
    return _polylineOptions
  }

  override fun setStrokeColor(color: Int) {
    _polylineOptions.color(color)
  }

  override fun setGeodesic(geodesic: Boolean) {
    _polylineOptions.geodesic(geodesic)
  }

  override fun setPoints(points: List<LatLng>) {
    _polylineOptions.addAll(points)
  }

  override fun setVisible(visible: Boolean) {
    _polylineOptions.visible(visible)
  }

  override fun setStrokeWidth(width: Float) {
    _polylineOptions.width(width)
  }

  override fun setZIndex(zIndex: Float) {
    _polylineOptions.zIndex(zIndex)
  }

  override fun setClickable(clickable: Boolean) {
    _polylineOptions.clickable(clickable)
  }

  override fun setStrokeJointType(strokeJointType: Int) {
    _polylineOptions.jointType(strokeJointType)
  }

  override fun setStrokePattern(strokePattern: List<PatternItem>) {
    _polylineOptions.pattern(strokePattern)
  }

  override fun setSpans(spans: List<StyleSpan>) {
    _polylineOptions.addAllSpans(spans)
  }
}
