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

import com.google.android.gms.maps.model.CircleOptions
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.PatternItem

class CircleBuilder : CircleOptionsSink {
  private val _circleOptions: CircleOptions = CircleOptions()

  fun build(): CircleOptions {
    return _circleOptions
  }

  override fun setPosition(position: LatLng) {
    _circleOptions.center(position)
  }

  override fun setRadius(radius: Double) {
    _circleOptions.radius(radius)
  }

  override fun setStrokeColor(color: Int) {
    _circleOptions.strokeColor(color)
  }

  override fun setStrokeWidth(width: Float) {
    _circleOptions.strokeWidth(width)
  }

  override fun setStrokePattern(strokePattern: List<PatternItem>) {
    _circleOptions.strokePattern(strokePattern)
  }

  override fun setFillColor(color: Int) {
    _circleOptions.fillColor(color)
  }

  override fun setZIndex(zIndex: Float) {
    _circleOptions.zIndex(zIndex)
  }

  override fun setVisible(visible: Boolean) {
    _circleOptions.visible(visible)
  }

  override fun setClickable(clickable: Boolean) {
    _circleOptions.clickable(clickable)
  }
}
