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

import 'dart:ui';

import '../../google_maps_navigation.dart';

/// Navigation view recenter clicked event.
/// {@category Navigation View}
class NavigationViewRecenterButtonClickedEvent {}

/// Map type.
/// {@category Navigation View}
enum MapType {
  /// No type set.
  none,

  /// Normal map.
  normal,

  /// Satellite map.
  satellite,

  /// Terrain map.
  terrain,

  /// Hybrid map.
  hybrid,
}

/// Represents the camera position in a Google Maps view.
/// {@category Navigation View}
class CameraPosition {
  /// Creates a [CameraPosition] object.
  ///
  /// All parameters have default values of zero, with the [target]
  /// set to the geographical coordinates (0,0).
  const CameraPosition(
      {this.bearing = 0,
      this.target = const LatLng(latitude: 0, longitude: 0),
      this.tilt = 0,
      this.zoom = 0})
      : assert(0 <= bearing && bearing < 360,
            'Bearing must be between 0 and 360 degrees.'),
        assert(
            0 <= tilt && tilt <= 90, 'Tilt must be between 0 and 90 degrees.'),
        assert(googleMapsMinZoomLevel <= zoom && zoom <= googleMapsMaxZoomLevel,
            'Zoom must be between $googleMapsMinZoomLevel and $googleMapsMaxZoomLevel.');

  /// Bearing of the camera, in degrees clockwise from true north.
  final double bearing;

  /// The location that the camera is pointing at.
  final LatLng target;

  /// The angle, in degrees, of the camera angle from the nadir (directly facing the Earth).
  final double tilt;

  /// Zoom level near the center of the screen.
  final double zoom;
}

/// Parameter given to parameter given to the followMyLocation()
/// to specify the orientation of the camera.
/// {@category Navigation View}
enum CameraPerspective {
  /// A tilted perspective facing in the same direction as the user.
  tilted,

  /// A heading-facing top-down perspective of the camera's target.
  topDownHeadingUp,

  /// A north-facing top-down perspective of the camera's target.
  topDownNorthUp
}

/// Represents the click position in a Google Maps view.
/// {@category Navigation View}
class MapClickEvent {
  /// Creates a [MapClickEvent] object.
  const MapClickEvent(this.target);

  /// The location where the click happened.
  final LatLng target;
}

/// Represents the long click position in a Google Maps view.
/// {@category Navigation View}
class MapLongClickEvent {
  /// Creates a [MapLongClickEvent] object.
  const MapLongClickEvent(this.target);

  /// The location where the long click happened.
  final LatLng target;
}

/// Traffic data statuses
/// {@category Navigation View}
enum RouteSegmentTrafficDataStatus {
  /// OK
  ok,

  /// UNAVAILABLE
  unavailable,
}

/// Route segment traffic data road strech rendering data type.
/// {@category Navigation View}
class RouteSegmentTrafficDataRoadStretchRenderingData {
  /// Initialize with style, length and offset.
  RouteSegmentTrafficDataRoadStretchRenderingData({
    required this.style,
    required this.lengthMeters,
    required this.offsetMeters,
  });

  /// Rendering data style.
  final RouteSegmentTrafficDataRoadStretchRenderingDataStyle style;

  /// Length in meters.
  final int lengthMeters;

  /// Offset in meters.
  final int offsetMeters;
}

/// Route segment traffic data road strech rendering style.
/// {@category Navigation View}
enum RouteSegmentTrafficDataRoadStretchRenderingDataStyle {
  /// UNKNOWN.
  unknown,

  /// SLOWER TRAFFIC.
  slowerTraffic,

  /// TRAFFIC JAM.
  trafficJam
}

/// Route segment traffic data.
/// {@category Navigation View}
class RouteSegmentTrafficData {
  /// Initialize with status, and rendering data list.
  RouteSegmentTrafficData({
    required this.status,
    required this.roadStretchRenderingDataList,
  });

