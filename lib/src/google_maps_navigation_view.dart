import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

/// On Google Navigation view created callback.
typedef OnNavigationViewCreatedCallback = void Function(
  GoogleNavigationViewController controller,
);

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
  final OnNavigationViewCreatedCallback onViewCreated;

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
    return GoogleMapsNavigationPlatform.instance.buildNavigationView(
        initializationOptions: MapViewInitializationOptions(
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