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
import android.view.ViewGroup
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.navigation.NavigationView

class GoogleMapsAutoMapView
internal constructor(
  mapOptions: MapOptions,
  viewRegistry: GoogleMapsViewRegistry,
  imageRegistry: ImageRegistry,
  private val navigationView: NavigationView,
  private val viewGroup: ViewGroup,
  map: GoogleMap,
) : GoogleMapsBaseMapView(null, mapOptions, null, imageRegistry) {
  private var _isTrafficPromptsEnabled: Boolean = true
  private var _isTrafficIncidentCardsEnabled: Boolean = true
  private var _isNavigationTripProgressBarEnabled: Boolean = false
  private var _isSpeedLimitIconEnabled: Boolean = false
  private var _isSpeedometerEnabled: Boolean = false
  private var _forceNightMode: Int = 0

  override fun getView(): View {
    return viewGroup
  }

  init {
    setMap(map)
    initListeners()
    imageRegistry.mapViewInitializationComplete()
    viewRegistry.registerAndroidAutoView(this)
    mapReady()
  }

  override fun setTrafficPromptsEnabled(enabled: Boolean) {
    navigationView.setTrafficPromptsEnabled(enabled)
    _isTrafficPromptsEnabled = enabled
  }

  override fun isTrafficPromptsEnabled(): Boolean {
    return _isTrafficPromptsEnabled
  }

  override fun setTrafficIncidentCardsEnabled(enabled: Boolean) {
    navigationView.setTrafficIncidentCardsEnabled(enabled)
    _isTrafficIncidentCardsEnabled = enabled
  }

  override fun isTrafficIncidentCardsEnabled(): Boolean {
    return _isTrafficIncidentCardsEnabled
  }

  override fun getForceNightMode(): Int {
    return _forceNightMode
  }

  override fun setForceNightMode(forceNightMode: Int) {
    navigationView.setForceNightMode(forceNightMode)
    _forceNightMode = forceNightMode
  }

  override fun isNavigationTripProgressBarEnabled(): Boolean {
    return _isNavigationTripProgressBarEnabled
  }

  override fun setNavigationTripProgressBarEnabled(enabled: Boolean) {
    navigationView.setTripProgressBarEnabled(enabled)
    _isNavigationTripProgressBarEnabled = enabled
  }

  override fun isSpeedLimitIconEnabled(): Boolean {
    return _isSpeedLimitIconEnabled
  }

  override fun setSpeedLimitIconEnabled(enabled: Boolean) {
    navigationView.setSpeedLimitIconEnabled(enabled)
    _isSpeedLimitIconEnabled = enabled
  }

  override fun isSpeedometerEnabled(): Boolean {
    return _isSpeedometerEnabled
  }

  override fun setSpeedometerEnabled(enabled: Boolean) {
    navigationView.setSpeedometerEnabled(enabled)
    _isSpeedometerEnabled = enabled
  }

  override fun showRouteOverview() {
    navigationView.showRouteOverview()
  }

  // Handled by AndroidAutoBaseScreen.
  override fun onStart(): Boolean {
    return super.onStart()
  }

  override fun onResume(): Boolean {
    return super.onResume()
  }

  override fun onStop(): Boolean {
    return super.onStop()
  }

  override fun onPause(): Boolean {
    return super.onPause()
  }
}
