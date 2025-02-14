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
class MapViewAPIImpl {
  final MapViewApi _viewApi = MapViewApi();
  bool _viewApiHasBeenSetUp = false;
  final StreamController<_ViewIdEventWrapper> _viewEventStreamController =
      StreamController<_ViewIdEventWrapper>.broadcast();

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

  Stream<T> _unwrapEventStream<T>({required int viewId}) {
    // If event that does not
    return _viewEventStreamController.stream
        .where((_ViewIdEventWrapper wrapper) =>
            (wrapper.event is T) && wrapper.viewId == viewId)
        .map<T>((_ViewIdEventWrapper wrapper) => wrapper.event as T);
  }

  /// This function ensures that the event API has been setup. This should be
  /// called when initializing navigation view.
  void ensureViewAPISetUp() {
    if (!_viewApiHasBeenSetUp) {
      ViewEventApi.setup(
        ViewEventApiImpl(viewEventStreamController: _viewEventStreamController),
      );
      _viewApiHasBeenSetUp = true;
    }
  }

  /// Builds creation params used to initialize navigation view with initial parameters.
  ViewCreationOptionsDto buildNavigationViewCreationOptions(
      MapViewType mapViewType,
      MapViewInitializationOptions initializationSettings) {
    assert(
        mapViewType == MapViewType.navigation ||
            initializationSettings.navigationViewOptions == null,
        'Navigation view options can only be set when using navigation view type');

    /// Map options
    final MapOptions mapOptions = initializationSettings.mapOptions;
    final CameraPosition cameraPosition = mapOptions.cameraPosition;
    final CameraPositionDto initialCameraPosition = CameraPositionDto(
      bearing: cameraPosition.bearing,
      target: LatLngDto(
          latitude: cameraPosition.target.latitude,
          longitude: cameraPosition.target.longitude),
      tilt: cameraPosition.tilt,
      zoom: cameraPosition.zoom,
    );
    final MapOptionsDto mapOptionsMessage = MapOptionsDto(
        cameraPosition: initialCameraPosition,
        mapType: mapOptions.mapType.toDto(),
        compassEnabled: mapOptions.compassEnabled,
        rotateGesturesEnabled: mapOptions.rotateGesturesEnabled,
        scrollGesturesEnabled: mapOptions.scrollGesturesEnabled,
        tiltGesturesEnabled: mapOptions.tiltGesturesEnabled,
        zoomGesturesEnabled: mapOptions.zoomGesturesEnabled,
        scrollGesturesEnabledDuringRotateOrZoom:
            mapOptions.scrollGesturesEnabledDuringRotateOrZoom,
        mapToolbarEnabled: mapOptions.mapToolbarEnabled,
        minZoomPreference: mapOptions.minZoomPreference,
        maxZoomPreference: mapOptions.maxZoomPreference,
        zoomControlsEnabled: mapOptions.zoomControlsEnabled,
        cameraTargetBounds: mapOptions.cameraTargetBounds?.toDto(),
        padding: mapOptions.padding != null
            ? MapPaddingDto(
                top: mapOptions.padding!.top.toInt(),
                left: mapOptions.padding!.left.toInt(),
                bottom: mapOptions.padding!.bottom.toInt(),
                right: mapOptions.padding!.right.toInt())
            : null);

    // Initialize navigation view options if given
    NavigationViewOptionsDto? navigationOptionsMessage;
    final NavigationViewOptions? navigationViewOptions =
        initializationSettings.navigationViewOptions;
    if (navigationViewOptions != null) {
      switch (navigationViewOptions.navigationUIEnabledPreference) {
        case NavigationUIEnabledPreference.automatic:
          navigationOptionsMessage = NavigationViewOptionsDto(
              navigationUIEnabledPreference:
                  NavigationUIEnabledPreferenceDto.automatic);
        case NavigationUIEnabledPreference.disabled:
          navigationOptionsMessage = NavigationViewOptionsDto(
              navigationUIEnabledPreference:
                  NavigationUIEnabledPreferenceDto.disabled);
      }
    }

    // Build ViewCreationMessage
    return ViewCreationOptionsDto(
        mapViewType: mapViewType == MapViewType.navigation
            ? MapViewTypeDto.navigation
            : MapViewTypeDto.map,
        mapOptions: mapOptionsMessage,
        navigationViewOptions: navigationOptionsMessage);
  }

