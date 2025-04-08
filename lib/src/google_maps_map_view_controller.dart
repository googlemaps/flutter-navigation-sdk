// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/widgets.dart';

import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

/// Map View Controller class to handle map view events.
/// {@category Map View}
class GoogleMapViewController {
  /// Basic constructor.
  ///
  /// Don't create this directly, but access through
  /// [GoogleMapsMapView.onViewCreated] callback.
  GoogleMapViewController(this._viewId)
      : settings = NavigationViewUISettings(_viewId);

  final int _viewId;

  /// Settings for the user interface of the map.
  final NavigationViewUISettings settings;

  /// Getter for view ID.
  int getViewId() {
    return _viewId;
  }

  /// Change status of my location enabled.
  ///
  Future<void> setMyLocationEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMyLocationEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Enable or disable the my location button on the map.
  ///
  /// The my location button allows users to center the map on their current location
  /// when tapped. By default, the button is enabled.
  Future<void> setMyLocationButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMyLocationButtonEnabled(viewId: _viewId, enabled: enabled);
  }

  /// This method returns the current map type of the Google Maps view instance.
  Future<MapType> getMapType() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMapType(viewId: _viewId);
  }

  /// Changes the type of the map being displayed on the Google Maps view.
  ///
  /// The [mapType] parameter specifies the new map type to be set.
  /// It should be one of the values defined in the [MapType] enum,
  /// such as [MapType.normal], [MapType.satellite], [MapType.terrain],
  /// or [MapType.hybrid].
  ///
  /// Example usage:
  /// ```dart
  /// _mapViewController.changeMapType(MapType.satellite);
  /// ```
  Future<void> setMapType({required MapType mapType}) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMapType(viewId: _viewId, mapType: mapType);
  }

  /// Sets the styling of the base map using a string containing JSON.
  /// Null value will reset the base map to default style.
  /// If [styleJson] is invalid throws [MapStyleException].
  ///
  /// For more details see the official documentation:
  /// https://developers.google.com/maps/documentation/ios-sdk/styling
  /// https://developers.google.com/maps/documentation/android-sdk/styling
  Future<void> setMapStyle(String? styleJson) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMapStyle(_viewId, styleJson);
  }

  /// Gets whether the my location is enabled or disabled.
  ///
  Future<bool> isMyLocationEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isMyLocationEnabled(viewId: _viewId);
  }

  
  /// Gets whether the my location button is enabled or disabled.
  ///
  /// Returns true if the my location button is currently enabled on the map,
  /// false otherwise.
  Future<bool> isMyLocationButtonEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isMyLocationButtonEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether zoom gestures should be enabled or disabled.
  Future<void> setZoomGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setZoomGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isZoomGesturesEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether zoom controls should be enabled or disabled.
  ///
  /// Note: This feature is not supported on iOS and will throw [UnsupportedError].
  Future<void> setZoomControlsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setZoomControlsEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  ///
  /// Note: This feature is not supported on iOS and will throw [UnsupportedError].
  Future<bool> isZoomControlsEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isZoomControlsEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether the compass should be enabled or disabled.
  Future<void> setCompassEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setCompassEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isCompassEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setRotateGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isRotateGesturesEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setScrollGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isScrollGesturesEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setScrollGesturesDuringRotateOrZoomEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isScrollGesturesEnabledDuringRotateOrZoom(viewId: _viewId);
  }

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTiltGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTiltGesturesEnabled(viewId: _viewId);
  }

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  ///
  /// Note: This feature is not supported on iOS and will throw [UnsupportedError].
  Future<void> setMapToolbarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMapToolbarEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Gets whether the Map Toolbar is enabled/disabled.
  ///
  /// Note: This feature is not supported on iOS and will throw [UnsupportedError].
  Future<bool> isMapToolbarEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isMapToolbarEnabled(viewId: _viewId);
  }

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTrafficEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTrafficEnabled(viewId: _viewId);
  }

  /// Register camera changed listeners.
  Future<void> registerOnCameraChangedListener() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .registerOnCameraChangedListener(viewId: _viewId);
  }

  /// Get map click event stream.
  Stream<MapClickEvent> getMapClickEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMapClickEventStream(viewId: _viewId);
  }

  /// Get map long click event stream.
  Stream<MapLongClickEvent> getMapLongClickEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMapLongClickEventStream(viewId: _viewId);
  }

  /// Get marker event stream.
  Stream<MarkerEvent> getMarkerEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMarkerEventStream(viewId: _viewId);
  }

  /// Get marker drag event stream.
  Stream<MarkerDragEvent> getMarkerDragEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMarkerDragEventStream(viewId: _viewId);
  }

  /// Get polygon clicked event stream.
  Stream<PolygonClickedEvent> getPolygonClickedEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getPolygonClickedEventStream(viewId: _viewId);
  }

  /// Get polyline clicked event stream.
  Stream<PolylineClickedEvent> getPolylineClickedEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getPolylineClickedEventStream(viewId: _viewId);
  }

  /// Get circle clicked event stream.
  Stream<CircleClickedEvent> getCircleClickedEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getCircleClickedEventStream(viewId: _viewId);
  }

  /// Get my location clicked event stream.
  Stream<MyLocationClickedEvent> getMyLocationClickedEventStream() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMyLocationClickedEventStream(viewId: _viewId);
  }

  
  /// Ask the camera to follow the user's location.
  ///
  /// Use [perspective] to specify the orientation of the camera
  /// and optional [zoomLevel] to control the map zoom.
  Future<void> followMyLocation(CameraPerspective perspective,
      {double? zoomLevel}) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI.followMyLocation(
        viewId: _viewId, perspective: perspective, zoomLevel: zoomLevel);
  }

  /// Gets user's current location.
  Future<LatLng?> getMyLocation() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMyLocation(viewId: _viewId);
  }

  /// Gets the current visible map region or camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getVisibleRegion(viewId: _viewId);
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getCameraPosition(viewId: _viewId);
  }

  /// Animates the movement of the camera from the current position
  /// to the position defined in the [cameraUpdate].
  ///
  /// See [CameraUpdate] for more information on how to create different camera
  /// animations.
  ///
  /// On Android you can override the default animation [duration] and
  /// set [onFinished] callback that is called when the animation completes
  /// (passes true) or is cancelled (passes false).
  ///
  /// Example usage:
  /// ```dart
  /// controller.animateCamera(CameraUpdate.zoomIn(),
  ///   duration: Duration(milliseconds: 600),
  ///   onFinished: (bool success) => {});
  /// ```
  /// On iOS [duration] and [onFinished] are not supported and defining them
  /// does nothing.
  ///
  /// See also [moveCamera], [followMyLocation].
  Future<void> animateCamera(CameraUpdate cameraUpdate,
      {Duration? duration, AnimationFinishedCallback? onFinished}) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.animateCamera(
        viewId: _viewId,
        cameraUpdate: cameraUpdate,
        duration: duration?.inMilliseconds,
        onFinished: onFinished);
  }

  /// Moves the camera from the current position to the position
  /// defined in the [cameraUpdate].
  ///
  /// See [CameraUpdate] for more information
  /// on how to create different camera movements.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .moveCamera(viewId: _viewId, cameraUpdate: cameraUpdate);
  }

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isRecenterButtonEnabled(viewId: _viewId);
  }

  /// Enable or disable the recenter button.
  ///
  /// By default, the recenter button is enabled.
  Future<void> setRecenterButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setRecenterButtonEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Returns the minimum zoom level preference from the map view.
  /// If minimum zoom preference is not set previously, returns minimum possible
  /// zoom level for the current map type.
  Future<double> getMinZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMinZoomPreference(viewId: _viewId);
  }

  /// Returns the maximum zoom level preference from the map view.
  /// If maximum zoom preference is not set previously, returns maximum possible
  /// zoom level for the current map type.
  Future<double> getMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMaxZoomPreference(viewId: _viewId);
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .resetMinMaxZoomPreference(viewId: _viewId);
  }

  /// Sets a preferred lower bound for the camera zoom.
  ///
  /// When the minimum zoom changes, the SDK adjusts all later camera updates
  /// to respect that minimum if possible. Note that there are technical
  /// considerations that may prevent the SDK from allowing users to zoom too low.
  ///
  /// Throws [MinZoomRangeException] if [minZoomPreference] is
  /// greater than maximum zoom lavel.
  Future<void> setMinZoomPreference(double minZoomPreference) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.setMinZoomPreference(
        viewId: _viewId, minZoomPreference: minZoomPreference);
  }

  /// Sets a preferred upper bound for the camera zoom.
  ///
  /// When the maximum zoom changes, the SDK adjusts all later camera updates
  /// to respect that maximum if possible. Note that there are technical
  /// considerations that may prevent the SDK from allowing users to zoom too
  /// deep into the map. For example, satellite or terrain may have a lower
  /// maximum zoom than the base map tiles.
  ///
  /// Throws [MaxZoomRangeException] if [maxZoomPreference] is
  /// less than minimum zoom lavel.
  Future<void> setMaxZoomPreference(double maxZoomPreference) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.setMaxZoomPreference(
        viewId: _viewId, maxZoomPreference: maxZoomPreference);
  }

  /// Retrieves all markers that have been added to the map view.
  Future<List<Marker?>> getMarkers() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getMarkers(viewId: _viewId);
  }

  /// Add markers to the map view.
  Future<List<Marker?>> addMarkers(List<MarkerOptions> markerOptions) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .addMarkers(viewId: _viewId, markerOptions: markerOptions);
  }

  /// Update markers to the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<List<Marker?>> updateMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .updateMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove markers from the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<void> removeMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .removeMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove all markers from the map view.
  Future<void> clearMarkers() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .clearMarkers(viewId: _viewId);
  }

  /// Retrieves all polygons that have been added to the map view.
  Future<List<Polygon?>> getPolygons() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getPolygons(viewId: _viewId);
  }

  /// Add polygons to the map view.
  Future<List<Polygon?>> addPolygons(List<PolygonOptions> polygonOptions) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .addPolygons(viewId: _viewId, polygonOptions: polygonOptions);
  }

  /// Update polygons to the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<List<Polygon?>> updatePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .updatePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove polygons from the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<void> removePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .removePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove all polygons from the map view.
  Future<void> clearPolygons() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .clearPolygons(viewId: _viewId);
  }

  /// Retrieves all polylines that have been added to the map view.
  Future<List<Polyline?>> getPolylines() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getPolylines(viewId: _viewId);
  }

  /// Add polylines to the map view.
  Future<List<Polyline?>> addPolylines(List<PolylineOptions> polylineOptions) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .addPolylines(viewId: _viewId, polylineOptions: polylineOptions);
  }

  /// Update polylines to the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<List<Polyline?>> updatePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .updatePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove polylines from the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<void> removePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .removePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove all polylines from the map view.
  Future<void> clearPolylines() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .clearPolylines(viewId: _viewId);
  }

  /// Gets all circles from the map view.
  Future<List<Circle?>> getCircles() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getCircles(viewId: _viewId);
  }

  /// Add circles to the map view.
  Future<List<Circle?>> addCircles(List<CircleOptions> options) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .addCircles(viewId: _viewId, options: options);
  }

  /// Update circles to the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<List<Circle?>> updateCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .updateCircles(viewId: _viewId, circles: circles);
  }

  /// Remove circles from the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<void> removeCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .removeCircles(viewId: _viewId, circles: circles);
  }

  /// Remove all circles from the map view.
  Future<void> clearCircles() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .clearCircles(viewId: _viewId);
  }

  /// Remove all markers, polylines, polygons, overlays, etc from the map view.
  Future<void> clear() {
    return GoogleMapsNavigationPlatform.instance.viewAPI.clear(viewId: _viewId);
  }

  /// Set padding for the map view.
  Future<void> setPadding(EdgeInsets padding) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setPadding(viewId: _viewId, padding: padding);
  }

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .getPadding(viewId: _viewId);
  }
}
