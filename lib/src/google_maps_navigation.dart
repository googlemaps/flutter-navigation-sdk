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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../google_maps_navigation.dart';
import 'google_maps_navigation_platform_interface.dart';

/// The view creation callback.
typedef OnCreatedCallback = void Function(
  GoogleNavigationViewController controller,
);

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

/// The main map view widget for Google Maps Navigation.
/// {@category Navigation View}
class GoogleMapsNavigationView extends StatefulWidget {
  /// The main widget for embedding Google Maps Navigation into a Flutter application.
  ///
  /// After creating the map view, the [onViewCreated] callback is triggered, providing a
  /// [GoogleNavigationViewController] that you can use to interact with the map programmatically.
  ///
  /// Example usage:
  /// ```dart
  /// GoogleMapsNavigationView(
  ///   onViewCreated: (controller) {
  ///     // Use the controller to interact with the map.
  ///   },
  ///   initialCameraPosition: CameraPosition(
  ///     // Initial camera position parameters
  ///   ),
  ///   // Other initial map settings...
  /// )
  /// ```
  const GoogleMapsNavigationView(
      {super.key,
      required this.onViewCreated,
      this.initialCameraPosition = const CameraPosition(),
      this.initialMapType = MapType.normal,
      this.initialCompassEnabled = true,
      this.initialRotateGesturesEnabled = true,
      this.initialScrollGesturesEnabled = true,
      this.initialTiltGesturesEnabled = true,
      this.initialZoomGesturesEnabled = true,
      this.initialScrollGesturesEnabledDuringRotateOrZoom = true,
      this.initialMapToolbarEnabled = true,
      this.initialMinZoomPreference,
      this.initialMaxZoomPreference,
      this.initialZoomControlsEnabled = true,
      this.initialCameraTargetBounds,
      this.initialNavigationUIEnabledPreference =
          NavigationUIEnabledPreference.automatic,
      this.layoutDirection,
      this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
      this.onRecenterButtonClicked,
      this.onMarkerClicked,
      this.onMarkerDrag,
      this.onMarkerDragStart,
      this.onMarkerDragEnd,
      this.onMarkerInfoWindowClicked,
      this.onMarkerInfoWindowClosed,
      this.onMarkerInfoWindowLongClicked,
      this.onMapClicked,
      this.onMapLongClicked,
      this.onPolygonClicked,
      this.onPolylineClicked,
      this.onCircleClicked,
      this.onNavigationUIEnabledChanged,
      this.onMyLocationClicked,
      this.onMyLocationButtonClicked,
      this.onCameraMoveStarted,
      this.onCameraMove,
      this.onCameraIdle,
      this.onCameraStartedFollowingLocation,
      this.onCameraStoppedFollowingLocation});

  /// On view created callback.
  final OnCreatedCallback onViewCreated;

  /// The initial positioning of the camera in the map view.
  final CameraPosition initialCameraPosition;

  /// The directionality to be used for text layout within the embedded view.
  final TextDirection? layoutDirection;

  /// The type of map to display, specified using [MapType] enum values.
  final MapType initialMapType;

  /// Specifies whether the compass should be enabled.
  ///
  /// The compass is an icon on the map that indicates the direction of north on the map.
  /// If enabled, it is only shown when the camera is tilted or rotated away from
  /// its default orientation (tilt of 0 and a bearing of 0).
  ///
  /// By default, the compass is enabled.
  final bool initialCompassEnabled;

  /// Specifies whether rotate gestures should be enabled.
  ///
  /// If enabled, users can use a two-finger rotate gesture to rotate the camera.
  /// If disabled, users cannot rotate the camera via gestures.
  /// This setting doesn't restrict the user from tapping the compass icon to reset the camera orientation,
  /// nor does it restrict programmatic movements and animation of the camera.
  ///
  /// By default, the rotation gestures are enabled.
  final bool initialRotateGesturesEnabled;

  /// Specifies whether scroll gestures should be enabled.
  ///
  /// By default, the scroll gestures are enabled.
  final bool initialScrollGesturesEnabled;

  /// Specifies whether tilt gestures should be enabled.
  ///
  /// By default, the tilt gestures are enabled.
  final bool initialTiltGesturesEnabled;

