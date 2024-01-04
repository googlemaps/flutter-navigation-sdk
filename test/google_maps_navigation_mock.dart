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
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_navigation/google_maps_navigation.dart';
import 'package:google_maps_navigation/src/google_maps_navigation_platform_interface.dart';
import 'package:google_maps_navigation/src/method_channel/convert/navigation_waypoint.dart';
import 'package:google_maps_navigation/src/method_channel/method_channel.dart';
import 'package:mockito/mockito.dart';

import 'google_maps_navigation_test.mocks.dart';

class NavigationSessionEventSubscription extends Mock
    implements StreamSubscription<NavigationSessionEvent> {}

class NavigationSessionEventStream extends Mock
    implements Stream<NavigationSessionEvent> {
  @override
  StreamSubscription<NavigationSessionEvent> listen(
      void Function(NavigationSessionEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return NavigationSessionEventSubscription();
  }
}

class NavigationViewMarkerEventSubscription extends Mock
    implements StreamSubscription<MarkerEvent> {}

class NavigationViewMarkerEventStream extends Mock
    implements Stream<MarkerEvent> {
  @override
  StreamSubscription<MarkerEvent> listen(
      void Function(MarkerEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return NavigationViewMarkerEventSubscription();
  }
}

class NavigationViewMarkerDragEventSubscription extends Mock
    implements StreamSubscription<MarkerDragEvent> {}

class NavigationViewMarkerDragEventStream extends Mock
    implements Stream<MarkerDragEvent> {
  @override
  StreamSubscription<MarkerDragEvent> listen(
      void Function(MarkerDragEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return NavigationViewMarkerDragEventSubscription();
  }
}

class PolygonDtoClickedEventSubscription extends Mock
    implements StreamSubscription<PolygonClickedEvent> {}

class PolygonDtoClickedEventStream extends Mock
    implements Stream<PolygonClickedEvent> {
  @override
  StreamSubscription<PolygonClickedEvent> listen(
      void Function(PolygonClickedEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return PolygonDtoClickedEventSubscription();
  }
}

class NavigationViewPolylineClickedEventSubscription extends Mock
    implements StreamSubscription<PolylineClickedEvent> {}

class NavigationViewPolylineClickedEventStream extends Mock
    implements Stream<PolylineClickedEvent> {
  @override
  StreamSubscription<PolylineClickedEvent> listen(
      void Function(PolylineClickedEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return NavigationViewPolylineClickedEventSubscription();
  }
}

class CircleDtoClickedEventSubscription extends Mock
    implements StreamSubscription<CircleClickedEvent> {}

class CircleDtoClickedEventStream extends Mock
    implements Stream<CircleClickedEvent> {
  @override
  StreamSubscription<CircleClickedEvent> listen(
      void Function(CircleClickedEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return CircleDtoClickedEventSubscription();
  }
}

class MockGoogleMapsNavigationPlatform extends GoogleMapsNavigationPlatform {
  MockGoogleMapsNavigationPlatform(
      {required this.sessionApi,
      required this.viewApi,
      required this.imageRegistryApi});
  final MockTestNavigationSessionApi sessionApi;
  final MockTestNavigationViewApi viewApi;
  final MockTestImageRegistryApi imageRegistryApi;

  @override
  Widget buildView(
      {required NavigationViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady}) {
    return const Text('Navigation');
  }

  @override
  Future<void> createNavigationSession(
      bool abnormalTerminationReportingEnabled) {
    return sessionApi
        .createNavigationSession(abnormalTerminationReportingEnabled);
  }

  @override
  Future<bool> isInitialized() async {
    return sessionApi.isInitialized();
  }

  @override
  Future<void> cleanup() async {
    return sessionApi.cleanup();
  }

  @override
  Stream<NavigationSessionEvent> getNavigationSessionEventStream() {
    return NavigationSessionEventStream();
  }

  @override
  Future<bool> areTermsAccepted() async {
    return sessionApi.areTermsAccepted();
  }

  @override
  Future<void> resetTermsAccepted() async {
    sessionApi.resetTermsAccepted();
  }

  @override
  Future<String> getNavSDKVersion() async {
    return sessionApi.getNavSDKVersion();
  }

  @override
  Future<void> setMapType({required int viewId, required MapType mapType}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setMapStyle(int viewId, String? styleJson) async {
    return viewApi.setMapStyle(viewId, styleJson ?? '[]');
  }

  @override
  Future<CameraPosition> getCameraPosition({required int viewId}) async {
    final CameraPositionDto position = viewApi.getCameraPosition(viewId);
    return position.toCameraPosition();
  }

  @override
  Future<LatLngBounds> getVisibleRegion({required int viewId}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> animateCamera(
      {required int viewId,
      required CameraUpdate cameraUpdate,
      required int? duration,
      AnimationFinishedCallback? onFinished}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        unawaited(viewApi
            .animateCameraToCameraPosition(viewId,
                cameraUpdate.cameraPosition!.toCameraPosition(), duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.latLng:
        unawaited(viewApi
            .animateCameraToLatLng(
                viewId, cameraUpdate.latLng!.toDto(), duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.latLngBounds:
        unawaited(viewApi
            .animateCameraToLatLngBounds(viewId, cameraUpdate.bounds!.toDto(),
                cameraUpdate.padding, duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.latLngZoom:
        unawaited(viewApi
            .animateCameraToLatLngZoom(viewId, cameraUpdate.latLng!.toDto(),
                cameraUpdate.zoom, duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.scrollBy:
        unawaited(viewApi
            .animateCameraByScroll(viewId, cameraUpdate.scrollByDx,
                cameraUpdate.scrollByDy, duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.zoomBy:
        unawaited(viewApi
            .animateCameraByZoom(viewId, cameraUpdate.zoomByAmount,
                cameraUpdate.focus?.dx, cameraUpdate.focus?.dy, duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
      case CameraUpdateType.zoomTo:
        return unawaited(viewApi
            .animateCameraToZoom(viewId, cameraUpdate.zoom, duration)
            .then((bool success) =>
                onFinished != null ? onFinished(success) : null));
    }
  }

  @override
  Future<void> moveCamera(
      {required int viewId, required CameraUpdate cameraUpdate}) async {
    switch (cameraUpdate.type) {
      case CameraUpdateType.cameraPosition:
        return viewApi.moveCameraToCameraPosition(
            viewId, cameraUpdate.cameraPosition!.toCameraPosition());
      case CameraUpdateType.latLng:
        return viewApi.moveCameraToLatLng(viewId, cameraUpdate.latLng!.toDto());
      case CameraUpdateType.latLngBounds:
        return viewApi.moveCameraToLatLngBounds(
            viewId, cameraUpdate.bounds!.toDto(), cameraUpdate.padding);
      case CameraUpdateType.latLngZoom:
        return viewApi.moveCameraToLatLngZoom(
            viewId, cameraUpdate.latLng!.toDto(), cameraUpdate.zoom);
      case CameraUpdateType.scrollBy:
        return viewApi.moveCameraByScroll(
            viewId, cameraUpdate.scrollByDx, cameraUpdate.scrollByDy);
      case CameraUpdateType.zoomBy:
        return viewApi.moveCameraByZoom(viewId, cameraUpdate.zoomByAmount,
            cameraUpdate.focus?.dx, cameraUpdate.focus?.dy);
      case CameraUpdateType.zoomTo:
        return viewApi.moveCameraToZoom(viewId, cameraUpdate.zoom);
    }
  }

  @override
  Future<void> followMyLocation(
      {required int viewId,
      required CameraPerspective perspective,
      required double? zoomLevel}) async {
    return viewApi.followMyLocation(viewId, perspective.toDto(), zoomLevel);
  }

  @override
  Future<void> setMyLocationEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setMyLocationEnabled(viewId, enabled);
  }

  @override
  Future<void> setMyLocationButtonEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setMyLocationButtonEnabled(viewId, enabled);
  }

  @override
  Future<void> setZoomGesturesEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setZoomGesturesEnabled(viewId, enabled);
  }

  @override
  Future<void> setZoomControlsEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setZoomControlsEnabled(viewId, enabled);
  }

  @override
  Future<void> setCompassEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setCompassEnabled(viewId, enabled);
  }

  @override
  Future<void> setRotateGesturesEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setRotateGesturesEnabled(viewId, enabled);
  }

  @override
  Future<void> setScrollGesturesEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setScrollGesturesEnabled(viewId, enabled);
  }

  @override
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setScrollGesturesDuringRotateOrZoomEnabled(viewId, enabled);
  }

  @override
  Future<void> setTiltGesturesEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setTiltGesturesEnabled(viewId, enabled);
  }

  @override
  Future<void> setMapToolbarEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setMapToolbarEnabled(viewId, enabled);
  }

  @override
  Future<void> setTrafficEnabled(
      {required int viewId, required bool enabled}) async {
    return viewApi.setTrafficEnabled(viewId, enabled);
  }

  @override
  Future<bool> isMyLocationEnabled({required int viewId}) async {
    return viewApi.isMyLocationEnabled(viewId);
  }

  @override
  Future<bool> isMyLocationButtonEnabled({required int viewId}) async {
    return viewApi.isMyLocationButtonEnabled(viewId);
  }

  @override
  Future<bool> isZoomGesturesEnabled({required int viewId}) async {
    return viewApi.isZoomGesturesEnabled(viewId);
  }

  @override
  Future<bool> isZoomControlsEnabled({required int viewId}) async {
    return viewApi.isZoomControlsEnabled(viewId);
  }

  @override
  Future<bool> isCompassEnabled({required int viewId}) async {
    return viewApi.isCompassEnabled(viewId);
  }

  @override
  Future<bool> isRotateGesturesEnabled({required int viewId}) async {
    return viewApi.isRotateGesturesEnabled(viewId);
  }

  @override
  Future<bool> isScrollGesturesEnabled({required int viewId}) async {
    return viewApi.isScrollGesturesEnabled(viewId);
  }

  @override
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom(
      {required int viewId}) async {
    return viewApi.isScrollGesturesEnabledDuringRotateOrZoom(viewId);
  }

  @override
  Future<bool> isTiltGesturesEnabled({required int viewId}) async {
    return viewApi.isTiltGesturesEnabled(viewId);
  }

  @override
  Future<bool> isMapToolbarEnabled({required int viewId}) async {
    return viewApi.isMapToolbarEnabled(viewId);
  }

  @override
  Future<bool> isTrafficEnabled({required int viewId}) async {
    return viewApi.isTrafficEnabled(viewId);
  }

  @override
  Future<bool> showTermsAndConditionsDialog(String title, String companyName,
      bool shouldOnlyShowDriverAwarenessDisclaimer) {
    return sessionApi.showTermsAndConditionsDialog(
        title, companyName, shouldOnlyShowDriverAwarenessDisclaimer);
  }

  @override
  Future<void> clearDestinations() async {
    sessionApi.clearDestinations();
  }

  @override
  Future<NavigationWaypoint?> continueToNextDestination() async {
    final NavigationWaypointDto? waypoint =
        sessionApi.continueToNextDestination();
    if (waypoint == null) {
      return null;
    }
    return waypoint.toNavigationWaypoint();
  }

  @override
  Future<NavigationTimeAndDistance> getCurrentTimeAndDistance() async {
    final NavigationTimeAndDistanceDto timeAndDistance =
        sessionApi.getCurrentTimeAndDistance();
    return timeAndDistance.toNavigationTimeAndDistance();
  }

  @override
  Future<void> setAudioGuidance(
      NavigationAudioGuidanceSettings settings) async {
    return sessionApi.setAudioGuidance(settings.toDto());
  }

  @override
  Future<NavigationRouteStatus> setDestinations(Destinations msg) async {
    final RouteStatusDto status = await sessionApi.setDestinations(msg.toDto());
    return status.toNavigationRouteStatus();
  }

  @override
  Future<void> startGuidance() async {
    return sessionApi.startGuidance();
  }

  @override
  Future<void> stopGuidance() async {
    return sessionApi.stopGuidance();
  }

  @override
  Future<void> simulateLocationsAlongExistingRoute() async {
    return sessionApi.simulateLocationsAlongExistingRoute();
  }

  @override
  Future<void> allowBackgroundLocationUpdates(bool allow) async {
    return sessionApi.allowBackgroundLocationUpdates(allow);
  }

  @override
  Stream<RoadSnappedLocationUpdatedEvent>
      getNavigationRoadSnappedLocationEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<SpeedingUpdatedEvent> getNavigationSpeedingEventStream() {
    throw UnimplementedError();
  }

  @override
  Future<void> pauseSimulation() async {
    return sessionApi.pauseSimulation();
  }

  @override
  Future<void> resumeSimulation() async {
    return sessionApi.resumeSimulation();
  }

  @override
  Future<void> setUserLocation(LatLng location) async {
    return sessionApi.setUserLocation(location.toDto());
  }

  @override
  Future<void> simulateLocationsAlongExistingRouteWithOptions(
      SimulationOptions options) async {
    return sessionApi.simulateLocationsAlongExistingRouteWithOptions(
        simulationOptionsToDto(options));
  }

  @override
  Future<NavigationRouteStatus> simulateLocationsAlongNewRoute(
      List<NavigationWaypoint> waypoints) async {
    final RouteStatusDto routeStatus =
        await sessionApi.simulateLocationsAlongNewRoute(waypoints.map(
      (NavigationWaypoint e) {
        return e.toDto();
      },
    ).toList());
    return routeStatus.toNavigationRouteStatus();
  }

  @override
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
          List<NavigationWaypoint> waypoints,
          RoutingOptions routingOptions,
          SimulationOptions simulationOptions) async {
    final RouteStatusDto routeStatus = await sessionApi
        .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
      waypoints.map(
        (NavigationWaypoint e) {
          return e.toDto();
        },
      ).toList(),
      routingOptions.toDto(),
      simulationOptionsToDto(simulationOptions),
    );
    return routeStatus.toNavigationRouteStatus();
  }

  @override
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingOptions(
          List<NavigationWaypoint> waypoints,
          RoutingOptions routingOptions) async {
    final RouteStatusDto routeStatus =
        await sessionApi.simulateLocationsAlongNewRouteWithRoutingOptions(
      waypoints.map(
        (NavigationWaypoint e) {
          return e.toDto();
        },
      ).toList(),
      routingOptions.toDto(),
    );
    return routeStatus.toNavigationRouteStatus();
  }

  @override
  Future<void> removeUserLocation() async {
    return sessionApi.removeUserLocation();
  }

  @override
  Stream<OnArrivalEvent> getNavigationOnArrivalEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<void> getNavigationOnReroutingEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<void> getNavigationOnRouteChangedEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<RemainingTimeOrDistanceChangedEvent>
      getNavigationRemainingTimeOrDistanceChangedEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<void> getNavigationTrafficUpdatedEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<RoadSnappedRawLocationUpdatedEvent>
      getNavigationRoadSnappedRawLocationEventStream() {
    throw UnimplementedError();
  }

  @override
  Stream<NavigationViewRecenterButtonClickedEvent>
      getNavigationRecenterButtonClickedEventStream({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setNavigationFooterEnabled(
      {required int viewId, required bool enabled}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setNavigationHeaderEnabled(
      {required int viewId, required bool enabled}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setNavigationTripProgressBarEnabled(
      {required int viewId, required bool enabled}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setNavigationUIEnabled(
      {required int viewId, required bool enabled}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setRecenterButtonEnabled(
      {required int viewId, required bool enabled}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> setSpeedLimitIconEnabled(
      {required int viewId, required bool enabled}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setSpeedometerEnabled(
      {required int viewId, required bool enabled}) {
    throw UnimplementedError();
  }

  @override
  Future<void> setIncidentCardsEnabled(
      {required int viewId, required bool enabled}) {
    throw UnimplementedError();
  }

  @override
  Future<void> showRouteOverview({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> disableRoadSnappedLocationUpdates() {
    throw UnimplementedError();
  }

  @override
  Future<void> enableRoadSnappedLocationUpdates() {
    throw UnimplementedError();
  }

  @override
  Future<List<Marker?>> getMarkers({required int viewId}) async {
    return viewApi
        .getMarkers(viewId)
        .map((MarkerDto? e) => e?.toMarker())
        .toList();
  }

  @override
  Future<List<Marker?>> addMarkers(
      {required int viewId, required List<MarkerOptions> markerOptions}) async {
    int markerIndex = 0;
    final List<MarkerDto> markerDtos = markerOptions.map((MarkerOptions e) {
      final MarkerDto marker =
          MarkerDto(markerId: 'Marker_$markerIndex', options: e.toDto());
      markerIndex += 1;
      return marker;
    }).toList();

    final List<MarkerDto?> addedMarkers =
        viewApi.addMarkers(viewId, markerDtos);
    return addedMarkers.map((MarkerDto? e) => e?.toMarker()).toList();
  }

  @override
  Future<void> clearMarkers({required int viewId}) async {
    return viewApi.clearMarkers(viewId);
  }

  @override
  Future<void> clear({required int viewId}) async {
    return viewApi.clear(viewId);
  }

  @override
  Future<void> removeMarkers(
      {required int viewId, required List<Marker> markers}) async {
    return viewApi.removeMarkers(
        viewId, markers.map((Marker e) => e.toDto()).toList());
  }

  @override
  Future<List<Marker?>> updateMarkers(
      {required int viewId, required List<Marker> markers}) async {
    final List<MarkerDto?> updatedMarkers = viewApi.updateMarkers(
        viewId, markers.map((Marker e) => e.toDto()).toList());

    return updatedMarkers
        .whereType<MarkerDto>()
        .map((MarkerDto m) => m.toMarker())
        .toList();
  }

  @override
  Stream<MarkerDragEvent> getMarkerDragEventStream({required int viewId}) {
    return NavigationViewMarkerDragEventStream();
  }

  @override
  Stream<MarkerEvent> getMarkerEventStream({required int viewId}) {
    return NavigationViewMarkerEventStream();
  }

  @override
  Future<MapType> getMapType({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isGuidanceRunning() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isNavigationUIEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isIncidentCardsEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isNavigationFooterEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isNavigationHeaderEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isNavigationTripProgressBarEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isRecenterButtonEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSpeedLimitIconEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSpeedometerEnabled({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Stream<MapClickEvent> getMapClickEventStream({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Stream<MapLongClickEvent> getMapLongClickEventStream({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<RouteSegment?> getCurrentRouteSegment() {
    throw UnimplementedError();
  }

  @override
  Future<LatLng?> getMyLocation({required int viewId}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RouteSegment>> getRouteSegments() {
    throw UnimplementedError();
  }

  @override
  Future<List<LatLng>> getTraveledRoute() {
    throw UnimplementedError();
  }

  @override
  Future<List<Polygon?>> addPolygons(
      {required int viewId,
      required List<PolygonOptions> polygonOptions}) async {
    int polygonIndex = 0;
    final List<PolygonDto> polygons = polygonOptions.map((PolygonOptions e) {
      final PolygonDto polygon =
          PolygonDto(polygonId: 'Polygon_$polygonIndex', options: e.toDto());
      polygonIndex += 1;
      return polygon;
    }).toList();

    final List<PolygonDto?> addedPolygons =
        viewApi.addPolygons(viewId, polygons);
    return addedPolygons.map((PolygonDto? e) => e?.toPolygon()).toList();
  }

  @override
  Future<void> clearPolygons({required int viewId}) async {
    return viewApi.clearPolygons(viewId);
  }

  @override
  Stream<PolygonClickedEvent> getPolygonClickedEventStream(
      {required int viewId}) {
    return PolygonDtoClickedEventStream();
  }

  @override
  Future<void> removePolygons(
      {required int viewId, required List<Polygon> polygons}) async {
    return viewApi.removePolygons(
        viewId, polygons.map((Polygon e) => e.toDto()).toList());
  }

  @override
  Future<List<Polygon?>> updatePolygons(
      {required int viewId, required List<Polygon> polygons}) async {
    final List<PolygonDto?> updatedPolygons = viewApi.updatePolygons(
        viewId, polygons.map((Polygon e) => e.toDto()).toList());

    return updatedPolygons
        .whereType<PolygonDto>()
        .map((PolygonDto e) => e.toPolygon())
        .toList();
  }

  @override
  Future<List<Polygon?>> getPolygons({required int viewId}) async {
    final List<PolygonDto?> polygons = viewApi.getPolygons(viewId);

    return polygons
        .whereType<PolygonDto>()
        .map((PolygonDto e) => e.toPolygon())
        .toList();
  }

  @override
  Future<void> awaitMapReady({required int viewId}) {
    return viewApi.awaitMapReady(viewId);
  }

  @override
  Future<List<Polyline?>> addPolylines(
      {required int viewId,
      required List<PolylineOptions> polylineOptions}) async {
    int polylineIndex = 0;
    final List<PolylineDto> polylines =
        polylineOptions.map((PolylineOptions e) {
      final PolylineDto polyline = PolylineDto(
          polylineId: 'Polyline_$polylineIndex', options: e.toDto());
      polylineIndex += 1;
      return polyline;
    }).toList();

    final List<PolylineDto?> addedPolylines =
        viewApi.addPolylines(viewId, polylines);
    return addedPolylines.map((PolylineDto? e) => e?.toPolyline()).toList();
  }

  @override
  Future<void> clearPolylines({required int viewId}) async {
    return viewApi.clearPolylines(viewId);
  }

  @override
  Stream<PolylineClickedEvent> getPolylineClickedEventStream(
      {required int viewId}) {
    return NavigationViewPolylineClickedEventStream();
  }

  @override
  Future<List<Polyline?>> getPolylines({required int viewId}) async {
    final List<PolylineDto?> polylines = viewApi.getPolylines(viewId);

    return polylines
        .whereType<PolylineDto>()
        .map((PolylineDto e) => e.toPolyline())
        .toList();
  }

  @override
  Future<void> removePolylines(
      {required int viewId, required List<Polyline> polylines}) async {
    return viewApi.removePolylines(viewId,
        polylines.map((Polyline e) => e.toNavigationViewPolyline()).toList());
  }

  @override
  Future<List<Polyline?>> updatePolylines(
      {required int viewId, required List<Polyline> polylines}) async {
    final List<PolylineDto?> updatedPolylines = viewApi.updatePolylines(viewId,
        polylines.map((Polyline e) => e.toNavigationViewPolyline()).toList());

    return updatedPolylines
        .whereType<PolylineDto>()
        .map((PolylineDto e) => e.toPolyline())
        .toList();
  }

  @override
  Future<void> registerRemainingTimeOrDistanceChangedListener(
      int remainingTimeThresholdSeconds,
      int remainingDistanceThresholdMeters) async {
    return sessionApi.registerRemainingTimeOrDistanceChangedListener(
        remainingTimeThresholdSeconds, remainingDistanceThresholdMeters);
  }

  @override
  Future<List<Circle?>> getCircles({required int viewId}) async {
    final List<CircleDto?> circles = viewApi.getCircles(viewId);

    return circles
        .whereType<CircleDto>()
        .map((CircleDto e) => e.toCircle())
        .toList();
  }

  @override
  Future<List<Circle?>> addCircles(
      {required int viewId, required List<CircleOptions> options}) async {
    int circleIndex = 0;
    final List<CircleDto> circles = options.map((CircleOptions e) {
      final CircleDto circle =
          CircleDto(circleId: 'Circle_$circleIndex', options: e.toDto());
      circleIndex += 1;
      return circle;
    }).toList();

    final List<CircleDto?> addedCircles = viewApi.addCircles(viewId, circles);
    return addedCircles.map((CircleDto? e) => e?.toCircle()).toList();
  }

  @override
  Future<void> clearCircles({required int viewId}) async {
    return viewApi.clearCircles(viewId);
  }

  @override
  Future<void> removeCircles(
      {required int viewId, required List<Circle> circles}) async {
    return viewApi.removeCircles(
        viewId, circles.map((Circle e) => e.toDto()).toList());
  }

  @override
  Future<List<Circle?>> updateCircles(
      {required int viewId, required List<Circle> circles}) async {
    final List<CircleDto?> updatedCircles = viewApi.updateCircles(
        viewId, circles.map((Circle e) => e.toDto()).toList());

    return updatedCircles
        .whereType<CircleDto>()
        .map((CircleDto e) => e.toCircle())
        .toList();
  }

  @override
  Stream<CircleClickedEvent> getCircleClickedEventStream(
      {required int viewId}) {
    return CircleDtoClickedEventStream();
  }

  @override
  Future<ImageDescriptor> registerBitmapImage(
      {required Uint8List bitmap,
      required double imagePixelRatio,
      double? width,
      double? height}) async {
    return imageRegistryApi
        .registerBitmapImage('Image_1', bitmap, imagePixelRatio, width, height)
        .toImageDescriptor();
  }

  @override
  Future<void> clearRegisteredImages() async {
    return imageRegistryApi.clearRegisteredImages();
  }

  @override
  Future<void> unregisterImage(
      {required ImageDescriptor imageDescriptor}) async {
    return imageRegistryApi.unregisterImage(imageDescriptor.toDto());
  }

  @override
  Future<List<ImageDescriptor>> getRegisteredImages() async {
    return imageRegistryApi
        .getRegisteredImages()
        .whereType<ImageDescriptorDto>()
        .map((ImageDescriptorDto e) => e.toImageDescriptor())
        .toList();
  }
}
