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
import '../google_navigation_flutter_platform_interface.dart';
import 'method_channel.dart';

/// @nodoc
/// Class that handles map view and navigation view communications.
mixin CommonAutoMapViewAPI on AutoMapViewAPIInterface {
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

  /// This function ensures that the event API has been setup. This should be
  /// called when initializing auto view controller.
  @override
  void initializeAutoViewEventAPI() {
    if (!_viewApiHasBeenSetUp) {
      AutoViewEventApi.setup(
        AutoViewEventApiImpl(
            viewEventStreamController: _autoEventStreamController),
      );
      _viewApiHasBeenSetUp = true;
    }
  }

  @override
  Future<bool> isMyLocationEnabledForAuto() {
    return _viewApi.isMyLocationEnabled();
  }

  @override
  Future<void> setMyLocationEnabledForAuto({required bool enabled}) {
    return _viewApi.setMyLocationEnabled(enabled);
  }

  @override
  Future<MapType> getMapTypeForAuto() async {
    final MapTypeDto mapType = await _viewApi.getMapType();
    return mapType.toMapType();
  }

  @override
  Future<void> setMapTypeForAuto({required MapType mapType}) async {
    return _viewApi.setMapType(mapType.toDto());
  }

  @override
  Future<void> setMapStyleForAuto(String? styleJson) async {
    try {
      // Set the given json to the viewApi or reset the map style if
      // the styleJson is null.
      return await _viewApi.setMapStyle(styleJson ?? '[]');
    } on PlatformException catch (error) {
      if (error.code == 'mapStyleError') {
        throw const MapStyleException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setMyLocationButtonEnabledForAuto({required bool enabled}) {
    return _viewApi.setMyLocationButtonEnabled(enabled);
  }

  @override
  Future<void> setConsumeMyLocationButtonClickEventsEnabledForAuto(
      {required bool enabled}) async {
    return _viewApi.setConsumeMyLocationButtonClickEventsEnabled(enabled);
  }

  @override
  Future<void> setZoomGesturesEnabledForAuto({required bool enabled}) {
    return _viewApi.setZoomGesturesEnabled(enabled);
  }

  @override
  Future<void> setZoomControlsEnabledForAuto({required bool enabled}) async {
    try {
      return await _viewApi.setZoomControlsEnabled(enabled);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setCompassEnabledForAuto({required bool enabled}) {
    return _viewApi.setCompassEnabled(enabled);
  }

  @override
  Future<void> setRotateGesturesEnabledForAuto({required bool enabled}) {
    return _viewApi.setRotateGesturesEnabled(enabled);
  }

  @override
  Future<void> setScrollGesturesEnabledForAuto({required bool enabled}) {
    return _viewApi.setScrollGesturesEnabled(enabled);
  }

  @override
  Future<void> setScrollGesturesDuringRotateOrZoomEnabledForAuto(
      {required bool enabled}) {
    return _viewApi.setScrollGesturesDuringRotateOrZoomEnabled(enabled);
  }

  @override
  Future<void> setTiltGesturesEnabledForAuto({required bool enabled}) {
    return _viewApi.setTiltGesturesEnabled(enabled);
  }

  @override
  Future<void> setMapToolbarEnabledForAuto({required bool enabled}) async {
    try {
      return await _viewApi.setMapToolbarEnabled(enabled);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setTrafficEnabledForAuto({required bool enabled}) {
    return _viewApi.setTrafficEnabled(enabled);
  }

  @override
  Future<bool> isMyLocationButtonEnabledForAuto() {
    return _viewApi.isMyLocationButtonEnabled();
  }

  @override
  Future<bool> isConsumeMyLocationButtonClickEventsEnabledForAuto() {
    return _viewApi.isConsumeMyLocationButtonClickEventsEnabled();
  }

  @override
  Future<bool> isZoomGesturesEnabledForAuto() {
    return _viewApi.isZoomGesturesEnabled();
  }

  @override
  Future<bool> isZoomControlsEnabledForAuto() async {
    try {
      return await _viewApi.isZoomControlsEnabled();
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<bool> isCompassEnabledForAuto() {
    return _viewApi.isCompassEnabled();
  }

  @override
  Future<bool> isRotateGesturesEnabledForAuto() {
    return _viewApi.isRotateGesturesEnabled();
  }

  @override
  Future<bool> isScrollGesturesEnabledForAuto() {
    return _viewApi.isScrollGesturesEnabled();
  }

  @override
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoomForAuto() {
    return _viewApi.isScrollGesturesEnabledDuringRotateOrZoom();
  }

  @override
  Future<bool> isTiltGesturesEnabledForAuto() {
    return _viewApi.isTiltGesturesEnabled();
  }

  @override
  Future<bool> isMapToolbarEnabledForAuto() async {
    try {
      return await _viewApi.isMapToolbarEnabled();
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<bool> isTrafficEnabledForAuto() {
    return _viewApi.isTrafficEnabled();
  }

  @override
  Future<void> followMyLocationForAuto(
      {required CameraPerspective perspective, required double? zoomLevel}) {
    return _viewApi.followMyLocation(perspective.toDto(), zoomLevel);
  }

  @override
  Future<LatLng?> getMyLocationForAuto() async {
    final LatLngDto? myLocation = await _viewApi.getMyLocation();
    if (myLocation == null) {
      return null;
    }
    return myLocation.toLatLng();
  }

  @override
  Future<CameraPosition> getCameraPositionForAuto() async {
    final CameraPositionDto position = await _viewApi.getCameraPosition();
    return position.toCameraPosition();
  }

  @override
  Future<LatLngBounds> getVisibleRegionForAuto() async {
    final LatLngBoundsDto bounds = await _viewApi.getVisibleRegion();
    return LatLngBounds(
      southwest: bounds.southwest.toLatLng(),
      northeast: bounds.northeast.toLatLng(),
    );
  }

  @override
  Future<void> animateCameraForAuto(
      {required CameraUpdate cameraUpdate,
      required int? duration,
      AnimationFinishedCallback? onFinished}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        unawaited(_viewApi
            .animateCameraToCameraPosition(
                cameraUpdate.cameraPosition!.toCameraPosition(), duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLng:
        unawaited(_viewApi
            .animateCameraToLatLng(cameraUpdate.latLng!.toDto(), duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLngBounds:
        unawaited(_viewApi
            .animateCameraToLatLngBounds(
                cameraUpdate.bounds!.toDto(), cameraUpdate.padding!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLngZoom:
        unawaited(_viewApi
            .animateCameraToLatLngZoom(
                cameraUpdate.latLng!.toDto(), cameraUpdate.zoom!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.scrollBy:
        unawaited(_viewApi
            .animateCameraByScroll(
                cameraUpdate.scrollByDx!, cameraUpdate.scrollByDy!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.zoomBy:
        unawaited(_viewApi
            .animateCameraByZoom(cameraUpdate.zoomByAmount!,
                cameraUpdate.focus?.dx, cameraUpdate.focus?.dy, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.zoomTo:
        unawaited(_viewApi
            .animateCameraToZoom(cameraUpdate.zoom!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
    }
  }

  @override
  Future<void> moveCameraForAuto({required CameraUpdate cameraUpdate}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        assert(cameraUpdate.cameraPosition != null, 'Camera position is null');
        return _viewApi.moveCameraToCameraPosition(
            cameraUpdate.cameraPosition!.toCameraPosition());
      case CameraUpdateType.latLng:
        return _viewApi.moveCameraToLatLng(cameraUpdate.latLng!.toDto());
      case CameraUpdateType.latLngBounds:
        assert(cameraUpdate.padding != null, 'Camera position is null');
        return _viewApi.moveCameraToLatLngBounds(
            cameraUpdate.bounds!.toDto(), cameraUpdate.padding!);
      case CameraUpdateType.latLngZoom:
        return _viewApi.moveCameraToLatLngZoom(
            cameraUpdate.latLng!.toDto(), cameraUpdate.zoom!);
      case CameraUpdateType.scrollBy:
        return _viewApi.moveCameraByScroll(
            cameraUpdate.scrollByDx!, cameraUpdate.scrollByDy!);
      case CameraUpdateType.zoomBy:
        return _viewApi.moveCameraByZoom(cameraUpdate.zoomByAmount!,
            cameraUpdate.focus?.dx, cameraUpdate.focus?.dy);
      case CameraUpdateType.zoomTo:
        return _viewApi.moveCameraToZoom(cameraUpdate.zoom!);
    }
  }

  @override
  Future<double> getMinZoomPreferenceForAuto() {
    return _viewApi.getMinZoomPreference();
  }

  @override
  Future<double> getMaxZoomPreferenceForAuto() {
    return _viewApi.getMaxZoomPreference();
  }

  @override
  Future<void> resetMinMaxZoomPreferenceForAuto() {
    return _viewApi.resetMinMaxZoomPreference();
  }

  @override
  Future<void> setMinZoomPreferenceForAuto(
      {required double minZoomPreference}) async {
    try {
      return await _viewApi.setMinZoomPreference(minZoomPreference);
    } on PlatformException catch (error) {
      if (error.code == 'minZoomGreaterThanMaxZoom') {
        throw const MinZoomRangeException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> setMaxZoomPreferenceForAuto(
      {required double maxZoomPreference}) async {
    try {
      return await _viewApi.setMaxZoomPreference(maxZoomPreference);
    } on PlatformException catch (error) {
      if (error.code == 'maxZoomLessThanMinZoom') {
        throw const MaxZoomRangeException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<List<Marker?>> getMarkersForAuto() async {
    final List<MarkerDto?> markers = await _viewApi.getMarkers();
    return markers
        .whereType<MarkerDto>()
        .map((MarkerDto e) => e.toMarker())
        .toList();
  }

  @override
  Future<List<Marker>> addMarkersForAuto(
      {required List<MarkerOptions> markerOptions}) async {
    // Convert options to pigeon format
    final List<MarkerOptionsDto> options =
        markerOptions.map((MarkerOptions opt) => opt.toDto()).toList();

    // Create marker objects with new ID's
    final List<MarkerDto> markersToAdd = options
        .map((MarkerOptionsDto options) =>
            MarkerDto(markerId: _createMarkerId(), options: options))
        .toList();

    // Add markers to map
    final List<MarkerDto?> markersAdded =
        await _viewApi.addMarkers(markersToAdd);

    if (markersToAdd.length != markersAdded.length) {
      throw Exception('Could not add all markers to map view');
    }

    return markersAdded
        .whereType<MarkerDto>()
        .map((MarkerDto markerDto) => markerDto.toMarker())
        .toList();
  }

  @override
  Future<List<Marker>> updateMarkersForAuto(
      {required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      final List<MarkerDto?> updatedMarkers =
          await _viewApi.updateMarkers(markerDtos);
      return updatedMarkers
          .whereType<MarkerDto>()
          .map((MarkerDto markerDto) => markerDto.toMarker())
          .toList();
    } on PlatformException catch (error) {
      if (error.code == 'markerNotFound') {
        throw const MarkerNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeMarkersForAuto({required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      return await _viewApi.removeMarkers(markerDtos);
    } on PlatformException catch (error) {
      if (error.code == 'markerNotFound') {
        throw const MarkerNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> clearMarkersForAuto() {
    return _viewApi.clearMarkers();
  }

  @override
  Future<void> clearForAuto() {
    return _viewApi.clear();
  }

  @override
  Future<List<Polygon?>> getPolygonsForAuto() async {
    final List<PolygonDto?> polygons = await _viewApi.getPolygons();

    return polygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  @override
  Future<List<Polygon?>> addPolygonsForAuto(
      {required List<PolygonOptions> polygonOptions}) async {
    // Convert options to pigeon format
    final List<PolygonOptionsDto> options =
        polygonOptions.map((PolygonOptions opt) => opt.toDto()).toList();

    // Create polygon objects with new ID's
    final List<PolygonDto> polygonsToAdd = options
        .map((PolygonOptionsDto options) =>
            PolygonDto(polygonId: _createPolygonId(), options: options))
        .toList();

    // Add polygons to map
    final List<PolygonDto?> polygonsAdded =
        await _viewApi.addPolygons(polygonsToAdd);

    if (polygonsToAdd.length != polygonsAdded.length) {
      throw Exception('Could not add all polygons to map view');
    }

    return polygonsAdded
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  @override
  Future<List<Polygon?>> updatePolygonsForAuto(
      {required List<Polygon> polygons}) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      final List<PolygonDto?> updatedPolygons =
          await _viewApi.updatePolygons(navigationViewPolygons);
      return updatedPolygons
          .whereType<PolygonDto>()
          .map((PolygonDto polygon) => polygon.toPolygon())
          .toList();
    } on PlatformException catch (error) {
      if (error.code == 'polygonNotFound') {
        throw const PolygonNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> removePolygonsForAuto({required List<Polygon> polygons}) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      return await _viewApi.removePolygons(navigationViewPolygons);
    } on PlatformException catch (error) {
      if (error.code == 'polygonNotFound') {
        throw const PolygonNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> clearPolygonsForAuto() {
    return _viewApi.clearPolygons();
  }

  @override
  Future<List<Polyline?>> getPolylinesForAuto() async {
    final List<PolylineDto?> polylines = await _viewApi.getPolylines();

    return polylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  @override
  Future<List<Polyline?>> addPolylinesForAuto(
      {required List<PolylineOptions> polylineOptions}) async {
    // Convert options to pigeon format
    final List<PolylineOptionsDto> options =
        polylineOptions.map((PolylineOptions opt) => opt.toDto()).toList();

    // Create polyline objects with new ID's
    final List<PolylineDto> polylinesToAdd = options
        .map((PolylineOptionsDto options) =>
            PolylineDto(polylineId: _createPolylineId(), options: options))
        .toList();

    // Add polylines to map
    final List<PolylineDto?> polylinesAdded =
        await _viewApi.addPolylines(polylinesToAdd);

    if (polylinesToAdd.length != polylinesAdded.length) {
      throw Exception('Could not add all polylines to map view');
    }

    return polylinesAdded
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  @override
  Future<List<Polyline?>> updatePolylinesForAuto(
      {required List<Polyline> polylines}) async {
    try {
      final List<PolylineDto> navigationViewPolylines = polylines
          .map((Polyline polyline) => polyline.toNavigationViewPolyline())
          .toList();
      final List<PolylineDto?> updatedPolylines =
          await _viewApi.updatePolylines(navigationViewPolylines);
      return updatedPolylines
          .whereType<PolylineDto>()
          .map((PolylineDto polyline) => polyline.toPolyline())
          .toList();
    } on PlatformException catch (error) {
      if (error.code == 'polylineNotFound') {
        throw const PolylineNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> removePolylinesForAuto(
      {required List<Polyline> polylines}) async {
    try {
      final List<PolylineDto> navigationViewPolylines = polylines
          .map((Polyline polyline) => polyline.toNavigationViewPolyline())
          .toList();
      return await _viewApi.removePolylines(navigationViewPolylines);
    } on PlatformException catch (error) {
      if (error.code == 'polylineNotFound') {
        throw const PolylineNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> clearPolylinesForAuto() {
    return _viewApi.clearPolylines();
  }

  @override
  Future<List<Circle?>> getCirclesForAuto() async {
    final List<CircleDto?> circles = await _viewApi.getCircles();

    return circles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  @override
  Future<List<Circle?>> addCirclesForAuto(
      {required List<CircleOptions> options}) async {
    // Convert options to pigeon format
    final List<CircleOptionsDto> optionsDto =
        options.map((CircleOptions opt) => opt.toDto()).toList();

    // Create circle objects with new ID's
    final List<CircleDto> circlesToAdd = optionsDto
        .map((CircleOptionsDto options) =>
            CircleDto(circleId: _createCircleId(), options: options))
        .toList();

    // Add circles to map
    final List<CircleDto?> circlesAdded =
        await _viewApi.addCircles(circlesToAdd);

    if (circlesToAdd.length != circlesAdded.length) {
      throw Exception('Could not add all circles to map view');
    }

    return circlesAdded
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  @override
  Future<List<Circle?>> updateCirclesForAuto(
      {required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      final List<CircleDto?> updatedCircles =
          await _viewApi.updateCircles(navigationViewCircles);

      return updatedCircles
          .whereType<CircleDto>()
          .map((CircleDto circle) => circle.toCircle())
          .toList();
    } on PlatformException catch (error) {
      if (error.code == 'circleNotFound') {
        throw const CircleNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> removeCirclesForAuto({required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      return await _viewApi.removeCircles(navigationViewCircles);
    } on PlatformException catch (error) {
      if (error.code == 'circleNotFound') {
        throw const CircleNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> clearCirclesForAuto() {
    return _viewApi.clearCircles();
  }

  @override
  Future<void> registerOnCameraChangedListenerForAuto() {
    return _viewApi.registerOnCameraChangedListener();
  }

  @override
  Future<void> setPaddingForAuto({required EdgeInsets padding}) {
    return _viewApi.setPadding(MapPaddingDto(
        top: padding.top.toInt(),
        left: padding.left.toInt(),
        bottom: padding.bottom.toInt(),
        right: padding.right.toInt()));
  }

  // Gets the map padding from the map view.
  @override
  Future<EdgeInsets> getPaddingForAuto() async {
    final MapPaddingDto padding = await _viewApi.getPadding();
    return EdgeInsets.only(
        top: padding.top.toDouble(),
        left: padding.left.toDouble(),
        bottom: padding.bottom.toDouble(),
        right: padding.right.toDouble());
  }

  @override
  Future<bool> isAutoScreenAvailable() {
    return _viewApi.isAutoScreenAvailable();
  }

  Stream<T> _unwrapEventStream<T>() {
    // If event that does not
    return _autoEventStreamController.stream
        .where((_AutoEventWrapper wrapper) => (wrapper.event is T))
        .map<T>((_AutoEventWrapper wrapper) => wrapper.event as T);
  }

  @override
  Stream<CustomNavigationAutoEvent> getCustomNavigationAutoEventStream() {
    return _unwrapEventStream<CustomNavigationAutoEvent>();
  }

  @override
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
        _AutoEventWrapper(CustomNavigationAutoEvent(event: event, data: data)));
  }

  @override
  void onAutoScreenAvailabilityChanged(bool isAvailable) {
    _viewEventStreamController.add(_AutoEventWrapper(
      AutoScreenAvailabilityChangedEvent(isAvailable: isAvailable),
    ));
  }
}

class _AutoEventWrapper {
  _AutoEventWrapper(this.event);

  final Object event;
}
