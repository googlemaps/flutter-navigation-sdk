// Copyright 2024 Google LLC
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
class GoogleMapsNavigationView extends GoogleMapsBaseMapView {
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
      super.initialCameraPosition = const CameraPosition(),
      super.initialMapType = MapType.normal,
      super.initialCompassEnabled = true,
      super.initialRotateGesturesEnabled = true,
      super.initialScrollGesturesEnabled = true,
      super.initialTiltGesturesEnabled = true,
      super.initialZoomGesturesEnabled = true,
      super.initialScrollGesturesEnabledDuringRotateOrZoom = true,
      super.initialMapToolbarEnabled = true,
      super.initialMinZoomPreference,
      super.initialMaxZoomPreference,
      super.initialZoomControlsEnabled = true,
      super.initialCameraTargetBounds,
      super.initialPadding,
      this.initialNavigationUIEnabledPreference =
          NavigationUIEnabledPreference.automatic,
      super.layoutDirection,
      super.gestureRecognizers =
          const <Factory<OneSequenceGestureRecognizer>>{},
      super.onRecenterButtonClicked,
      super.onMarkerClicked,
      super.onMarkerDrag,
      super.onMarkerDragStart,
      super.onMarkerDragEnd,
      super.onMarkerInfoWindowClicked,
      super.onMarkerInfoWindowClosed,
      super.onMarkerInfoWindowLongClicked,
      super.onMapClicked,
      super.onMapLongClicked,
      super.onPolygonClicked,
      super.onPolylineClicked,
      super.onCircleClicked,
      this.onNavigationUIEnabledChanged,
      super.onMyLocationClicked,
      super.onMyLocationButtonClicked,
      super.onCameraMoveStarted,
      super.onCameraMove,
      super.onCameraIdle,
      super.onCameraStartedFollowingLocation,
      super.onCameraStoppedFollowingLocation});

  /// On view created callback.
  final OnNavigationViewCreatedCallback onViewCreated;

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

  /// On navigation UI enabled changed callback.
  final OnNavigationUIEnabledChanged? onNavigationUIEnabledChanged;

  /// Creates a [State] for this [GoogleMapsNavigationView].
  @override
  State createState() => GoogleMapsNavigationViewState();
}

/// Google Maps Navigation.
/// {@category Navigation View}
class GoogleMapsNavigationViewState
    extends MapViewState<GoogleMapsNavigationView> {
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
              padding: widget.initialPadding,
            ),
            navigationViewOptions: NavigationViewOptions(
                navigationUIEnabledPreference:
                    widget.initialNavigationUIEnabledPreference)),
        onMapReady: _onPlatformViewCreated);
  }

  /// Callback method when platform view is created.
  void _onPlatformViewCreated(int viewId) {
    initMapViewListeners(viewId);
    _initNavigationViewListeners(viewId);
    final GoogleNavigationViewController viewController =
        GoogleNavigationViewController(viewId);
    widget.onViewCreated(viewController);
  }

  void _initNavigationViewListeners(int viewId) {
    if (widget.onRecenterButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getNavigationRecenterButtonClickedEventStream(viewId: viewId)
          .listen(widget.onRecenterButtonClicked);
    }
    if (widget.onMyLocationClicked != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getMyLocationClickedEventStream(viewId: viewId)
          .listen(widget.onMyLocationClicked);
    }
    if (widget.onNavigationUIEnabledChanged != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getNavigationUIEnabledChangedEventStream(viewId: viewId)
          .listen((NavigationUIEnabledChangedEvent event) {
        widget.onNavigationUIEnabledChanged?.call(event.navigationUIEnabled);
      });
    }
    if (widget.onMyLocationButtonClicked != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getMyLocationButtonClickedEventStream(viewId: viewId)
          .listen(widget.onMyLocationButtonClicked);
    }
  }
}