  /// Specifies whether zoom gestures should be enabled.
  ///
  /// By default, the zoom gestures enabled.
  final bool initialZoomGesturesEnabled;

  /// Specifies whether scroll gestures during rotate or zoom should be enabled.
  ///
  /// If enabled, users can swipe to pan the camera. If disabled, swiping has no effect.
  /// This setting doesn't restrict programmatic movement and animation of the camera.
  ///
  /// By default, the zoom gestures enabled.
  final bool initialScrollGesturesEnabledDuringRotateOrZoom;

  /// Specifies whether the map toolbar should be enabled. Only applicable on Android.
  ///
  /// If enabled, and the map toolbar can be shown in the current context,
  /// users will see a bar with various context-dependent actions.
  ///
  /// By default, the map toolbar is enabled.
  final bool initialMapToolbarEnabled;

  /// Specifies a preferred lower bound for camera zoom.
  ///
  /// Null by default (not limited).
  final double? initialMinZoomPreference;

  /// Specifies a preferred upper bound for camera zoom.
  ///
  /// Null by default (not limited).
  final double? initialMaxZoomPreference;

  /// Specifies whether the zoom controls should be enabled. Only applicable on Android.
  ///
  /// By default, the zoom controls are enabled.
  final bool initialZoomControlsEnabled;

  /// Specifies a bounds to constrain the camera target, so that when users scroll and pan the map,
  /// the camera target does not move outside these bounds.
  ///
  /// Null by default (unbounded).
  final LatLngBounds? initialCameraTargetBounds;

  /// Determines the initial visibility of the navigation UI on map initialization.
  ///
  /// By default set to [NavigationUIEnabledPreference.automatic],
  /// meaning the navigation UI gets enabled if the navigation
  /// session has already been successfully started.
  ///
  /// If set to [NavigationUIEnabledPreference.disabled] the navigation view
  /// initially displays a classic map view.
  ///
  /// Note on Android enabling the navigation UI for the view requires that the
  /// navigation session has already been successfully started with
  /// [GoogleMapsNavigator.initializeNavigationSession]. On iOS accepting
  /// the terms and conditions is enough.
  final NavigationUIEnabledPreference initialNavigationUIEnabledPreference;

  /// Which gestures should be forwarded to the PlatformView.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  ///
  /// See [PlatformViewSurface.gestureRecognizers] for details.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// On recenter button clicked event callback.
  final OnRecenterButtonClicked? onRecenterButtonClicked;

  /// On marker clicked callback.
  final OnMarkerClicked? onMarkerClicked;

  /// On marker drag callback.
  final OnMarkerDrag? onMarkerDrag;

  /// On marker drag start callback.
  final OnMarkerDragStart? onMarkerDragStart;

  /// On marker drag end callback.
  final OnMarkerDragEnd? onMarkerDragEnd;

  /// On marker info window clicked callback.
  final OnMarkerInfoWindowClicked? onMarkerInfoWindowClicked;

  /// On marker info window closed callback.
  final OnMarkerInfoWindowClosed? onMarkerInfoWindowClosed;

  /// On marker info window long clicked callback.
  final OnMarkerInfoWindowLongClicked? onMarkerInfoWindowLongClicked;

  /// On map clicked callback.
  final OnMapClicked? onMapClicked;

  /// On map long clicked callback.
  final OnMapLongClicked? onMapLongClicked;

  /// On polygon clicked callback.
  final OnPolygonClicked? onPolygonClicked;

  /// On polyline clicked callback.
  final OnPolylineClicked? onPolylineClicked;

  /// On circle clicked callback.
  final OnCircleClicked? onCircleClicked;

  /// On navigation UI enabled changed callback.
  final OnNavigationUIEnabledChanged? onNavigationUIEnabledChanged;

  /// On my location clicked callback.
  final OnMyLocationClicked? onMyLocationClicked;

  /// On my location button clicked callback.
  final OnMyLocationButtonClicked? onMyLocationButtonClicked;

  /// On camera move started callback.
  final OnCameraMoveStarted? onCameraMoveStarted;

  /// On camera move callback.
  final OnCameraMove? onCameraMove;

  /// On camera idle callback.
  final OnCameraIdle? onCameraIdle;

  /// On camera started following location callback (Android-only).
  final OnCameraStartedFollowingLocation? onCameraStartedFollowingLocation;

