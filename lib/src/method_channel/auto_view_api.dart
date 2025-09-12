// Copyright 2023 Google LLC
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

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../google_navigation_flutter.dart';
import 'method_channel.dart';

/// @nodoc
/// Class that handles map view and navigation view communications.
class AutoMapViewAPIImpl {
  final AutoMapViewApi _viewApi = AutoMapViewApi();
  bool _viewApiHasBeenSetUp = false;
  final StreamController<_AutoEventWrapper> _autoEventStreamController =
      StreamController<_AutoEventWrapper>.broadcast();

  /// Keep track of marker count, used to generate marker ID's.
  int _markerCounter = 0;
  String _createMarkerId() {
    final String markerId = 'Marker_$_markerCounter';
    _markerCounter += 1;
    return markerId;
  }

  /// Keep track of polygon count, used to generate polygon ID's.
  int _polygonCounter = 0;
  String _createPolygonId() {
    final String polygonId = 'Polygon_$_polygonCounter';
    _polygonCounter += 1;
    return polygonId;
  }

  /// Keep track of polyline count, used to generate polyline ID's.
  int _polylineCounter = 0;
  String _createPolylineId() {
    final String polylineId = 'Polyline_$_polylineCounter';
    _polylineCounter += 1;
    return polylineId;
  }

  /// Keep track of circle count, used to generate circle ID's.
  int _circleCounter = 0;
  String _createCircleId() {
    final String circleId = 'Circle_$_circleCounter';
    _circleCounter += 1;
    return circleId;
  }

  Stream<T> _unwrapEventStream<T>() {
    // If event that does not
    return _autoEventStreamController.stream
        .where((_AutoEventWrapper wrapper) => (wrapper.event is T))
        .map<T>((_AutoEventWrapper wrapper) => wrapper.event as T);
  }

  /// This function ensures that the event API has been setup. This should be
  /// called when initializing auto view controller.
  void ensureAutoViewApiSetUp() {
    if (!_viewApiHasBeenSetUp) {
      AutoViewEventApi.setUp(
        AutoViewEventApiImpl(
          viewEventStreamController: _autoEventStreamController,
        ),
      );
      _viewApiHasBeenSetUp = true;
    }
  }