  /// Status.
  final RouteSegmentTrafficDataStatus status;

  /// Rendering data list.
  final List<RouteSegmentTrafficDataRoadStretchRenderingData?>
      roadStretchRenderingDataList;
}

/// Navigation route segment
/// {@category Navigation View}
class RouteSegment {
  /// Initialize with traffic data (Android only),
  /// destination coordinate, traveled route and destination waypoint.
  RouteSegment({
    this.trafficData,
    required this.destinationLatLng,
    required this.latLngs,
    required this.destinationWaypoint,
  });

  /// Traffic data (Android only).
  final RouteSegmentTrafficData? trafficData;

  /// Destination coordinate.
  final LatLng destinationLatLng;

  /// Traveled route.
  final List<LatLng?>? latLngs;

  /// Destination waypoint.
  final NavigationWaypoint? destinationWaypoint;
}

/// Internal camera update type.
/// {@category Navigation View}
enum CameraUpdateType {
  /// Camera update to a camera position.
  cameraPosition,

  /// Camera update to a co-ordinate.
  latLng,

  /// Camera update to bounded box on the Earth's surface.
  latLngBounds,

  /// Camera update to a co-ordinate and an absolute zoom value.
  latLngZoom,

  /// Camera update by scrolling the map.
  scrollBy,

  /// Camera update by zooming a specific amount.
  zoomBy,

  /// Camera update to an absolute zoom value.
  zoomTo
}

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
/// {@category Navigation View}
class CameraUpdate {
  CameraUpdate._(this.type);

  /// Returns a camera update that moves the camera to the specified position.
  static CameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.cameraPosition);
    update.cameraPosition = cameraPosition;
    return update;
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static CameraUpdate newLatLng(LatLng latLng) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.latLng);
    update.latLng = latLng;
    return update;
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [padding] insets the bounding box in
  /// logical pixels from the map view's edges.
  ///
  /// The camera's new tilt and bearing will both be 0.0.
  static CameraUpdate newLatLngBounds(LatLngBounds bounds,
      {double padding = 0.0}) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.latLngBounds);
    update.bounds = bounds;

    update.padding = padding;
    return update;
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static CameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.latLngZoom);
    update.latLng = latLng;
    update.zoom = zoom;
    return update;
  }

  /// Returns a camera update that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static CameraUpdate scrollBy(double dx, double dy) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.scrollBy);
    update.scrollByDx = dx;
    update.scrollByDy = dy;
    return update;
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static CameraUpdate zoomBy(double amount, {Offset? focus}) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.zoomBy);
    update.zoomByAmount = amount;

    update.focus = focus;
    return update;
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static CameraUpdate zoomIn() {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.zoomBy);
    update.zoomByAmount = 1.0;
    return update;
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static CameraUpdate zoomOut() {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.zoomBy);
    update.zoomByAmount = -1.0;
    return update;
  }

  /// Returns a camera update that sets the camera zoom level.
  static CameraUpdate zoomTo(double zoom) {
    final CameraUpdate update = CameraUpdate._(CameraUpdateType.zoomTo);
    update.zoom = zoom;
    return update;
  }

  /// Internal camera update type.
  final CameraUpdateType type;

  /// Camera update to a camera position.
  CameraPosition? cameraPosition;

  /// Camera update to a co-ordinate.
  LatLng? latLng;

  /// Camera update to bounded box on the Earth's surface.
  LatLngBounds? bounds;

  /// The padding added to the bounding box camera.
  double? padding;

  /// Camera update to an absolute zoom value.
  double? zoom;

  /// Camera update by zooming a specific amount.
  double? zoomByAmount;

  /// Camera update by scrolling longitude.
  double? scrollByDx;

  /// Camera update by scrolling latitude.
  double? scrollByDy;

  /// The screen position co-ordinates for the zoom-by camera.
  Offset? focus;
}