  /// On camera stopped following location callback (Android-only).
  final OnCameraStoppedFollowingLocation? onCameraStoppedFollowingLocation;

  /// Creates a [State] for this [GoogleMapsNavigationView].
  @override
  State createState() => GoogleMapsNavigationViewState();
}

/// Google Maps Navigation.
/// {@category Navigation View}
class GoogleMapsNavigationViewState extends State<GoogleMapsNavigationView> {
  @override
  Widget build(BuildContext context) {
    return GoogleMapsNavigationPlatform.instance.buildView(
        initializationOptions: NavigationViewInitializationOptions(
            layoutDirection: widget.layoutDirection ??
                Directionality.maybeOf(context) ??
                TextDirection.ltr,
            gestureRecognizers: widget.gestureRecognizers,
            mapOptions: MapOptions(
              cameraPosition: widget.initialCameraPosition,
              mapType: widget.initialMapType,
              compassEnabled: widget.initialCompassEnabled,
              rotateGesturesEnabled: widget.initialRotateGesturesEnabled,
              scrollGesturesEnabled: widget.initialScrollGesturesEnabled,
              tiltGesturesEnabled: widget.initialTiltGesturesEnabled,
              zoomGesturesEnabled: widget.initialZoomGesturesEnabled,
              scrollGesturesEnabledDuringRotateOrZoom:
                  widget.initialScrollGesturesEnabledDuringRotateOrZoom,
              mapToolbarEnabled: widget.initialMapToolbarEnabled,
              minZoomPreference: widget.initialMinZoomPreference,
              maxZoomPreference: widget.initialMaxZoomPreference,
              zoomControlsEnabled: widget.initialZoomControlsEnabled,
              cameraTargetBounds: widget.initialCameraTargetBounds,
            ),
            navigationViewOptions: NavigationViewOptions(
                navigationUIEnabledPreference:
                    widget.initialNavigationUIEnabledPreference)),
        onMapReady: _onPlatformViewCreated);
  }

  /// Callback method when platform view is created.
  void _onPlatformViewCreated(int viewId) {
    final GoogleNavigationViewController viewController =
        GoogleNavigationViewController(viewId, this);
    widget.onViewCreated(viewController);
  }
}

/// Settings for the user interface of the map.
/// {@category Navigation View}
class NavigationViewUISettings {
  /// [NavigationViewUISettings] constructor.
  NavigationViewUISettings(this._viewId);

  final int _viewId;

  /// Enables or disables the my location button.
  ///
  /// By default, the my location button is visible
  /// when the my location indicator is shown.
  Future<void> setMyLocationButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
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
    return GoogleMapsNavigationPlatform.instance
        .setConsumeMyLocationButtonClickEventsEnabled(
            viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to zoom the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomGesturesEnabled].
  Future<void> setZoomGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setZoomGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the zoom controls.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomControlsEnabled].
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> setZoomControlsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setZoomControlsEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the compass.
  ///
  /// Compass is only shown when the map is rotated
  /// from the default position, where the north points up.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialCompassEnabled].
  Future<void> setCompassEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setCompassEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to rotate the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialRotateGesturesEnabled].
  Future<void> setRotateGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setRotateGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabled].
  Future<void> setScrollGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setScrollGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map
  /// at the same time when zooming or rotating the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabledDuringRotateOrZoom].
  Future<void> setScrollGesturesDuringRotateOrZoomEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setScrollGesturesDuringRotateOrZoomEnabled(
            viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to tilt the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialTiltGesturesEnabled].
  Future<void> setTiltGesturesEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setTiltGesturesEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Turns the traffic layer on or off.
  ///
  /// By default, the traffic layer is off.
  Future<void> setTrafficEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setTrafficEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the map toolbar should be enabled or disabled.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialMapToolbarEnabled].
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> setMapToolbarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setMapToolbarEnabled(viewId: _viewId, enabled: enabled);
  }

  /// Checks if the my location button is enabled.
  Future<bool> isMyLocationButtonEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMyLocationButtonEnabled(viewId: _viewId);
  }

  /// Checks if the my location button consumes click events.
  Future<bool> isConsumeMyLocationButtonClickEventsEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isConsumeMyLocationButtonClickEventsEnabled(viewId: _viewId);
  }

  /// Checks if the zoom gestures are enabled.
  Future<bool> isZoomGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isZoomGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the zoom controls are enabled.
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isZoomControlsEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isZoomControlsEnabled(viewId: _viewId);
  }

  /// Checks if the compass is enabled.
  Future<bool> isCompassEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isCompassEnabled(viewId: _viewId);
  }

  /// Checks if the rotate gestures are enabled.
  Future<bool> isRotateGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isRotateGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled.
  Future<bool> isScrollGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isScrollGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled during the rotation and
  /// zoom gestures.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() async {
    return GoogleMapsNavigationPlatform.instance
        .isScrollGesturesEnabledDuringRotateOrZoom(viewId: _viewId);
  }

  /// Checks if the scroll gestures are enabled.
  Future<bool> isTiltGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isTiltGesturesEnabled(viewId: _viewId);
  }

  /// Checks if the map toolbar is enabled.
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isMapToolbarEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMapToolbarEnabled(viewId: _viewId);
  }

  /// Checks if the map is displaying traffic data.
  Future<bool> isTrafficEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isTrafficEnabled(viewId: _viewId);
  }
}