  /// Get the preference for whether the my location should be enabled or disabled.
  Future<bool> isMyLocationEnabled() async {
    try {
      return await _viewApi.isMyLocationEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Enabled location in the navigation view.
  Future<void> setMyLocationEnabled({required bool enabled}) async {
    try {
      await _viewApi.setMyLocationEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get the map type.
  Future<MapType> getMapType() async {
    try {
      final MapTypeDto mapType = await _viewApi.getMapType();
      return mapType.toMapType();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Modified visible map type.
  Future<void> setMapType({required MapType mapType}) async {
    try {
      await _viewApi.setMapType(mapType.toDto());
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Set map style by json string.
  Future<void> setMapStyle(String? styleJson) async {
    try {
      // Set the given json to the viewApi or reset the map style if
      // the styleJson is null.
      await _viewApi.setMapStyle(styleJson ?? '[]');
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabled({required bool enabled}) async {
    try {
      await _viewApi.setMyLocationButtonEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled({
    required bool enabled,
  }) async {
    try {
      await _viewApi.setConsumeMyLocationButtonClickEventsEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabled({required bool enabled}) async {
    try {
      await _viewApi.setZoomGesturesEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabled({required bool enabled}) async {
    try {
      await _viewApi.setZoomControlsEnabled(enabled);
    } catch (e, stackTrace) {
      if (e is PlatformException && e.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        throw convertPlatformException(e, stackTrace);
      }
    }
  }

  /// Enables or disables the compass.
  Future<void> setCompassEnabled({required bool enabled}) async {
    try {
      await _viewApi.setCompassEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled({required bool enabled}) async {
    try {
      await _viewApi.setRotateGesturesEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled({required bool enabled}) async {
    try {
      await _viewApi.setScrollGesturesEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled({
    required bool enabled,
  }) async {
    try {
      await _viewApi.setScrollGesturesDuringRotateOrZoomEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled({required bool enabled}) async {
    try {
      await _viewApi.setTiltGesturesEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabled({required bool enabled}) async {
    try {
      await _viewApi.setMapToolbarEnabled(enabled);
    } catch (e, stackTrace) {
      if (e is PlatformException && e.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        throw convertPlatformException(e, stackTrace);
      }
    }
  }

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled({required bool enabled}) async {
    try {
      await _viewApi.setTrafficEnabled(enabled);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabled() async {
    try {
      return await _viewApi.isMyLocationButtonEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled() async {
    try {
      return await _viewApi.isConsumeMyLocationButtonClickEventsEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled() async {
    try {
      return await _viewApi.isZoomGesturesEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabled() async {
    try {
      return await _viewApi.isZoomControlsEnabled();
    } catch (e, stackTrace) {
      if (e is PlatformException && e.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        throw convertPlatformException(e, stackTrace);
      }
    }
  }

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled() async {
    try {
      return await _viewApi.isCompassEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled() async {
    try {
      return await _viewApi.isRotateGesturesEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled() async {
    try {
      return await _viewApi.isScrollGesturesEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() async {
    try {
      return await _viewApi.isScrollGesturesEnabledDuringRotateOrZoom();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled() async {
    try {
      return await _viewApi.isTiltGesturesEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabled() async {
    try {
      return await _viewApi.isMapToolbarEnabled();
    } catch (e, stackTrace) {
      if (e is PlatformException && e.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        throw convertPlatformException(e, stackTrace);
      }
    }
  }

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled() async {
    try {
      return await _viewApi.isTrafficEnabled();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocation({
    required CameraPerspective perspective,
    required double? zoomLevel,
  }) async {
    try {
      await _viewApi.followMyLocation(perspective.toDto(), zoomLevel);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets users current location.
  Future<LatLng?> getMyLocation() async {
    try {
      final LatLngDto? myLocation = await _viewApi.getMyLocation();
      if (myLocation == null) {
        return null;
      }
      return myLocation.toLatLng();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    try {
      final CameraPositionDto position = await _viewApi.getCameraPosition();
      return position.toCameraPosition();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    try {
      final LatLngBoundsDto bounds = await _viewApi.getVisibleRegion();
      return LatLngBounds(
        southwest: bounds.southwest.toLatLng(),
        northeast: bounds.northeast.toLatLng(),
      );
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Animates the movement of the camera.
  Future<void> animateCamera({
    required CameraUpdate cameraUpdate,
    required int? duration,
    AnimationFinishedCallback? onFinished,
  }) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        unawaited(
          _viewApi
              .animateCameraToCameraPosition(
                cameraUpdate.cameraPosition!.toCameraPosition(),
                duration,
              )
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.latLng:
        unawaited(
          _viewApi
              .animateCameraToLatLng(cameraUpdate.latLng!.toDto(), duration)
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.latLngBounds:
        unawaited(
          _viewApi
              .animateCameraToLatLngBounds(
                cameraUpdate.bounds!.toDto(),
                cameraUpdate.padding!,
                duration,
              )
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.latLngZoom:
        unawaited(
          _viewApi
              .animateCameraToLatLngZoom(
                cameraUpdate.latLng!.toDto(),
                cameraUpdate.zoom!,
                duration,
              )
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.scrollBy:
        unawaited(
          _viewApi
              .animateCameraByScroll(
                cameraUpdate.scrollByDx!,
                cameraUpdate.scrollByDy!,
                duration,
              )
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.zoomBy:
        unawaited(
          _viewApi
              .animateCameraByZoom(
                cameraUpdate.zoomByAmount!,
                cameraUpdate.focus?.dx,
                cameraUpdate.focus?.dy,
                duration,
              )
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
      case CameraUpdateType.zoomTo:
        unawaited(
          _viewApi
              .animateCameraToZoom(cameraUpdate.zoom!, duration)
              .then(
                (bool success) =>
                    onFinished != null && Platform.isAndroid
                        ? onFinished(success)
                        : null,
              ),
        );
    }
  }

  /// Moves the camera.
  Future<void> moveCamera({required CameraUpdate cameraUpdate}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        assert(cameraUpdate.cameraPosition != null, 'Camera position is null');
        return _viewApi.moveCameraToCameraPosition(
          cameraUpdate.cameraPosition!.toCameraPosition(),
        );
      case CameraUpdateType.latLng:
        return _viewApi.moveCameraToLatLng(cameraUpdate.latLng!.toDto());
      case CameraUpdateType.latLngBounds:
        assert(cameraUpdate.padding != null, 'Camera position is null');
        return _viewApi.moveCameraToLatLngBounds(
          cameraUpdate.bounds!.toDto(),
          cameraUpdate.padding!,
        );
      case CameraUpdateType.latLngZoom:
        return _viewApi.moveCameraToLatLngZoom(
          cameraUpdate.latLng!.toDto(),
          cameraUpdate.zoom!,
        );
      case CameraUpdateType.scrollBy:
        return _viewApi.moveCameraByScroll(
          cameraUpdate.scrollByDx!,
          cameraUpdate.scrollByDy!,
        );
      case CameraUpdateType.zoomBy:
        return _viewApi.moveCameraByZoom(
          cameraUpdate.zoomByAmount!,
          cameraUpdate.focus?.dx,
          cameraUpdate.focus?.dy,
        );
      case CameraUpdateType.zoomTo:
        return _viewApi.moveCameraToZoom(cameraUpdate.zoom!);
    }
  }

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreference() async {
    try {
      return await _viewApi.getMinZoomPreference();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreference() async {
    try {
      return await _viewApi.getMaxZoomPreference();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() async {
    try {
      await _viewApi.resetMinMaxZoomPreference();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreference({required double minZoomPreference}) async {
    try {
      return await _viewApi.setMinZoomPreference(minZoomPreference);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreference({required double maxZoomPreference}) async {
    try {
      return await _viewApi.setMaxZoomPreference(maxZoomPreference);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers() async {
    try {
      final List<MarkerDto?> markers = await _viewApi.getMarkers();
      return markers
          .whereType<MarkerDto>()
          .map((MarkerDto e) => e.toMarker())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Add markers to map view.
  Future<List<Marker>> addMarkers({
    required List<MarkerOptions> markerOptions,
  }) async {
    try {
      // Convert options to pigeon format
      final List<MarkerOptionsDto> options =
          markerOptions.map((MarkerOptions opt) => opt.toDto()).toList();

      // Create marker objects with new ID's
      final List<MarkerDto> markersToAdd =
          options
              .map(
                (MarkerOptionsDto options) =>
                    MarkerDto(markerId: _createMarkerId(), options: options),
              )
              .toList();

      // Add markers to map
      final List<MarkerDto?> markersAdded = await _viewApi.addMarkers(
        markersToAdd,
      );

      if (markersToAdd.length != markersAdded.length) {
        throw Exception('Could not add all markers to map view');
      }

      return markersAdded
          .whereType<MarkerDto>()
          .map((MarkerDto markerDto) => markerDto.toMarker())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Update markers on the map view.
  Future<List<Marker>> updateMarkers({required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      final List<MarkerDto?> updatedMarkers = await _viewApi.updateMarkers(
        markerDtos,
      );
      return updatedMarkers
          .whereType<MarkerDto>()
          .map((MarkerDto markerDto) => markerDto.toMarker())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove markers from map view.
  Future<void> removeMarkers({required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      return await _viewApi.removeMarkers(markerDtos);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove all markers from map view.
  Future<void> clearMarkers() async {
    try {
      await _viewApi.clearMarkers();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear() async {
    try {
      return await _viewApi.clear();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons() async {
    try {
      final List<PolygonDto?> polygons = await _viewApi.getPolygons();

      return polygons
          .whereType<PolygonDto>()
          .map((PolygonDto polygon) => polygon.toPolygon())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons({
    required List<PolygonOptions> polygonOptions,
  }) async {
    try {
      // Convert options to pigeon format
      final List<PolygonOptionsDto> options =
          polygonOptions.map((PolygonOptions opt) => opt.toDto()).toList();

      // Create polygon objects with new ID's
      final List<PolygonDto> polygonsToAdd =
          options
              .map(
                (PolygonOptionsDto options) =>
                    PolygonDto(polygonId: _createPolygonId(), options: options),
              )
              .toList();

      // Add polygons to map
      final List<PolygonDto?> polygonsAdded = await _viewApi.addPolygons(
        polygonsToAdd,
      );

      if (polygonsToAdd.length != polygonsAdded.length) {
        throw Exception('Could not add all polygons to map view');
      }

      return polygonsAdded
          .whereType<PolygonDto>()
          .map((PolygonDto polygon) => polygon.toPolygon())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Update polygons on the map view.
  Future<List<Polygon?>> updatePolygons({
    required List<Polygon> polygons,
  }) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      final List<PolygonDto?> updatedPolygons = await _viewApi.updatePolygons(
        navigationViewPolygons,
      );
      return updatedPolygons
          .whereType<PolygonDto>()
          .map((PolygonDto polygon) => polygon.toPolygon())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove polygons from map view.
  Future<void> removePolygons({required List<Polygon> polygons}) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      return await _viewApi.removePolygons(navigationViewPolygons);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove all polygons from map view.
  Future<void> clearPolygons() async {
    try {
      await _viewApi.clearPolygons();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines() async {
    try {
      final List<PolylineDto?> polylines = await _viewApi.getPolylines();

      return polylines
          .whereType<PolylineDto>()
          .map((PolylineDto polyline) => polyline.toPolyline())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines({
    required List<PolylineOptions> polylineOptions,
  }) async {
    try {
      // Convert options to pigeon format
      final List<PolylineOptionsDto> options =
          polylineOptions.map((PolylineOptions opt) => opt.toDto()).toList();

      // Create polyline objects with new ID's
      final List<PolylineDto> polylinesToAdd =
          options
              .map(
                (PolylineOptionsDto options) => PolylineDto(
                  polylineId: _createPolylineId(),
                  options: options,
                ),
              )
              .toList();

      // Add polylines to map
      final List<PolylineDto?> polylinesAdded = await _viewApi.addPolylines(
        polylinesToAdd,
      );

      if (polylinesToAdd.length != polylinesAdded.length) {
        throw Exception('Could not add all polylines to map view');
      }

      return polylinesAdded
          .whereType<PolylineDto>()
          .map((PolylineDto polyline) => polyline.toPolyline())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Update polylines on the map view.
  Future<List<Polyline?>> updatePolylines({
    required List<Polyline> polylines,
  }) async {
    try {
      final List<PolylineDto> navigationViewPolylines =
          polylines
              .map((Polyline polyline) => polyline.toNavigationViewPolyline())
              .toList();
      final List<PolylineDto?> updatedPolylines = await _viewApi
          .updatePolylines(navigationViewPolylines);
      return updatedPolylines
          .whereType<PolylineDto>()
          .map((PolylineDto polyline) => polyline.toPolyline())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove polylines from map view.
  Future<void> removePolylines({required List<Polyline> polylines}) async {
    try {
      final List<PolylineDto> navigationViewPolylines =
          polylines
              .map((Polyline polyline) => polyline.toNavigationViewPolyline())
              .toList();
      return await _viewApi.removePolylines(navigationViewPolylines);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove all polylines from map view.
  Future<void> clearPolylines() async {
    try {
      return await _viewApi.clearPolylines();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles() async {
    try {
      final List<CircleDto?> circles = await _viewApi.getCircles();

      return circles
          .whereType<CircleDto>()
          .map((CircleDto circle) => circle.toCircle())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Add circles to map view.
  Future<List<Circle?>> addCircles({
    required List<CircleOptions> options,
  }) async {
    try {
      // Convert options to pigeon format
      final List<CircleOptionsDto> optionsDto =
          options.map((CircleOptions opt) => opt.toDto()).toList();

      // Create circle objects with new ID's
      final List<CircleDto> circlesToAdd =
          optionsDto
              .map(
                (CircleOptionsDto options) =>
                    CircleDto(circleId: _createCircleId(), options: options),
              )
              .toList();

      // Add circles to map
      final List<CircleDto?> circlesAdded = await _viewApi.addCircles(
        circlesToAdd,
      );

      if (circlesToAdd.length != circlesAdded.length) {
        throw Exception('Could not add all circles to map view');
      }

      return circlesAdded
          .whereType<CircleDto>()
          .map((CircleDto circle) => circle.toCircle())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Update circles on the map view.
  Future<List<Circle?>> updateCircles({required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      final List<CircleDto?> updatedCircles = await _viewApi.updateCircles(
        navigationViewCircles,
      );

      return updatedCircles
          .whereType<CircleDto>()
          .map((CircleDto circle) => circle.toCircle())
          .toList();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove circles from map view.
  Future<void> removeCircles({required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      return await _viewApi.removeCircles(navigationViewCircles);
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Remove all circles from map view.
  Future<void> clearCircles() async {
    try {
      await _viewApi.clearCircles();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Register camera changed listeners.
  Future<void> enableOnCameraChangedEvents() async {
    try {
      return await _viewApi.enableOnCameraChangedEvents();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  Future<void> setPadding({required EdgeInsets padding}) async {
    try {
      await _viewApi.setPadding(
        MapPaddingDto(
          top: padding.top.toInt(),
          left: padding.left.toInt(),
          bottom: padding.bottom.toInt(),
          right: padding.right.toInt(),
        ),
      );
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding() async {
    try {
      final MapPaddingDto padding = await _viewApi.getPadding();
      return EdgeInsets.only(
        top: padding.top.toDouble(),
        left: padding.left.toDouble(),
        bottom: padding.bottom.toDouble(),
        right: padding.right.toDouble(),
      );
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  Future<bool> isAutoScreenAvailable() async {
    try {
      return await _viewApi.isAutoScreenAvailable();
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }

  /// Get custom navigation auto event stream from the auto view.
  Stream<CustomNavigationAutoEvent> getCustomNavigationAutoEventStream() {
    return _unwrapEventStream<CustomNavigationAutoEvent>();
  }

  /// Get auto screen availibility changed event stream from the auto view.
  Stream<AutoScreenAvailabilityChangedEvent>
  getAutoScreenAvailabilityChangedEventStream() {
    return _unwrapEventStream<AutoScreenAvailabilityChangedEvent>();
  }
}

class AutoViewEventApiImpl implements AutoViewEventApi {
  /// Initialize implementation for NavigationViewEventApi.
  const AutoViewEventApiImpl({
    required StreamController<Object> viewEventStreamController,
  }) : _viewEventStreamController = viewEventStreamController;

  final StreamController<Object> _viewEventStreamController;

  @override
  void onCustomNavigationAutoEvent(String event, Object data) {
    _viewEventStreamController.add(
      _AutoEventWrapper(CustomNavigationAutoEvent(event: event, data: data)),
    );
  }

  @override
  void onAutoScreenAvailabilityChanged(bool isAvailable) {
    _viewEventStreamController.add(
      _AutoEventWrapper(
        AutoScreenAvailabilityChangedEvent(isAvailable: isAvailable),
      ),
    );
  }
}

class _AutoEventWrapper {
  _AutoEventWrapper(this.event);

  final Object event;
}
