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

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Point
import android.location.Location
import android.view.View
import com.google.android.gms.maps.CameraUpdate
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMap.OnMarkerDragListener
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.FollowMyLocationOptions
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.gms.maps.model.MapStyleOptions
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.Polygon
import com.google.android.gms.maps.model.Polyline
import com.google.android.libraries.navigation.NavigationView
import io.flutter.plugin.platform.PlatformView

class GoogleMapsNavigationView
internal constructor(
  context: Context,
  mapOptions: GoogleMapOptions,
  navigationOptions: NavigationViewOptions,
  private val viewId: Int,
  private val viewRegistry: GoogleMapsNavigationViewRegistry,
  private val navigationViewEventApi: NavigationViewEventApi,
  private val imageRegistry: ImageRegistry
) : PlatformView {
  companion object {
    const val INVALIDATION_FRAME_SKIP_AMOUNT = 4 // Amount of skip frames before invalidation
  }

  private val _navigationView: NavigationView
  private var _map: GoogleMap? = null
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
  private var _isIncidentCardsEnabled: Boolean = true
  private var _consumeMyLocationButtonClickEventsEnabled: Boolean = false

  // Nullable variable to hold the callback function
  private var _mapReadyCallback: ((Result<Unit>) -> Unit)? = null

  override fun getView(): View {
    return _navigationView
  }

  init {
    _navigationView = NavigationView(context, mapOptions)

    // Call all of these three lifecycle functions in sequence to fully
    // initialize the navigation view.
    _navigationView.onCreate(context.applicationInfo.metaData)
    _navigationView.onStart()
    _navigationView.onResume()

    // Initialize navigation view with given navigation view options
    var navigationViewEnabled: Boolean = false
    if (
      navigationOptions.navigationUiEnabledPreference == NavigationUIEnabledPreference.AUTOMATIC
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
      _map = map
      initListeners()
      imageRegistry.mapViewInitializationComplete()

      // Re set navigation view enabled state as sometimes earlier value is not
      // respected.
      _navigationView.isNavigationUiEnabled = navigationViewEnabled
      if (!navigationViewEnabled) {
        map.moveCamera(CameraUpdateFactory.newCameraPosition(mapOptions.camera))
      }

      // Call and clear view ready callback if available.
      _mapReadyCallback?.let { callback ->
        callback(Result.success(Unit))
        _mapReadyCallback = null
      }

      invalidateViewAfterMapLoad()
    }

    viewRegistry.registerView(viewId, this)
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

    viewRegistry.unregisterView(viewId)
  }

  private fun initListeners() {
    _navigationView.addOnRecenterButtonClickedListener {
      navigationViewEventApi.onRecenterButtonClicked(viewId.toLong()) {}
    }
    _navigationView.addOnNavigationUiChangedListener {
      navigationViewEventApi.onNavigationUIEnabledChanged(viewId.toLong(), it) {}
    }
    getMap().setOnMapClickListener {
      navigationViewEventApi.onMapClickEvent(
        viewId.toLong(),
        LatLngDto(it.latitude, it.longitude),
      ) {}
    }
    getMap().setOnMapLongClickListener {
      navigationViewEventApi.onMapLongClickEvent(
        viewId.toLong(),
        LatLngDto(it.latitude, it.longitude),
      ) {}
    }
    getMap().setOnMarkerClickListener { marker ->
      val markerId = findMarkerId(marker)
      val controller = findMarkerController(markerId)

      sendMarkerEvent(marker, MarkerEventTypeDto.CLICKED)

      // This return value controls the default onClick behaviour,
      // return true for default behaviour to occur and false to not.
      // Default behavior is for the camera to move to the marker and an info window to
      // appear.
      controller?.consumeTapEvents ?: false
    }
    getMap()
      .setOnMarkerDragListener(
        object : OnMarkerDragListener {
          override fun onMarkerDrag(marker: Marker) {
            sendMarkerDragEvent(marker, MarkerDragEventTypeDto.DRAG)
          }

          override fun onMarkerDragEnd(marker: Marker) {
            sendMarkerDragEvent(marker, MarkerDragEventTypeDto.DRAGEND)
          }

          override fun onMarkerDragStart(marker: Marker) {
            sendMarkerDragEvent(marker, MarkerDragEventTypeDto.DRAGSTART)
          }
        }
      )
    getMap().setOnInfoWindowClickListener { marker ->
      sendMarkerEvent(marker, MarkerEventTypeDto.INFOWINDOWCLICKED)
    }
    getMap().setOnInfoWindowCloseListener { marker ->
      try {
        sendMarkerEvent(marker, MarkerEventTypeDto.INFOWINDOWCLOSED)
      } catch (exception: FlutterError) {
        // Google maps trigger this callback if info window is open for marker that is removed.
        // As marker and it's information that maps the marker to the markerId is removed,
        // [FlutterError] is thrown. In this case info window close event is not sent.
      }
    }
    getMap().setOnInfoWindowLongClickListener { marker ->
      sendMarkerEvent(marker, MarkerEventTypeDto.INFOWINDOWLONGCLICKED)
    }

    getMap().setOnPolygonClickListener { polygon ->
      val polygonId = findPolygonId(polygon)
      navigationViewEventApi.onPolygonClicked(viewId.toLong(), polygonId) {}
    }

    getMap().setOnPolylineClickListener { polyline ->
      val polylineId = findPolylineId(polyline)
      navigationViewEventApi.onPolylineClicked(viewId.toLong(), polylineId) {}
    }

    getMap().setOnCircleClickListener { circle ->
      val circleId = findCircleId(circle)
      navigationViewEventApi.onCircleClicked(viewId.toLong(), circleId) {}
    }

    getMap().setOnMyLocationClickListener {
      navigationViewEventApi.onMyLocationClicked(viewId.toLong()) {}
    }

    getMap().setOnMyLocationButtonClickListener {
      navigationViewEventApi.onMyLocationButtonClicked(viewId.toLong()) {}
      _consumeMyLocationButtonClickEventsEnabled
    }
  }

  @Throws(FlutterError::class)
  private fun getMap(): GoogleMap {
    if (_map != null) {
      return _map!!
    } else {
      throw FlutterError("mapNotFound", "GoogleMap not initialized yet")
    }
  }

  /**
   * Workaround for map view not showing added or edited map objects immediately after add/edit.
   * Schedules [NavigationView.invalidate] call after a certain amount of frames are drawn. In
   * marker updates short delay is not enough, [doubleInvalidate] is set to true.
   *
   * @param doubleInvalidate if true, schedules another invalidate event after the first one.
   */
  private fun invalidateViewAfterMapLoad(doubleInvalidate: Boolean = false) {
    if (_loadedCallbackPending) {
      return
    }
    _loadedCallbackPending = true
    getMap().setOnMapLoadedCallback {
      _loadedCallbackPending = false
      _frameDelayHandler.scheduleActionWithFrameDelay {
        _navigationView.invalidate()
        if (doubleInvalidate) {
          _frameDelayHandler.scheduleActionWithFrameDelay { _navigationView.invalidate() }
        }
      }
    }
  }

  fun onStart() {
    _navigationView.onStart()
  }

  fun onResume() {
    _navigationView.onResume()
  }

  fun onStop() {
    _navigationView.onStop()
  }

  fun onPause() {
    _navigationView.onPause()
  }

  fun onConfigurationChanged(configuration: Configuration) {
    _navigationView.onConfigurationChanged(configuration)
  }

  fun onTrimMemory(level: Int) {
    _navigationView.onTrimMemory(level)
  }

  @Throws(FlutterError::class)
  private fun findMarkerId(marker: Marker): String {
    return _markers.find { it.marker == marker }?.markerId
      ?: throw FlutterError("markerNotFound", "Could not find the marker.")
  }

  @Throws(FlutterError::class)
  private fun findMarkerController(markerId: String): MarkerController? {
    return _markers.find { it.markerId == markerId }
  }

  @Throws(FlutterError::class)
  private fun findPolygonId(polygon: Polygon): String {
    return _polygons.find { it.polygon == polygon }?.polygonId
      ?: throw FlutterError("polygonNotFound", "Could not find the polygon.")
  }

  @Throws(FlutterError::class)
  private fun findPolylineId(polyline: Polyline): String {
    return _polylines.find { it.polyline == polyline }?.polylineId
      ?: throw FlutterError("polylineNotFound", "Could not find the polyline.")
  }

  @Throws(FlutterError::class)
  private fun findCircleId(circle: Circle): String {
    return _circles.find { it.circle == circle }?.circleId
      ?: throw FlutterError("circleNotFound", "Could not find the circle")
  }

  @Throws(FlutterError::class)
  private fun findPolygonController(polygonId: String): PolygonController? {
    return _polygons.find { it.polygonId == polygonId }
  }

  @Throws(FlutterError::class)
  private fun findPolylineController(polylineId: String): PolylineController? {
    return _polylines.find { it.polylineId == polylineId }
  }

  @Throws(FlutterError::class)
  private fun findCircleController(circleId: String): CircleController? {
    return _circles.find { it.circleId == circleId }
  }

  @Throws(FlutterError::class)
  private fun sendMarkerEvent(marker: Marker, eventType: MarkerEventTypeDto) {
    val markerId = findMarkerId(marker)
    navigationViewEventApi.onMarkerEvent(viewId.toLong(), markerId, eventType) {}
  }

  @Throws(FlutterError::class)
  private fun sendMarkerDragEvent(marker: Marker, eventType: MarkerDragEventTypeDto) {
    val markerId = findMarkerId(marker)
    navigationViewEventApi.onMarkerDragEvent(
      viewId.toLong(),
      markerId,
      eventType,
      LatLngDto(marker.position.latitude, marker.position.longitude)
    ) {}
  }

  fun isMyLocationEnabled(): Boolean {
    return getMap().isMyLocationEnabled
  }

  @SuppressLint("MissingPermission")
  fun setMyLocationEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    getMap().isMyLocationEnabled = enabled
  }

  fun setMyLocationButtonEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    getMap().uiSettings.isMyLocationButtonEnabled = enabled
  }

  fun setZoomGesturesEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    getMap().uiSettings.isZoomGesturesEnabled = enabled
  }

  fun setZoomControlsEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    getMap().uiSettings.isZoomControlsEnabled = enabled
  }

  fun setCompassEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    getMap().uiSettings.isCompassEnabled = enabled
  }

  fun setRotateGesturesEnabled(enabled: Boolean) {
    getMap().uiSettings.isRotateGesturesEnabled = enabled
  }

  fun setScrollGesturesEnabled(enabled: Boolean) {
    getMap().uiSettings.isScrollGesturesEnabled = enabled
  }

  fun setScrollGesturesDuringRotateOrZoomEnabled(enabled: Boolean) {
    getMap().uiSettings.isScrollGesturesEnabledDuringRotateOrZoom = enabled
  }

  fun setTiltGesturesEnabled(enabled: Boolean) {
    getMap().uiSettings.isTiltGesturesEnabled = enabled
  }

  fun setMapToolbarEnabled(enabled: Boolean) {
    getMap().uiSettings.isMapToolbarEnabled = enabled
  }

  fun setTrafficEnabled(enabled: Boolean) {
    getMap().isTrafficEnabled = enabled
  }

  fun isMyLocationButtonEnabled(): Boolean {
    return getMap().uiSettings.isMyLocationButtonEnabled
  }

  fun isZoomGesturesEnabled(): Boolean {
    return getMap().uiSettings.isZoomGesturesEnabled
  }

  fun isZoomControlsEnabled(): Boolean {
    return getMap().uiSettings.isZoomControlsEnabled
  }

  fun isCompassEnabled(): Boolean {
    return getMap().uiSettings.isCompassEnabled
  }

  fun isRotateGesturesEnabled(): Boolean {
    return getMap().uiSettings.isRotateGesturesEnabled
  }

  fun isScrollGesturesEnabled(): Boolean {
    return getMap().uiSettings.isScrollGesturesEnabled
  }

  fun isScrollGesturesEnabledDuringRotateOrZoom(): Boolean {
    return getMap().uiSettings.isScrollGesturesEnabledDuringRotateOrZoom
  }

  fun isTiltGesturesEnabled(): Boolean {
    return getMap().uiSettings.isTiltGesturesEnabled
  }

  fun isMapToolbarEnabled(): Boolean {
    return getMap().uiSettings.isMapToolbarEnabled
  }

  fun isTrafficEnabled(): Boolean {
    return getMap().isTrafficEnabled
  }

  fun getMyLocation(): Location? {
    // Remove this functionality and either guide users to use separate flutter
    // library for geolocation or implement separate method under
    // [GoogleMapsNavigationSessionManager] to fetch the location
    // using the [FusedLocationProviderApi].
    @Suppress("DEPRECATION") return getMap().myLocation
  }

  fun getCameraPosition(): CameraPosition {
    return getMap().cameraPosition ?: CameraPosition(LatLng(0.0, 0.0), 0.0F, 0.0F, 0.0F)
  }

  fun getVisibleRegion(): LatLngBounds {
    return getMap().projection.visibleRegion.latLngBounds
  }

  private fun getMapCallback(callback: (Result<Boolean>) -> Unit): GoogleMap.CancelableCallback {
    return object : GoogleMap.CancelableCallback {
      override fun onFinish() {
        callback(Result.success(true))
      }

      override fun onCancel() {
        callback(Result.success(false))
      }
    }
  }

  private fun animateCamera(
    cameraUpdate: CameraUpdate,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    // Native animateCamera() doesn't allow setting null duration so need to do two calls
    if (duration == null) {
      getMap().animateCamera(cameraUpdate, getMapCallback(callback))
    } else {
      getMap().animateCamera(cameraUpdate, duration.toInt(), getMapCallback(callback))
    }
  }

  fun animateCameraToCameraPosition(
    cameraPosition: CameraPosition,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition), duration, callback)
  }

  fun animateCameraToLatLng(point: LatLng, duration: Long?, callback: (Result<Boolean>) -> Unit) {
    animateCamera(CameraUpdateFactory.newLatLng(point), duration, callback)
  }

  fun animateCameraToLatLngBounds(
    bounds: LatLngBounds,
    padding: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding.toInt()), duration, callback)
  }

  fun animateCameraToLatLngZoom(
    point: LatLng,
    zoom: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    animateCamera(CameraUpdateFactory.newLatLngZoom(point, zoom.toFloat()), duration, callback)
  }

  fun animateCameraByScroll(
    scrollByDx: Double,
    scrollByDy: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    animateCamera(
      CameraUpdateFactory.scrollBy(scrollByDx.toFloat(), scrollByDy.toFloat()),
      duration,
      callback
    )
  }

  fun animateCameraByZoom(
    zoomBy: Double,
    focus: Point?,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit
  ) {
    // Native animateCamera() doesn't allow setting null duration or focus so need to split to
    // multiple calls
    val cameraUpdate =
      if (focus != null) {
        CameraUpdateFactory.zoomBy(zoomBy.toFloat(), focus)
      } else {
        CameraUpdateFactory.zoomBy(zoomBy.toFloat())
      }
    animateCamera(cameraUpdate, duration, callback)
  }

  fun animateCameraToZoom(zoom: Double, duration: Long?, callback: (Result<Boolean>) -> Unit) {
    animateCamera(CameraUpdateFactory.zoomTo(zoom.toFloat()), duration, callback)
  }

  fun moveCameraToCameraPosition(cameraPosition: CameraPosition) {
    return getMap().moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
  }

  fun moveCameraToLatLng(point: LatLng) {
    return getMap().moveCamera(CameraUpdateFactory.newLatLng(point))
  }

  fun moveCameraToLatLngBounds(bounds: LatLngBounds, padding: Double) {
    return getMap().moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, padding.toInt()))
  }

  fun moveCameraToLatLngZoom(point: LatLng, zoom: Double) {
    return getMap().moveCamera(CameraUpdateFactory.newLatLngZoom(point, zoom.toFloat()))
  }

  fun moveCameraByScroll(scrollByDx: Double, scrollByDy: Double) {
    return getMap()
      .moveCamera(CameraUpdateFactory.scrollBy(scrollByDx.toFloat(), scrollByDy.toFloat()))
  }

  fun moveCameraByZoom(zoomBy: Double, focus: Point?) {
    if (focus != null) {
      getMap().moveCamera(CameraUpdateFactory.zoomBy(zoomBy.toFloat(), focus))
    } else {
      getMap().moveCamera(CameraUpdateFactory.zoomBy(zoomBy.toFloat()))
    }
  }

  fun moveCameraToZoom(zoom: Double) {
    return getMap().moveCamera(CameraUpdateFactory.zoomTo(zoom.toFloat()))
  }

  fun getMapType(): Int {
    return getMap().mapType
  }

  fun setMapType(mapType: Int) {
    invalidateViewAfterMapLoad()
    getMap().mapType = mapType
  }

  fun setMapStyle(styleJson: String) {
    invalidateViewAfterMapLoad()
    if (!getMap().setMapStyle(MapStyleOptions(styleJson))) {
      throw FlutterError("mapStyleError", "Failed to set map style")
    }
  }

  fun isNavigationTripProgressBarEnabled(): Boolean {
    return _isNavigationTripProgressBarEnabled
  }

  @SuppressLint("MissingPermission")
  fun followMyLocation(perspective: Int, zoomLevel: Double?) {
    invalidateViewAfterMapLoad()
    getMap().followMyLocation(perspective)
    if (zoomLevel != null) {
      val options: FollowMyLocationOptions =
        FollowMyLocationOptions.builder().setZoomLevel(zoomLevel.toFloat()).build()
      getMap().followMyLocation(perspective, options)
    } else {
      getMap().followMyLocation(perspective)
    }
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

  fun isIncidentCardsEnabled(): Boolean {
    return _isIncidentCardsEnabled
  }

  fun setIncidentCardsEnabled(enabled: Boolean) {
    invalidateViewAfterMapLoad()
    _navigationView.setTrafficIncidentCardsEnabled(enabled)
    _isIncidentCardsEnabled = enabled
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

  fun awaitMapReady(callback: (Result<Unit>) -> Unit) {
    if (_map != null) {
      // Call the callback immediately as the map is already initialized
      callback(Result.success(Unit))
    } else if (_mapReadyCallback != null) {
      // If there is already a callback pending, throw an error to avoid overriding it
      callback(
        Result.failure(
          FlutterError(
            "mapReadyCallbackAlreadyPending",
            "A callback is already pending and cannot be overridden."
          )
        )
      )
    } else {
      // Save the callback to be called once the map is initialized
      _mapReadyCallback = callback
    }
  }

  fun getMarkers(): List<MarkerDto> {
    return _markers.map { MarkerDto(it.markerId, Convert.markerControllerToMarkerOptions(it)) }
  }

  fun addMarkers(markers: List<MarkerDto>): List<MarkerDto> {
    val result = mutableListOf<MarkerDto>()
    markers.forEach {
      val builder = MarkerBuilder()
      Convert.sinkMarkerOptions(it.options, builder, imageRegistry)
      val options = builder.build()
      val marker = getMap().addMarker(options)
      if (marker != null) {
        val registeredImage =
          it.options.icon.registeredImageId?.let { id -> imageRegistry.findRegisteredImage(id) }
        val controller =
          MarkerController(
            marker,
            it.markerId,
            builder.consumeTapEvents,
            it.options.anchor.u.toFloat(),
            it.options.anchor.v.toFloat(),
            it.options.infoWindow.anchor.u.toFloat(),
            it.options.infoWindow.anchor.v.toFloat(),
            registeredImage
          )
        _markers.add(controller)
        result.add(it)
      }
    }
    // Double invalidate map view. Marker icon updates seem to take extra
    // time and some times icon did not update properly after single invalidate.
    invalidateViewAfterMapLoad(true)
    return result
  }

  @Throws(FlutterError::class)
  fun updateMarkers(markers: List<MarkerDto>): List<MarkerDto> {
    val result = mutableListOf<MarkerDto>()
    var error: Throwable? = null
    markers.forEach {
      findMarkerController(it.markerId)?.let { controller ->
        Convert.sinkMarkerOptions(it.options, controller, imageRegistry)
        result.add(it)
      }
        ?: run {
          error = FlutterError("markerNotFound", "Failed to update marker with id ${it.markerId}")
        }
    }
    error?.let { throw error as Throwable }
    // Double invalidate map view. Marker icon updates seem to take extra
    // time and some times icon did not update properly after single invalidate.
    invalidateViewAfterMapLoad(true)
    return result
  }

  @Throws(FlutterError::class)
  fun removeMarkers(markers: List<MarkerDto>) {
    invalidateViewAfterMapLoad()
    var error: Throwable? = null
    markers.forEach {
      findMarkerController(it.markerId)?.let { controller ->
        controller.remove()
        _markers.remove(controller)
      }
        ?: run {
          error = FlutterError("markerNotFound", "Failed to remove marker with id ${it.markerId}")
        }
    }
    error?.let { throw error as Throwable }
  }

  fun clearMarkers() {
    invalidateViewAfterMapLoad()
    _markers.forEach { controller -> controller.remove() }
    _markers.clear()
  }

  fun clear() {
    getMap().clear()
    _markers.clear()
    _polygons.clear()
    _polylines.clear()
    _circles.clear()
  }

  fun getPolygons(): List<PolygonDto> {
    val density = Resources.getSystem().displayMetrics.density
    return _polygons.map {
      PolygonDto(it.polygonId, Convert.polygonToPolygonOptions(it.polygon, density))
    }
  }

  fun addPolygons(
    polygons: List<PolygonDto>,
  ): List<PolygonDto> {
    val density = Resources.getSystem().displayMetrics.density
    invalidateViewAfterMapLoad()
    val result = mutableListOf<PolygonDto>()
    polygons.forEach {
      val builder = PolygonBuilder()
      Convert.sinkPolygonOptions(it.options, builder, density)
      val options = builder.build()
      val polygon = getMap().addPolygon(options)
      if (polygon != null) {
        val controller = PolygonController(polygon, it.polygonId)
        _polygons.add(controller)
        result.add(it)
      }
    }
    return result
  }

  fun updatePolygons(polygons: List<PolygonDto>): List<PolygonDto> {
    invalidateViewAfterMapLoad()
    var error: Throwable? = null
    val result = mutableListOf<PolygonDto>()
    val density = Resources.getSystem().displayMetrics.density
    polygons.forEach {
      findPolygonController(it.polygonId)?.let { controller ->
        Convert.sinkPolygonOptions(it.options, controller, density)
        result.add(it)
      }
        ?: run {
          error =
            FlutterError("polygonNotFound", "Failed to update polygon with id ${it.polygonId}")
        }
    }
    error?.let { throw error as Throwable }

    return result
  }

  fun removePolygons(polygons: List<PolygonDto>) {
    invalidateViewAfterMapLoad()
    var error: Throwable? = null
    polygons.forEach {
      findPolygonController(it.polygonId)?.let { controller ->
        controller.remove()
        _polygons.remove(controller)
      }
        ?: run {
          error =
            FlutterError("polygonNotFound", "Failed to remove polygon with id ${it.polygonId}")
        }
    }
    error?.let { throw error as Throwable }
  }

  fun clearPolygons() {
    invalidateViewAfterMapLoad()
    _polygons.forEach { controller -> controller.remove() }
    _polygons.clear()
  }

  fun getPolylines(): List<PolylineDto> {
    val density = Resources.getSystem().displayMetrics.density
    return _polylines.map {
      PolylineDto(it.polylineId, Convert.polylineToPolylineOptions(it.polyline, density))
    }
  }

  fun addPolylines(
    polylines: List<PolylineDto>,
  ): List<PolylineDto> {
    val density = Resources.getSystem().displayMetrics.density
    invalidateViewAfterMapLoad()
    val result = mutableListOf<PolylineDto>()
    polylines.forEach {
      val builder = PolylineBuilder()
      Convert.sinkPolylineOptions(it.options, builder, density)
      val options = builder.build()
      val polyline = getMap().addPolyline(options)
      if (polyline != null) {
        val controller = PolylineController(polyline, it.polylineId)
        _polylines.add(controller)
        result.add(it)
      }
    }
    return result
  }

  fun updatePolylines(polylines: List<PolylineDto>): List<PolylineDto> {
    var error: Throwable? = null
    val density = Resources.getSystem().displayMetrics.density
    invalidateViewAfterMapLoad()
    val result = mutableListOf<PolylineDto>()
    polylines.forEach {
      findPolylineController(it.polylineId)?.let { controller ->
        Convert.sinkPolylineOptions(it.options, controller, density)
        result.add(it)
      }
        ?: run {
          error =
            FlutterError("polylineNotFound", "Failed to update polyline with id ${it.polylineId}")
        }
    }
    error?.let { throw error as Throwable }
    return result
  }

  fun removePolylines(polylines: List<PolylineDto>) {
    invalidateViewAfterMapLoad()
    var error: Throwable? = null
    polylines.forEach {
      findPolylineController(it.polylineId)?.let { controller ->
        controller.remove()
        _polylines.remove(controller)
      }
        ?: run {
          error =
            FlutterError("polylineNotFound", "Failed to remove polyline with id ${it.polylineId}")
        }
    }
    error?.let { throw error as Throwable }
  }

  fun clearPolylines() {
    invalidateViewAfterMapLoad()
    _polylines.forEach { controller -> controller.remove() }
    _polylines.clear()
  }

  fun getCircles(): List<CircleDto> {
    val density = Resources.getSystem().displayMetrics.density
    return _circles.map {
      CircleDto(it.circleId, Convert.circleToCircleOptions(it.circle, density))
    }
  }

  fun addCircles(circles: List<CircleDto>): List<CircleDto> {
    val density = Resources.getSystem().displayMetrics.density
    invalidateViewAfterMapLoad()
    val result = mutableListOf<CircleDto>()
    circles.forEach {
      val builder = CircleBuilder()
      Convert.sinkCircleOptions(it.options, builder, density)
      val options = builder.build()
      val circle = getMap().addCircle(options)
      if (circle != null) {
        val controller = CircleController(circle, it.circleId)
        _circles.add(controller)
        result.add(it)
      }
    }
    return result
  }

  fun updateCircles(circles: List<CircleDto>): List<CircleDto> {
    val density = Resources.getSystem().displayMetrics.density
    invalidateViewAfterMapLoad()
    val result = mutableListOf<CircleDto>()
    var error: Throwable? = null
    circles.forEach {
      findCircleController(it.circleId)?.let { controller ->
        Convert.sinkCircleOptions(it.options, controller, density)
        result.add(it)
      }
        ?: run {
          error = FlutterError("circleNotFound", "Failed to update circle with id ${it.circleId}")
        }
    }
    error?.let { throw error as Throwable }
    return result
  }

  fun removeCircles(circles: List<CircleDto>) {
    invalidateViewAfterMapLoad()
    var error: Throwable? = null
    circles.forEach {
      findCircleController(it.circleId)?.let { controller ->
        controller.remove()
        _circles.remove(controller)
      }
        ?: run {
          error = FlutterError("circleNotFound", "Failed to remove circle with id ${it.circleId}")
        }
    }
    error?.let { throw error as Throwable }
  }

  fun clearCircles() {
    invalidateViewAfterMapLoad()
    _circles.forEach { controller -> controller.remove() }
    _circles.clear()
  }

  fun setConsumeMyLocationButtonClickEventsEnabled(enabled: Boolean) {
    _consumeMyLocationButtonClickEventsEnabled = enabled
  }

  fun isConsumeMyLocationButtonClickEventsEnabled(): Boolean {
    return _consumeMyLocationButtonClickEventsEnabled
  }
}