/// Navigation View Controller class to handle navigation view events.
/// {@category Navigation View}
class GoogleNavigationViewController {
  /// Basic constructor.
  ///
  /// Don't create this directly, but access through
  /// [GoogleMapsNavigationView.onViewCreated] callback.
  GoogleNavigationViewController(this._viewId, [this._viewState])
      : settings = NavigationViewUISettings(_viewId) {
    _initListeners();
  }

  final int _viewId;

  final GoogleMapsNavigationViewState? _viewState;

  /// Settings for the user interface of the map.
  final NavigationViewUISettings settings;

  /// Getter for view ID.
  int getViewId() {
    return _viewId;
  }

  /// Initializes the event channel listeners for the navigation view instance.
  void _initListeners() {
    _setOnMapClickedListeners();
    _setOnRecenterButtonClickedListener();
    _setOnMarkerClickedListeners();
    _setOnMarkerDragListeners();
    _setOnPolygonClickedListener();
    _setOnPolylineClickedListener();
    _setOnCircleClickedListener();
    _setOnNavigationUIEnabledChangedListener();
    _setOnMyLocationClickedListener();
    _setOnMyLocationButtonClickedListener();
    _setOnCameraChangedListener();
  }

  /// Sets the event channel listener for the map click event listeners.
  void _setOnMapClickedListeners() {
    if (_viewState != null) {
      if (_viewState?.widget.onMapClicked != null) {
        GoogleMapsNavigationPlatform.instance
            .getMapClickEventStream(viewId: _viewId)
            .listen((MapClickEvent event) {
          _viewState!.widget.onMapClicked!(event.target);
        });
      }
      if (_viewState?.widget.onMapLongClicked != null) {
        GoogleMapsNavigationPlatform.instance
            .getMapLongClickEventStream(viewId: _viewId)
            .listen((MapLongClickEvent event) {
          _viewState!.widget.onMapLongClicked!(event.target);
        });
      }
    }
  }

  /// Sets the event channel listener for the on recenter button clicked event.
  void _setOnRecenterButtonClickedListener() {
    if (_viewState != null &&
        _viewState?.widget.onRecenterButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getNavigationRecenterButtonClickedEventStream(viewId: _viewId)
          .listen(_viewState?.widget.onRecenterButtonClicked);
    }
  }

