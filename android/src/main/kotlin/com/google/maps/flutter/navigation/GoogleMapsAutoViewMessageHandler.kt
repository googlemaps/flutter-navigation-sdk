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

/** GoogleMapsAutoViewMessageHandler */
class GoogleMapsAutoViewMessageHandler(private val viewRegistry: GoogleMapsViewRegistry) :
  AutoMapViewApi {

  private fun getView(): GoogleMapsBaseMapView {
    val view = viewRegistry.getAndroidAutoView()
    if (view != null) {
      return view
    } else {
      throw FlutterError("viewNotFound", "No valid android auto view found")
    }
  }

  override fun isMyLocationEnabled(): Boolean {
    return getView().isMyLocationEnabled()
  }

  override fun setMyLocationEnabled(enabled: Boolean) {
    getView().setMyLocationEnabled(enabled)
  }

  override fun getMapType(): MapTypeDto {
    val googleMapType = getView().getMapType()
    return Convert.convertMapTypeToDto(googleMapType)
  }

  override fun setMapType(mapType: MapTypeDto) {
    val view = getView()
    val googleMapType = Convert.convertMapTypeFromDto(mapType)
    view.setMapType(googleMapType)
  }

  override fun setMapStyle(styleJson: String) {
    val view = getView()
    view.setMapStyle(styleJson)
  }

  override fun setMyLocationButtonEnabled(enabled: Boolean) {
    getView().setMyLocationButtonEnabled(enabled)
  }

  override fun setConsumeMyLocationButtonClickEventsEnabled(enabled: Boolean) {
    getView().setConsumeMyLocationButtonClickEventsEnabled(enabled)
  }

  override fun setZoomGesturesEnabled(enabled: Boolean) {
    getView().setZoomGesturesEnabled(enabled)
  }

  override fun setZoomControlsEnabled(enabled: Boolean) {
    getView().setZoomControlsEnabled(enabled)
  }

  override fun setCompassEnabled(enabled: Boolean) {
    getView().setCompassEnabled(enabled)
  }

  override fun setRotateGesturesEnabled(enabled: Boolean) {
    getView().setRotateGesturesEnabled(enabled)
  }

  override fun setScrollGesturesEnabled(enabled: Boolean) {
    getView().setScrollGesturesEnabled(enabled)
  }

  override fun setScrollGesturesDuringRotateOrZoomEnabled(enabled: Boolean) {
    getView().setScrollGesturesDuringRotateOrZoomEnabled(enabled)
  }

  override fun setTiltGesturesEnabled(enabled: Boolean) {
    getView().setTiltGesturesEnabled(enabled)
  }

  override fun setMapToolbarEnabled(enabled: Boolean) {
    getView().setMapToolbarEnabled(enabled)
  }

  override fun setTrafficEnabled(enabled: Boolean) {
    getView().setTrafficEnabled(enabled)
  }

  override fun isMyLocationButtonEnabled(): Boolean {
    return getView().isMyLocationButtonEnabled()
  }

  override fun isConsumeMyLocationButtonClickEventsEnabled(): Boolean {
    return getView().isConsumeMyLocationButtonClickEventsEnabled()
  }

  override fun isZoomGesturesEnabled(): Boolean {
    return getView().isZoomGesturesEnabled()
  }

  override fun isZoomControlsEnabled(): Boolean {
    return getView().isZoomControlsEnabled()
  }

  override fun isCompassEnabled(): Boolean {
    return getView().isCompassEnabled()
  }

  override fun isRotateGesturesEnabled(): Boolean {
    return getView().isRotateGesturesEnabled()
  }

  override fun isScrollGesturesEnabled(): Boolean {
    return getView().isScrollGesturesEnabled()
  }

  override fun isScrollGesturesEnabledDuringRotateOrZoom(): Boolean {
    return getView().isScrollGesturesEnabledDuringRotateOrZoom()
  }

  override fun isTiltGesturesEnabled(): Boolean {
    return getView().isTiltGesturesEnabled()
  }

  override fun isMapToolbarEnabled(): Boolean {
    return getView().isMapToolbarEnabled()
  }

  override fun isTrafficEnabled(): Boolean {
    return getView().isTrafficEnabled()
  }

  override fun getMyLocation(): LatLngDto? {
    val location = getView().getMyLocation() ?: return null
    return LatLngDto(location.latitude, location.longitude)
  }

  override fun getCameraPosition(): CameraPositionDto {
    return Convert.convertCameraPositionToDto(getView().getCameraPosition())
  }

  override fun getVisibleRegion(): LatLngBoundsDto {
    return Convert.convertLatLngBoundsToDto(getView().getVisibleRegion())
  }

  override fun animateCameraToCameraPosition(
    cameraPosition: CameraPositionDto,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView()
      .animateCameraToCameraPosition(
        Convert.convertCameraPositionFromDto(cameraPosition),
        duration,
        callback,
      )
  }

  override fun animateCameraToLatLng(
    point: LatLngDto,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView().animateCameraToLatLng(Convert.convertLatLngFromDto(point), duration, callback)
  }

  override fun animateCameraToLatLngBounds(
    bounds: LatLngBoundsDto,
    padding: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    val density = Resources.getSystem().displayMetrics.density
    return getView()
      .animateCameraToLatLngBounds(
        Convert.convertLatLngBoundsFromDto(bounds),
        Convert.convertLogicalToScreenPixel(padding, density),
        duration,
        callback,
      )
  }

  override fun animateCameraToLatLngZoom(
    point: LatLngDto,
    zoom: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView()
      .animateCameraToLatLngZoom(Convert.convertLatLngFromDto(point), zoom, duration, callback)
  }

  override fun animateCameraByScroll(
    scrollByDx: Double,
    scrollByDy: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView().animateCameraByScroll(scrollByDx, scrollByDy, duration, callback)
  }

  override fun animateCameraByZoom(
    zoomBy: Double,
    focusDx: Double?,
    focusDy: Double?,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView()
      .animateCameraByZoom(
        zoomBy,
        Convert.convertDeltaToPoint(focusDx, focusDy),
        duration,
        callback,
      )
  }

  override fun animateCameraToZoom(
    zoom: Double,
    duration: Long?,
    callback: (Result<Boolean>) -> Unit,
  ) {
    return getView().animateCameraToZoom(zoom, duration, callback)
  }

  override fun moveCameraToCameraPosition(cameraPosition: CameraPositionDto) {
    return getView()
      .moveCameraToCameraPosition(Convert.convertCameraPositionFromDto(cameraPosition))
  }

  override fun moveCameraToLatLng(point: LatLngDto) {
    return getView().moveCameraToLatLng(Convert.convertLatLngFromDto(point))
  }

  override fun moveCameraToLatLngBounds(bounds: LatLngBoundsDto, padding: Double) {
    val density = Resources.getSystem().displayMetrics.density
    return getView()
      .moveCameraToLatLngBounds(
        Convert.convertLatLngBoundsFromDto(bounds),
        Convert.convertLogicalToScreenPixel(padding, density),
      )
  }

  override fun moveCameraToLatLngZoom(point: LatLngDto, zoom: Double) {
    return getView().moveCameraToLatLngZoom(Convert.convertLatLngFromDto(point), zoom)
  }

  override fun moveCameraByScroll(scrollByDx: Double, scrollByDy: Double) {
    return getView().moveCameraByScroll(scrollByDx, scrollByDy)
  }

  override fun moveCameraByZoom(zoomBy: Double, focusDx: Double?, focusDy: Double?) {
    return getView().moveCameraByZoom(zoomBy, Convert.convertDeltaToPoint(focusDx, focusDy))
  }

  override fun moveCameraToZoom(zoom: Double) {
    return getView().moveCameraToZoom(zoom)
  }

  override fun followMyLocation(perspective: CameraPerspectiveDto, zoomLevel: Double?) {
    getView().followMyLocation(Convert.convertCameraPerspectiveFromDto(perspective), zoomLevel)
  }

  override fun getMinZoomPreference(): Double {
    return getView().getMinZoomPreference().toDouble()
  }

  override fun getMaxZoomPreference(): Double {
    return getView().getMaxZoomPreference().toDouble()
  }

  override fun resetMinMaxZoomPreference() {
    getView().resetMinMaxZoomPreference()
  }

  override fun setMinZoomPreference(minZoomPreference: Double) {
    getView().setMinZoomPreference(minZoomPreference.toFloat())
  }

  override fun setMaxZoomPreference(maxZoomPreference: Double) {
    getView().setMaxZoomPreference(maxZoomPreference.toFloat())
  }

  override fun getMarkers(): List<MarkerDto> {
    return getView().getMarkers()
  }

  override fun addMarkers(markers: List<MarkerDto>): List<MarkerDto> {
    return getView().addMarkers(markers)
  }

  override fun updateMarkers(markers: List<MarkerDto>): List<MarkerDto> {
    return getView().updateMarkers(markers)
  }

  override fun removeMarkers(markers: List<MarkerDto>) {
    getView().removeMarkers(markers)
  }

  override fun clearMarkers() {
    getView().clearMarkers()
  }

  override fun clear() {
    getView().clear()
  }

  override fun getPolygons(): List<PolygonDto> {
    return getView().getPolygons()
  }

  override fun addPolygons(polygons: List<PolygonDto>): List<PolygonDto> {
    return getView().addPolygons(polygons)
  }

  override fun updatePolygons(polygons: List<PolygonDto>): List<PolygonDto> {
    return getView().updatePolygons(polygons)
  }

  override fun removePolygons(polygons: List<PolygonDto>) {
    getView().removePolygons(polygons)
  }

  override fun clearPolygons() {
    getView().clearPolygons()
  }

  override fun getPolylines(): List<PolylineDto> {
    return getView().getPolylines()
  }

  override fun addPolylines(polylines: List<PolylineDto>): List<PolylineDto> {
    return getView().addPolylines(polylines)
  }

  override fun updatePolylines(polylines: List<PolylineDto>): List<PolylineDto> {
    return getView().updatePolylines(polylines)
  }

  override fun removePolylines(polylines: List<PolylineDto>) {
    getView().removePolylines(polylines)
  }

  override fun clearPolylines() {
    getView().clearPolylines()
  }

  override fun getCircles(): List<CircleDto> {
    return getView().getCircles()
  }

  override fun addCircles(circles: List<CircleDto>): List<CircleDto> {
    return getView().addCircles(circles)
  }

  override fun updateCircles(circles: List<CircleDto>): List<CircleDto> {
    return getView().updateCircles(circles)
  }

  override fun removeCircles(circles: List<CircleDto>) {
    getView().removeCircles(circles)
  }

  override fun clearCircles() {
    getView().clearCircles()
  }

  override fun registerOnCameraChangedListener() {
    getView().registerOnCameraChangedListener()
  }

  override fun isAutoScreenAvailable(): Boolean {
    return viewRegistry.getAndroidAutoView() != null
  }

  override fun setPadding(padding: MapPaddingDto) {
    getView().setPadding(padding)
  }

  override fun getPadding(): MapPaddingDto {
    return getView().getPadding()
  }
}
