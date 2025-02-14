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

class GoogleMapsAutoViewController {
  GoogleMapsAutoViewController() {
    GoogleMapsNavigationPlatform.instance.autoAPI.ensureAutoViewApiSetUp();
  }

  /// Change status of my location enabled.
  ///
  Future<void> setMyLocationEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .setMyLocationEnabled(enabled: enabled);
  }

  /// This method returns the current map type of the Google Maps view instance.
  Future<MapType> getMapType() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getMapType();
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
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .setMapType(mapType: mapType);
  }

  /// Sets the styling of the base map using a string containing JSON.
  /// Null value will reset the base map to default style.
  /// If [styleJson] is invalid throws [MapStyleException].
  ///
  /// For more details see the official documentation:
  /// https://developers.google.com/maps/documentation/ios-sdk/styling
  /// https://developers.google.com/maps/documentation/android-sdk/styling
  Future<void> setMapStyle(String? styleJson) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.setMapStyle(styleJson);
  }

  /// Gets whether the my location is enabled or disabled.
  ///
  Future<bool> isMyLocationEnabled() async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.isMyLocationEnabled();
  }

  /// Ask the camera to follow the user's location.
  ///
  /// Use [perspective] to specify the orientation of the camera
  /// and optional [zoomLevel] to control the map zoom.
  Future<void> followMyLocation(CameraPerspective perspective,
      {double? zoomLevel}) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .followMyLocation(perspective: perspective, zoomLevel: zoomLevel);
  }

  /// Gets user's current location.
  Future<LatLng?> getMyLocation() async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getMyLocation();
  }

  /// Gets the current visible map region or camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getVisibleRegion();
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getCameraPosition();
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
    return GoogleMapsNavigationPlatform.instance.autoAPI.animateCamera(
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
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .moveCamera(cameraUpdate: cameraUpdate);
  }

  /// Returns the minimum zoom level preference from the map view.
  /// If minimum zoom preference is not set previously, returns minimum possible
  /// zoom level for the current map type.
  Future<double> getMinZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getMinZoomPreference();
  }

  /// Returns the maximum zoom level preference from the map view.
  /// If maximum zoom preference is not set previously, returns maximum possible
  /// zoom level for the current map type.
  Future<double> getMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getMaxZoomPreference();
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .resetMinMaxZoomPreference();
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
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .setMinZoomPreference(minZoomPreference: minZoomPreference);
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
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .setMaxZoomPreference(maxZoomPreference: maxZoomPreference);
  }

  /// Retrieves all markers that have been added to the map view.
  Future<List<Marker?>> getMarkers() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getMarkers();
  }

  /// Add markers to the map view.
  Future<List<Marker?>> addMarkers(List<MarkerOptions> markerOptions) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .addMarkers(markerOptions: markerOptions);
  }

  /// Update markers to the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<List<Marker?>> updateMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .updateMarkers(markers: markers);
  }

  /// Remove markers from the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<void> removeMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .removeMarkers(markers: markers);
  }

  /// Remove all markers from the map view.
  Future<void> clearMarkers() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.clearMarkers();
  }

  /// Retrieves all polygons that have been added to the map view.
  Future<List<Polygon?>> getPolygons() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getPolygons();
  }

  /// Add polygons to the map view.
  Future<List<Polygon?>> addPolygons(List<PolygonOptions> polygonOptions) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .addPolygons(polygonOptions: polygonOptions);
  }

  /// Update polygons to the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<List<Polygon?>> updatePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .updatePolygons(polygons: polygons);
  }

  /// Remove polygons from the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<void> removePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .removePolygons(polygons: polygons);
  }

  /// Remove all polygons from the map view.
  Future<void> clearPolygons() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.clearPolygons();
  }

  /// Retrieves all polylines that have been added to the map view.
  Future<List<Polyline?>> getPolylines() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getPolylines();
  }

  /// Add polylines to the map view.
  Future<List<Polyline?>> addPolylines(List<PolylineOptions> polylineOptions) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .addPolylines(polylineOptions: polylineOptions);
  }

  /// Update polylines to the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<List<Polyline?>> updatePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .updatePolylines(polylines: polylines);
  }

  /// Remove polylines from the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<void> removePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .removePolylines(polylines: polylines);
  }

  /// Remove all polylines from the map view.
  Future<void> clearPolylines() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.clearPolylines();
  }

  /// Gets all circles from the map view.
  Future<List<Circle?>> getCircles() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getCircles();
  }

  /// Add circles to the map view.
  Future<List<Circle?>> addCircles(List<CircleOptions> options) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .addCircles(options: options);
  }

  /// Update circles to the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<List<Circle?>> updateCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .updateCircles(circles: circles);
  }

  /// Remove circles from the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<void> removeCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .removeCircles(circles: circles);
  }

  /// Remove all circles from the map view.
  Future<void> clearCircles() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.clearCircles();
  }

  /// Remove all markers, polylines, polygons, overlays, etc from the map view.
  Future<void> clear() {
    return GoogleMapsNavigationPlatform.instance.autoAPI.clear();
  }

  /// Set padding for the map view.
  Future<void> setPadding(EdgeInsets padding) {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .setPadding(padding: padding);
  }

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding() async {
    return GoogleMapsNavigationPlatform.instance.autoAPI.getPadding();
  }

  Future<bool> isAutoScreenAvailable() {
    return GoogleMapsNavigationPlatform.instance.autoAPI
        .isAutoScreenAvailable();
  }

  void listenForCustomNavigationAutoEvents(
      void Function(CustomNavigationAutoEvent event) func) {
    GoogleMapsNavigationPlatform.instance.autoAPI
        .getCustomNavigationAutoEventStream()
        .listen((CustomNavigationAutoEvent event) {
      func(event);
    });
  }

  void listenForAutoScreenAvailibilityChangedEvent(
      void Function(AutoScreenAvailabilityChangedEvent event) func) {
    GoogleMapsNavigationPlatform.instance.autoAPI
        .getAutoScreenAvailabilityChangedEventStream()
        .listen((AutoScreenAvailabilityChangedEvent event) {
      func(event);
    });
  }
}
