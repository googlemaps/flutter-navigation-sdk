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

import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

/// Called during speeding event.
typedef OnSpeedingUpdatedEventCallback = void Function(
  SpeedingUpdatedEvent onSpeedingUpdatedEvent,
);

/// Called when the camera animation finishes.
///
/// Returns [success] true if the animation completed, false
/// if the animation was canceled.
typedef AnimationFinishedCallback = void Function(bool success);

/// Called during road snapped location event.
typedef OnRoadSnappedLocationUpdatedEventCallback = void Function(
  RoadSnappedLocationUpdatedEvent onRoadSnappedLocationUpdatedEvent,
);

/// Called during road snapped raw location event (Android only).
typedef OnRoadSnappedRawLocationUpdatedEventCallback = void Function(
  RoadSnappedRawLocationUpdatedEvent onRoadSnappedRawLocationUpdatedEvent,
);

/// Called during arriving to destination event.
typedef OnArrivalEventCallback = void Function(OnArrivalEvent onArrivalEvent);

/// Called during rerouting event. (Android only)
typedef OnReroutingEventCallback = void Function();

/// Called during GPS availability event. (Android only).
typedef OnGpsAvailabilityEventCallback = void Function(
    GpsAvailabilityUpdatedEvent gpsAvailabilityUpdatedEvent);

/// Called during traffic updated event. (Android only)
typedef OnTrafficUpdatedEventCallback = void Function();

/// Called during route changed event.
typedef OnRouteChangedEventCallback = void Function();

/// Called during recenter button click event.
typedef OnRecenterButtonClicked = void Function(
    NavigationViewRecenterButtonClickedEvent);

/// Called during remaining time or distance changed event.
typedef OnRemainingTimeOrDistanceChangedEventCallback = void Function(
    RemainingTimeOrDistanceChangedEvent onRemainingTimeOrDistanceChangedEvent);

/// Called on navigation info event.
typedef OnNavInfoEventCallback = void Function(NavInfoEvent onNavInfo);

/// Called during marker click event.
typedef OnMarkerClicked = void Function(String markerId);

/// Called during marker drag event.
typedef OnMarkerDrag = void Function(String markerId, LatLng newPosition);

/// Called during marker drag start event.
typedef OnMarkerDragStart = void Function(String markerId, LatLng newPosition);

/// Called during marker drag end event.
typedef OnMarkerDragEnd = void Function(String markerId, LatLng newPosition);

/// Called during marker info window clicked event.
typedef OnMarkerInfoWindowClicked = void Function(String markerId);

/// Called during marker info window closed event.
typedef OnMarkerInfoWindowClosed = void Function(String markerId);

/// Called during marker info window long clicked event.
typedef OnMarkerInfoWindowLongClicked = void Function(String markerId);

/// Called during map clicked event.
typedef OnMapClicked = void Function(LatLng position);

/// Called during map long clicked event.
typedef OnMapLongClicked = void Function(LatLng position);

/// Called during polygon clicked event.
typedef OnPolygonClicked = void Function(String polygonId);

/// Called during polyline clicked event.
typedef OnPolylineClicked = void Function(String polylineId);

/// Called during circle clicked event.
typedef OnCircleClicked = void Function(String circleId);

/// Called when the [GoogleNavigationViewController.isNavigationUIEnabled] status changes.
typedef OnNavigationUIEnabledChanged = void Function(bool navigationUIEnabled);

/// Called during my location clicked event.
typedef OnMyLocationClicked = void Function(MyLocationClickedEvent);

/// Called during my location button clicked event.
typedef OnMyLocationButtonClicked = void Function(MyLocationButtonClickedEvent);

/// Called when the camera starts moving after it has been idle or when the
/// reason for the camera motion has changed.
///
/// [gesture] is true when the camera motion has been initiated in response
/// to the user gestures on the map. For example: pan, tilt, pinch to zoom, or
/// rotate.
/// [gesture] is false when the camera motion has been initiated in response
/// to user actions. For example: zoom buttons, my location button, or marker
/// clicks.
/// [position] is the camera position where the motion started.
typedef OnCameraMoveStarted = void Function(
    CameraPosition position, bool gesture);

/// Called repeatedly as the camera continues to move after the
/// [OnCameraMoveStarted] call. The method may be called as often as once every
/// frame.
///
/// [position] is the current camera position.
typedef OnCameraMove = void Function(CameraPosition position);

/// Called when the camera movement has ended, there are no pending animations
/// and the user has stopped interacting with the map.
///
/// [position] is the camera position where the motion ended.
typedef OnCameraIdle = void Function(CameraPosition position);

/// Called when the camera starts following current location, typically will
/// get called in response to [GoogleNavigationViewController.followMyLocation].
/// Only applicable on Android.
///
/// [position] is the current camera position.
typedef OnCameraStartedFollowingLocation = void Function(
    CameraPosition position);

/// Called when the camera stops following current location. A camera already
/// following location will exit the follow mode if the camera is moved via
/// user gesture or an API call, e.g. [GoogleNavigationViewController.moveCamera]
/// or [GoogleNavigationViewController.animateCamera].
/// Only applicable on Android.
///
/// [position] is the current camera position.
typedef OnCameraStoppedFollowingLocation = void Function(
    CameraPosition position);

/// Settings for the user interface of the map.
/// {@category Navigation View}
/// {@category Map View}
class NavigationViewUISettings {
  /// [NavigationViewUISettings] constructor.
  NavigationViewUISettings(this._viewId);