  /// Sets the event channel listener for the marker clicked events.
  void _setOnMarkerClickedListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerEventStream(viewId: _viewId)
        .listen((MarkerEvent event) {
      switch (event.eventType) {
        case MarkerEventType.clicked:
          _viewState?.widget.onMarkerClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClicked:
          _viewState?.widget.onMarkerInfoWindowClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClosed:
          _viewState?.widget.onMarkerInfoWindowClosed?.call(event.markerId);
        case MarkerEventType.infoWindowLongClicked:
          _viewState?.widget.onMarkerInfoWindowLongClicked
              ?.call(event.markerId);
      }
    });
  }

  /// Sets the event channel listener for the on my location clicked event.
  void _setOnMyLocationClickedListener() {
    if (_viewState != null && _viewState?.widget.onMyLocationClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getMyLocationClickedEventStream(viewId: _viewId)
          .listen(_viewState?.widget.onMyLocationClicked);
    }
  }

  /// Sets the event channel listener for the on my location button clicked event.
  void _setOnMyLocationButtonClickedListener() {
    if (_viewState != null &&
        _viewState?.widget.onMyLocationButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getMyLocationButtonClickedEventStream(viewId: _viewId)
          .listen(_viewState?.widget.onMyLocationButtonClicked);
    }
  }

  /// Sets the event channel listener for camera changed events.
  void _setOnCameraChangedListener() {
    // Register listeners if any of the callbacks are not null.
    if (_viewState?.widget.onCameraMoveStarted != null ||
        _viewState?.widget.onCameraMove != null ||
        _viewState?.widget.onCameraIdle != null) {
      GoogleMapsNavigationPlatform.instance
          .registerOnCameraChangedListener(viewId: _viewId);
    }
    GoogleMapsNavigationPlatform.instance
        .getCameraChangedEventStream(viewId: _viewId)
        .listen((CameraChangedEvent event) {
      switch (event.eventType) {
        case CameraEventType.moveStartedByApi:
          _viewState?.widget.onCameraMoveStarted?.call(event.position, false);
        case CameraEventType.moveStartedByGesture:
          _viewState?.widget.onCameraMoveStarted?.call(event.position, true);
        case CameraEventType.onCameraMove:
          _viewState?.widget.onCameraMove?.call(event.position);
        case CameraEventType.onCameraIdle:
          _viewState?.widget.onCameraIdle?.call(event.position);
        case CameraEventType.onCameraStartedFollowingLocation:
          _viewState?.widget.onCameraStartedFollowingLocation
              ?.call(event.position);
        case CameraEventType.onCameraStoppedFollowingLocation:
          _viewState?.widget.onCameraStoppedFollowingLocation
              ?.call(event.position);
      }
    });
  }

  /// Sets the event channel listener for the marker drag event.
  void _setOnMarkerDragListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerDragEventStream(viewId: _viewId)
        .listen((MarkerDragEvent event) {
      switch (event.eventType) {
        case MarkerDragEventType.drag:
          _viewState?.widget.onMarkerDrag?.call(event.markerId, event.position);
        case MarkerDragEventType.dragEnd:
          _viewState?.widget.onMarkerDragEnd
              ?.call(event.markerId, event.position);
        case MarkerDragEventType.dragStart:
          _viewState?.widget.onMarkerDragStart
              ?.call(event.markerId, event.position);
      }
    });
  }

  /// Sets the event channel listener for the polygon clicked event.
  void _setOnPolygonClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolygonClickedEventStream(viewId: _viewId)
        .listen((PolygonClickedEvent event) {
      _viewState?.widget.onPolygonClicked?.call(event.polygonId);
    });
  }

  /// Sets the event channel listener for the polyline clicked event.
  void _setOnPolylineClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolylineClickedEventStream(viewId: _viewId)
        .listen((PolylineClickedEvent event) {
      _viewState?.widget.onPolylineClicked?.call(event.polylineId);
    });
  }

  /// Sets the event channel listener for the circle clicked event.
  void _setOnCircleClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getCircleClickedEventStream(viewId: _viewId)
        .listen((CircleClickedEvent event) {
      _viewState?.widget.onCircleClicked?.call(event.circleId);
    });
  }

  /// Sets the event channel listener for the navigation UI enabled changed event.
  void _setOnNavigationUIEnabledChangedListener() {
    GoogleMapsNavigationPlatform.instance
        .getNavigationUIEnabledChangedEventStream(viewId: _viewId)
        .listen((NavigationUIEnabledChangedEvent event) {
      _viewState?.widget.onNavigationUIEnabledChanged
          ?.call(event.navigationUIEnabled);
    });
  }

  /// Change status of my location enabled.
  ///
  /// By default, the my location layer is disabled, but gets
  /// automatically enabled on Android when the navigation starts.
  ///
  /// On iOS this property doesn't control the my location indication during
  /// the navigation.
  Future<void> setMyLocationEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setMyLocationEnabled(viewId: _viewId, enabled: enabled);
  }

  /// This method returns the current map type of the Google Maps view instance.
  Future<MapType> getMapType() {
    return GoogleMapsNavigationPlatform.instance.getMapType(viewId: _viewId);
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
  /// _navigationViewController.changeMapType(MapType.satellite);
  /// ```
  Future<void> setMapType({required MapType mapType}) async {
    return GoogleMapsNavigationPlatform.instance
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
    return GoogleMapsNavigationPlatform.instance
        .setMapStyle(_viewId, styleJson);
  }

  /// Gets whether the my location is enabled or disabled.
  ///
  /// By default, the my location layer is disabled, but gets
  /// automatically enabled on Android when the navigation starts.
  ///
  /// On iOS this property doesn't control the my location indication during
  /// the navigation.
  Future<bool> isMyLocationEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMyLocationEnabled(viewId: _viewId);
  }

  /// Ask the camera to follow the user's location.
  ///
  /// Use [perspective] to specify the orientation of the camera
  /// and optional [zoomLevel] to control the map zoom.
  ///
  /// Automatically started in the perspective [CameraPerspective.tilted] when
  /// the navigation is initialized with [GoogleMapsNavigator.initializeNavigationSession]
  /// or when navigation UI gets re-enabled with [setNavigationUIEnabled].
  ///
  /// In Android, you can use [GoogleMapsNavigationView.onCameraStartedFollowingLocation]
  /// and [GoogleMapsNavigationView.onCameraStoppedFollowingLocation] callbacks
  /// to detect when the follow location mode is enabled or disabled.
  ///
  /// Note there are small differences on how Android and iOS handle the camera
  /// during the follow my location mode (tilt, zoom, transitions, etc.).
  ///
  /// See also [GoogleMapsNavigator.startGuidance], [showRouteOverview] and [animateCamera].
  Future<void> followMyLocation(CameraPerspective perspective,
      {double? zoomLevel}) async {
    return GoogleMapsNavigationPlatform.instance.followMyLocation(
        viewId: _viewId, perspective: perspective, zoomLevel: zoomLevel);
  }

  /// Gets user's current location.
  Future<LatLng?> getMyLocation() async {
    return GoogleMapsNavigationPlatform.instance.getMyLocation(viewId: _viewId);
  }

  /// Gets the current visible map region or camera bounds.
  Future<LatLngBounds> getVisibleRegion() async {
    return GoogleMapsNavigationPlatform.instance
        .getVisibleRegion(viewId: _viewId);
  }

  /// Gets the current position of the camera.
  Future<CameraPosition> getCameraPosition() async {
    return GoogleMapsNavigationPlatform.instance
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
  /// See also [moveCamera], [followMyLocation], [showRouteOverview].
  Future<void> animateCamera(CameraUpdate cameraUpdate,
      {Duration? duration, AnimationFinishedCallback? onFinished}) {
    return GoogleMapsNavigationPlatform.instance.animateCamera(
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
    return GoogleMapsNavigationPlatform.instance
        .moveCamera(viewId: _viewId, cameraUpdate: cameraUpdate);
  }

  /// Is the navigation trip progress bar enabled.
  Future<bool> isNavigationTripProgressBarEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationTripProgressBarEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation trip progress bar.
  ///
  /// By default, the navigation trip progress bar is disabled.
  Future<void> setNavigationTripProgressBarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setNavigationTripProgressBarEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationHeaderEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation header.
  ///
  /// By default, the navigation header is enabled.
  Future<void> setNavigationHeaderEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationHeaderEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationFooterEnabled(viewId: _viewId);
  }

  /// Enable or disable the navigation footer.
  ///
  /// By default, the navigation footer is enabled.
  ///
  /// Also known as ETA card, for example in Android
  /// calls [setEtaCardEnabled().](https://developers.google.com/maps/documentation/navigation/android-sdk/v1/reference/com/google/android/libraries/navigation/NavigationView#setEtaCardEnabled(boolean))
  Future<void> setNavigationFooterEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationFooterEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isRecenterButtonEnabled(viewId: _viewId);
  }

  /// Enable or disable the recenter button.
  ///
  /// By default, the recenter button is enabled.
  Future<void> setRecenterButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setRecenterButtonEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Can the speed limit indication be displayed.
  Future<bool> isSpeedLimitIconEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedLimitIconEnabled(viewId: _viewId);
  }

  /// Allow showing the speed limit indicator.
  ///
  /// By default, the speed limit is not displayed.
  Future<void> setSpeedLimitIconEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedLimitIconEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Can the speedometer be displayed.
  Future<bool> isSpeedometerEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedometerEnabled(viewId: _viewId);
  }

  /// Allow showing the speedometer.
  ///
  /// By default, the speedometer is not displayed.
  Future<void> setSpeedometerEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedometerEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Are the incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isTrafficIncidentCardsEnabled(viewId: _viewId);
  }

  /// Enable or disable showing of the incident cards.
  ///
  /// By default, the incident cards are shown.
  Future<void> setTrafficIncidentCardsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setTrafficIncidentCardsEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Check if the navigation user interface is shown.
  Future<bool> isNavigationUIEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationUIEnabled(viewId: _viewId);
  }

  /// Show or hide the navigation user interface shown on top of the map.
  ///
  /// When enabled also actives [followMyLocation] camera mode.
  ///
  /// Disabling hides routes on iOS, but on Android the routes stay visible.
  ///
  /// By default, the navigation UI is enabled when the session has been
  /// initialized with [GoogleMapsNavigator.initializeNavigationSession].
  ///
  /// Fails on Android if the navigation session has not been initialized,
  /// and on iOS if the terms and conditions have not been accepted.
  Future<void> setNavigationUIEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationUIEnabled(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Move the map camera to show the route overview.
  ///
  /// See also [followMyLocation] and [animateCamera].
  Future<void> showRouteOverview() {
    return GoogleMapsNavigationPlatform.instance.showRouteOverview(
      viewId: _viewId,
    );
  }

  /// Returns the minimum zoom level preference from the map view.
  /// If minimum zoom preference is not set previously, returns minimum possible
  /// zoom level for the current map type.
  Future<double> getMinZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
        .getMinZoomPreference(viewId: _viewId);
  }

  /// Returns the maximum zoom level preference from the map view.
  /// If maximum zoom preference is not set previously, returns maximum possible
  /// zoom level for the current map type.
  Future<double> getMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
        .getMaxZoomPreference(viewId: _viewId);
  }

  /// Removes any previously specified upper and lower zoom bounds.
  Future<void> resetMinMaxZoomPreference() {
    return GoogleMapsNavigationPlatform.instance
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
    return GoogleMapsNavigationPlatform.instance.setMinZoomPreference(
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
    return GoogleMapsNavigationPlatform.instance.setMaxZoomPreference(
        viewId: _viewId, maxZoomPreference: maxZoomPreference);
  }

  /// Retrieves all markers that have been added to the map view.
  Future<List<Marker?>> getMarkers() {
    return GoogleMapsNavigationPlatform.instance.getMarkers(viewId: _viewId);
  }

  /// Add markers to the map view.
  Future<List<Marker?>> addMarkers(List<MarkerOptions> markerOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addMarkers(viewId: _viewId, markerOptions: markerOptions);
  }

  /// Update markers to the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<List<Marker?>> updateMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .updateMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove markers from the map view.
  ///
  /// Throws [MarkerNotFoundException] if the [markers] list contains one or
  /// more markers that have not been added to the map view via [addMarkers] or
  /// contains markers that have already been removed from the map view.
  Future<void> removeMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .removeMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove all markers from the map view.
  Future<void> clearMarkers() {
    return GoogleMapsNavigationPlatform.instance.clearMarkers(viewId: _viewId);
  }

  /// Retrieves all polygons that have been added to the map view.
  Future<List<Polygon?>> getPolygons() {
    return GoogleMapsNavigationPlatform.instance.getPolygons(viewId: _viewId);
  }

  /// Add polygons to the map view.
  Future<List<Polygon?>> addPolygons(List<PolygonOptions> polygonOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolygons(viewId: _viewId, polygonOptions: polygonOptions);
  }

  /// Update polygons to the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<List<Polygon?>> updatePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove polygons from the map view.
  ///
  /// Throws [PolygonNotFoundException] if the [polygons] list contains
  /// polygon that has not beed added to the map view via [addPolygons] or
  /// contains polygon that has already been removed from the map view.
  Future<void> removePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove all polygons from the map view.
  Future<void> clearPolygons() {
    return GoogleMapsNavigationPlatform.instance.clearPolygons(viewId: _viewId);
  }

  /// Retrieves all polylines that have been added to the map view.
  Future<List<Polyline?>> getPolylines() {
    return GoogleMapsNavigationPlatform.instance.getPolylines(viewId: _viewId);
  }

  /// Add polylines to the map view.
  Future<List<Polyline?>> addPolylines(List<PolylineOptions> polylineOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolylines(viewId: _viewId, polylineOptions: polylineOptions);
  }

  /// Update polylines to the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<List<Polyline?>> updatePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove polylines from the map view.
  ///
  /// Throws [PolylineNotFoundException] if the [polylines] list contains
  /// polyline that has not beed added to the map view via [addPolylines] or
  /// contains polyline that has already been removed from the map view.
  Future<void> removePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove all polylines from the map view.
  Future<void> clearPolylines() {
    return GoogleMapsNavigationPlatform.instance
        .clearPolylines(viewId: _viewId);
  }

  /// Gets all circles from the map view.
  Future<List<Circle?>> getCircles() {
    return GoogleMapsNavigationPlatform.instance.getCircles(viewId: _viewId);
  }

  /// Add circles to the map view.
  Future<List<Circle?>> addCircles(List<CircleOptions> options) {
    return GoogleMapsNavigationPlatform.instance
        .addCircles(viewId: _viewId, options: options);
  }

  /// Update circles to the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<List<Circle?>> updateCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .updateCircles(viewId: _viewId, circles: circles);
  }

  /// Remove circles from the map view.
  ///
  /// Throws [CircleNotFoundException] if the [circles] list contains one or
  /// more circles that have not been added to the map view via [addCircles] or
  /// contains circles that have already been removed from the map view.
  Future<void> removeCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .removeCircles(viewId: _viewId, circles: circles);
  }

  /// Remove all circles from the map view.
  Future<void> clearCircles() {
    return GoogleMapsNavigationPlatform.instance.clearCircles(viewId: _viewId);
  }

  /// Remove all markers, polylines, polygons, overlays, etc from the map view.
  Future<void> clear() {
    return GoogleMapsNavigationPlatform.instance.clear(viewId: _viewId);
  }
}

