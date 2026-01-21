/*
 * Copyright 2026 Google LLC
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
import com.google.maps.android.clustering.ClusterItem

/**
 * Wrapper class that makes a marker compatible with the clustering library. Implements ClusterItem
 * interface required by ClusterManager.
 */
class MarkerClusterItem(
  val markerId: String,
  val clusterManagerId: String,
  private var markerOptions: MarkerDto,
  var registeredImage: RegisteredImage?,
  var consumeTapEvents: Boolean,
) : ClusterItem {

  override fun getPosition(): LatLng {
    return Convert.convertLatLngFromDto(markerOptions.options.position)
  }

  override fun getTitle(): String? {
    return markerOptions.options.infoWindow.title
  }

  override fun getSnippet(): String? {
    return markerOptions.options.infoWindow.snippet
  }

  override fun getZIndex(): Float {
    return markerOptions.options.zIndex.toFloat()
  }

  /** Returns the marker data transfer object. */
  fun getMarkerDto(): MarkerDto {
    return markerOptions
  }

  /** Updates the marker options. */
  fun updateMarkerOptions(
    newMarkerOptions: MarkerDto,
    newRegisteredImage: RegisteredImage?,
    newConsumeTapEvents: Boolean,
  ) {
    markerOptions = newMarkerOptions
    registeredImage = newRegisteredImage
    consumeTapEvents = newConsumeTapEvents
  }
}
