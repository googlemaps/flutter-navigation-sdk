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

import '../../google_navigation_flutter.dart';

/// Destinations main type.
///
/// Asserts if both [routeTokenOptions] and [routingOptions] are provided.
///
/// {@category Navigation}
class Destinations {
  /// Destinations initializer with waypoints and options.
  Destinations({
    required this.waypoints,
    required this.displayOptions,
    this.routingOptions,
    this.routeTokenOptions,
  }) : assert(routeTokenOptions == null || routingOptions == null,
            'Only one of routeTokenOptions or routingOptions can be provided');

  /// List of navigation waypoints.
  final List<NavigationWaypoint> waypoints;

  /// Navigation display options.
  final NavigationDisplayOptions displayOptions;

  /// Navigation routing options.
  final RoutingOptions? routingOptions;

  /// Navigation route token options.
  final RouteTokenOptions? routeTokenOptions;
}

/// Provides options for routing using a route token
/// in the Google Maps Navigation SDK.
///
/// This class is used to specify routing preferences when using the
/// [GoogleMapsNavigator.setDestinations] method. It allows the integration
/// of a predefined route token, which the SDK can utilize for
/// routing if possible.
///
/// {@category Navigation}
class RouteTokenOptions {
  /// Route token options initializer with token and travel mode.
  ///
  /// The [travelMode] must match the travel mode used to generate
  /// the [routeToken].
  RouteTokenOptions({
    required this.routeToken,
    required this.travelMode,
  });

  /// Route token.
  final String routeToken;

  /// Specifies the type of [NavigationTravelMode] used to determine the
  /// navigation directions.
  ///
  /// It must match the travel mode used to generate the [routeToken].
  /// If there is a mismatch, [travelMode] will override the travel mode used to
  /// generate the [routeToken].
  final NavigationTravelMode? travelMode;
}

/// Alternative routes strategy.
/// {@category Navigation}
enum NavigationAlternateRoutesStrategy {
  /// All.
  all,

  /// None.
  none,

  /// One.
  one,
}

/// Routing strategy.
/// {@category Navigation}
enum NavigationRoutingStrategy {
  /// DefaultBest.
  defaultBest,

  /// DeltaToTargetDistance.
  deltaToTargetDistance,

  /// Shorter.
  shorter,
}

/// Travel model for routing options.
/// {@category Navigation}
enum NavigationTravelMode {
  /// Driving.
  driving,

  /// Cycling.
  cycling,

  /// Walking.
  walking,

  /// Two wheeler.
  twoWheeler,

  /// Taxi.
  taxi,
}

/// Routing options.
/// {@category Navigation}
class RoutingOptions {
  /// Routing options initializer with options.
  RoutingOptions({
    this.alternateRoutesStrategy,
    this.routingStrategy,
    this.targetDistanceMeters,
    this.travelMode,
    this.avoidTolls,
    this.avoidFerries,
    this.avoidHighways,
    this.locationTimeoutMs,
  });

  /// Alternate routes strategy.
  final NavigationAlternateRoutesStrategy? alternateRoutesStrategy;

  /// Routing strategy.
  final NavigationRoutingStrategy? routingStrategy;

  /// Target distance meters.
  final List<int?>? targetDistanceMeters;

  /// Travel mode
  final NavigationTravelMode? travelMode;

  /// Tolls should be avoided.
  final bool? avoidTolls;

  /// Ferries should be avoided.
  final bool? avoidFerries;

  /// Highways should be avoided.
  final bool? avoidHighways;

  /// Maximum time to wait for a location fix before failure. (Only Android)
  final int? locationTimeoutMs;
}

/// Display options.
///
/// By default, the destination markers are shown, stop signs
/// and traffic lights are not.
/// {@category Navigation}
class NavigationDisplayOptions {
  /// Initializer for display options.
  NavigationDisplayOptions({
    this.showDestinationMarkers,
    this.showStopSigns,
    this.showTrafficLights,
  });

  /// Show destination markers.
  final bool? showDestinationMarkers;

