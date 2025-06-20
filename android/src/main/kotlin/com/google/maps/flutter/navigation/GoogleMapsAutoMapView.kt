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

import android.view.View
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.navigation.NavigationViewForAuto

class GoogleMapsAutoMapView
internal constructor(
  mapOptions: MapOptions,
  viewRegistry: GoogleMapsViewRegistry,
  imageRegistry: ImageRegistry,
  private val mapView: NavigationViewForAuto,
  map: GoogleMap,
) : GoogleMapsBaseMapView(null, mapOptions, null, imageRegistry) {
  override fun getView(): View {
    return mapView
  }

  init {
    setMap(map)
    initListeners()
    imageRegistry.mapViewInitializationComplete()
    viewRegistry.registerAndroidAutoView(this)
    mapReady()
  }

  // Handled by AndroidAutoBaseScreen.
  override fun onStart() {}

  // Handled by AndroidAutoBaseScreen.
  override fun onResume() {}

  // Handled by AndroidAutoBaseScreen.
  override fun onStop() {}

  // Handled by AndroidAutoBaseScreen.
  override fun onPause() {}
}
