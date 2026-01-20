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

  /// Provides access to the auto event stream controller for testing purposes.
  /// This allows test subclasses to access the parent's stream controller.
  @visibleForTesting
  StreamController<Object> get autoEventStreamControllerForTesting =>
      _autoEventStreamController;

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
  Future<bool> isMyLocationEnabled() =>
      _viewApi.isMyLocationEnabled().wrapPlatformException();

  /// Enabled location in the navigation view.
  Future<void> setMyLocationEnabled({required bool enabled}) =>
      _viewApi.setMyLocationEnabled(enabled).wrapPlatformException();

  /// Get the map type.
  Future<MapType> getMapType() async {
    final MapTypeDto mapType = await _viewApi
        .getMapType()
        .wrapPlatformException();
    return mapType.toMapType();
  }

  /// Modified visible map type.
  Future<void> setMapType({required MapType mapType}) =>
      _viewApi.setMapType(mapType.toDto()).wrapPlatformException();

  /// Set map style by json string.
  Future<void> setMapStyle(String? styleJson) =>
      // Set the given json to the viewApi or reset the map style if
      // the styleJson is null.
      _viewApi.setMapStyle(styleJson ?? '[]').wrapPlatformException();

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabled({required bool enabled}) =>
      _viewApi.setMyLocationButtonEnabled(enabled).wrapPlatformException();

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled({
    required bool enabled,
  }) => _viewApi
      .setConsumeMyLocationButtonClickEventsEnabled(enabled)
      .wrapPlatformException();

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabled({required bool enabled}) =>
      _viewApi.setZoomGesturesEnabled(enabled).wrapPlatformException();

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabled({required bool enabled}) =>
      _viewApi.setZoomControlsEnabled(enabled).wrapPlatformException();

  /// Enables or disables the compass.
  Future<void> setCompassEnabled({required bool enabled}) =>
      _viewApi.setCompassEnabled(enabled).wrapPlatformException();

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled({required bool enabled}) =>
      _viewApi.setRotateGesturesEnabled(enabled).wrapPlatformException();

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled({required bool enabled}) =>
      _viewApi.setScrollGesturesEnabled(enabled).wrapPlatformException();

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled({
    required bool enabled,
  }) => _viewApi
      .setScrollGesturesDuringRotateOrZoomEnabled(enabled)
      .wrapPlatformException();

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled({required bool enabled}) =>
      _viewApi.setTiltGesturesEnabled(enabled).wrapPlatformException();

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabled({required bool enabled}) =>
      _viewApi.setMapToolbarEnabled(enabled).wrapPlatformException();

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled({required bool enabled}) =>
      _viewApi.setTrafficEnabled(enabled).wrapPlatformException();

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabled() =>
      _viewApi.isMyLocationButtonEnabled().wrapPlatformException();

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled() => _viewApi
      .isConsumeMyLocationButtonClickEventsEnabled()
      .wrapPlatformException();

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled() =>
      _viewApi.isZoomGesturesEnabled().wrapPlatformException();

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabled() =>
      _viewApi.isZoomControlsEnabled().wrapPlatformException();

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled() =>
      _viewApi.isCompassEnabled().wrapPlatformException();

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled() =>
      _viewApi.isRotateGesturesEnabled().wrapPlatformException();

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled() =>
      _viewApi.isScrollGesturesEnabled().wrapPlatformException();

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() => _viewApi
      .isScrollGesturesEnabledDuringRotateOrZoom()
      .wrapPlatformException();

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled() =>
      _viewApi.isTiltGesturesEnabled().wrapPlatformException();

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabled() =>
      _viewApi.isMapToolbarEnabled().wrapPlatformException();

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled() =>
      _viewApi.isTrafficEnabled().wrapPlatformException();

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocation({
    required CameraPerspective perspective,
    required double? zoomLevel,
  }) => _viewApi
      .followMyLocation(perspective.toDto(), zoomLevel)
      .wrapPlatformException();

  /// Gets users current location.
  Future<LatLng?> getMyLocation() async {
    final LatLngDto? myLocation = await _viewApi
        .getMyLocation()
        .wrapPlatformException();
    return myLocation?.toLatLng();
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    final CameraPositionDto position = await _viewApi
        .getCameraPosition()
        .wrapPlatformException();
    return position.toCameraPosition();
  }

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    final LatLngBoundsDto bounds = await _viewApi
        .getVisibleRegion()
        .wrapPlatformException();
    return LatLngBounds(
      southwest: bounds.southwest.toLatLng(),
      northeast: bounds.northeast.toLatLng(),
    );
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
                (bool success) => onFinished != null && Platform.isAndroid
                    ? onFinished(success)
                    : null,
              ),
        );
      case CameraUpdateType.latLng:
        unawaited(
          _viewApi
              .animateCameraToLatLng(cameraUpdate.latLng!.toDto(), duration)
              .then(
                (bool success) => onFinished != null && Platform.isAndroid
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
                (bool success) => onFinished != null && Platform.isAndroid
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
                (bool success) => onFinished != null && Platform.isAndroid
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
                (bool success) => onFinished != null && Platform.isAndroid
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
                (bool success) => onFinished != null && Platform.isAndroid
                    ? onFinished(success)
                    : null,
              ),
        );
      case CameraUpdateType.zoomTo:
        unawaited(
          _viewApi
              .animateCameraToZoom(cameraUpdate.zoom!, duration)
              .then(
                (bool success) => onFinished != null && Platform.isAndroid
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
        return _viewApi
            .moveCameraToCameraPosition(
              cameraUpdate.cameraPosition!.toCameraPosition(),
            )
            .wrapPlatformException();
      case CameraUpdateType.latLng:
        return _viewApi
            .moveCameraToLatLng(cameraUpdate.latLng!.toDto())
            .wrapPlatformException();
      case CameraUpdateType.latLngBounds:
        assert(cameraUpdate.padding != null, 'Camera position is null');
        return _viewApi
            .moveCameraToLatLngBounds(
              cameraUpdate.bounds!.toDto(),
              cameraUpdate.padding!,
            )
            .wrapPlatformException();
      case CameraUpdateType.latLngZoom:
        return _viewApi
            .moveCameraToLatLngZoom(
              cameraUpdate.latLng!.toDto(),
              cameraUpdate.zoom!,
            )
            .wrapPlatformException();
      case CameraUpdateType.scrollBy:
        return _viewApi
            .moveCameraByScroll(
              cameraUpdate.scrollByDx!,
              cameraUpdate.scrollByDy!,
            )
            .wrapPlatformException();
      case CameraUpdateType.zoomBy:
        return _viewApi
            .moveCameraByZoom(
              cameraUpdate.zoomByAmount!,
              cameraUpdate.focus?.dx,
              cameraUpdate.focus?.dy,
            )
            .wrapPlatformException();
      case CameraUpdateType.zoomTo:
        return _viewApi
            .moveCameraToZoom(cameraUpdate.zoom!)
            .wrapPlatformException();
    }
  }

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreference() =>
      _viewApi.getMinZoomPreference().wrapPlatformException();

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreference() =>
      _viewApi.getMaxZoomPreference().wrapPlatformException();

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() =>
      _viewApi.resetMinMaxZoomPreference().wrapPlatformException();

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreference({required double minZoomPreference}) =>
      _viewApi.setMinZoomPreference(minZoomPreference).wrapPlatformException();

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreference({required double maxZoomPreference}) =>
      _viewApi.setMaxZoomPreference(maxZoomPreference).wrapPlatformException();

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers() async {
    final List<MarkerDto?> markers = await _viewApi
        .getMarkers()
        .wrapPlatformException();
    return markers
        .whereType<MarkerDto>()
        .map((MarkerDto e) => e.toMarker())
        .toList();
  }

  /// Add markers to map view.
  Future<List<Marker>> addMarkers({
    required List<MarkerOptions> markerOptions,
  }) async {
    // Convert options to pigeon format
    final List<MarkerOptionsDto> options = markerOptions
        .map((MarkerOptions opt) => opt.toDto())
        .toList();

    // Create marker objects with new ID's
    final List<MarkerDto> markersToAdd = options
        .map(
          (MarkerOptionsDto options) =>
              MarkerDto(markerId: _createMarkerId(), options: options),
        )
        .toList();

    // Add markers to map
    final List<MarkerDto?> markersAdded = await _viewApi
        .addMarkers(markersToAdd)
        .wrapPlatformException();

    if (markersToAdd.length != markersAdded.length) {
      throw Exception('Could not add all markers to map view');
    }

    return markersAdded
        .whereType<MarkerDto>()
        .map((MarkerDto markerDto) => markerDto.toMarker())
        .toList();
  }

  /// Update markers on the map view.
  Future<List<Marker>> updateMarkers({required List<Marker> markers}) async {
    final List<MarkerDto> markerDtos = markers
        .map((Marker marker) => marker.toDto())
        .toList();
    final List<MarkerDto?> updatedMarkers = await _viewApi
        .updateMarkers(markerDtos)
        .wrapPlatformException();
    return updatedMarkers
        .whereType<MarkerDto>()
        .map((MarkerDto markerDto) => markerDto.toMarker())
        .toList();
  }

  /// Remove markers from map view.
  Future<void> removeMarkers({required List<Marker> markers}) => _viewApi
      .removeMarkers(markers.map((Marker marker) => marker.toDto()).toList())
      .wrapPlatformException();

  /// Remove all markers from map view.
  Future<void> clearMarkers() =>
      _viewApi.clearMarkers().wrapPlatformException();

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear() => _viewApi.clear().wrapPlatformException();

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons() async {
    final List<PolygonDto?> polygons = await _viewApi
        .getPolygons()
        .wrapPlatformException();

    return polygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons({
    required List<PolygonOptions> polygonOptions,
  }) async {
    // Convert options to pigeon format
    final List<PolygonOptionsDto> options = polygonOptions
        .map((PolygonOptions opt) => opt.toDto())
        .toList();

    // Create polygon objects with new ID's
    final List<PolygonDto> polygonsToAdd = options
        .map(
          (PolygonOptionsDto options) =>
              PolygonDto(polygonId: _createPolygonId(), options: options),
        )
        .toList();

    // Add polygons to map
    final List<PolygonDto?> polygonsAdded = await _viewApi
        .addPolygons(polygonsToAdd)
        .wrapPlatformException();

    if (polygonsToAdd.length != polygonsAdded.length) {
      throw Exception('Could not add all polygons to map view');
    }

    return polygonsAdded
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Update polygons on the map view.
  Future<List<Polygon?>> updatePolygons({
    required List<Polygon> polygons,
  }) async {
    final List<PolygonDto> navigationViewPolygons = polygons
        .map((Polygon polygon) => polygon.toDto())
        .toList();
    final List<PolygonDto?> updatedPolygons = await _viewApi
        .updatePolygons(navigationViewPolygons)
        .wrapPlatformException();
    return updatedPolygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Remove polygons from map view.
  Future<void> removePolygons({required List<Polygon> polygons}) => _viewApi
      .removePolygons(
        polygons.map((Polygon polygon) => polygon.toDto()).toList(),
      )
      .wrapPlatformException();

  /// Remove all polygons from map view.
  Future<void> clearPolygons() =>
      _viewApi.clearPolygons().wrapPlatformException();

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines() async {
    final List<PolylineDto?> polylines = await _viewApi
        .getPolylines()
        .wrapPlatformException();

    return polylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines({
    required List<PolylineOptions> polylineOptions,
  }) async {
    // Convert options to pigeon format
    final List<PolylineOptionsDto> options = polylineOptions
        .map((PolylineOptions opt) => opt.toDto())
        .toList();

    // Create polyline objects with new ID's
    final List<PolylineDto> polylinesToAdd = options
        .map(
          (PolylineOptionsDto options) =>
              PolylineDto(polylineId: _createPolylineId(), options: options),
        )
        .toList();

    // Add polylines to map
    final List<PolylineDto?> polylinesAdded = await _viewApi
        .addPolylines(polylinesToAdd)
        .wrapPlatformException();

    if (polylinesToAdd.length != polylinesAdded.length) {
      throw Exception('Could not add all polylines to map view');
    }

    return polylinesAdded
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Update polylines on the map view.
  Future<List<Polyline?>> updatePolylines({
    required List<Polyline> polylines,
  }) async {
    final List<PolylineDto> navigationViewPolylines = polylines
        .map((Polyline polyline) => polyline.toNavigationViewPolyline())
        .toList();
    final List<PolylineDto?> updatedPolylines = await _viewApi
        .updatePolylines(navigationViewPolylines)
        .wrapPlatformException();
    return updatedPolylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Remove polylines from map view.
  Future<void> removePolylines({required List<Polyline> polylines}) => _viewApi
      .removePolylines(
        polylines
            .map((Polyline polyline) => polyline.toNavigationViewPolyline())
            .toList(),
      )
      .wrapPlatformException();

  /// Remove all polylines from map view.
  Future<void> clearPolylines() =>
      _viewApi.clearPolylines().wrapPlatformException();

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles() async {
    final List<CircleDto?> circles = await _viewApi
        .getCircles()
        .wrapPlatformException();

    return circles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Add circles to map view.
  Future<List<Circle?>> addCircles({
    required List<CircleOptions> options,
  }) async {
    // Convert options to pigeon format
    final List<CircleOptionsDto> optionsDto = options
        .map((CircleOptions opt) => opt.toDto())
        .toList();

    // Create circle objects with new ID's
    final List<CircleDto> circlesToAdd = optionsDto
        .map(
          (CircleOptionsDto options) =>
              CircleDto(circleId: _createCircleId(), options: options),
        )
        .toList();

    // Add circles to map
    final List<CircleDto?> circlesAdded = await _viewApi
        .addCircles(circlesToAdd)
        .wrapPlatformException();

    if (circlesToAdd.length != circlesAdded.length) {
      throw Exception('Could not add all circles to map view');
    }

    return circlesAdded
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Update circles on the map view.
  Future<List<Circle?>> updateCircles({required List<Circle> circles}) async {
    final List<CircleDto> navigationViewCircles = circles
        .map((Circle circle) => circle.toDto())
        .toList();
    final List<CircleDto?> updatedCircles = await _viewApi
        .updateCircles(navigationViewCircles)
        .wrapPlatformException();

    return updatedCircles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Remove circles from map view.
  Future<void> removeCircles({required List<Circle> circles}) => _viewApi
      .removeCircles(circles.map((Circle circle) => circle.toDto()).toList())
      .wrapPlatformException();

  /// Remove all circles from map view.
  Future<void> clearCircles() =>
      _viewApi.clearCircles().wrapPlatformException();

  /// Register camera changed listeners.
  Future<void> enableOnCameraChangedEvents() =>
      _viewApi.enableOnCameraChangedEvents().wrapPlatformException();

  Future<void> setPadding({required EdgeInsets padding}) => _viewApi
      .setPadding(
        MapPaddingDto(
          top: padding.top.toInt(),
          left: padding.left.toInt(),
          bottom: padding.bottom.toInt(),
          right: padding.right.toInt(),
        ),
      )
      .wrapPlatformException();

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding() async {
    final MapPaddingDto padding = await _viewApi
        .getPadding()
        .wrapPlatformException();
    return EdgeInsets.only(
      top: padding.top.toDouble(),
      left: padding.left.toDouble(),
      bottom: padding.bottom.toDouble(),
      right: padding.right.toDouble(),
    );
  }

  Future<bool> isAutoScreenAvailable() =>
      _viewApi.isAutoScreenAvailable().wrapPlatformException();

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
