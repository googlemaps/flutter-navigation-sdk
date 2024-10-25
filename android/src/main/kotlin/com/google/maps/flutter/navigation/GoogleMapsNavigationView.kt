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
import com.google.android.gms.maps.GoogleMap.OnCameraMoveStartedListener
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.Polygon
import com.google.android.gms.maps.model.Polyline
import com.google.android.libraries.navigation.NavigationView
import io.flutter.plugin.platform.PlatformView

class GoogleMapsNavigationView
internal constructor(
  context: Context,
  mapOptions: GoogleMapOptions,
  navigationOptions: NavigationViewOptions?,
  viewId: Int,
  private val viewRegistry: GoogleMapsViewRegistry,
  viewEventApi: ViewEventApi,
  private val imageRegistry: ImageRegistry
) : PlatformView, GoogleMapsBaseMapView(viewId, viewEventApi, imageRegistry) {
  companion object {
    const val INVALIDATION_FRAME_SKIP_AMOUNT = 4 // Amount of skip frames before invalidation
  }

  private val _navigationView: NavigationView = NavigationView(context, mapOptions)
  private val _frameDelayHandler = FrameDelayHandler(INVALIDATION_FRAME_SKIP_AMOUNT)
  private var _loadedCallbackPending = false
  private val _markers = mutableListOf<MarkerController>()
  private val _polygons = mutableListOf<PolygonController>()
  private val _polylines = mutableListOf<PolylineController>()
  private val _circles = mutableListOf<CircleController>()

  // Store preferred zoom values here because MapView getMinZoom and
  // getMaxZoom always return min/max possible values and not the preferred ones.
  private var _minZoomLevelPreference: Float? = null
  private var _maxZoomLevelPreference: Float? = null

  /// Default values for UI features.
  private var _isNavigationTripProgressBarEnabled: Boolean = false
  private var _isNavigationHeaderEnabled: Boolean = true
  private var _isNavigationFooterEnabled: Boolean = true
  private var _isRecenterButtonEnabled: Boolean = true
  private var _isSpeedLimitIconEnabled: Boolean = false
  private var _isSpeedometerEnabled: Boolean = false
  private var _isTrafficIncidentCardsEnabled: Boolean = true

  // Nullable variable to hold the callback function
  private var _mapReadyCallback: ((Result<Unit>) -> Unit)? = null

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

    _minZoomLevelPreference = mapOptions.minZoomPreference
    _maxZoomLevelPreference = mapOptions.maxZoomPreference

    _navigationView.getMapAsync { map ->
      setMap(map)
      initListeners()
      imageRegistry.mapViewInitializationComplete()

      // Re set navigation view enabled state as sometimes earlier value is not
      // respected.
      _navigationView.isNavigationUiEnabled = navigationViewEnabled
      if (!navigationViewEnabled) {
        map.moveCamera(CameraUpdateFactory.newCameraPosition(mapOptions.camera))
      }

      // Call and clear view ready callback if available.
      mapReady()
      invalidateViewAfterMapLoad()
    }

    viewRegistry.registerNavigationView(viewId, this)
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

    viewRegistry.unregisterNavigationView(viewId)
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
      viewEventApi.onRecenterButtonClicked(viewId.toLong()) {}
    }
    _navigationView.addOnNavigationUiChangedListener {
      viewEventApi.onNavigationUIEnabledChanged(viewId.toLong(), it) {}
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

  fun getMinZoomPreference(): Float {
    return _minZoomLevelPreference ?: getMap().minZoomLevel
  }

  fun getMaxZoomPreference(): Float {
    return _maxZoomLevelPreference ?: getMap().maxZoomLevel
  }

  fun resetMinMaxZoomPreference() {
    _minZoomLevelPreference = null
    _maxZoomLevelPreference = null
    getMap().resetMinMaxZoomPreference()
  }

  @Throws(FlutterError::class)
  fun setMinZoomPreference(minZoomPreference: Float) {
    if (minZoomPreference > (_maxZoomLevelPreference ?: getMap().maxZoomLevel)) {
      throw FlutterError(
        "minZoomGreaterThanMaxZoom",
        "Minimum zoom level cannot be greater than maximum zoom level"
      )
    }

    _minZoomLevelPreference = minZoomPreference
    getMap().setMinZoomPreference(minZoomPreference)
  }

  @Throws(FlutterError::class)
  fun setMaxZoomPreference(maxZoomPreference: Float) {
    if (maxZoomPreference < (_minZoomLevelPreference ?: getMap().minZoomLevel)) {
      throw FlutterError(
        "maxZoomLessThanMinZoom",
        "Maximum zoom level cannot be less than minimum zoom level"
      )
    }

    _maxZoomLevelPreference = maxZoomPreference
    getMap().setMaxZoomPreference(maxZoomPreference)
  }

  fun registerOnCameraChangedListener() {
    getMap().setOnCameraMoveStartedListener { reason ->
      val event =
        when (reason) {
          OnCameraMoveStartedListener.REASON_API_ANIMATION,
          OnCameraMoveStartedListener.REASON_DEVELOPER_ANIMATION ->
            CameraEventTypeDto.MOVESTARTEDBYAPI
          OnCameraMoveStartedListener.REASON_GESTURE -> CameraEventTypeDto.MOVESTARTEDBYGESTURE
          else -> {
            // This should not happen, added that the compiler does not complain.
            throw RuntimeException("Unknown camera move started reason: $reason")
          }
        }
      val position = Convert.convertCameraPositionToDto(getMap().cameraPosition)
      viewEventApi.onCameraChanged(viewId.toLong(), event, position) {}
    }
    getMap().setOnCameraMoveListener {
      val position = Convert.convertCameraPositionToDto(getMap().cameraPosition)
      viewEventApi.onCameraChanged(viewId.toLong(), CameraEventTypeDto.ONCAMERAMOVE, position) {}
    }
    getMap().setOnCameraIdleListener {
      val position = Convert.convertCameraPositionToDto(getMap().cameraPosition)
      viewEventApi.onCameraChanged(viewId.toLong(), CameraEventTypeDto.ONCAMERAIDLE, position) {}
    }
  }
}
