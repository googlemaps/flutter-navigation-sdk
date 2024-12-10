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

import android.content.Context
import android.view.View
import com.google.android.gms.maps.MapView
import io.flutter.plugin.platform.PlatformView

class GoogleMapView
internal constructor(
  context: Context,
  mapOptions: MapOptions,
  viewId: Int,
  viewEventApi: ViewEventApi,
  private val viewRegistry: GoogleMapsViewRegistry,
  imageRegistry: ImageRegistry,
) : PlatformView, GoogleMapsBaseMapView(viewId, mapOptions, viewEventApi, imageRegistry) {
  private val _mapView: MapView = MapView(context, mapOptions.googleMapOptions)

  override fun getView(): View {
    return _mapView
  }

  init {
    // Call all of these three lifecycle functions in sequence to fully
    // initialize the map view.
    _mapView.onCreate(context.applicationInfo.metaData)
    _mapView.onStart()
    _mapView.onResume()

    viewRegistry.registerMapView(viewId, this)

    _mapView.getMapAsync { map ->
      setMap(map)
      initListeners()
      imageRegistry.mapViewInitializationComplete()
      mapReady()
      mapOptions.padding?.let { setPadding(it) }
      invalidateViewAfterMapLoad()
    }
  }

  override fun dispose() {
    // When view is disposed, all of these lifecycle functions must be
    // called to properly dispose navigation view and prevent leaks.
    _mapView.onPause()
    _mapView.onStop()
    _mapView.onDestroy()

    viewRegistry.unregisterMapView(getViewId())
  }

  override fun onStart() {
    _mapView.onStart()
  }

  override fun onResume() {
    _mapView.onResume()
  }

  override fun onStop() {
    _mapView.onStop()
  }

  override fun onPause() {
    _mapView.onPause()
  }
}