  /// Awaits the platform view to be ready for communication.
  Future<void> awaitMapReady({required int viewId}) {
    return _viewApi.awaitMapReady(viewId);
  }

  /// Get the preference for whether the my location should be enabled or disabled.
  Future<bool> isMyLocationEnabled({required int viewId}) {
    return _viewApi.isMyLocationEnabled(viewId);
  }

  /// Enabled location in the navigation view.
  Future<void> setMyLocationEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setMyLocationEnabled(viewId, enabled);
  }

  /// Get the map type.
  Future<MapType> getMapType({required int viewId}) async {
    final MapTypeDto mapType = await _viewApi.getMapType(viewId);
    return mapType.toMapType();
  }

  /// Modified visible map type.
  Future<void> setMapType(
      {required int viewId, required MapType mapType}) async {
    return _viewApi.setMapType(viewId, mapType.toDto());
  }

  /// Set map style by json string.
  Future<void> setMapStyle(int viewId, String? styleJson) async {
    try {
      // Set the given json to the viewApi or reset the map style if
      // the styleJson is null.
      return await _viewApi.setMapStyle(viewId, styleJson ?? '[]');
    } on PlatformException catch (error) {
      if (error.code == 'mapStyleError') {
        throw const MapStyleException();
      } else {
        rethrow;
      }
    }
  }

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setMyLocationButtonEnabled(viewId, enabled);
  }

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled(
      {required int viewId, required bool enabled}) async {
    return _viewApi.setConsumeMyLocationButtonClickEventsEnabled(
        viewId, enabled);
  }

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setZoomGesturesEnabled(viewId, enabled);
  }

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabled(
      {required int viewId, required bool enabled}) async {
    try {
      return await _viewApi.setZoomControlsEnabled(viewId, enabled);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  /// Enables or disables the compass.
  Future<void> setCompassEnabled({required int viewId, required bool enabled}) {
    return _viewApi.setCompassEnabled(viewId, enabled);
  }

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setRotateGesturesEnabled(viewId, enabled);
  }

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setScrollGesturesEnabled(viewId, enabled);
  }

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setScrollGesturesDuringRotateOrZoomEnabled(viewId, enabled);
  }

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setTiltGesturesEnabled(viewId, enabled);
  }

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabled(
      {required int viewId, required bool enabled}) async {
    try {
      return await _viewApi.setMapToolbarEnabled(viewId, enabled);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled({required int viewId, required bool enabled}) {
    return _viewApi.setTrafficEnabled(viewId, enabled);
  }

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabled({required int viewId}) {
    return _viewApi.isMyLocationButtonEnabled(viewId);
  }

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled(
      {required int viewId}) {
    return _viewApi.isConsumeMyLocationButtonClickEventsEnabled(viewId);
  }

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled({required int viewId}) {
    return _viewApi.isZoomGesturesEnabled(viewId);
  }

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabled({required int viewId}) async {
    try {
      return await _viewApi.isZoomControlsEnabled(viewId);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Zoom controls are not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled({required int viewId}) {
    return _viewApi.isCompassEnabled(viewId);
  }

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled({required int viewId}) {
    return _viewApi.isRotateGesturesEnabled(viewId);
  }

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled({required int viewId}) {
    return _viewApi.isScrollGesturesEnabled(viewId);
  }

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom(
      {required int viewId}) {
    return _viewApi.isScrollGesturesEnabledDuringRotateOrZoom(viewId);
  }

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled({required int viewId}) {
    return _viewApi.isTiltGesturesEnabled(viewId);
  }

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabled({required int viewId}) async {
    try {
      return await _viewApi.isMapToolbarEnabled(viewId);
    } on PlatformException catch (error) {
      if (error.code == 'notSupported') {
        throw UnsupportedError('Map toolbar is not supported on iOS.');
      } else {
        rethrow;
      }
    }
  }

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled({required int viewId}) {
    return _viewApi.isTrafficEnabled(viewId);
  }

  /// Gets users current location.
  Future<LatLng?> getMyLocation({required int viewId}) async {
    final LatLngDto? myLocation = await _viewApi.getMyLocation(viewId);
    if (myLocation == null) {
      return null;
    }
    return myLocation.toLatLng();
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition({required int viewId}) async {
    final CameraPositionDto position = await _viewApi.getCameraPosition(
      viewId,
    );
    return position.toCameraPosition();
  }

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegion({required int viewId}) async {
    final LatLngBoundsDto bounds = await _viewApi.getVisibleRegion(
      viewId,
    );
    return LatLngBounds(
      southwest: bounds.southwest.toLatLng(),
      northeast: bounds.northeast.toLatLng(),
    );
  }

  /// Animates the movement of the camera.
  Future<void> animateCamera(
      {required int viewId,
      required CameraUpdate cameraUpdate,
      required int? duration,
      AnimationFinishedCallback? onFinished}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        unawaited(_viewApi
            .animateCameraToCameraPosition(viewId,
                cameraUpdate.cameraPosition!.toCameraPosition(), duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLng:
        unawaited(_viewApi
            .animateCameraToLatLng(
                viewId, cameraUpdate.latLng!.toDto(), duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLngBounds:
        unawaited(_viewApi
            .animateCameraToLatLngBounds(viewId, cameraUpdate.bounds!.toDto(),
                cameraUpdate.padding!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.latLngZoom:
        unawaited(_viewApi
            .animateCameraToLatLngZoom(viewId, cameraUpdate.latLng!.toDto(),
                cameraUpdate.zoom!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.scrollBy:
        unawaited(_viewApi
            .animateCameraByScroll(viewId, cameraUpdate.scrollByDx!,
                cameraUpdate.scrollByDy!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.zoomBy:
        unawaited(_viewApi
            .animateCameraByZoom(viewId, cameraUpdate.zoomByAmount!,
                cameraUpdate.focus?.dx, cameraUpdate.focus?.dy, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
      case CameraUpdateType.zoomTo:
        unawaited(_viewApi
            .animateCameraToZoom(viewId, cameraUpdate.zoom!, duration)
            .then((bool success) => onFinished != null && Platform.isAndroid
                ? onFinished(success)
                : null));
    }
  }

  /// Moves the camera.
  Future<void> moveCamera(
      {required int viewId, required CameraUpdate cameraUpdate}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        assert(cameraUpdate.cameraPosition != null, 'Camera position is null');
        return _viewApi.moveCameraToCameraPosition(
            viewId, cameraUpdate.cameraPosition!.toCameraPosition());
      case CameraUpdateType.latLng:
        return _viewApi.moveCameraToLatLng(
            viewId, cameraUpdate.latLng!.toDto());
      case CameraUpdateType.latLngBounds:
        assert(cameraUpdate.padding != null, 'Camera position is null');
        return _viewApi.moveCameraToLatLngBounds(
            viewId, cameraUpdate.bounds!.toDto(), cameraUpdate.padding!);
      case CameraUpdateType.latLngZoom:
        return _viewApi.moveCameraToLatLngZoom(
            viewId, cameraUpdate.latLng!.toDto(), cameraUpdate.zoom!);
      case CameraUpdateType.scrollBy:
        return _viewApi.moveCameraByScroll(
            viewId, cameraUpdate.scrollByDx!, cameraUpdate.scrollByDy!);
      case CameraUpdateType.zoomBy:
        return _viewApi.moveCameraByZoom(viewId, cameraUpdate.zoomByAmount!,
            cameraUpdate.focus?.dx, cameraUpdate.focus?.dy);
      case CameraUpdateType.zoomTo:
        return _viewApi.moveCameraToZoom(viewId, cameraUpdate.zoom!);
    }
  }

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocation(
      {required int viewId,
      required CameraPerspective perspective,
      required double? zoomLevel}) {
    return _viewApi.followMyLocation(viewId, perspective.toDto(), zoomLevel);
  }

  /// Is the navigation trip progress bar enabled.
  Future<bool> isNavigationTripProgressBarEnabled({required int viewId}) {
    return _viewApi.isNavigationTripProgressBarEnabled(viewId);
  }

  /// Enable navigation trip progress bar.
  Future<void> setNavigationTripProgressBarEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setNavigationTripProgressBarEnabled(viewId, enabled);
  }

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled({required int viewId}) {
    return _viewApi.isNavigationHeaderEnabled(viewId);
  }

  /// Enable navigation header.
  Future<void> setNavigationHeaderEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setNavigationHeaderEnabled(viewId, enabled);
  }

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled({required int viewId}) {
    return _viewApi.isNavigationFooterEnabled(viewId);
  }

  /// Enable the navigation footer.
  Future<void> setNavigationFooterEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setNavigationFooterEnabled(viewId, enabled);
  }

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled({required int viewId}) {
    return _viewApi.isRecenterButtonEnabled(viewId);
  }

  /// Enable the recenter button.
  Future<void> setRecenterButtonEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setRecenterButtonEnabled(viewId, enabled);
  }

  /// Is the speed limit displayed.
  Future<bool> isSpeedLimitIconEnabled({required int viewId}) {
    return _viewApi.isSpeedLimitIconEnabled(viewId);
  }

  /// Should display speed limit.
  Future<void> setSpeedLimitIconEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setSpeedLimitIconEnabled(viewId, enabled);
  }

  /// Is speedometer displayed.
  Future<bool> isSpeedometerEnabled({required int viewId}) {
    return _viewApi.isSpeedometerEnabled(viewId);
  }

  /// Should display speedometer.
  Future<void> setSpeedometerEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setSpeedometerEnabled(viewId, enabled);
  }

  /// Is incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled({required int viewId}) {
    return _viewApi.isTrafficIncidentCardsEnabled(viewId);
  }

  /// Should display incident cards.
  Future<void> setTrafficIncidentCardsEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setTrafficIncidentCardsEnabled(viewId, enabled);
  }

  /// Is navigation UI enabled.
  Future<bool> isNavigationUIEnabled({required int viewId}) {
    return _viewApi.isNavigationUIEnabled(viewId);
  }

  /// Enable navigation UI.
  Future<void> setNavigationUIEnabled(
      {required int viewId, required bool enabled}) {
    return _viewApi.setNavigationUIEnabled(viewId, enabled);
  }

  /// Show route overview.
  Future<void> showRouteOverview({required int viewId}) {
    return _viewApi.showRouteOverview(viewId);
  }

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreference({required int viewId}) {
    return _viewApi.getMinZoomPreference(viewId);
  }

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreference({required int viewId}) {
    return _viewApi.getMaxZoomPreference(viewId);
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference({required int viewId}) {
    return _viewApi.resetMinMaxZoomPreference(viewId);
  }

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreference(
      {required int viewId, required double minZoomPreference}) async {
    try {
      return await _viewApi.setMinZoomPreference(viewId, minZoomPreference);
    } on PlatformException catch (error) {
      if (error.code == 'minZoomGreaterThanMaxZoom') {
        throw const MinZoomRangeException();
      } else {
        rethrow;
      }
    }
  }

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreference(
      {required int viewId, required double maxZoomPreference}) async {
    try {
      return await _viewApi.setMaxZoomPreference(viewId, maxZoomPreference);
    } on PlatformException catch (error) {
      if (error.code == 'maxZoomLessThanMinZoom') {
        throw const MaxZoomRangeException();
      } else {
        rethrow;
      }
    }
  }

  /// Get navigation recenter button clicked event stream from the navigation view.
  Stream<NavigationViewRecenterButtonClickedEvent>
      getNavigationRecenterButtonClickedEventStream({required int viewId}) {
    return _unwrapEventStream<NavigationViewRecenterButtonClickedEvent>(
        viewId: viewId);
  }

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers({required int viewId}) async {
    final List<MarkerDto?> markers = await _viewApi.getMarkers(viewId);
    return markers
        .whereType<MarkerDto>()
        .map((MarkerDto e) => e.toMarker())
        .toList();
  }

  /// Add markers to map view.
  Future<List<Marker>> addMarkers(
      {required int viewId, required List<MarkerOptions> markerOptions}) async {
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
        await _viewApi.addMarkers(viewId, markersToAdd);

    if (markersToAdd.length != markersAdded.length) {
      throw Exception('Could not add all markers to map view');
    }

    return markersAdded
        .whereType<MarkerDto>()
        .map((MarkerDto markerDto) => markerDto.toMarker())
        .toList();
  }

  /// Update markers on the map view.
  Future<List<Marker>> updateMarkers(
      {required int viewId, required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      final List<MarkerDto?> updatedMarkers =
          await _viewApi.updateMarkers(viewId, markerDtos);
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

  /// Remove markers from map view.
  Future<void> removeMarkers(
      {required int viewId, required List<Marker> markers}) async {
    try {
      final List<MarkerDto> markerDtos =
          markers.map((Marker marker) => marker.toDto()).toList();
      return await _viewApi.removeMarkers(viewId, markerDtos);
    } on PlatformException catch (error) {
      if (error.code == 'markerNotFound') {
        throw const MarkerNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  /// Remove all markers from map view.
  Future<void> clearMarkers({required int viewId}) {
    return _viewApi.clearMarkers(viewId);
  }

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear({required int viewId}) {
    return _viewApi.clear(viewId);
  }

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons({required int viewId}) async {
    final List<PolygonDto?> polygons = await _viewApi.getPolygons(viewId);

    return polygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons(
      {required int viewId,
      required List<PolygonOptions> polygonOptions}) async {
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
        await _viewApi.addPolygons(viewId, polygonsToAdd);

    if (polygonsToAdd.length != polygonsAdded.length) {
      throw Exception('Could not add all polygons to map view');
    }

    return polygonsAdded
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Update polygons on the map view.
  Future<List<Polygon?>> updatePolygons(
      {required int viewId, required List<Polygon> polygons}) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      final List<PolygonDto?> updatedPolygons =
          await _viewApi.updatePolygons(viewId, navigationViewPolygons);
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

  /// Remove polygons from map view.
  Future<void> removePolygons(
      {required int viewId, required List<Polygon> polygons}) async {
    try {
      final List<PolygonDto> navigationViewPolygons =
          polygons.map((Polygon polygon) => polygon.toDto()).toList();
      return await _viewApi.removePolygons(viewId, navigationViewPolygons);
    } on PlatformException catch (error) {
      if (error.code == 'polygonNotFound') {
        throw const PolygonNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  /// Remove all polygons from map view.
  Future<void> clearPolygons({required int viewId}) {
    return _viewApi.clearPolygons(viewId);
  }

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines({required int viewId}) async {
    final List<PolylineDto?> polylines = await _viewApi.getPolylines(viewId);

    return polylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines(
      {required int viewId,
      required List<PolylineOptions> polylineOptions}) async {
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
        await _viewApi.addPolylines(viewId, polylinesToAdd);

    if (polylinesToAdd.length != polylinesAdded.length) {
      throw Exception('Could not add all polylines to map view');
    }

    return polylinesAdded
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Update polylines on the map view.
  Future<List<Polyline?>> updatePolylines(
      {required int viewId, required List<Polyline> polylines}) async {
    try {
      final List<PolylineDto> navigationViewPolylines = polylines
          .map((Polyline polyline) => polyline.toNavigationViewPolyline())
          .toList();
      final List<PolylineDto?> updatedPolylines =
          await _viewApi.updatePolylines(viewId, navigationViewPolylines);
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

  /// Remove polylines from map view.
  Future<void> removePolylines(
      {required int viewId, required List<Polyline> polylines}) async {
    try {
      final List<PolylineDto> navigationViewPolylines = polylines
          .map((Polyline polyline) => polyline.toNavigationViewPolyline())
          .toList();
      return await _viewApi.removePolylines(viewId, navigationViewPolylines);
    } on PlatformException catch (error) {
      if (error.code == 'polylineNotFound') {
        throw const PolylineNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  /// Remove all polylines from map view.
  Future<void> clearPolylines({required int viewId}) {
    return _viewApi.clearPolylines(viewId);
  }

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles({required int viewId}) async {
    final List<CircleDto?> circles = await _viewApi.getCircles(viewId);

    return circles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Add circles to map view.
  Future<List<Circle?>> addCircles(
      {required int viewId, required List<CircleOptions> options}) async {
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
        await _viewApi.addCircles(viewId, circlesToAdd);

    if (circlesToAdd.length != circlesAdded.length) {
      throw Exception('Could not add all circles to map view');
    }

    return circlesAdded
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Update circles on the map view.
  Future<List<Circle?>> updateCircles(
      {required int viewId, required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      final List<CircleDto?> updatedCircles =
          await _viewApi.updateCircles(viewId, navigationViewCircles);

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

  /// Remove circles from map view.
  Future<void> removeCircles(
      {required int viewId, required List<Circle> circles}) async {
    try {
      final List<CircleDto> navigationViewCircles =
          circles.map((Circle circle) => circle.toDto()).toList();
      return await _viewApi.removeCircles(viewId, navigationViewCircles);
    } on PlatformException catch (error) {
      if (error.code == 'circleNotFound') {
        throw const CircleNotFoundException();
      } else {
        rethrow;
      }
    }
  }

  /// Remove all circles from map view.
  Future<void> clearCircles({required int viewId}) {
    return _viewApi.clearCircles(viewId);
  }

  /// Register camera changed listeners.
  Future<void> registerOnCameraChangedListener({required int viewId}) {
    return _viewApi.registerOnCameraChangedListener(viewId);
  }

  Future<void> setPadding({required int viewId, required EdgeInsets padding}) {
    return _viewApi.setPadding(
        viewId,
        MapPaddingDto(
            top: padding.top.toInt(),
            left: padding.left.toInt(),
            bottom: padding.bottom.toInt(),
            right: padding.right.toInt()));
  }

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding({required int viewId}) async {
    final MapPaddingDto padding = await _viewApi.getPadding(viewId);
    return EdgeInsets.only(
        top: padding.top.toDouble(),
        left: padding.left.toDouble(),
        bottom: padding.bottom.toDouble(),
        right: padding.right.toDouble());
  }

  Stream<MapClickEvent> getMapClickEventStream({required int viewId}) {
    return _unwrapEventStream<MapClickEvent>(viewId: viewId);
  }

  /// Get map long clicked event stream from the navigation view.
  Stream<MapLongClickEvent> getMapLongClickEventStream({required int viewId}) {
    return _unwrapEventStream<MapLongClickEvent>(viewId: viewId);
  }

  /// Get navigation view marker event stream from the navigation view.
  Stream<MarkerEvent> getMarkerEventStream({required int viewId}) {
    return _unwrapEventStream<MarkerEvent>(viewId: viewId);
  }

  /// Get navigation view marker drag event stream from the navigation view.
  Stream<MarkerDragEvent> getMarkerDragEventStream({required int viewId}) {
    return _unwrapEventStream<MarkerDragEvent>(viewId: viewId);
  }

  /// Get navigation view polygon clicked event stream from the navigation view.
  Stream<PolygonClickedEvent> getPolygonClickedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<PolygonClickedEvent>(viewId: viewId);
  }

  /// Get navigation view polyline clicked event stream from the navigation view.
  Stream<PolylineClickedEvent> getPolylineClickedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<PolylineClickedEvent>(viewId: viewId);
  }

  /// Get navigation view circle clicked event stream from the navigation view.
  Stream<CircleClickedEvent> getCircleClickedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<CircleClickedEvent>(viewId: viewId);
  }

  /// Get navigation UI changed event stream from the navigation view.
  Stream<NavigationUIEnabledChangedEvent>
      getNavigationUIEnabledChangedEventStream({required int viewId}) {
    return _unwrapEventStream<NavigationUIEnabledChangedEvent>(viewId: viewId);
  }

  /// Get navigation view my location clicked event stream from the navigation view.
  Stream<MyLocationClickedEvent> getMyLocationClickedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<MyLocationClickedEvent>(viewId: viewId);
  }

  /// Get navigation view my location button clicked event stream from the navigation view.
  Stream<MyLocationButtonClickedEvent> getMyLocationButtonClickedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<MyLocationButtonClickedEvent>(viewId: viewId);
  }

  /// Get navigation view camera changed event stream from the navigation view.
  Stream<CameraChangedEvent> getCameraChangedEventStream(
      {required int viewId}) {
    return _unwrapEventStream<CameraChangedEvent>(viewId: viewId);
  }
}

/// Implementation for navigation view event API event handling.
class ViewEventApiImpl implements ViewEventApi {
  /// Initialize implementation for NavigationViewEventApi.
  const ViewEventApiImpl({
    required StreamController<Object> viewEventStreamController,
  }) : _viewEventStreamController = viewEventStreamController;

  final StreamController<Object> _viewEventStreamController;

  @override
  void onRecenterButtonClicked(int viewId) {
    _viewEventStreamController.add(_ViewIdEventWrapper(
        viewId, NavigationViewRecenterButtonClickedEvent()));
  }

  @override
  void onMapClickEvent(int viewId, LatLngDto latLng) {
    _viewEventStreamController
        .add(_ViewIdEventWrapper(viewId, MapClickEvent(latLng.toLatLng())));
  }

  @override
  void onMapLongClickEvent(int viewId, LatLngDto latLng) {
    _viewEventStreamController
        .add(_ViewIdEventWrapper(viewId, MapLongClickEvent(latLng.toLatLng())));
  }

  @override
  void onMarkerDragEvent(int viewId, String markerId,
      MarkerDragEventTypeDto eventType, LatLngDto position) {
    //   _viewEventStreamController.add(_ViewIdEventWrapper(event.viewId, event));
  }

  @override
  void onMarkerEvent(
      int viewId, String markerId, MarkerEventTypeDto eventType) {
    _viewEventStreamController.add(_ViewIdEventWrapper(
        viewId,
        MarkerEvent(
            markerId: markerId, eventType: eventType.toMarkerEventType())));
  }

  @override
  void onPolygonClicked(int viewId, String polygonId) {
    _viewEventStreamController.add(
        _ViewIdEventWrapper(viewId, PolygonClickedEvent(polygonId: polygonId)));
  }

  @override
  void onPolylineClicked(int viewId, String polylineId) {
    _viewEventStreamController.add(_ViewIdEventWrapper(
        viewId, PolylineClickedEvent(polylineId: polylineId)));
  }

  @override
  void onCircleClicked(int viewId, String circleId) {
    _viewEventStreamController.add(
        _ViewIdEventWrapper(viewId, CircleClickedEvent(circleId: circleId)));
  }

  @override
  void onNavigationUIEnabledChanged(int viewId, bool enabled) {
    _viewEventStreamController.add(
        _ViewIdEventWrapper(viewId, NavigationUIEnabledChangedEvent(enabled)));
  }

  @override
  void onMyLocationClicked(int viewId) {
    _viewEventStreamController
        .add(_ViewIdEventWrapper(viewId, MyLocationClickedEvent()));
  }

  @override
  void onMyLocationButtonClicked(int viewId) {
    _viewEventStreamController
        .add(_ViewIdEventWrapper(viewId, MyLocationButtonClickedEvent()));
  }

  @override
  void onCameraChanged(
      int viewId, CameraEventTypeDto eventType, CameraPositionDto position) {
    _viewEventStreamController.add(_ViewIdEventWrapper(
        viewId,
        CameraChangedEvent(
            eventType: eventType.toCameraEventType(),
            position: position.toCameraPosition())));
  }
}

class _ViewIdEventWrapper {
  _ViewIdEventWrapper(this.viewId, this.event);

  final int viewId;
  final Object event;
}
