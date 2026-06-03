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

import com.google.android.libraries.navigation.ForceNightMode
import com.google.android.libraries.navigation.NavigationView

/**
 * Base class for map views backed by a [NavigationView] from the Navigation SDK.
 *
 * It extends [GoogleMapsBaseMapView] with the navigation UI features that operate on the wrapped
 * [NavigationView] and are therefore shared by both navigation views [GoogleMapsNavigationView] and
 * the Android Auto [GoogleMapsAutoMapView]).
 */
abstract class GoogleMapsBaseNavigationView(
  viewId: Int?,
  mapOptions: MapOptions,
  viewEventApi: ViewEventApi?,
  imageRegistry: ImageRegistry,
) : GoogleMapsBaseMapView(viewId, mapOptions, viewEventApi, imageRegistry) {

  /** The underlying Navigation SDK view that backs this map view. */
  protected abstract val navigationView: NavigationView

  // Cached navigation UI feature states. The Navigation SDK does not expose getters for these
  // values, so they are tracked here to answer the corresponding is*/get* queries.
  private var _forceNightMode: Int = ForceNightMode.AUTO
  private var _isNavigationTripProgressBarEnabled: Boolean = false
  private var _isSpeedLimitIconEnabled: Boolean = false
  private var _isSpeedometerEnabled: Boolean = false
  private var _isTrafficIncidentCardsEnabled: Boolean = true
  private var _isTrafficPromptsEnabled: Boolean = true
  private var _isNavigationHeaderEnabled: Boolean = true
  private var _isNavigationFooterEnabled: Boolean = true
  private var _isRecenterButtonEnabled: Boolean = true
  private var _isReportIncidentButtonEnabled: Boolean = true

  fun isNavigationTripProgressBarEnabled(): Boolean {
    return _isNavigationTripProgressBarEnabled
  }

  fun setNavigationTripProgressBarEnabled(enabled: Boolean) {
    navigationView.setTripProgressBarEnabled(enabled)
    _isNavigationTripProgressBarEnabled = enabled
  }

  fun isSpeedLimitIconEnabled(): Boolean {
    return _isSpeedLimitIconEnabled
  }

  fun setSpeedLimitIconEnabled(enabled: Boolean) {
    navigationView.setSpeedLimitIconEnabled(enabled)
    _isSpeedLimitIconEnabled = enabled
  }

  fun isSpeedometerEnabled(): Boolean {
    return _isSpeedometerEnabled
  }

  fun setSpeedometerEnabled(enabled: Boolean) {
    navigationView.setSpeedometerEnabled(enabled)
    _isSpeedometerEnabled = enabled
  }

  fun isTrafficIncidentCardsEnabled(): Boolean {
    return _isTrafficIncidentCardsEnabled
  }

  fun setTrafficIncidentCardsEnabled(enabled: Boolean) {
    navigationView.setTrafficIncidentCardsEnabled(enabled)
    _isTrafficIncidentCardsEnabled = enabled
  }

  fun isTrafficPromptsEnabled(): Boolean {
    return _isTrafficPromptsEnabled
  }

  fun setTrafficPromptsEnabled(enabled: Boolean) {
    navigationView.setTrafficPromptsEnabled(enabled)
    _isTrafficPromptsEnabled = enabled
  }

  fun showRouteOverview() {
    navigationView.showRouteOverview()
  }

  fun getForceNightMode(): Int {
    return _forceNightMode
  }

  fun setForceNightMode(forceNightMode: Int) {
    navigationView.setForceNightMode(forceNightMode)
    _forceNightMode = forceNightMode
  }

  fun isNavigationHeaderEnabled(): Boolean {
    return _isNavigationHeaderEnabled
  }

  fun setNavigationHeaderEnabled(enabled: Boolean) {
    navigationView.setHeaderEnabled(enabled)
    _isNavigationHeaderEnabled = enabled
  }

  fun isNavigationFooterEnabled(): Boolean {
    return _isNavigationFooterEnabled
  }

  fun setNavigationFooterEnabled(enabled: Boolean) {
    navigationView.setEtaCardEnabled(enabled)
    _isNavigationFooterEnabled = enabled
  }

  fun isRecenterButtonEnabled(): Boolean {
    return _isRecenterButtonEnabled
  }

  fun setRecenterButtonEnabled(enabled: Boolean) {
    navigationView.setRecenterButtonEnabled(enabled)
    _isRecenterButtonEnabled = enabled
  }

  fun isReportIncidentButtonEnabled(): Boolean {
    return _isReportIncidentButtonEnabled
  }

  fun setReportIncidentButtonEnabled(enabled: Boolean) {
    navigationView.setReportIncidentButtonEnabled(enabled)
    _isReportIncidentButtonEnabled = enabled
  }

  fun isIncidentReportingAvailable(): Boolean {
    return navigationView.isIncidentReportingAvailable()
  }

  fun showReportIncidentsPanel() {
    navigationView.showReportIncidentsPanel()
  }

  fun isNavigationUIEnabled(): Boolean {
    return navigationView.isNavigationUiEnabled
  }

  fun setNavigationUIEnabled(enabled: Boolean) {
    if (navigationView.isNavigationUiEnabled != enabled) {
      navigationView.isNavigationUiEnabled = enabled
    }
  }
}
