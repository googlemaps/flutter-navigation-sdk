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

import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.PatternItem

class CircleController(val circle: Circle, val circleId: String) : CircleOptionsSink {
  override fun setPosition(position: LatLng) {
    circle.center = position
  }

  override fun setRadius(radius: Double) {
    circle.radius = radius
  }

  override fun setStrokeWidth(width: Float) {
    circle.strokeWidth = width
  }

  override fun setStrokeColor(color: Int) {
    circle.strokeColor = color
  }

  override fun setStrokePattern(strokePattern: List<PatternItem>) {
    circle.strokePattern = strokePattern
  }

  override fun setFillColor(color: Int) {
    circle.fillColor = color
  }

  override fun setZIndex(zIndex: Float) {
    circle.zIndex = zIndex
  }

  override fun setVisible(visible: Boolean) {
    circle.isVisible = visible
  }

  override fun setClickable(clickable: Boolean) {
    circle.isClickable = clickable
  }

  fun remove() {
    circle.remove()
  }
}