/// [GoogleNavigationViewController.updateMarkers] or
/// [GoogleNavigationViewController.removeMarkers] failed
/// to find the marker given to the method.
/// {@category Navigation View}
class MarkerNotFoundException implements Exception {
  /// Default constructor for [MarkerNotFoundException].
  const MarkerNotFoundException();
}

/// [GoogleNavigationViewController.updatePolygons] or
/// [GoogleNavigationViewController.removePolygons] failed
/// to find the polygon given to the method.
/// {@category Navigation View}
class PolygonNotFoundException implements Exception {
  /// Default constructor for [PolygonNotFoundException].
  const PolygonNotFoundException();
}

/// [GoogleNavigationViewController.updatePolylines] or
/// [GoogleNavigationViewController.removePolylines] failed
/// to find the polyline given to the method.
/// {@category Navigation View}
class PolylineNotFoundException implements Exception {
  /// Default constructor for [PolylineNotFoundException].
  const PolylineNotFoundException();
}

/// [GoogleNavigationViewController.updateCircles] or
/// [GoogleNavigationViewController.removeCircles] failed
/// to find the circle given to the method.
/// {@category Navigation View}
class CircleNotFoundException implements Exception {
  /// Default constructor for [CircleNotFoundException].
  const CircleNotFoundException();
}

/// [GoogleNavigationViewController.setMapStyle] failed to set the map style.
/// {@category Navigation View}
class MapStyleException implements Exception {
  /// Default constructor for [MapStyleException].
  const MapStyleException();
}

/// [GoogleNavigationViewController.setMaxZoomPreference] failed to set zoom level.
/// {@category Navigation View}
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
class MinZoomRangeException implements Exception {
  /// Default constructor for [MinZoomRangeException].
  const MinZoomRangeException();

  @override
  String toString() {
    return 'MinZoomRangeException: Cannot set min zoom to greater than max zoom';
  }
}