  final int _viewId;

  /// Enables or disables the my location button.
  ///
  /// By default, the my location button is visible
  /// when the my location indicator is shown.
  Future<void> setMyLocationButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMyLocationButtonEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets whether to consume my location button click events.
  ///
  /// If [enabled] is set to true, the default behaviour does not occur.
  /// If [enabled] is set to false, the default behaviour occurs. The default
  /// behavior is for the camera move such that it is centered on the user location.
  ///
  /// Note: By default, the button click events are not consumed, and the map
  /// follows its native default behavior. This method can be used to override this behavior.
  Future<void> setConsumeMyLocationButtonClickEventsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setConsumeMyLocationButtonClickEventsEnabled(
            viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to zoom the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomGesturesEnabled].
  Future<void> setZoomGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setZoomGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the zoom controls.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomControlsEnabled].
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> setZoomControlsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setZoomControlsEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the compass.
  ///
  /// Compass is only shown when the map is rotated
  /// from the default position, where the north points up.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialCompassEnabled].
  Future<void> setCompassEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setCompassEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to rotate the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialRotateGesturesEnabled].
  Future<void> setRotateGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setRotateGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabled].
  Future<void> setScrollGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setScrollGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map
  /// at the same time when zooming or rotating the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabledDuringRotateOrZoom].
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setScrollGesturesDuringRotateOrZoomEnabled(
            viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to tilt the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialTiltGesturesEnabled].
  Future<void> setTiltGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTiltGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Turns the traffic layer on or off.
  ///
  /// By default, the traffic layer is off.
  Future<void> setTrafficEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTrafficEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the map toolbar should be enabled or disabled.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialMapToolbarEnabled].
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> setMapToolbarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setMapToolbarEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Checks if the my location button is enabled.
  Future<bool> isMyLocationButtonEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isMyLocationButtonEnabled(viewId: _viewId);
  }

  /// Checks if the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isConsumeMyLocationButtonClickEventsEnabled(viewId: _viewId);
  }

  /// Checks if the zoom gestures are enabled.
  Future<bool> isZoomGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isZoomGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the zoom controls are enabled.
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isZoomControlsEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isZoomControlsEnabled(viewId: _viewId);
  }

  /// Checks if the compass is enabled.
  Future<bool> isCompassEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isCompassEnabled(viewId: _viewId);
  }

  /// Checks if the rotate gestures are enabled.
  Future<bool> isRotateGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isRotateGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled.
  Future<bool> isScrollGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isScrollGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled during the rotation and
  /// zoom gestures.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isScrollGesturesEnabledDuringRotateOrZoom(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled.
  Future<bool> isTiltGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTiltGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the map toolbar is enabled.
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isMapToolbarEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isMapToolbarEnabled(viewId: _viewId);
  }

  /// Checks if the map is displaying traffic data.
  Future<bool> isTrafficEnabled() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTrafficEnabled(viewId: _viewId);
  }
}

/// [GoogleNavigationViewController.updateMarkers] or
/// [GoogleNavigationViewController.removeMarkers] failed
/// to find the marker given to the method.
/// {@category Navigation View}
/// {@category Map View}
class MarkerNotFoundException implements Exception {
  /// Default constructor for [MarkerNotFoundException].
  const MarkerNotFoundException();
}

/// [GoogleNavigationViewController.updatePolygons] or
/// [GoogleNavigationViewController.removePolygons] failed
/// to find the polygon given to the method.
/// {@category Navigation View}
/// {@category Map View}
class PolygonNotFoundException implements Exception {
  /// Default constructor for [PolygonNotFoundException].
  const PolygonNotFoundException();
}

/// [GoogleNavigationViewController.updatePolylines] or
/// [GoogleNavigationViewController.removePolylines] failed
/// to find the polyline given to the method.
/// {@category Navigation View}
/// {@category Map View}
class PolylineNotFoundException implements Exception {
  /// Default constructor for [PolylineNotFoundException].
  const PolylineNotFoundException();
}

/// [GoogleNavigationViewController.updateCircles] or
/// [GoogleNavigationViewController.removeCircles] failed
/// to find the circle given to the method.
/// {@category Navigation View}
/// {@category Map View}
class CircleNotFoundException implements Exception {
  /// Default constructor for [CircleNotFoundException].
  const CircleNotFoundException();
}

/// [GoogleNavigationViewController.setMapStyle] failed to set the map style.
/// {@category Navigation View}
/// {@category Map View}
class MapStyleException implements Exception {
  /// Default constructor for [MapStyleException].
  const MapStyleException();
}

/// [GoogleNavigationViewController.setMaxZoomPreference] failed to set zoom level.
/// {@category Navigation View}
/// {@category Map View}
class MaxZoomRangeException implements Exception {
  /// Default constructor for [MaxZoomRangeException].
  const MaxZoomRangeException();

  @override
  String toString() {
    return 'MaxZoomRangeException: Cannot set max zoom to less than min zoom';
  }
}

/// [GoogleNavigationViewController.setMinZoomPreference] failed to set zoom level.
/// {@category Navigation View}
/// {@category Map View}
class MinZoomRangeException implements Exception {
  /// Default constructor for [MinZoomRangeException].
  const MinZoomRangeException();

  @override
  String toString() {
    return 'MinZoomRangeException: Cannot set min zoom to greater than max zoom';
  }
}
