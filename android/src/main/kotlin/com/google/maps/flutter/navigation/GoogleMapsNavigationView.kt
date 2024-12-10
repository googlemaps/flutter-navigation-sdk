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
import android.content.res.Configuration
import android.view.View
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.libraries.navigation.NavigationView
import io.flutter.plugin.platform.PlatformView

class GoogleMapsNavigationView
internal constructor(
  context: Context,
  mapOptions: MapOptions,
  navigationOptions: NavigationViewOptions?,
  viewId: Int,
  private val viewRegistry: GoogleMapsViewRegistry,
  viewEventApi: ViewEventApi,
  private val imageRegistry: ImageRegistry,
) : PlatformView, GoogleMapsBaseMapView(viewId, mapOptions, viewEventApi, imageRegistry) {
  private val _navigationView: NavigationView = NavigationView(context, mapOptions.googleMapOptions)

  /// Default values for UI features.
  private var _isNavigationTripProgressBarEnabled: Boolean = false
  private var _isNavigationHeaderEnabled: Boolean = true
  private var _isNavigationFooterEnabled: Boolean = true
  private var _isRecenterButtonEnabled: Boolean = true
  private var _isSpeedLimitIconEnabled: Boolean = false
  private var _isSpeedometerEnabled: Boolean = false
  private var _isTrafficIncidentCardsEnabled: Boolean = true

  override fun getView(): View {
    return _navigationView
  }

  init {
    // Call all of these three lifecycle functions in sequence to fully
    // initialize the navigation view.
    _navigationView.onCreate(context.applicationInfo.metaData)
    _navigationView.onStart()
    _navigationView.onResume()

    // Initialize navigation view with given navigation view options
    var navigationViewEnabled: Boolean = false
    if (
      navigationOptions?.navigationUiEnabledPreference == NavigationUIEnabledPreference.AUTOMATIC
    ) {
      val navigatorInitialized = GoogleMapsNavigationSessionManager.getInstance().isInitialized()
      if (navigatorInitialized) {
        navigationViewEnabled = true
      }
    }
    _navigationView.isNavigationUiEnabled = navigationViewEnabled

    viewRegistry.registerNavigationView(viewId, this)

    _navigationView.getMapAsync { map ->
      setMap(map)
      initListeners()
      imageRegistry.mapViewInitializationComplete()

      // Re set navigation view enabled state as sometimes earlier value is not
      // respected.
      _navigationView.isNavigationUiEnabled = navigationViewEnabled
      if (!navigationViewEnabled) {
        map.moveCamera(CameraUpdateFactory.newCameraPosition(mapOptions.googleMapOptions.camera))
      }

      // Call and clear view ready callback if available.
      mapReady()
      mapOptions.padding?.let { setPadding(it) }
      invalidateViewAfterMapLoad()
    }
  }

  override fun dispose() {
    getMap().setOnMapClickListener(null)
    getMap().setOnMapLongClickListener(null)
    getMap().setOnMarkerClickListener(null)
    getMap().setOnMarkerDragListener(null)
    getMap().setOnInfoWindowClickListener(null)
    getMap().setOnInfoWindowClickListener(null)
    getMap().setOnInfoWindowLongClickListener(null)
    getMap().setOnPolygonClickListener(null)
    getMap().setOnPolylineClickListener(null)

    // When view is disposed, all of these lifecycle functions must be
    // called to properly dispose navigation view and prevent leaks.
    _navigationView.isNavigationUiEnabled = false
    _navigationView.onPause()
    _navigationView.onStop()
    _navigationView.onDestroy()

    _navigationView.removeOnRecenterButtonClickedListener {}

    viewRegistry.unregisterNavigationView(getViewId())
  }

  override fun onStart() {
    _navigationView.onStart()
  }

  override fun onResume() {
    _navigationView.onResume()
  }

  override fun onStop() {
    _navigationView.onStop()
  }

  override fun onPause() {
    _navigationView.onPause()
  }

  fun onConfigurationChanged(configuration: Configuration) {
    _navigationView.onConfigurationChanged(configuration)
  }

  fun onTrimMemory(level: Int) {
    _navigationView.onTrimMemory(level)
  }

  override fun initListeners() {
    _navigationView.addOnRecenterButtonClickedListener {
      viewEventApi?.onRecenterButtonClicked(getViewId().toLong()) {}
    }
    _navigationView.addOnNavigationUiChangedListener {
      viewEventApi?.onNavigationUIEnabledChanged(getViewId().toLong(), it) {}
    }
    super.initListeners()
  }

  fun isNavigationTripProgressBarEnabled(): Boolean {
    return _isNavigationTripProgressBarEnabled
  }

  fun setNavigationTripProgressBarEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setTripProgressBarEnabled(enabled)
    _isNavigationTripProgressBarEnabled = enabled
  }

  fun isNavigationHeaderEnabled(): Boolean {
    return _isNavigationHeaderEnabled
  }

  fun setNavigationHeaderEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setHeaderEnabled(enabled)
    _isNavigationHeaderEnabled = enabled
  }

  fun isNavigationFooterEnabled(): Boolean {
    return _isNavigationFooterEnabled
  }

  fun setNavigationFooterEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setEtaCardEnabled(enabled)
    _isNavigationFooterEnabled = enabled
  }

  fun isRecenterButtonEnabled(): Boolean {
    return _isRecenterButtonEnabled
  }

  fun setRecenterButtonEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setRecenterButtonEnabled(enabled)
    _isRecenterButtonEnabled = enabled
  }

  fun isSpeedLimitIconEnabled(): Boolean {
    return _isSpeedLimitIconEnabled
  }

  fun setSpeedLimitIconEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setSpeedLimitIconEnabled(enabled)
    _isSpeedLimitIconEnabled = enabled
  }

  fun isSpeedometerEnabled(): Boolean {
    return _isSpeedometerEnabled
  }

  fun setSpeedometerEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setSpeedometerEnabled(enabled)
    _isSpeedometerEnabled = enabled
  }

  fun isTrafficIncidentCardsEnabled(): Boolean {
    return _isTrafficIncidentCardsEnabled
  }

  fun setTrafficIncidentCardsEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setTrafficIncidentCardsEnabled(enabled)
    _isTrafficIncidentCardsEnabled = enabled
  }

  fun isNavigationUIEnabled(): Boolean {
    return _navigationView.isNavigationUiEnabled
  }

  fun setNavigationUIEnabled(enabled: Boolean) {
    if (_navigationView.isNavigationUiEnabled != enabled) {
      invalidateViewAfterMapLoad()
      _navigationView.isNavigationUiEnabled = enabled
    }
  }

  fun showRouteOverview() {
    invalidateViewAfterMapLoad()
    _navigationView.showRouteOverview()
  }
}
