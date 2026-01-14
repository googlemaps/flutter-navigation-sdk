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
import 'package:meta/meta.dart';

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

  @visibleForTesting
  StreamController<Object> get viewEventStreamControllerForTesting =>
      _viewEventStreamController;

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
        .where(
          (_ViewIdEventWrapper wrapper) =>
              (wrapper.event is T) && wrapper.viewId == viewId,
        )
        .map<T>((_ViewIdEventWrapper wrapper) => wrapper.event as T);
  }

  /// This function ensures that the event API has been setup. This should be
  /// called when initializing navigation view.
  void ensureViewAPISetUp() {
    if (!_viewApiHasBeenSetUp) {
      ViewEventApi.setUp(
        ViewEventApiImpl(viewEventStreamController: _viewEventStreamController),
      );
      _viewApiHasBeenSetUp = true;
    }
  }

  /// Builds creation params used to initialize navigation view with initial parameters.
  ViewCreationOptionsDto buildPlatformViewCreationOptions(
    MapViewType mapViewType,
    MapViewInitializationOptions initializationSettings,
  ) {
    assert(
      mapViewType == MapViewType.navigation ||
          initializationSettings.navigationViewOptions == null,
      'Navigation view options can only be set when using navigation view type',
    );

    /// Map options
    final MapOptions mapOptions = initializationSettings.mapOptions;
    final CameraPosition cameraPosition = mapOptions.cameraPosition;
    final CameraPositionDto initialCameraPosition = CameraPositionDto(
      bearing: cameraPosition.bearing,
      target: LatLngDto(
        latitude: cameraPosition.target.latitude,
        longitude: cameraPosition.target.longitude,
      ),
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
              right: mapOptions.padding!.right.toInt(),
            )
          : null,
      mapId: mapOptions.mapId,
      mapColorScheme: mapOptions.mapColorScheme.toDto(),
    );

    // Initialize navigation view options if given
    final NavigationViewOptionsDto? navigationOptionsMessage =
        initializationSettings.navigationViewOptions?.toDto();

    // Build ViewCreationMessage
    return ViewCreationOptionsDto(
      mapViewType: mapViewType == MapViewType.navigation
          ? MapViewTypeDto.navigation
          : MapViewTypeDto.map,
      mapOptions: mapOptionsMessage,
      navigationViewOptions: navigationOptionsMessage,
    );
  }

  /// Awaits the platform view to be ready for communication.
  Future<void> awaitMapReady({required int viewId}) =>
      _viewApi.awaitMapReady(viewId).wrapPlatformException();

  /// Get the preference for whether the my location should be enabled or disabled.
  Future<bool> isMyLocationEnabled({required int viewId}) =>
      _viewApi.isMyLocationEnabled(viewId).wrapPlatformException();

  /// Enabled location in the navigation view.
  Future<void> setMyLocationEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setMyLocationEnabled(viewId, enabled).wrapPlatformException();

  /// Get the map type.
  Future<MapType> getMapType({required int viewId}) async {
    final MapTypeDto mapType = await _viewApi
        .getMapType(viewId)
        .wrapPlatformException();
    return mapType.toMapType();
  }

  /// Modified visible map type.
  Future<void> setMapType({required int viewId, required MapType mapType}) =>
      _viewApi.setMapType(viewId, mapType.toDto()).wrapPlatformException();

  /// Set map style by json string.
  Future<void> setMapStyle(int viewId, String? styleJson) =>
      // Set the given json to the viewApi or reset the map style if
      // the styleJson is null.
      _viewApi.setMapStyle(viewId, styleJson ?? '[]').wrapPlatformException();

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setMyLocationButtonEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setConsumeMyLocationButtonClickEventsEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabled({
    required int viewId,
    required bool enabled,
  }) =>
      _viewApi.setZoomGesturesEnabled(viewId, enabled).wrapPlatformException();

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabled({
    required int viewId,
    required bool enabled,
  }) =>
      _viewApi.setZoomControlsEnabled(viewId, enabled).wrapPlatformException();

  /// Enables or disables the compass.
  Future<void> setCompassEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setCompassEnabled(viewId, enabled).wrapPlatformException();

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setRotateGesturesEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setScrollGesturesEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setScrollGesturesDuringRotateOrZoomEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled({
    required int viewId,
    required bool enabled,
  }) =>
      _viewApi.setTiltGesturesEnabled(viewId, enabled).wrapPlatformException();

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setMapToolbarEnabled(viewId, enabled).wrapPlatformException();

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setTrafficEnabled(viewId, enabled).wrapPlatformException();

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabled({required int viewId}) =>
      _viewApi.isMyLocationButtonEnabled(viewId).wrapPlatformException();

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled({
    required int viewId,
  }) => _viewApi
      .isConsumeMyLocationButtonClickEventsEnabled(viewId)
      .wrapPlatformException();

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled({required int viewId}) =>
      _viewApi.isZoomGesturesEnabled(viewId).wrapPlatformException();

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabled({required int viewId}) =>
      _viewApi.isZoomControlsEnabled(viewId).wrapPlatformException();

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled({required int viewId}) =>
      _viewApi.isCompassEnabled(viewId).wrapPlatformException();

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled({required int viewId}) =>
      _viewApi.isRotateGesturesEnabled(viewId).wrapPlatformException();

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled({required int viewId}) =>
      _viewApi.isScrollGesturesEnabled(viewId).wrapPlatformException();

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom({
    required int viewId,
  }) => _viewApi
      .isScrollGesturesEnabledDuringRotateOrZoom(viewId)
      .wrapPlatformException();

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled({required int viewId}) =>
      _viewApi.isTiltGesturesEnabled(viewId).wrapPlatformException();

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabled({required int viewId}) =>
      _viewApi.isMapToolbarEnabled(viewId).wrapPlatformException();

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled({required int viewId}) =>
      _viewApi.isTrafficEnabled(viewId).wrapPlatformException();

  /// Gets users current location.
  Future<LatLng?> getMyLocation({required int viewId}) async {
    final LatLngDto? myLocation = await _viewApi
        .getMyLocation(viewId)
        .wrapPlatformException();
    return myLocation?.toLatLng();
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition({required int viewId}) async {
    final CameraPositionDto position = await _viewApi
        .getCameraPosition(viewId)
        .wrapPlatformException();
    return position.toCameraPosition();
  }

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegion({required int viewId}) async {
    final LatLngBoundsDto bounds = await _viewApi
        .getVisibleRegion(viewId)
        .wrapPlatformException();
    return LatLngBounds(
      southwest: bounds.southwest.toLatLng(),
      northeast: bounds.northeast.toLatLng(),
    );
  }

  /// Converts geographic coordinates to screen pixel coordinates.
  Future<ScreenCoordinate> getScreenCoordinate({
    required int viewId,
    required LatLng latLng,
  }) async {
    final ScreenCoordinateDto screenCoordinate = await _viewApi
        .getScreenCoordinate(viewId, latLng.toDto());
    return screenCoordinate.toScreenCoordinate();
  }

  /// Converts screen pixel coordinates to geographic coordinates.
  Future<LatLng> getLatLng({
    required int viewId,
    required ScreenCoordinate screenCoordinate,
  }) async {
    final LatLngDto latLng = await _viewApi.getLatLng(
      viewId,
      screenCoordinate.toDto(),
    );
    return latLng.toLatLng();
  }

  /// Animates the movement of the camera.
  Future<void> animateCamera({
    required int viewId,
    required CameraUpdate cameraUpdate,
    required int? duration,
    AnimationFinishedCallback? onFinished,
  }) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        unawaited(
          _viewApi
              .animateCameraToCameraPosition(
                viewId,
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
              .animateCameraToLatLng(
                viewId,
                cameraUpdate.latLng!.toDto(),
                duration,
              )
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
                viewId,
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
                viewId,
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
                viewId,
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
                viewId,
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
              .animateCameraToZoom(viewId, cameraUpdate.zoom!, duration)
              .then(
                (bool success) => onFinished != null && Platform.isAndroid
                    ? onFinished(success)
                    : null,
              ),
        );
    }
  }

  /// Moves the camera.
  Future<void> moveCamera({
    required int viewId,
    required CameraUpdate cameraUpdate,
  }) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        assert(cameraUpdate.cameraPosition != null, 'Camera position is null');
        return _viewApi.moveCameraToCameraPosition(
          viewId,
          cameraUpdate.cameraPosition!.toCameraPosition(),
        );
      case CameraUpdateType.latLng:
        return _viewApi.moveCameraToLatLng(
          viewId,
          cameraUpdate.latLng!.toDto(),
        );
      case CameraUpdateType.latLngBounds:
        assert(cameraUpdate.padding != null, 'Camera position is null');
        return _viewApi.moveCameraToLatLngBounds(
          viewId,
          cameraUpdate.bounds!.toDto(),
          cameraUpdate.padding!,
        );
      case CameraUpdateType.latLngZoom:
        return _viewApi.moveCameraToLatLngZoom(
          viewId,
          cameraUpdate.latLng!.toDto(),
          cameraUpdate.zoom!,
        );
      case CameraUpdateType.scrollBy:
        return _viewApi.moveCameraByScroll(
          viewId,
          cameraUpdate.scrollByDx!,
          cameraUpdate.scrollByDy!,
        );
      case CameraUpdateType.zoomBy:
        return _viewApi.moveCameraByZoom(
          viewId,
          cameraUpdate.zoomByAmount!,
          cameraUpdate.focus?.dx,
          cameraUpdate.focus?.dy,
        );
      case CameraUpdateType.zoomTo:
        return _viewApi.moveCameraToZoom(viewId, cameraUpdate.zoom!);
    }
  }

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocation({
    required int viewId,
    required CameraPerspective perspective,
    required double? zoomLevel,
  }) => _viewApi
      .followMyLocation(viewId, perspective.toDto(), zoomLevel)
      .wrapPlatformException();

  /// Checks if the navigation trip progress bar is enabled.
  Future<bool> isNavigationTripProgressBarEnabled({required int viewId}) =>
      _viewApi
          .isNavigationTripProgressBarEnabled(viewId)
          .wrapPlatformException();

  /// Enable navigation trip progress bar.
  Future<void> setNavigationTripProgressBarEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setNavigationTripProgressBarEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the navigation header is enabled.
  Future<bool> isNavigationHeaderEnabled({required int viewId}) =>
      _viewApi.isNavigationHeaderEnabled(viewId).wrapPlatformException();

  /// Enable navigation header.
  Future<void> setNavigationHeaderEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setNavigationHeaderEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the navigation footer is enabled.
  Future<bool> isNavigationFooterEnabled({required int viewId}) =>
      _viewApi.isNavigationFooterEnabled(viewId).wrapPlatformException();

  /// Enable the navigation footer.
  Future<void> setNavigationFooterEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setNavigationFooterEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the recenter button is enabled.
  Future<bool> isRecenterButtonEnabled({required int viewId}) =>
      _viewApi.isRecenterButtonEnabled(viewId).wrapPlatformException();

  /// Enable the recenter button.
  Future<void> setRecenterButtonEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setRecenterButtonEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the speed limit icon is displayed.
  Future<bool> isSpeedLimitIconEnabled({required int viewId}) =>
      _viewApi.isSpeedLimitIconEnabled(viewId).wrapPlatformException();

  /// Should display speed limit.
  Future<void> setSpeedLimitIconEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setSpeedLimitIconEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the speedometer is displayed.
  Future<bool> isSpeedometerEnabled({required int viewId}) =>
      _viewApi.isSpeedometerEnabled(viewId).wrapPlatformException();

  /// Should display speedometer.
  Future<void> setSpeedometerEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setSpeedometerEnabled(viewId, enabled).wrapPlatformException();

  /// Checks if incident cards are displayed.
  Future<bool> isTrafficIncidentCardsEnabled({required int viewId}) =>
      _viewApi.isTrafficIncidentCardsEnabled(viewId).wrapPlatformException();

  /// Should display incident cards.
  Future<void> setTrafficIncidentCardsEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setTrafficIncidentCardsEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if the report incident button is displayed.
  Future<bool> isReportIncidentButtonEnabled({required int viewId}) =>
      _viewApi.isReportIncidentButtonEnabled(viewId).wrapPlatformException();

  /// Should display the report incident button.
  Future<void> setReportIncidentButtonEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setReportIncidentButtonEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if incident reporting is currently available.
  @experimental
  Future<bool> isIncidentReportingAvailable({required int viewId}) =>
      _viewApi.isIncidentReportingAvailable(viewId).wrapPlatformException();

  /// Presents a panel allowing users to report an incident.
  @experimental
  Future<void> showReportIncidentsPanel({required int viewId}) =>
      _viewApi.showReportIncidentsPanel(viewId).wrapPlatformException();

  /// Checks if 3D buildings layer is enabled.
  Future<bool> isBuildingsEnabled({required int viewId}) =>
      _viewApi.isBuildingsEnabled(viewId).wrapPlatformException();

  /// Turns the 3D buildings layer on or off.
  Future<void> setBuildingsEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi.setBuildingsEnabled(viewId, enabled).wrapPlatformException();

  /// Are the traffic prompts displayed.
  Future<bool> isTrafficPromptsEnabled({required int viewId}) =>
      _viewApi.isTrafficPromptsEnabled(viewId).wrapPlatformException();

  /// Should display the traffic prompts..
  Future<void> setTrafficPromptsEnabled({
    required int viewId,
    required bool enabled,
  }) => _viewApi
      .setTrafficPromptsEnabled(viewId, enabled)
      .wrapPlatformException();

  /// Checks if navigation UI is enabled.
  Future<bool> isNavigationUIEnabled({required int viewId}) =>
      _viewApi.isNavigationUIEnabled(viewId).wrapPlatformException();

  /// Enable navigation UI.
  Future<void> setNavigationUIEnabled({
    required int viewId,
    required bool enabled,
  }) =>
      _viewApi.setNavigationUIEnabled(viewId, enabled).wrapPlatformException();

  /// Show route overview.
  Future<void> showRouteOverview({required int viewId}) =>
      _viewApi.showRouteOverview(viewId).wrapPlatformException();

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreference({required int viewId}) =>
      _viewApi.getMinZoomPreference(viewId).wrapPlatformException();

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreference({required int viewId}) =>
      _viewApi.getMaxZoomPreference(viewId).wrapPlatformException();

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference({required int viewId}) =>
      _viewApi.resetMinMaxZoomPreference(viewId).wrapPlatformException();

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreference({
    required int viewId,
    required double minZoomPreference,
  }) => _viewApi
      .setMinZoomPreference(viewId, minZoomPreference)
      .wrapPlatformException();

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreference({
    required int viewId,
    required double maxZoomPreference,
  }) => _viewApi
      .setMaxZoomPreference(viewId, maxZoomPreference)
      .wrapPlatformException();

  /// Get navigation recenter button clicked event stream from the navigation view.
  Stream<NavigationViewRecenterButtonClickedEvent>
  getNavigationRecenterButtonClickedEventStream({required int viewId}) {
    return _unwrapEventStream<NavigationViewRecenterButtonClickedEvent>(
      viewId: viewId,
    );
  }

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers({required int viewId}) async {
    final List<MarkerDto?> markers = await _viewApi
        .getMarkers(viewId)
        .wrapPlatformException();
    return markers
        .whereType<MarkerDto>()
        .map((MarkerDto e) => e.toMarker())
        .toList();
  }

  /// Add markers to map view.
  Future<List<Marker>> addMarkers({
    required int viewId,
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
        .addMarkers(viewId, markersToAdd)
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
  Future<List<Marker>> updateMarkers({
    required int viewId,
    required List<Marker> markers,
  }) async {
    final List<MarkerDto> markerDtos = markers
        .map((Marker marker) => marker.toDto())
        .toList();
    final List<MarkerDto?> updatedMarkers = await _viewApi
        .updateMarkers(viewId, markerDtos)
        .wrapPlatformException();
    return updatedMarkers
        .whereType<MarkerDto>()
        .map((MarkerDto markerDto) => markerDto.toMarker())
        .toList();
  }

  /// Remove markers from map view.
  Future<void> removeMarkers({
    required int viewId,
    required List<Marker> markers,
  }) {
    final List<MarkerDto> markerDtos = markers
        .map((Marker marker) => marker.toDto())
        .toList();
    return _viewApi.removeMarkers(viewId, markerDtos).wrapPlatformException();
  }

  /// Remove all markers from map view.
  Future<void> clearMarkers({required int viewId}) =>
      _viewApi.clearMarkers(viewId).wrapPlatformException();

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear({required int viewId}) =>
      _viewApi.clear(viewId).wrapPlatformException();

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons({required int viewId}) async {
    final List<PolygonDto?> polygons = await _viewApi
        .getPolygons(viewId)
        .wrapPlatformException();
    return polygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons({
    required int viewId,
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
        .addPolygons(viewId, polygonsToAdd)
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
    required int viewId,
    required List<Polygon> polygons,
  }) async {
    final List<PolygonDto> navigationViewPolygons = polygons
        .map((Polygon polygon) => polygon.toDto())
        .toList();
    final List<PolygonDto?> updatedPolygons = await _viewApi
        .updatePolygons(viewId, navigationViewPolygons)
        .wrapPlatformException();
    return updatedPolygons
        .whereType<PolygonDto>()
        .map((PolygonDto polygon) => polygon.toPolygon())
        .toList();
  }

  /// Remove polygons from map view.
  Future<void> removePolygons({
    required int viewId,
    required List<Polygon> polygons,
  }) {
    final List<PolygonDto> navigationViewPolygons = polygons
        .map((Polygon polygon) => polygon.toDto())
        .toList();
    return _viewApi
        .removePolygons(viewId, navigationViewPolygons)
        .wrapPlatformException();
  }

  /// Remove all polygons from map view.
  Future<void> clearPolygons({required int viewId}) =>
      _viewApi.clearPolygons(viewId).wrapPlatformException();

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines({required int viewId}) async {
    final List<PolylineDto?> polylines = await _viewApi
        .getPolylines(viewId)
        .wrapPlatformException();
    return polylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines({
    required int viewId,
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
        .addPolylines(viewId, polylinesToAdd)
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
    required int viewId,
    required List<Polyline> polylines,
  }) async {
    final List<PolylineDto> navigationViewPolylines = polylines
        .map((Polyline polyline) => polyline.toNavigationViewPolyline())
        .toList();
    final List<PolylineDto?> updatedPolylines = await _viewApi
        .updatePolylines(viewId, navigationViewPolylines)
        .wrapPlatformException();
    return updatedPolylines
        .whereType<PolylineDto>()
        .map((PolylineDto polyline) => polyline.toPolyline())
        .toList();
  }

  /// Remove polylines from map view.
  Future<void> removePolylines({
    required int viewId,
    required List<Polyline> polylines,
  }) {
    final List<PolylineDto> navigationViewPolylines = polylines
        .map((Polyline polyline) => polyline.toNavigationViewPolyline())
        .toList();
    return _viewApi
        .removePolylines(viewId, navigationViewPolylines)
        .wrapPlatformException();
  }

  /// Remove all polylines from map view.
  Future<void> clearPolylines({required int viewId}) =>
      _viewApi.clearPolylines(viewId).wrapPlatformException();

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles({required int viewId}) async {
    final List<CircleDto?> circles = await _viewApi
        .getCircles(viewId)
        .wrapPlatformException();
    return circles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Add circles to map view.
  Future<List<Circle?>> addCircles({
    required int viewId,
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
        .addCircles(viewId, circlesToAdd)
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
  Future<List<Circle?>> updateCircles({
    required int viewId,
    required List<Circle> circles,
  }) async {
    final List<CircleDto> navigationViewCircles = circles
        .map((Circle circle) => circle.toDto())
        .toList();
    final List<CircleDto?> updatedCircles = await _viewApi
        .updateCircles(viewId, navigationViewCircles)
        .wrapPlatformException();

    return updatedCircles
        .whereType<CircleDto>()
        .map((CircleDto circle) => circle.toCircle())
        .toList();
  }

  /// Remove circles from map view.
  Future<void> removeCircles({
    required int viewId,
    required List<Circle> circles,
  }) {
    final List<CircleDto> navigationViewCircles = circles
        .map((Circle circle) => circle.toDto())
        .toList();
    return _viewApi
        .removeCircles(viewId, navigationViewCircles)
        .wrapPlatformException();
  }

  /// Remove all circles from map view.
  Future<void> clearCircles({required int viewId}) =>
      _viewApi.clearCircles(viewId).wrapPlatformException();

  /// Register camera changed listeners.
  Future<void> enableOnCameraChangedEvents({required int viewId}) =>
      _viewApi.enableOnCameraChangedEvents(viewId).wrapPlatformException();

  Future<void> setPadding({required int viewId, required EdgeInsets padding}) =>
      _viewApi
          .setPadding(
            viewId,
            MapPaddingDto(
              top: padding.top.toInt(),
              left: padding.left.toInt(),
              bottom: padding.bottom.toInt(),
              right: padding.right.toInt(),
            ),
          )
          .wrapPlatformException();

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding({required int viewId}) async {
    final MapPaddingDto padding = await _viewApi
        .getPadding(viewId)
        .wrapPlatformException();
    return EdgeInsets.only(
      top: padding.top.toDouble(),
      left: padding.left.toDouble(),
      bottom: padding.bottom.toDouble(),
      right: padding.right.toDouble(),
    );
  }

  /// Gets the current map color scheme from the map view.
  Future<MapColorScheme> getMapColorScheme({required int viewId}) async {
    final MapColorSchemeDto colorScheme = await _viewApi
        .getMapColorScheme(viewId)
        .wrapPlatformException();
    return colorScheme.toMapColorScheme();
  }

  /// Sets the map color scheme for the map view.
  Future<void> setMapColorScheme({
    required int viewId,
    required MapColorScheme mapColorScheme,
  }) => _viewApi
      .setMapColorScheme(viewId, mapColorScheme.toDto())
      .wrapPlatformException();

  /// Gets the current force night mode from the navigation view.
  Future<NavigationForceNightMode> getForceNightMode({
    required int viewId,
  }) async {
    final NavigationForceNightModeDto forceNightMode = await _viewApi
        .getForceNightMode(viewId)
        .wrapPlatformException();
    return forceNightMode.toNavigationForceNightMode();
  }

  /// Sets the force night mode for the navigation view.
  Future<void> setForceNightMode({
    required int viewId,
    required NavigationForceNightMode forceNightMode,
  }) => _viewApi
      .setForceNightMode(viewId, forceNightMode.toDto())
      .wrapPlatformException();

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
  Stream<PolygonClickedEvent> getPolygonClickedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<PolygonClickedEvent>(viewId: viewId);
  }

  /// Get navigation view polyline clicked event stream from the navigation view.
  Stream<PolylineClickedEvent> getPolylineClickedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<PolylineClickedEvent>(viewId: viewId);
  }

  /// Get navigation view circle clicked event stream from the navigation view.
  Stream<CircleClickedEvent> getCircleClickedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<CircleClickedEvent>(viewId: viewId);
  }

  /// Get POI (Point of Interest) clicked event stream from the map view.
  Stream<PoiClickedEvent> getPoiClickedEventStream({required int viewId}) {
    return _unwrapEventStream<PoiClickedEvent>(viewId: viewId);
  }

  /// Get navigation UI changed event stream from the navigation view.
  Stream<NavigationUIEnabledChangedEvent>
  getNavigationUIEnabledChangedEventStream({required int viewId}) {
    return _unwrapEventStream<NavigationUIEnabledChangedEvent>(viewId: viewId);
  }

  /// Get prompt visibility changed event stream from the navigation view.
  Stream<PromptVisibilityChangedEvent> getPromptVisibilityChangedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<PromptVisibilityChangedEvent>(viewId: viewId);
  }

  /// Get navigation view my location clicked event stream from the navigation view.
  Stream<MyLocationClickedEvent> getMyLocationClickedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<MyLocationClickedEvent>(viewId: viewId);
  }

  /// Get navigation view my location button clicked event stream from the navigation view.
  Stream<MyLocationButtonClickedEvent> getMyLocationButtonClickedEventStream({
    required int viewId,
  }) {
    return _unwrapEventStream<MyLocationButtonClickedEvent>(viewId: viewId);
  }

  /// Get navigation view camera changed event stream from the navigation view.
  Stream<CameraChangedEvent> getCameraChangedEventStream({
    required int viewId,
  }) {
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
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, NavigationViewRecenterButtonClickedEvent()),
    );
  }

  @override
  void onMapClickEvent(int viewId, LatLngDto latLng) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, MapClickEvent(latLng.toLatLng())),
    );
  }

  @override
  void onMapLongClickEvent(int viewId, LatLngDto latLng) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, MapLongClickEvent(latLng.toLatLng())),
    );
  }

  @override
  void onMarkerDragEvent(
    int viewId,
    String markerId,
    MarkerDragEventTypeDto eventType,
    LatLngDto position,
  ) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(
        viewId,
        MarkerDragEvent(
          markerId: markerId,
          eventType: eventType.toMarkerDragEventType(),
          position: position.toLatLng(),
        ),
      ),
    );
  }

  @override
  void onMarkerEvent(
    int viewId,
    String markerId,
    MarkerEventTypeDto eventType,
  ) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(
        viewId,
        MarkerEvent(
          markerId: markerId,
          eventType: eventType.toMarkerEventType(),
        ),
      ),
    );
  }

  @override
  void onPolygonClicked(int viewId, String polygonId) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, PolygonClickedEvent(polygonId: polygonId)),
    );
  }

  @override
  void onPolylineClicked(int viewId, String polylineId) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, PolylineClickedEvent(polylineId: polylineId)),
    );
  }

  @override
  void onCircleClicked(int viewId, String circleId) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, CircleClickedEvent(circleId: circleId)),
    );
  }

  @override
  void onPoiClick(int viewId, PointOfInterestDto pointOfInterest) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(
        viewId,
        PoiClickedEvent(pointOfInterest: pointOfInterest.toPointOfInterest()),
      ),
    );
  }

  @override
  void onNavigationUIEnabledChanged(int viewId, bool enabled) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, NavigationUIEnabledChangedEvent(enabled)),
    );
  }

  @override
  void onPromptVisibilityChanged(int viewId, bool promptVisible) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, PromptVisibilityChangedEvent(promptVisible)),
    );
  }

  @override
  void onMyLocationClicked(int viewId) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, MyLocationClickedEvent()),
    );
  }

  @override
  void onMyLocationButtonClicked(int viewId) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(viewId, MyLocationButtonClickedEvent()),
    );
  }

  @override
  void onCameraChanged(
    int viewId,
    CameraEventTypeDto eventType,
    CameraPositionDto position,
  ) {
    _viewEventStreamController.add(
      _ViewIdEventWrapper(
        viewId,
        CameraChangedEvent(
          eventType: eventType.toCameraEventType(),
          position: position.toCameraPosition(),
        ),
      ),
    );
  }
}

/// @nodoc
class _ViewIdEventWrapper {
  _ViewIdEventWrapper(this.viewId, this.event);

  final int viewId;
  final Object event;
}
