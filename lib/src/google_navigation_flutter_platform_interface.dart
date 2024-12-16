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

import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../google_navigation_flutter.dart';

/// Callback signature for when a map view is ready.
///
/// `viewId` is the platform view's unique identifier.
/// @nodoc
typedef MapReadyCallback = void Function(int viewId);

/// Describes the type of Google map view to construct.
enum MapViewType {
  /// Navigation view supports navigation overlay, and current navigation session is displayed on the map.
  navigation,

  /// Classic map view, without navigation overlay.
  map,
}

/// Google Maps Navigation Platform Interface for iOS and Android implementations.
/// @nodoc
abstract class GoogleMapsNavigationPlatform extends PlatformInterface
    with
        NavigationSessionAPIInterface,
        MapViewAPIInterface,
        AutoMapViewAPIInterface,
        ImageRegistryAPIInterface {
  /// Constructs a GoogleMapsNavigationPlatform.
  GoogleMapsNavigationPlatform() : super(token: _token);

  static final Object _token = Object();

  static GoogleMapsNavigationPlatform? _instance;

  /// The default instance of [GoogleMapsNavigationPlatform] to use.
  ///
  /// Defaults to [GoogleMapsNavigationPlatform].
  static GoogleMapsNavigationPlatform get instance {
    if (_instance == null) {
      throw UnimplementedError('instance has not been set for the platform.');
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GoogleMapsNavigationPlatform] when
  /// they register themselves.
  static set instance(GoogleMapsNavigationPlatform instance) {
    _instance = instance;
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Builds and returns a classic GoogleMaps map view.
  ///
  /// This method is responsible for creating a navigation view with the
  /// provided [initializationOptions].
  ///
  /// The [onMapReady] callback is invoked once the platform view has been created
  /// and is ready for interaction.
  Widget buildMapView(
      {required MapViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady});

  /// Builds and returns a navigation view.
  ///
  /// This method is responsible for creating a navigation view with the
  /// provided [initializationOptions].
  ///
  /// The [onMapReady] callback is invoked once the platform view has been created
  /// and is ready for interaction.
  Widget buildNavigationView(
      {required MapViewInitializationOptions initializationOptions,
      required MapReadyCallback onMapReady});
}

/// API interface for actions of the navigation session.
abstract mixin class NavigationSessionAPIInterface {
  /// Creates navigation session in the native platform and returns navigation session controller.
  Future<void> createNavigationSession(
      bool abnormalTerminationReportingEnabled);

  /// Check whether navigator has been initialized.
  Future<bool> isInitialized();

  /// Cleanup navigation session.
  Future<void> cleanup();

  /// Show terms and conditions dialog.
  Future<bool> showTermsAndConditionsDialog(String title, String companyName,
      bool shouldOnlyShowDriverAwarenessDisclaimer);

  /// Check if terms of service has been accepted.
  Future<bool> areTermsAccepted();

  /// Resets terms of service acceptance state.
  Future<void> resetTermsAccepted();

  /// Gets the native navigation SDK version as string.
  Future<String> getNavSDKVersion();

  /// Has guidance been started.
  Future<bool> isGuidanceRunning();

  /// Starts navigation guidance.
  Future<void> startGuidance();

  /// Stops navigation guidance.
  Future<void> stopGuidance();

  /// Sets destination waypoints and other settings.
  Future<NavigationRouteStatus> setDestinations(Destinations destinations);

  /// Clears destinations.
  Future<void> clearDestinations();

  /// Continues to next waypoint.
  Future<NavigationWaypoint?> continueToNextDestination();

  /// Gets current time and distance left.
  Future<NavigationTimeAndDistance> getCurrentTimeAndDistance();

  /// Sets audio guidance settings.
  Future<void> setAudioGuidance(NavigationAudioGuidanceSettings settings);

  /// Sets user location.
  Future<void> setUserLocation(LatLng location);

  /// Unsets user location.
  Future<void> removeUserLocation();

  /// Simulates locations along existing route.
  Future<void> simulateLocationsAlongExistingRoute();

  /// Simulates locations along existing route with simulation options.
  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  );

  /// Simulates locations along new route.
  Future<NavigationRouteStatus> simulateLocationsAlongNewRoute(
    List<NavigationWaypoint> waypoints,
  );

  /// Simulates locations along new route with routing options.
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingOptions(
    List<NavigationWaypoint> waypoints,
    RoutingOptions routingOptions,
  );

  /// Simulates locations along new route with routing and simulation options.
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
    List<NavigationWaypoint> waypoints,
    RoutingOptions routingOptions,
    SimulationOptions simulationOptions,
  );

  /// Pauses simulation.
  Future<void> pauseSimulation();

  /// Resumes simulation.
  Future<void> resumeSimulation();

  /// Sets state of allow background location updates. (iOS only)
  Future<void> allowBackgroundLocationUpdates(bool allow);

  /// Enables road snapped location updates.
  Future<void> enableRoadSnappedLocationUpdates();

  /// Disables road snapped location updates.
  Future<void> disableRoadSnappedLocationUpdates();

  /// Enables navigation info updates.
  Future<void> enableTurnByTurnNavigationEvents(int? numNextStepsToPreview);

  /// Disables navigation info updates.
  Future<void> disableTurnByTurnNavigationEvents();

  /// Get route segments.
  Future<List<RouteSegment>> getRouteSegments();

  /// Get traveled route.
  Future<List<LatLng>> getTraveledRoute();

  /// Get current route segment.
  Future<RouteSegment?> getCurrentRouteSegment();

  /// Get navigation speeding event stream from the navigation session.
  Stream<SpeedingUpdatedEvent> getNavigationSpeedingEventStream();

  /// Get navigation road snapped location event stream from the navigation session.
  Stream<RoadSnappedLocationUpdatedEvent>
      getNavigationRoadSnappedLocationEventStream();

  /// Get navigation road snapped raw location event stream from the navigation session.
  /// Android only.
  Stream<RoadSnappedRawLocationUpdatedEvent>
      getNavigationRoadSnappedRawLocationEventStream();

  /// Get navigation on arrival event stream from the navigation session.
  Stream<OnArrivalEvent> getNavigationOnArrivalEventStream();

  /// Get navigation on rerouting event stream from the navigation session.
  Stream<void> getNavigationOnReroutingEventStream();

  /// Get navigation on GPS availability update event stream from the navigation session.
  Stream<GpsAvailabilityUpdatedEvent>
      getNavigationOnGpsAvailabilityUpdateEventStream();

  /// Get navigation traffic updated event stream from the navigation session.
  Stream<void> getNavigationTrafficUpdatedEventStream();

  /// Get navigation on route changed event stream from the navigation session.
  Stream<void> getNavigationOnRouteChangedEventStream();

  /// Get navigation remaining time or distance event stream from the navigation session.
  Stream<RemainingTimeOrDistanceChangedEvent>
      getNavigationRemainingTimeOrDistanceChangedEventStream();

  /// Register remaining time or distance change listener with thresholds.
  Future<void> registerRemainingTimeOrDistanceChangedListener(
      int remainingTimeThresholdSeconds, int remainingDistanceThresholdMeters);

  /// Get navigation info event stream from the navigation session.
  Stream<NavInfoEvent> getNavInfoStream();
}