  /// Show stop signs.
  final bool? showStopSigns;

  /// Show traffic lights.
  final bool? showTrafficLights;
}

/// Navigation waypoint with different constructors based in on type of
/// initialization.
/// {@category Navigation}
class NavigationWaypoint {
  /// Initializer for [NavigationWaypoint].
  NavigationWaypoint({
    required this.title,
    this.target,
    this.placeID,
    this.preferSameSideOfRoad,
    this.preferredSegmentHeading,
  }) : assert(target != null || placeID != null,
            'Either target or placeID must be provided');

  /// Initialize waypoint with coordinates.
  NavigationWaypoint.withLatLngTarget({
    required this.title,
    required this.target,
  });

  /// Initialize waypoint with coordinates and same side of road preference.
  NavigationWaypoint.withPreferSameSideOfRoad({
    required this.title,
    required this.target,
    required this.preferSameSideOfRoad,
  });

  /// Initialize waypoint with coordinates and preferred segment heading.
  NavigationWaypoint.withPreferredSegmentHeading({
    required this.title,
    required this.target,
    required this.preferredSegmentHeading,
  });

  /// Initialize waypoint with placeID.
  NavigationWaypoint.withPlaceID({
    required this.title,
    required this.placeID,
  });

  /// Title of the waypoint.
  final String title;

  /// Target in as [LatLng].
  LatLng? target;

  /// Place ID of the waypoint.
  String? placeID;

  /// Prefer to arrive on the same side of the road as the waypoint—snapped to
  /// the nearest sidewalk.
  bool? preferSameSideOfRoad;

  /// Preferred segment heading of the waypoint.
  ///
  /// An arrival heading that matches the direction of traffic flow on the same
  /// side of the road as the waiting consumer.
  ///
  /// The Navigation SDK chooses the road segment closest to the waypoint—that
  /// has a lane direction that aligns (within +/- 55 degrees) with the side of
  /// the road that the waypoint is on.
  int? preferredSegmentHeading;
}

/// Status of the navigation routing.
/// {@category Navigation}
enum NavigationRouteStatus {
  /// Internal error.
  internalError,

  /// Status ok.
  statusOk,

  /// Route not found.
  routeNotFound,

  /// Network error.
  networkError,

  /// Quota exceeded.
  quotaExceeded,

  /// API key not authorized.
  apiKeyNotAuthorized,

  /// Status canceled.
  statusCanceled,

  /// Duplicate waypoints error.
  duplicateWaypointsError,

  /// No waypoints error.
  noWaypointsError,

  /// Location unavailable.
  locationUnavailable,

  /// Waypoint error.
  waypointError,

  /// Travel mode unsupported.
  travelModeUnsupported,

  /// Unknown.
  unknown,

  /// Location unknown.
  locationUnknown,

  /// Quota check failed
  quotaCheckFailed
}

/// Time and distance to next waypoint.
/// {@category Navigation}
class NavigationTimeAndDistance {
  /// Initialize with time and distance.
  NavigationTimeAndDistance({
    required this.time,
    required this.distance,
  });

  /// Time to destination.
  final double time;

  /// Distance to destination.
  final double distance;
}

/// Navigation audio guidance type.
/// {@category Navigation}
enum NavigationAudioGuidanceType {
  /// Silent.
  silent,

  /// Alerts only.
  alertsOnly,

  /// Alerts and guidance.
  alertsAndGuidance,
}

/// Navigation audio guidance settings.
/// {@category Navigation}
class NavigationAudioGuidanceSettings {
  /// Initialize with options and guidance type.
  NavigationAudioGuidanceSettings({
    this.isBluetoothAudioEnabled,
    this.isVibrationEnabled,
    this.guidanceType,
  });

  /// Is Bluetooth audio enabled.
  final bool? isBluetoothAudioEnabled;

  /// Is vibration enabled.
  final bool? isVibrationEnabled;

  /// Guidance type.
  final NavigationAudioGuidanceType? guidanceType;
}
