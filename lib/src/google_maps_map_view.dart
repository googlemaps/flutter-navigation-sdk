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

/// On Google Map view created callback.
typedef OnMapViewCreatedCallback = void Function(
  GoogleMapViewController controller,
);

/// The base view for map view and navigation view. Not to be used by itself.
/// {@category Map View}
@protected
abstract class GoogleMapsBaseMapView extends StatefulWidget {
  /// Abstract base class that contans the shared logic of GoogleMapsMapView and GoogleMapsNavigation View.
  const GoogleMapsBaseMapView(
      {super.key,
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
      this.initialPadding,
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
      this.onMyLocationClicked,
      this.onMyLocationButtonClicked,
      this.onCameraMoveStarted,
      this.onCameraMove,
      this.onCameraIdle,
      this.onCameraStartedFollowingLocation,
      this.onCameraStoppedFollowingLocation});

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

  /// Specifies the initial padding for the map view.
  ///
  /// Null by default (no padding).
  final EdgeInsets? initialPadding;

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
}

/// The main map view widget for Google Maps Map View.
/// {@category Map View}
class GoogleMapsMapView extends GoogleMapsBaseMapView {
  /// The main widget for embedding Google Maps Map View into a Flutter application.
  ///
  /// After creating the map view, the [onViewCreated] callback is triggered, providing a
  /// [GoogleMapViewController] that you can use to interact with the map programmatically.
  ///
  /// Example usage:
  /// ```dart
  /// GoogleMapsMapView(
  ///   onViewCreated: (controller) {
  ///     // Use the controller to interact with the map.
  ///   },
  ///   initialCameraPosition: CameraPosition(
  ///     // Initial camera position parameters
  ///   ),
  ///   // Other initial map settings...
  /// )
  /// ```
  const GoogleMapsMapView(
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
      super.onMyLocationClicked,
      super.onMyLocationButtonClicked,
      super.onCameraMoveStarted,
      super.onCameraMove,
      super.onCameraIdle,
      super.onCameraStartedFollowingLocation,
      super.onCameraStoppedFollowingLocation});

  /// On view created callback.
  final OnMapViewCreatedCallback onViewCreated;

  /// Creates a [State] for this [GoogleMapsMapView].
  @override
  State createState() => GoogleMapsMapViewState();
}

abstract class MapViewState<T extends GoogleMapsBaseMapView> extends State<T> {
  @protected
  void initMapViewListeners(int viewId) {
    if (widget.onMapClicked != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getMapClickEventStream(viewId: viewId)
          .listen((MapClickEvent event) {
        widget.onMapClicked!(event.target);
      });
    }

    if (widget.onMapLongClicked != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .getMapLongClickEventStream(viewId: viewId)
          .listen((MapLongClickEvent event) {
        widget.onMapLongClicked!(event.target);
      });
    }

    GoogleMapsNavigationPlatform.instance.viewAPI
        .getMarkerEventStream(viewId: viewId)
        .listen((MarkerEvent event) {
      switch (event.eventType) {
        case MarkerEventType.clicked:
          widget.onMarkerClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClicked:
          widget.onMarkerInfoWindowClicked?.call(event.markerId);
        case MarkerEventType.infoWindowClosed:
          widget.onMarkerInfoWindowClosed?.call(event.markerId);
        case MarkerEventType.infoWindowLongClicked:
          widget.onMarkerInfoWindowLongClicked?.call(event.markerId);
      }
    });

    GoogleMapsNavigationPlatform.instance.viewAPI
        .getMarkerDragEventStream(viewId: viewId)
        .listen((MarkerDragEvent event) {
      switch (event.eventType) {
        case MarkerDragEventType.drag:
          widget.onMarkerDrag?.call(event.markerId, event.position);
        case MarkerDragEventType.dragEnd:
          widget.onMarkerDragEnd?.call(event.markerId, event.position);
        case MarkerDragEventType.dragStart:
          widget.onMarkerDragStart?.call(event.markerId, event.position);
      }

      GoogleMapsNavigationPlatform.instance.viewAPI
          .getPolygonClickedEventStream(viewId: viewId)
          .listen((PolygonClickedEvent event) {
        widget.onPolygonClicked?.call(event.polygonId);
      });

      GoogleMapsNavigationPlatform.instance.viewAPI
          .getPolylineClickedEventStream(viewId: viewId)
          .listen((PolylineClickedEvent event) {
        widget.onPolylineClicked?.call(event.polylineId);
      });

      GoogleMapsNavigationPlatform.instance.viewAPI
          .getCircleClickedEventStream(viewId: viewId)
          .listen((CircleClickedEvent event) {
        widget.onCircleClicked?.call(event.circleId);
      });
    });

    if (widget.onCameraMoveStarted != null ||
        widget.onCameraMove != null ||
        widget.onCameraIdle != null) {
      GoogleMapsNavigationPlatform.instance.viewAPI
          .registerOnCameraChangedListener(viewId: viewId);
    }
    GoogleMapsNavigationPlatform.instance.viewAPI
        .getCameraChangedEventStream(viewId: viewId)
        .listen((CameraChangedEvent event) {
      switch (event.eventType) {
        case CameraEventType.moveStartedByApi:
          widget.onCameraMoveStarted?.call(event.position, false);
        case CameraEventType.moveStartedByGesture:
          widget.onCameraMoveStarted?.call(event.position, true);
        case CameraEventType.onCameraMove:
          widget.onCameraMove?.call(event.position);
        case CameraEventType.onCameraIdle:
          widget.onCameraIdle?.call(event.position);
        case CameraEventType.onCameraStartedFollowingLocation:
          widget.onCameraStartedFollowingLocation?.call(event.position);
        case CameraEventType.onCameraStoppedFollowingLocation:
          widget.onCameraStoppedFollowingLocation?.call(event.position);
      }
    });
  }
}

/// Google Maps Map View.
/// {@category Map View}
class GoogleMapsMapViewState extends MapViewState<GoogleMapsMapView> {
  @override
  Widget build(BuildContext context) {
    return GoogleMapsNavigationPlatform.instance.buildMapView(
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
        ),
        onMapReady: _onPlatformViewCreated);
  }

  /// Callback method when platform view is created.
  void _onPlatformViewCreated(int viewId) {
    initMapViewListeners(viewId);

    final GoogleMapViewController viewController =
        GoogleMapViewController(viewId);
    widget.onViewCreated(viewController);
  }
}
