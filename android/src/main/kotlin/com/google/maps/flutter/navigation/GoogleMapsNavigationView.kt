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
import com.google.android.libraries.navigation.ForceNightMode
import com.google.android.libraries.navigation.NavigationView
import com.google.android.libraries.navigation.OnNavigationUiChangedListener
import com.google.android.libraries.navigation.PromptVisibilityChangedListener
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
  private var _forceNightMode: Int = ForceNightMode.AUTO
  private var _isNavigationTripProgressBarEnabled: Boolean = false
  private var _isNavigationHeaderEnabled: Boolean = true
  private var _isNavigationFooterEnabled: Boolean = true
  private var _isRecenterButtonEnabled: Boolean = true
  private var _isSpeedLimitIconEnabled: Boolean = false
  private var _isSpeedometerEnabled: Boolean = false
  private var _isTrafficIncidentCardsEnabled: Boolean = true
  private var _isReportIncidentButtonEnabled: Boolean = true
  private var _isTrafficPromptsEnabled: Boolean = true

  private var _onRecenterButtonClickedListener: NavigationView.OnRecenterButtonClickedListener? =
    null
  private var _onNavigationUIEnabledChanged: OnNavigationUiChangedListener? = null

  private var _onPromptVisibilityChanged: PromptVisibilityChangedListener? = null

  override fun getView(): View {
    return _navigationView
  }

  init {
    // Call all of these three lifecycle functions in sequence to fully
    // initialize the navigation view.
    _navigationView.onCreate(context.applicationInfo.metaData)
    onStart()
    onResume()

    // Initialize navigation view with given navigation view options
    var navigationViewEnabled = false
    if (
      navigationOptions?.navigationUiEnabledPreference == NavigationUIEnabledPreference.AUTOMATIC &&
        GoogleMapsNavigatorHolder.getInitializationState() ==
          GoogleNavigatorInitializationState.INITIALIZED
    ) {
      navigationViewEnabled = true
    }
    _navigationView.isNavigationUiEnabled = navigationViewEnabled

    // Initialize force night mode if provided
    navigationOptions?.forceNightMode?.let { forceNightMode ->
      _forceNightMode = forceNightMode
      _navigationView.setForceNightMode(forceNightMode)
    }

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
    }
  }

  override fun dispose() {
    if (super.isDestroyed()) {
      return
    }

    viewRegistry.unregisterNavigationView(getViewId())

    // Remove navigation view specific listeners
    if (_onRecenterButtonClickedListener != null) {
      _navigationView.removeOnRecenterButtonClickedListener(_onRecenterButtonClickedListener)
      _onRecenterButtonClickedListener = null
    }
    if (_onNavigationUIEnabledChanged != null) {
      _navigationView.removeOnNavigationUiChangedListener(_onNavigationUIEnabledChanged)
      _onNavigationUIEnabledChanged = null
    }
    if (_onPromptVisibilityChanged != null) {
      _navigationView.removePromptVisibilityChangedListener(_onPromptVisibilityChanged)
      _onPromptVisibilityChanged = null
    }

    // When view is disposed, all of these lifecycle functions must be
    // called to properly dispose navigation view and prevent leaks.
    onPause()
    onStop()
    super.onDispose()
    _navigationView.onDestroy()
  }

  override fun onStart(): Boolean {
    if (super.onStart()) {
      _navigationView.onStart()
      return true
    }
    return false
  }

  override fun onResume(): Boolean {
    if (super.onResume()) {
      _navigationView.onResume()
      return true
    }
    return false
  }

  override fun onStop(): Boolean {
    if (super.onStop()) {
      _navigationView.onStop()
      return true
    }
    return false
  }

  override fun onPause(): Boolean {
    if (super.onPause()) {
      _navigationView.onPause()
      return true
    }
    return false
  }

  fun onConfigurationChanged(configuration: Configuration) {
    _navigationView.onConfigurationChanged(configuration)
  }

  fun onTrimMemory(level: Int) {
    _navigationView.onTrimMemory(level)
  }

  override fun initListeners() {
    _onRecenterButtonClickedListener =
      NavigationView.OnRecenterButtonClickedListener {
        viewEventApi?.onRecenterButtonClicked(getViewId().toLong()) {}
      }
    _navigationView.addOnRecenterButtonClickedListener(_onRecenterButtonClickedListener)

    _onNavigationUIEnabledChanged = OnNavigationUiChangedListener {
      viewEventApi?.onNavigationUIEnabledChanged(getViewId().toLong(), it) {}
    }
    _navigationView.addOnNavigationUiChangedListener(_onNavigationUIEnabledChanged)

    _onPromptVisibilityChanged = PromptVisibilityChangedListener { promptVisible ->
      viewEventApi?.onPromptVisibilityChanged(getViewId().toLong(), promptVisible) {}
    }
    _navigationView.addPromptVisibilityChangedListener(_onPromptVisibilityChanged)

    super.initListeners()
  }

  override fun isNavigationTripProgressBarEnabled(): Boolean {
    return _isNavigationTripProgressBarEnabled
  }

  override fun setNavigationTripProgressBarEnabled(enabled: Boolean) {
    _navigationView.setTripProgressBarEnabled(enabled)
    _isNavigationTripProgressBarEnabled = enabled
  }

  override fun isNavigationHeaderEnabled(): Boolean {
    return _isNavigationHeaderEnabled
  }

  override fun setNavigationHeaderEnabled(enabled: Boolean) {
    _navigationView.setHeaderEnabled(enabled)
    _isNavigationHeaderEnabled = enabled
  }

  override fun isNavigationFooterEnabled(): Boolean {
    return _isNavigationFooterEnabled
  }

  override fun setNavigationFooterEnabled(enabled: Boolean) {
    _navigationView.setEtaCardEnabled(enabled)
    _isNavigationFooterEnabled = enabled
  }

  override fun isRecenterButtonEnabled(): Boolean {
    return _isRecenterButtonEnabled
  }

  override fun setRecenterButtonEnabled(enabled: Boolean) {
    _navigationView.setRecenterButtonEnabled(enabled)
    _isRecenterButtonEnabled = enabled
  }

  override fun isSpeedLimitIconEnabled(): Boolean {
    return _isSpeedLimitIconEnabled
  }

  override fun setSpeedLimitIconEnabled(enabled: Boolean) {
    _navigationView.setSpeedLimitIconEnabled(enabled)
    _isSpeedLimitIconEnabled = enabled
  }

  override fun isSpeedometerEnabled(): Boolean {
    return _isSpeedometerEnabled
  }

  override fun setSpeedometerEnabled(enabled: Boolean) {
    _navigationView.setSpeedometerEnabled(enabled)
    _isSpeedometerEnabled = enabled
  }

  override fun isTrafficIncidentCardsEnabled(): Boolean {
    return _isTrafficIncidentCardsEnabled
  }

  override fun setTrafficIncidentCardsEnabled(enabled: Boolean) {
    _navigationView.setTrafficIncidentCardsEnabled(enabled)
    _isTrafficIncidentCardsEnabled = enabled
  }

  override fun isReportIncidentButtonEnabled(): Boolean {
    return _isReportIncidentButtonEnabled
  }

  override fun setReportIncidentButtonEnabled(enabled: Boolean) {
    _navigationView.setReportIncidentButtonEnabled(enabled)
    _isReportIncidentButtonEnabled = enabled
  }

  override fun isIncidentReportingAvailable(): Boolean {
    return _navigationView.isIncidentReportingAvailable()
  }

  override fun showReportIncidentsPanel() {
    _navigationView.showReportIncidentsPanel()
  }

  override fun isTrafficPromptsEnabled(): Boolean {
    return _isTrafficPromptsEnabled
  }

  override fun setTrafficPromptsEnabled(enabled: Boolean) {
    _navigationView.setTrafficPromptsEnabled(enabled)
    _isTrafficPromptsEnabled = enabled
  }

  override fun isNavigationUIEnabled(): Boolean {
    return _navigationView.isNavigationUiEnabled
  }

  override fun setNavigationUIEnabled(enabled: Boolean) {
    if (_navigationView.isNavigationUiEnabled != enabled) {
      _navigationView.isNavigationUiEnabled = enabled
    }
  }

  override fun showRouteOverview() {
    _navigationView.showRouteOverview()
  }

  override fun getForceNightMode(): Int {
    return _forceNightMode
  }

  override fun setForceNightMode(forceNightMode: Int) {
    _forceNightMode = forceNightMode
    _navigationView.setForceNightMode(forceNightMode)
  }
}
