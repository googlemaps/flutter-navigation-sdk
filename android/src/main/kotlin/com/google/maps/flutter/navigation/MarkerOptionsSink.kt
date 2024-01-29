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

/** Interface for marker configuration options */
interface MarkerOptionsSink {
  fun setAlpha(alpha: Float)

  fun setAnchor(u: Float, v: Float)

  fun setConsumeTapEvents(consumeTapEvents: Boolean)

  fun setDraggable(draggable: Boolean)

  fun setFlat(flat: Boolean)

  fun setInfoWindowAnchor(u: Float, v: Float)

  fun setTitle(title: String?)

  fun setSnippet(snippet: String?)

  fun setPosition(position: LatLng)

  fun setRotation(rotation: Float)

  fun setVisible(visible: Boolean)

  fun setZIndex(zIndex: Float)

  fun setIcon(registeredImage: RegisteredImage?)
}