/// API interface for actions of the navigation view.
/// @nodoc
abstract mixin class MapViewAPIInterface {
  /// Awaits the platform view to be ready for communication.
  Future<void> awaitMapReady({required int viewId});

  /// Get the preference for whether the my location should be enabled or disabled.
  Future<bool> isMyLocationEnabled({required int viewId});

  /// Enabled location in the navigation view.
  Future<void> setMyLocationEnabled(
      {required int viewId, required bool enabled});

  /// Get the map type.
  Future<MapType> getMapType({required int viewId});

  /// Modified visible map type.
  Future<void> setMapType({required int viewId, required MapType mapType});

  /// Set map style by json string.
  Future<void> setMapStyle(int viewId, String? styleJson);

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabled(
      {required int viewId, required bool enabled});

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled(
      {required int viewId, required bool enabled});

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabled(
      {required int viewId, required bool enabled});

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabled(
      {required int viewId, required bool enabled});

  /// Enables or disables the compass.
  Future<void> setCompassEnabled({required int viewId, required bool enabled});

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabled(
      {required int viewId, required bool enabled});

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabled(
      {required int viewId, required bool enabled});

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(
      {required int viewId, required bool enabled});

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabled(
      {required int viewId, required bool enabled});

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabled(
      {required int viewId, required bool enabled});

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabled({required int viewId, required bool enabled});

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabled({required int viewId});

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled(
      {required int viewId});

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabled({required int viewId});

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabled({required int viewId});

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabled({required int viewId});

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabled({required int viewId});

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabled({required int viewId});

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom({required int viewId});

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabled({required int viewId});

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabled({required int viewId});

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabled({required int viewId});

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocation(
      {required int viewId,
      required CameraPerspective perspective,
      required double? zoomLevel});

  /// Gets users current location.
  Future<LatLng?> getMyLocation({required int viewId});

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition({required int viewId});

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegion({required int viewId});

  /// Animates the movement of the camera.
  Future<void> animateCamera(
      {required int viewId,
      required CameraUpdate cameraUpdate,
      required int? duration,
      AnimationFinishedCallback? onFinished});

  /// Moves the camera.
  Future<void> moveCamera(
      {required int viewId, required CameraUpdate cameraUpdate});

  /// Is the navigation trip progress bar enabled.
  Future<bool> isNavigationTripProgressBarEnabled({required int viewId});

  /// Enable navigation trip progress bar.
  Future<void> setNavigationTripProgressBarEnabled(
      {required int viewId, required bool enabled});

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled({required int viewId});

  /// Enable navigation header.
  Future<void> setNavigationHeaderEnabled(
      {required int viewId, required bool enabled});

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled({required int viewId});

  /// Enable the navigation footer.
  Future<void> setNavigationFooterEnabled(
      {required int viewId, required bool enabled});

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled({required int viewId});

  /// Enable the recenter button.
  Future<void> setRecenterButtonEnabled(
      {required int viewId, required bool enabled});

  /// Is the speed limit displayed.
  Future<bool> isSpeedLimitIconEnabled({required int viewId});

  /// Should display speed limit.
  Future<void> setSpeedLimitIconEnabled(
      {required int viewId, required bool enabled});

  /// Is speedometer displayed.
  Future<bool> isSpeedometerEnabled({required int viewId});

  /// Should display speedometer.
  Future<void> setSpeedometerEnabled(
      {required int viewId, required bool enabled});

  /// Is incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled({required int viewId});

  /// Should display incident cards.
  Future<void> setTrafficIncidentCardsEnabled(
      {required int viewId, required bool enabled});

  /// Is navigation UI enabled.
  Future<bool> isNavigationUIEnabled({required int viewId});

  /// Enable navigation UI.
  Future<void> setNavigationUIEnabled(
      {required int viewId, required bool enabled});

  /// Show route overview.
  Future<void> showRouteOverview({required int viewId});

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreference({required int viewId});

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreference({required int viewId});

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference({required int viewId});

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreference(
      {required int viewId, required double minZoomPreference});

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreference(
      {required int viewId, required double maxZoomPreference});

  /// Get map clicked event stream from the navigation view.
  Stream<MapClickEvent> getMapClickEventStream({required int viewId});

  /// Get map long clicked event stream from the navigation view.
  Stream<MapLongClickEvent> getMapLongClickEventStream({required int viewId});

  /// Get navigation recenter button clicked event stream from the navigation view.
  Stream<NavigationViewRecenterButtonClickedEvent>
      getNavigationRecenterButtonClickedEventStream({required int viewId});

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers({required int viewId});

  /// Add markers to map view.
  Future<List<Marker?>> addMarkers(
      {required int viewId, required List<MarkerOptions> markerOptions});

  /// Update markers on the map view.
  Future<List<Marker?>> updateMarkers(
      {required int viewId, required List<Marker> markers});

  /// Remove markers from map view.
  Future<void> removeMarkers(
      {required int viewId, required List<Marker> markers});

  /// Remove all markers from map view.
  Future<void> clearMarkers({required int viewId});

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear({required int viewId});

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons({required int viewId});

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons(
      {required int viewId, required List<PolygonOptions> polygonOptions});

  /// Update polygons on the map view.
  Future<List<Polygon?>> updatePolygons(
      {required int viewId, required List<Polygon> polygons});

  /// Remove polygons from map view.
  Future<void> removePolygons(
      {required int viewId, required List<Polygon> polygons});

  /// Remove all polygons from map view.
  Future<void> clearPolygons({required int viewId});

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines({required int viewId});

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines(
      {required int viewId, required List<PolylineOptions> polylineOptions});

  /// Update polylines on the map view.
  Future<List<Polyline?>> updatePolylines(
      {required int viewId, required List<Polyline> polylines});

  /// Remove polylines from map view.
  Future<void> removePolylines(
      {required int viewId, required List<Polyline> polylines});

  /// Remove all polylines from map view.
  Future<void> clearPolylines({required int viewId});

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles({required int viewId});

  /// Add circles to map view.
  Future<List<Circle?>> addCircles(
      {required int viewId, required List<CircleOptions> options});

  /// Update circles on the map view.
  Future<List<Circle?>> updateCircles(
      {required int viewId, required List<Circle> circles});

  /// Remove circles from map view.
  Future<void> removeCircles(
      {required int viewId, required List<Circle> circles});

  /// Remove all circles from map view.
  Future<void> clearCircles({required int viewId});

  /// Register camera changed listeners.
  Future<void> registerOnCameraChangedListener({required int viewId});

  // Sets the map padding for the map view.
  Future<void> setPadding({required int viewId, required EdgeInsets padding});

  // Gets the map padding from the map view.
  Future<EdgeInsets> getPadding({required int viewId});

  /// Get navigation view marker event stream from the navigation view.
  Stream<MarkerEvent> getMarkerEventStream({required int viewId});

  /// Get navigation view marker drag event stream from the navigation view.
  Stream<MarkerDragEvent> getMarkerDragEventStream({required int viewId});

  /// Get navigation view polygon clicked event stream from the navigation view.
  Stream<PolygonClickedEvent> getPolygonClickedEventStream(
      {required int viewId});

  /// Get navigation view polyline clicked event stream from the navigation view.
  Stream<PolylineClickedEvent> getPolylineClickedEventStream(
      {required int viewId});

  /// Get navigation view circle clicked event stream from the navigation view.
  Stream<CircleClickedEvent> getCircleClickedEventStream({required int viewId});

  /// Get navigation UI changed event stream from the navigation view.
  Stream<NavigationUIEnabledChangedEvent>
      getNavigationUIEnabledChangedEventStream({required int viewId});

  /// Get navigation view my location clicked event stream from the navigation view.
  Stream<MyLocationClickedEvent> getMyLocationClickedEventStream(
      {required int viewId});

  /// Get navigation view my location button clicked event stream from the navigation view.
  Stream<MyLocationButtonClickedEvent> getMyLocationButtonClickedEventStream(
      {required int viewId});

  /// Get navigation view camera changed event stream from the navigation view.
  Stream<CameraChangedEvent> getCameraChangedEventStream({required int viewId});

  /// Populates [GoogleNavigationInspectorPlatform.instance] to allow
  /// inspecting the platform map state.
  @visibleForTesting
  void enableDebugInspection() {
    throw UnimplementedError(
        'enableDebugInspection() has not been implemented.');
  }
}

