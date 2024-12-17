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

import android.content.res.Resources

/** GoogleMapsViewMessageHandler */
class GoogleMapsViewMessageHandler(private val viewRegistry: GoogleMapsViewRegistry) : MapViewApi {

  private fun getNavigationView(viewId: Int): GoogleMapsNavigationView {
    val view = viewRegistry.getNavigationView(viewId)
    if (view != null) {
      return view
    } else {
      throw FlutterError("viewNotFound", "No valid navigation view found")
    }
  }

  private fun getView(viewId: Int): GoogleMapsBaseMapView {
    val view = viewRegistry.getMapView(viewId)
    if (view != null) {
      return view
    } else {
      throw FlutterError("viewNotFound", "No valid view found")
    }
  }

  override fun awaitMapReady(viewId: Long, callback: (Result<Unit>) -> Unit) {
    return getView(viewId.toInt()).awaitMapReady(callback)
  }

  override fun isMyLocationEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isMyLocationEnabled()
  }

  override fun setMyLocationEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setMyLocationEnabled(enabled)
  }

  override fun getMapType(viewId: Long): MapTypeDto {
    val googleMapType = getView(viewId.toInt()).getMapType()
    return Convert.convertMapTypeToDto(googleMapType)
  }

  override fun setMapType(viewId: Long, mapType: MapTypeDto) {
    val view = getView(viewId.toInt())
    val googleMapType = Convert.convertMapTypeFromDto(mapType)
    view.setMapType(googleMapType)
  }

  override fun setMapStyle(viewId: Long, styleJson: String) {
    val view = getView(viewId.toInt())
    view.setMapStyle(styleJson)
  }

  override fun setMyLocationButtonEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setMyLocationButtonEnabled(enabled)
  }

  override fun setConsumeMyLocationButtonClickEventsEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setConsumeMyLocationButtonClickEventsEnabled(enabled)
  }

  override fun setZoomGesturesEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setZoomGesturesEnabled(enabled)
  }

  override fun setZoomControlsEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setZoomControlsEnabled(enabled)
  }

  override fun setCompassEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setCompassEnabled(enabled)
  }

  override fun setRotateGesturesEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setRotateGesturesEnabled(enabled)
  }

  override fun setScrollGesturesEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setScrollGesturesEnabled(enabled)
  }

  override fun setScrollGesturesDuringRotateOrZoomEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setScrollGesturesDuringRotateOrZoomEnabled(enabled)
  }

  override fun setTiltGesturesEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setTiltGesturesEnabled(enabled)
  }

  override fun setMapToolbarEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setMapToolbarEnabled(enabled)
  }

  override fun setTrafficEnabled(viewId: Long, enabled: Boolean) {
    getView(viewId.toInt()).setTrafficEnabled(enabled)
  }

  override fun isMyLocationButtonEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isMyLocationButtonEnabled()
  }

  override fun isConsumeMyLocationButtonClickEventsEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isConsumeMyLocationButtonClickEventsEnabled()
  }

  override fun isZoomGesturesEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isZoomGesturesEnabled()
  }

  override fun isZoomControlsEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isZoomControlsEnabled()
  }

  override fun isCompassEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isCompassEnabled()
  }

  override fun isRotateGesturesEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isRotateGesturesEnabled()
  }

  override fun isScrollGesturesEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isScrollGesturesEnabled()
  }

  override fun isScrollGesturesEnabledDuringRotateOrZoom(viewId: Long): Boolean {
    return getView(viewId.toInt()).isScrollGesturesEnabledDuringRotateOrZoom()
  }

  override fun isTiltGesturesEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isTiltGesturesEnabled()
  }

  override fun isMapToolbarEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isMapToolbarEnabled()
  }

  override fun isTrafficEnabled(viewId: Long): Boolean {
    return getView(viewId.toInt()).isTrafficEnabled()
  }

  override fun getMyLocation(viewId: Long): LatLngDto? {
    val location = getView(viewId.toInt()).getMyLocation() ?: return null
    return LatLngDto(location.latitude, location.longitude)
  }

  override fun getCameraPosition(viewId: Long): CameraPositionDto {
    return Convert.convertCameraPositionToDto(getView(viewId.toInt()).getCameraPosition())
  }

  override fun getVisibleRegion(viewId: Long): LatLngBoundsDto {
    return Convert.convertLatLngBoundsToDto(getView(viewId.toInt()).getVisibleRegion())
  }

  override fun animateCameraToCameraPosition(
    viewId: Long,
    cameraPosition: CameraPositionDto,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt())
      .animateCameraToCameraPosition(
        Convert.convertCameraPositionFromDto(cameraPosition),
        duration,
        callback,
      )
  }

  override fun animateCameraToLatLng(
    viewId: Long,
    point: LatLngDto,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt())
      .animateCameraToLatLng(Convert.convertLatLngFromDto(point), duration, callback)
  }

  override fun animateCameraToLatLngBounds(
    viewId: Long,
    bounds: LatLngBoundsDto,
    padding: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    val density = Resources.getSystem().displayMetrics.density
    return getView(viewId.toInt())
      .animateCameraToLatLngBounds(
        Convert.convertLatLngBoundsFromDto(bounds),
        Convert.convertLogicalToScreenPixel(padding, density),
        duration,
        callback,
      )
  }

  override fun animateCameraToLatLngZoom(
    viewId: Long,
    point: LatLngDto,
    zoom: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt())
      .animateCameraToLatLngZoom(Convert.convertLatLngFromDto(point), zoom, duration, callback)
  }

  override fun animateCameraByScroll(
    viewId: Long,
    scrollByDx: Double,
    scrollByDy: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt()).animateCameraByScroll(scrollByDx, scrollByDy, duration, callback)
  }

  override fun animateCameraByZoom(
    viewId: Long,
    zoomBy: Double,
    focusDx: Double?,
    focusDy: Double?,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt())
      .animateCameraByZoom(
        zoomBy,
        Convert.convertDeltaToPoint(focusDx, focusDy),
        duration,
        callback,
      )
  }

  override fun animateCameraToZoom(
    viewId: Long,
    zoom: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView(viewId.toInt()).animateCameraToZoom(zoom, duration, callback)
  }

  override fun moveCameraToCameraPosition(viewId: Long, cameraPosition: CameraPositionDto) {
    return getView(viewId.toInt())
      .moveCameraToCameraPosition(Convert.convertCameraPositionFromDto(cameraPosition))
  }

  override fun moveCameraToLatLng(viewId: Long, point: LatLngDto) {
    return getView(viewId.toInt()).moveCameraToLatLng(Convert.convertLatLngFromDto(point))
  }

  override fun moveCameraToLatLngBounds(viewId: Long, bounds: LatLngBoundsDto, padding: Double) {
    val density = Resources.getSystem().displayMetrics.density
    return getView(viewId.toInt())
      .moveCameraToLatLngBounds(
        Convert.convertLatLngBoundsFromDto(bounds),
        Convert.convertLogicalToScreenPixel(padding, density),
      )
  }

  override fun moveCameraToLatLngZoom(viewId: Long, point: LatLngDto, zoom: Double) {
    return getView(viewId.toInt()).moveCameraToLatLngZoom(Convert.convertLatLngFromDto(point), zoom)
  }

  override fun moveCameraByScroll(viewId: Long, scrollByDx: Double, scrollByDy: Double) {
    return getView(viewId.toInt()).moveCameraByScroll(scrollByDx, scrollByDy)
  }

  override fun moveCameraByZoom(viewId: Long, zoomBy: Double, focusDx: Double?, focusDy: Double?) {
    return getView(viewId.toInt())
      .moveCameraByZoom(zoomBy, Convert.convertDeltaToPoint(focusDx, focusDy))
  }

  override fun moveCameraToZoom(viewId: Long, zoom: Double) {
    return getView(viewId.toInt()).moveCameraToZoom(zoom)
  }

  override fun isNavigationTripProgressBarEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isNavigationTripProgressBarEnabled()
  }

  override fun followMyLocation(
    viewId: Long,
    perspective: CameraPerspectiveDto,
    zoomLevel: Double?,
  ) {
    val view = viewRegistry.getMapView(viewId.toInt())
    view?.followMyLocation(Convert.convertCameraPerspectiveFromDto(perspective), zoomLevel)
  }

  override fun setNavigationTripProgressBarEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setNavigationTripProgressBarEnabled(enabled)
  }

  override fun isNavigationHeaderEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isNavigationHeaderEnabled()
  }

  override fun setNavigationHeaderEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setNavigationHeaderEnabled(enabled)
  }

  override fun isNavigationFooterEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isNavigationFooterEnabled()
  }

  override fun setNavigationFooterEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setNavigationFooterEnabled(enabled)
  }

  override fun isRecenterButtonEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isRecenterButtonEnabled()
  }

  override fun setRecenterButtonEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setRecenterButtonEnabled(enabled)
  }

  override fun isSpeedLimitIconEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isSpeedLimitIconEnabled()
  }

  override fun setSpeedLimitIconEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setSpeedLimitIconEnabled(enabled)
  }

  override fun isSpeedometerEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isSpeedometerEnabled()
  }

  override fun setSpeedometerEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setSpeedometerEnabled(enabled)
  }

  override fun isTrafficIncidentCardsEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isTrafficIncidentCardsEnabled()
  }

  override fun setTrafficIncidentCardsEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setTrafficIncidentCardsEnabled(enabled)
  }

  override fun isNavigationUIEnabled(viewId: Long): Boolean {
    return getNavigationView(viewId.toInt()).isNavigationUIEnabled()
  }

  override fun setNavigationUIEnabled(viewId: Long, enabled: Boolean) {
    getNavigationView(viewId.toInt()).setNavigationUIEnabled(enabled)
  }

  override fun showRouteOverview(viewId: Long) {
    getNavigationView(viewId.toInt()).showRouteOverview()
  }

  override fun getMinZoomPreference(viewId: Long): Double {
    return getView(viewId.toInt()).getMinZoomPreference().toDouble()
  }

  override fun getMaxZoomPreference(viewId: Long): Double {
    return getView(viewId.toInt()).getMaxZoomPreference().toDouble()
  }

  override fun resetMinMaxZoomPreference(viewId: Long) {
    getView(viewId.toInt()).resetMinMaxZoomPreference()
  }

  override fun setMinZoomPreference(viewId: Long, minZoomPreference: Double) {
    getView(viewId.toInt()).setMinZoomPreference(minZoomPreference.toFloat())
  }

  override fun setMaxZoomPreference(viewId: Long, maxZoomPreference: Double) {
    getView(viewId.toInt()).setMaxZoomPreference(maxZoomPreference.toFloat())
  }

  override fun getMarkers(viewId: Long): List<MarkerDto> {
    return getView(viewId.toInt()).getMarkers()
  }

  override fun addMarkers(viewId: Long, markers: List<MarkerDto>): List<MarkerDto> {
    return getView(viewId.toInt()).addMarkers(markers)
  }

  override fun updateMarkers(viewId: Long, markers: List<MarkerDto>): List<MarkerDto> {
    return getView(viewId.toInt()).updateMarkers(markers)
  }

  override fun removeMarkers(viewId: Long, markers: List<MarkerDto>) {
    getView(viewId.toInt()).removeMarkers(markers)
  }

  override fun clearMarkers(viewId: Long) {
    getView(viewId.toInt()).clearMarkers()
  }

  override fun clear(viewId: Long) {
    getView(viewId.toInt()).clear()
  }

  override fun getPolygons(viewId: Long): List<PolygonDto> {
    return getView(viewId.toInt()).getPolygons()
  }

  override fun addPolygons(viewId: Long, polygons: List<PolygonDto>): List<PolygonDto> {
    return getView(viewId.toInt()).addPolygons(polygons)
  }

  override fun updatePolygons(viewId: Long, polygons: List<PolygonDto>): List<PolygonDto> {
    return getView(viewId.toInt()).updatePolygons(polygons)
  }

  override fun removePolygons(viewId: Long, polygons: List<PolygonDto>) {
    getView(viewId.toInt()).removePolygons(polygons)
  }

  override fun clearPolygons(viewId: Long) {
    getView(viewId.toInt()).clearPolygons()
  }

  override fun getPolylines(viewId: Long): List<PolylineDto> {
    return getView(viewId.toInt()).getPolylines()
  }

  override fun addPolylines(viewId: Long, polylines: List<PolylineDto>): List<PolylineDto> {
    return getView(viewId.toInt()).addPolylines(polylines)
  }

  override fun updatePolylines(viewId: Long, polylines: List<PolylineDto>): List<PolylineDto> {
    return getView(viewId.toInt()).updatePolylines(polylines)
  }

  override fun removePolylines(viewId: Long, polylines: List<PolylineDto>) {
    getView(viewId.toInt()).removePolylines(polylines)
  }

  override fun clearPolylines(viewId: Long) {
    getView(viewId.toInt()).clearPolylines()
  }

  override fun getCircles(viewId: Long): List<CircleDto> {
    return getView(viewId.toInt()).getCircles()
  }

  override fun addCircles(viewId: Long, circles: List<CircleDto>): List<CircleDto> {
    return getView(viewId.toInt()).addCircles(circles)
  }

  override fun updateCircles(viewId: Long, circles: List<CircleDto>): List<CircleDto> {
    return getView(viewId.toInt()).updateCircles(circles)
  }

  override fun removeCircles(viewId: Long, circles: List<CircleDto>) {
    getView(viewId.toInt()).removeCircles(circles)
  }

  override fun clearCircles(viewId: Long) {
    getView(viewId.toInt()).clearCircles()
  }

  override fun registerOnCameraChangedListener(viewId: Long) {
    getView(viewId.toInt()).registerOnCameraChangedListener()
  }

  override fun setPadding(viewId: Long, padding: MapPaddingDto) {
    getView(viewId.toInt()).setPadding(padding)
  }

  override fun getPadding(viewId: Long): MapPaddingDto {
    return getView(viewId.toInt()).getPadding()
  }
}
