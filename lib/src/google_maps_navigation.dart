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
import 'types/util/marker_conversion.dart';

/// Created callback.
typedef OnCreatedCallback = void Function(
  GoogleNavigationViewController controller,
);

/// Navigation session events callback.
typedef OnNavigationSessionEventCallback = void Function(
  NavigationSessionEvent onNavigationSessionEvent,
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

/// Called during arriving to destination event.
typedef OnArrivalEventCallback = void Function(OnArrivalEvent onArrivalEvent);

/// Called during rerouting event. (Android only)
typedef OnReroutingEventCallback = void Function();

/// Called during traffic updated event. (Android only)
typedef OnTrafficUpdatedEventCallback = void Function();

/// Called during route changed event.
typedef OnRouteChangedEventCallback = void Function();

/// Called during recenter button click event.
typedef OnRecenterButtonClickedEventCallback = void Function(
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
  const GoogleMapsNavigationView({
    super.key,
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
    this.initialNavigationUiEnabled = false,
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
  });

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

  /// /// Specifies whether scroll gestures during rotate or zoom should be enabled.
  ///
  /// If enabled, users can swipe to pan the camera. If disabled, swiping has no effect.
  /// This setting doesn't restrict programmatic movement and animation of the camera.
  ///
  /// By default, the zoom gestures enabled.
  final bool initialScrollGesturesEnabledDuringRotateOrZoom;

  /// Specifies whether the mapToolbar should be enabled. Only applicable on Android.
  ///
  /// If enabled, and the Map Toolbar can be shown in the current context,
  /// users will see a bar with various context-dependent actions.
  ///
  /// By default, the Map Toolbar is enabled.
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
  /// False by default.
  final bool initialNavigationUiEnabled;

  /// Which gestures should be forwarded to the PlatformView.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  ///
  /// See [PlatformViewSurface.gestureRecognizers] for details.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// On recenter button clicked event callback.
  final OnRecenterButtonClickedEventCallback? onRecenterButtonClicked;

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

  /// Creates a [State] for this [GoogleMapsNavigationView].
  @override
  State createState() => GoogleMapsNavigationViewState();
}

/// Google Maps Navigation.
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
                navigationUIEnabled: widget.initialNavigationUiEnabled)),
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
  /// NavigationViewUISettings constructor.
  NavigationViewUISettings(this._viewId);

  final int _viewId;

  /// Enables or disables the my location button.
  ///
  /// By default, the my location button is visible
  /// when the my location indicator is shown.
  Future<void> enableMyLocationButton({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableMyLocationButton(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to zoom the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomGesturesEnabled].
  Future<void> enableZoomGestures({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableZoomGestures(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the zoom controls.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialZoomControlsEnabled].
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> enableZoomControls({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableZoomControls(viewId: _viewId, enabled: enabled);
  }

  /// Enables or disables the compass.
  ///
  /// Compass is only shown when the map is rotated
  /// from the default position, where the north points up.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialCompassEnabled].
  Future<void> enableCompass({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableCompass(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to rotate the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialRotateGesturesEnabled].
  Future<void> enableRotateGestures({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableRotateGestures(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map using a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabled].
  Future<void> enableScrollGestures({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableScrollGestures(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to scroll the map
  /// at the same time when zooming or rotating the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialScrollGesturesEnabledDuringRotateOrZoom].
  Future<void> enableScrollGesturesDuringRotateOrZoom({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableScrollGesturesDuringRotateOrZoom(
            viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the user is allowed to tilt the map with a gesture.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialTiltGesturesEnabled].
  Future<void> enableTiltGestures({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableTiltGestures(viewId: _viewId, enabled: enabled);
  }

  /// Turns the traffic layer on or off.
  ///
  /// By default, the traffic layer is off.
  Future<void> enableTraffic({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableTraffic(viewId: _viewId, enabled: enabled);
  }

  /// Sets the preference for whether the map toolbar should be enabled or disabled.
  ///
  /// Initial value can be set with [GoogleMapsNavigationView.initialMapToolbarEnabled].
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<void> enableMapToolbar({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableMapToolbar(viewId: _viewId, enabled: enabled);
  }

  /// Gets whether the my location button is enabled or disabled.
  Future<bool> isMyLocationButtonEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMyLocationButtonEnabled(viewId: _viewId);
  }

  /// Gets whether zoom gestures are enabled/disabled.
  Future<bool> isZoomGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isZoomGesturesEnabled(viewId: _viewId);
  }

  /// Gets whether zoom controls are enabled/disabled.
  ///
  /// The zoom controls are only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isZoomControlsEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isZoomControlsEnabled(viewId: _viewId);
  }

  /// Gets whether the compass is enabled/disabled.
  Future<bool> isCompassEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isCompassEnabled(viewId: _viewId);
  }

  /// Gets whether rotate gestures are enabled/disabled.
  Future<bool> isRotateGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isRotateGesturesEnabled(viewId: _viewId);
  }

  /// Gets whether scroll gestures are enabled/disabled.
  Future<bool> isScrollGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isScrollGesturesEnabled(viewId: _viewId);
  }

  /// Gets whether scroll gestures are enabled/disabled during rotation and zoom gestures.
  Future<bool> isScrollGesturesEnabledDuringRotateOrZoom() async {
    return GoogleMapsNavigationPlatform.instance
        .isScrollGesturesEnabledDuringRotateOrZoom(viewId: _viewId);
  }

  /// Gets whether tilt gestures are enabled/disabled.
  Future<bool> isTiltGesturesEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isTiltGesturesEnabled(viewId: _viewId);
  }

  /// Gets whether the Map Toolbar is enabled/disabled.
  ///
  /// The map toolbar is only available on Android. Throws [UnsupportedError] on iOS.
  Future<bool> isMapToolbarEnabled() async {
    return GoogleMapsNavigationPlatform.instance
        .isMapToolbarEnabled(viewId: _viewId);
  }

  /// Checks whether the map is drawing traffic data.
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
  /// GoogleMapsNavigation.onViewCreated() callback.
  GoogleNavigationViewController(this._viewId, [this._viewState])
      : settings = NavigationViewUISettings(_viewId) {
    _initListeners();
  }

  final int _viewId;

  final GoogleMapsNavigationViewState? _viewState;

  /// Settings for the user interface of the map.
  final NavigationViewUISettings settings;

  /// Getter for viewId.
  int getViewId() {
    return _viewId;
  }

  /// Initializes the event channel listeners for the navigation view instance.
  void _initListeners() {
    setOnMapClickedListeners();
    setOnRecenterButtonClickedListener();
    setOnMarkerClickedListeners();
    setOnMarkerDragListeners();
    setOnPolygonClickedListener();
    setOnPolylineClickedListener();
    setOnCircleClickedListener();
  }

  /// Sets the event channel listener for the map click event listeners.
  void setOnMapClickedListeners() {
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
  void setOnRecenterButtonClickedListener() {
    if (_viewState != null &&
        _viewState?.widget.onRecenterButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance
          .getNavigationRecenterButtonClickedEventStream(viewId: _viewId)
          .listen(_viewState?.widget.onRecenterButtonClicked);
    }
  }

  /// Sets the event channel listener for the marker clicked events.
  void setOnMarkerClickedListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerEventStream(viewId: _viewId)
        .listen((MarkerEventDto event) {
      switch (event.eventType) {
        case MarkerEventTypeDto.clicked:
          _viewState?.widget.onMarkerClicked?.call(event.markerId);
        case MarkerEventTypeDto.infoWindowClicked:
          _viewState?.widget.onMarkerInfoWindowClicked?.call(event.markerId);
        case MarkerEventTypeDto.infoWindowClosed:
          _viewState?.widget.onMarkerInfoWindowClosed?.call(event.markerId);
        case MarkerEventTypeDto.infoWindowLongClicked:
          _viewState?.widget.onMarkerInfoWindowLongClicked
              ?.call(event.markerId);
      }
    });
  }

  /// Sets the event channel listener for the marker drag event.
  void setOnMarkerDragListeners() {
    GoogleMapsNavigationPlatform.instance
        .getMarkerDragEventStream(viewId: _viewId)
        .listen((MarkerDragEventDto event) {
      switch (event.eventType) {
        case MarkerDragEventTypeDto.drag:
          _viewState?.widget.onMarkerDrag
              ?.call(event.markerId, event.position.toLatLng());
        case MarkerDragEventTypeDto.dragEnd:
          _viewState?.widget.onMarkerDragEnd
              ?.call(event.markerId, event.position.toLatLng());
        case MarkerDragEventTypeDto.dragStart:
          _viewState?.widget.onMarkerDragStart
              ?.call(event.markerId, event.position.toLatLng());
      }
    });
  }

  /// Sets the event channel listener for the polygon clicked event.
  void setOnPolygonClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolygonClickedEventStream(viewId: _viewId)
        .listen((PolygonClickedEventDto event) {
      _viewState?.widget.onPolygonClicked?.call(event.polygonId);
    });
  }

  /// Sets the event channel listener for the polyline clicked event.
  void setOnPolylineClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getPolylineDtoClickedEventStream(viewId: _viewId)
        .listen((PolylineClickedEventDto event) {
      _viewState?.widget.onPolylineClicked?.call(event.polylineId);
    });
  }

  /// Sets the event channel listener for the circle clicked event.
  void setOnCircleClickedListener() {
    GoogleMapsNavigationPlatform.instance
        .getCircleDtoClickedEventStream(viewId: _viewId)
        .listen((CircleClickedEventDto event) {
      _viewState?.widget.onCircleClicked?.call(event.circleId);
    });
  }

  /// Change status of my location enabled.
  ///
  /// By default, the my location layer is disabled, but gets
  /// automatically enabled on Android when the navigation starts.
  ///
  /// On iOS this property doesn't control the my location indication during
  /// the navigation.
  Future<void> enableMyLocation({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableMyLocation(viewId: _viewId, enabled: enabled);
  }

  /// Get the map type.
  Future<MapType> getMapType() {
    return GoogleMapsNavigationPlatform.instance.getMapType(viewId: _viewId);
  }

  /// Change the map type.
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
  /// Automatically started in perspective [CameraPerspective.tilted] when
  /// the navigation guidance begins.
  ///
  /// See also [GoogleMapsNavigator.startGuidance], [showRouteOverview] and [animateCamera].
  Future<void> followMyLocation(CameraPerspective perspective,
      {double? zoomLevel}) async {
    return GoogleMapsNavigationPlatform.instance.followMyLocation(
        viewId: _viewId, perspective: perspective, zoomLevel: zoomLevel);
  }

  /// Gets users current location.
  Future<LatLng?> getMyLocation() async {
    return GoogleMapsNavigationPlatform.instance.getMyLocation(viewId: _viewId);
  }

  /// Gets current visible map region / camera bounds.
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
  /// See CameraUpdate for more information
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

  /// Enable the navigation trip progress bar.
  ///
  /// By default, the navigation trip progress bar is disabled.
  Future<void> enableNavigationTripProgressBar({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance
        .enableNavigationTripProgressBar(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationHeaderEnabled(viewId: _viewId);
  }

  /// Enable the navigation header.
  ///
  /// By default, the navigation header is enabled.
  Future<void> enableNavigationHeader({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance.enableNavigationHeader(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationFooterEnabled(viewId: _viewId);
  }

  /// Enable the navigation footer.
  ///
  /// By default, the navigation footer is enabled.
  ///
  /// Also known as ETA card, for example in Android
  /// calls [setEtaCardEnabled().](https://developers.google.com/maps/documentation/navigation/android-sdk/v1/reference/com/google/android/libraries/navigation/NavigationView#setEtaCardEnabled(boolean))
  Future<void> enableNavigationFooter({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance.enableNavigationFooter(
      viewId: _viewId,
      enabled: enabled,
    );
  }

  /// Is the recenter button enabled.
  Future<bool> isRecenterButtonEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isRecenterButtonEnabled(viewId: _viewId);
  }

  /// Enable the recenter button.
  ///
  /// By default, the recenter button is enabled.
  Future<void> enableRecenterButton({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance.enableRecenterButton(
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
  Future<void> enableSpeedLimitIcon({required bool enable}) {
    return GoogleMapsNavigationPlatform.instance.enableSpeedLimitIcon(
      viewId: _viewId,
      enable: enable,
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
  Future<void> enableSpeedometer({required bool enable}) {
    return GoogleMapsNavigationPlatform.instance.enableSpeedometer(
      viewId: _viewId,
      enable: enable,
    );
  }

  /// Are the incident cards displayed.
  Future<bool> isIncidentCardsEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isIncidentCardsEnabled(viewId: _viewId);
  }

  /// Enable showing of the incident cards.
  ///
  /// By default, the incident cards are shown.
  Future<void> enableIncidentCards({required bool enable}) {
    return GoogleMapsNavigationPlatform.instance.enableIncidentCards(
      viewId: _viewId,
      enable: enable,
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
  /// initialized with GoogleMapsNavigotor.initializeNavigationSession().
  Future<void> enableNavigationUI({required bool enabled}) {
    return GoogleMapsNavigationPlatform.instance.enableNavigationUI(
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

  /// Get all markers from map view.
  Future<List<Marker?>> getMarkers() {
    return GoogleMapsNavigationPlatform.instance.getMarkers(viewId: _viewId);
  }

  /// Add markers to the map.
  Future<List<Marker?>> addMarkers(List<MarkerOptions> markerOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addMarkers(viewId: _viewId, markerOptions: markerOptions);
  }

  /// Update markers to the map.
  ///
  /// If the [markers] cannot be not be found throws [MarkerNotFoundException].
  Future<List<Marker?>> updateMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .updateMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove markers from the map.
  ///
  /// If the [markers] cannot be not be found throws [MarkerNotFoundException].
  Future<void> removeMarkers(List<Marker> markers) async {
    return GoogleMapsNavigationPlatform.instance
        .removeMarkers(viewId: _viewId, markers: markers);
  }

  /// Remove all markers from the map.
  Future<void> clearMarkers() {
    return GoogleMapsNavigationPlatform.instance.clearMarkers(viewId: _viewId);
  }

  /// Get all polygons from map view.
  Future<List<Polygon?>> getPolygons() {
    return GoogleMapsNavigationPlatform.instance.getPolygons(viewId: _viewId);
  }

  /// Add polygons to map view.
  Future<List<Polygon?>> addPolygons(List<PolygonOptions> polygonOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolygons(viewId: _viewId, polygonOptions: polygonOptions);
  }

  /// Update polygons to map view.
  ///
  /// If [polygons] cannot be not be found throws [PolygonNotFoundException].
  Future<List<Polygon?>> updatePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove polygons from map.
  ///
  /// If [polygons] cannot be not be found throws [PolygonNotFoundException].
  Future<void> removePolygons(List<Polygon> polygons) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolygons(viewId: _viewId, polygons: polygons);
  }

  /// Remove all polygons from map.
  Future<void> clearPolygons() {
    return GoogleMapsNavigationPlatform.instance.clearPolygons(viewId: _viewId);
  }

  /// Get all polylines from map view.
  Future<List<Polyline?>> getPolylines() {
    return GoogleMapsNavigationPlatform.instance.getPolylines(viewId: _viewId);
  }

  /// Add polylines to map view.
  Future<List<Polyline?>> addPolylines(List<PolylineOptions> polylineOptions) {
    return GoogleMapsNavigationPlatform.instance
        .addPolylines(viewId: _viewId, polylineOptions: polylineOptions);
  }

  /// Update polylines to map view.
  ///
  /// If [polylines] cannot be not be found throws [PolylineNotFoundException].
  Future<List<Polyline?>> updatePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .updatePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove polylines from map.
  ///
  /// If [polylines] cannot be not be found throws [PolylineNotFoundException].
  Future<void> removePolylines(List<Polyline> polylines) async {
    return GoogleMapsNavigationPlatform.instance
        .removePolylines(viewId: _viewId, polylines: polylines);
  }

  /// Remove all polylines from map.
  Future<void> clearPolylines() {
    return GoogleMapsNavigationPlatform.instance
        .clearPolylines(viewId: _viewId);
  }

  /// Get all circles from map view.
  Future<List<Circle?>> getCircles() {
    return GoogleMapsNavigationPlatform.instance.getCircles(viewId: _viewId);
  }

  /// Add circles to map view.
  Future<List<Circle?>> addCircles(List<CircleOptions> options) {
    return GoogleMapsNavigationPlatform.instance
        .addCircles(viewId: _viewId, options: options);
  }

  /// Update circles to map view.
  Future<List<Circle?>> updateCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .updateCircles(viewId: _viewId, circles: circles);
  }

  /// Remove circles from map.
  Future<void> removeCircles(List<Circle> circles) async {
    return GoogleMapsNavigationPlatform.instance
        .removeCircles(viewId: _viewId, circles: circles);
  }

  /// Remove all circles from map.
  Future<void> clearCircles() {
    return GoogleMapsNavigationPlatform.instance.clearCircles(viewId: _viewId);
  }

  /// Removes all markers, polylines, polygons, overlays, etc from the map.
  Future<void> clear() {
    return GoogleMapsNavigationPlatform.instance.clear(viewId: _viewId);
  }
}

/// [GoogleNavigationViewController.updateMarkers] or
/// [GoogleNavigationViewController.removeMarkers] failed
/// to find the marker given to the method.
class MarkerNotFoundException implements Exception {
  /// Default constructor for [MarkerNotFoundException].
  const MarkerNotFoundException();
}

/// [GoogleNavigationViewController.updatePolygons] or
/// [GoogleNavigationViewController.removePolygons] failed
/// to find the polygon given to the method.
class PolygonNotFoundException implements Exception {
  /// Default constructor for [PolygonNotFoundException].
  const PolygonNotFoundException();
}

/// [GoogleNavigationViewController.updatePolylines] or
/// [GoogleNavigationViewController.removePolylines] failed
/// to find the polyline given to the method.
class PolylineNotFoundException implements Exception {
  /// Default constructor for [PolylineNotFoundException].
  const PolylineNotFoundException();
}

/// [GoogleNavigationViewController.updateCircles] or
/// [GoogleNavigationViewController.removeCircles] failed
/// to find the circle given to the method.
class CircleNotFoundException implements Exception {
  /// Default constructor for [CircleNotFoundException].
  const CircleNotFoundException();
}

/// [GoogleNavigationViewController.setMapStyle] failed to set the map style.
class MapStyleException implements Exception {
  /// Default constructor for [MapStyleException].
  const MapStyleException();
}