abstract mixin class AutoMapViewAPIInterface {
  /// Get the preference for whether the my location should be enabled or disabled.
  Future<bool> isMyLocationEnabledForAuto();

  /// Enabled location in the auto map view.
  Future<void> setMyLocationEnabledForAuto({required bool enabled});

  /// Get the map type.
  Future<MapType> getMapTypeForAuto();

  /// Modified visible map type.
  Future<void> setMapTypeForAuto({required MapType mapType});

  /// Set map style by json string.
  Future<void> setMapStyleForAuto(String? styleJson);

  /// Enables or disables the my-location button.
  Future<void> setMyLocationButtonEnabledForAuto({required bool enabled});

  /// Enables or disables if the my location button consumes click events.
  Future<void> setConsumeMyLocationButtonClickEventsEnabledForAuto(
      {required bool enabled});

  /// Enables or disables the zoom gestures.
  Future<void> setZoomGesturesEnabledForAuto({required bool enabled});

  /// Enables or disables the zoom controls.
  Future<void> setZoomControlsEnabledForAuto({required bool enabled});

  /// Enables or disables the compass.
  Future<void> setCompassEnabledForAuto({required bool enabled});

  /// Sets the preference for whether rotate gestures should be enabled or disabled.
  Future<void> setRotateGesturesEnabledForAuto({required bool enabled});

  /// Sets the preference for whether scroll gestures should be enabled or disabled.
  Future<void> setScrollGesturesEnabledForAuto({required bool enabled});

  /// Sets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<void> setScrollGesturesDuringRotateOrZoomEnabledForAuto(
      {required bool enabled});

  /// Sets the preference for whether tilt gestures should be enabled or disabled.
  Future<void> setTiltGesturesEnabledForAuto({required bool enabled});

  /// Sets the preference for whether the Map Toolbar should be enabled or disabled.
  Future<void> setMapToolbarEnabledForAuto({required bool enabled});

  /// Turns the traffic layer on or off.
  Future<void> setTrafficEnabledForAuto({required bool enabled});

  /// Get the preference for whether the my location button should be enabled or disabled.
  Future<bool> isMyLocationButtonEnabledForAuto();

  /// Get the preference for whether the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabledForAuto();

  /// Gets the preference for whether zoom gestures should be enabled or disabled.
  Future<bool> isZoomGesturesEnabledForAuto();

  /// Gets the preference for whether zoom controls should be enabled or disabled.
  Future<bool> isZoomControlsEnabledForAuto();

  /// Gets the preference for whether compass should be enabled or disabled.
  Future<bool> isCompassEnabledForAuto();

  /// Gets the preference for whether rotate gestures should be enabled or disabled.
  Future<bool> isRotateGesturesEnabledForAuto();

  /// Gets the preference for whether scroll gestures should be enabled or disabled.
  Future<bool> isScrollGesturesEnabledForAuto();

  /// Gets the preference for whether scroll gestures can take place at the same time as a zoom or rotate gesture.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoomForAuto();

  /// Gets the preference for whether tilt gestures should be enabled or disabled.
  Future<bool> isTiltGesturesEnabledForAuto();

  /// Gets whether the Map Toolbar is enabled/disabled.
  Future<bool> isMapToolbarEnabledForAuto();

  /// Checks whether the map is drawing traffic data.
  Future<bool> isTrafficEnabledForAuto();

  /// Sets the Camera to follow the location of the user.
  Future<void> followMyLocationForAuto(
      {required CameraPerspective perspective, required double? zoomLevel});

  /// Gets users current location.
  Future<LatLng?> getMyLocationForAuto();

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPositionForAuto();

  /// Gets the current visible area / camera bounds.
  Future<LatLngBounds> getVisibleRegionForAuto();

  /// Animates the movement of the camera.
  Future<void> animateCameraForAuto(
      {required CameraUpdate cameraUpdate,
      required int? duration,
      AnimationFinishedCallback? onFinished});

  /// Moves the camera.
  Future<void> moveCameraForAuto({required CameraUpdate cameraUpdate});

  /// Returns the minimum zoom level.
  Future<double> getMinZoomPreferenceForAuto();

  /// Returns the maximum zoom level for the current camera position.
  Future<double> getMaxZoomPreferenceForAuto();

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreferenceForAuto();

  /// Sets a preferred lower bound for the camera zoom.
  Future<void> setMinZoomPreferenceForAuto({required double minZoomPreference});

  /// Sets a preferred upper bound for the camera zoom.
  Future<void> setMaxZoomPreferenceForAuto({required double maxZoomPreference});

  /// Get all markers from auto map view.
  Future<List<Marker?>> getMarkersForAuto();

  /// Add markers to auto map view.
  Future<List<Marker?>> addMarkersForAuto(
      {required List<MarkerOptions> markerOptions});

  /// Update markers on the auto map view.
  Future<List<Marker?>> updateMarkersForAuto({required List<Marker> markers});

  /// Remove markers from auto map view.
  Future<void> removeMarkersForAuto({required List<Marker> markers});

  /// Remove all markers from auto map view.
  Future<void> clearMarkersForAuto();

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clearForAuto();

  /// Get all polygons from map auto view.
  Future<List<Polygon?>> getPolygonsForAuto();

  /// Add polygons to auto map view.
  Future<List<Polygon?>> addPolygonsForAuto(
      {required List<PolygonOptions> polygonOptions});

  /// Update polygons on the auto map view.
  Future<List<Polygon?>> updatePolygonsForAuto(
      {required List<Polygon> polygons});

  /// Remove polygons from auto map view.
  Future<void> removePolygonsForAuto({required List<Polygon> polygons});

  /// Remove all polygons from auto map view.
  Future<void> clearPolygonsForAuto();

  /// Get all polylines from auto map view.
  Future<List<Polyline?>> getPolylinesForAuto();

  /// Add polylines to auto map view.
  Future<List<Polyline?>> addPolylinesForAuto(
      {required List<PolylineOptions> polylineOptions});

  /// Update polylines on the auto map view.
  Future<List<Polyline?>> updatePolylinesForAuto(
      {required List<Polyline> polylines});

  /// Remove polylines from auto map view.
  Future<void> removePolylinesForAuto({required List<Polyline> polylines});

  /// Remove all polylines from auto map view.
  Future<void> clearPolylinesForAuto();

  /// Get all circles from auto map view.
  Future<List<Circle?>> getCirclesForAuto();

  /// Add circles to auto map view.
  Future<List<Circle?>> addCirclesForAuto(
      {required List<CircleOptions> options});

  /// Update circles on the auto map view.
  Future<List<Circle?>> updateCirclesForAuto({required List<Circle> circles});

  /// Remove circles from auto map view.
  Future<void> removeCirclesForAuto({required List<Circle> circles});

  /// Remove all circles from auto map view.
  Future<void> clearCirclesForAuto();

  /// Register camera changed listeners.
  Future<void> registerOnCameraChangedListenerForAuto();

  // Check whether auto screen is available;
  Future<bool> isAutoScreenAvailable();

  // Sets the map padding for the auto map view.
  Future<void> setPaddingForAuto({required EdgeInsets padding});

  // Gets the map padding from the auto map view.
  Future<EdgeInsets> getPaddingForAuto();

  /// Get custom navigation auto event stream from the auto view.
  Stream<CustomNavigationAutoEvent> getCustomNavigationAutoEventStream();

  /// Get auto screen availibility changed event stream from the auto view.
  Stream<AutoScreenAvailabilityChangedEvent>
      getAutoScreenAvailabilityChangedEventStream();

  void initializeAutoViewEventAPI();
}

/// API interface for actions of the image registry.
/// @nodoc
abstract mixin class ImageRegistryAPIInterface {
  /// Register bitmap to image registry.
  Future<ImageDescriptor> registerBitmapImage(
      {required Uint8List bitmap,
      required double imagePixelRatio,
      double? width,
      double? height});

  /// Delete bitmap from image registry.
  Future<void> unregisterImage({required ImageDescriptor imageDescriptor});

  /// Get all registered bitmaps from image registry.
  Future<List<ImageDescriptor>> getRegisteredImages();

  /// Remove all registered bitmaps from image registry.
  Future<void> clearRegisteredImages();
}
