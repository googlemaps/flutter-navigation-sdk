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

import '../../google_maps_navigation.dart';

/// Destinations main type.
/// {@category Navigation}
class Destinations {
  /// Destinations initializer with waypoints and options.
  Destinations({
    required this.waypoints,
    required this.displayOptions,
    this.routingOptions,
  });

  /// List of navigation waypoints.
  final List<NavigationWaypoint> waypoints;

  /// Navigation display options.
  final NavigationDisplayOptions displayOptions;

  /// Navigation routing options.
  final RoutingOptions? routingOptions;
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
  NavigationWaypoint._({
    required this.title,
    this.target,
    this.placeID,
    this.preferSameSideOfRoad,
    this.preferredSegmentHeading,
  });

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

  /// Same side of the road preference of the waypoint.
  bool? preferSameSideOfRoad;

  /// Preferred segment heading of the waypoint.
  int? preferredSegmentHeading;
}

/// Navigation event messages that are returned from the native platforms.
/// {@category Navigation}
class NavigationSessionEvent {
  /// Initializer for the event with type and message.
  NavigationSessionEvent({
    required this.type,
    required this.message,
  });

  /// Type of the event
  final NavigationSessionEventType type;

  /// Message of the event.
  final String message;
}

/// Navigation Session events that returned from the native platforms.
/// {@category Navigation}
enum NavigationSessionEventType {
  /// Arrival event.
  arrivalEvent,

  ///Route changes event.
  routeChanged,

  /// Error received event.
  errorReceived;
}

/// Converts navigation session event message from DTO.
/// @nodoc
NavigationSessionEvent navigationSessionEventFromDto(
    NavigationSessionEventDto msg) {
  final NavigationSessionEventType type = (() {
    switch (msg.type) {
      case NavigationSessionEventTypeDto.arrivalEvent:
        return NavigationSessionEventType.arrivalEvent;
      case NavigationSessionEventTypeDto.routeChanged:
        return NavigationSessionEventType.routeChanged;
      case NavigationSessionEventTypeDto.errorReceived:
        return NavigationSessionEventType.errorReceived;
    }
  })();

  return NavigationSessionEvent(
    type: type,
    message: msg.message,
  );
}

/// Converts navigation destination to the Pigeon DTO format.
/// @nodoc
DestinationsDto navigationDestinationToDto(Destinations data) {
  return DestinationsDto(
      waypoints: data.waypoints.map(
        (NavigationWaypoint e) {
          return navigationWaypointToDto(e);
        },
      ).toList(),
      displayOptions: navigationDisplayOptionsToDto(data.displayOptions),
      routingOptions: data.routingOptions == null
          ? null
          : routingOptionsToDto(data.routingOptions!));
}

/// Converts waypoint from the Pigeon DTO format.
/// @nodoc
NavigationWaypoint navigationWaypointFromDto(NavigationWaypointDto waypoint) {
  return NavigationWaypoint._(
    title: waypoint.title,
    target: waypoint.target != null ? latLngFromDto(waypoint.target!) : null,
    placeID: waypoint.placeID,
    preferSameSideOfRoad: waypoint.preferSameSideOfRoad,
    preferredSegmentHeading: waypoint.preferredSegmentHeading,
  );
}

/// Converts waypoint to the Pigeon DTO format.
/// @nodoc
NavigationWaypointDto navigationWaypointToDto(NavigationWaypoint waypoint) {
  return NavigationWaypointDto(
    title: waypoint.title,
    target: waypoint.target != null ? latLngToDto(waypoint.target!) : null,
    placeID: waypoint.placeID,
    preferSameSideOfRoad: waypoint.preferSameSideOfRoad,
    preferredSegmentHeading: waypoint.preferredSegmentHeading,
  );
}

/// Converts display options to the Pigeon DTO format.
/// @nodoc
NavigationDisplayOptionsDto navigationDisplayOptionsToDto(
    NavigationDisplayOptions options) {
  return NavigationDisplayOptionsDto(
    showDestinationMarkers: options.showDestinationMarkers,
    showStopSigns: options.showStopSigns,
    showTrafficLights: options.showTrafficLights,
  );
}

/// Converts travel model to the Pigeon DTO format.
/// @nodoc
TravelModeDto? navigationTravelModeToDto(NavigationTravelMode? travelMode) {
  switch (travelMode) {
    case NavigationTravelMode.driving:
      return TravelModeDto.driving;
    case NavigationTravelMode.cycling:
      return TravelModeDto.cycling;
    case NavigationTravelMode.walking:
      return TravelModeDto.walking;
    case NavigationTravelMode.twoWheeler:
      return TravelModeDto.twoWheeler;
    case NavigationTravelMode.taxi:
      return TravelModeDto.taxi;
    case null:
      return null;
  }
}

/// Converts routing options to the Pigeon DTO format.
/// @nodoc
RoutingOptionsDto routingOptionsToDto(RoutingOptions options) {
  return RoutingOptionsDto(
    alternateRoutesStrategy:
        navigationAlternateRoutesStrategyToDto(options.alternateRoutesStrategy),
    routingStrategy:
        navigationRoutingStrategyToPigeonFormat(options.routingStrategy),
    targetDistanceMeters: options.targetDistanceMeters,
    travelMode: navigationTravelModeToDto(options.travelMode),
    avoidFerries: options.avoidFerries,
    avoidHighways: options.avoidHighways,
    avoidTolls: options.avoidTolls,
    locationTimeoutMs: options.locationTimeoutMs,
  );
}

/// Converts alternate routes strategy to the Pigeon DTO format.
/// @nodoc
AlternateRoutesStrategyDto? navigationAlternateRoutesStrategyToDto(
    NavigationAlternateRoutesStrategy? strategy) {
  switch (strategy) {
    case NavigationAlternateRoutesStrategy.all:
      return AlternateRoutesStrategyDto.all;
    case NavigationAlternateRoutesStrategy.none:
      return AlternateRoutesStrategyDto.none;
    case NavigationAlternateRoutesStrategy.one:
      return AlternateRoutesStrategyDto.one;
    case null:
      return null;
  }
}

/// Converts routing strategy to the Pigeon DTO format.
/// @nodoc
RoutingStrategyDto? navigationRoutingStrategyToPigeonFormat(
    NavigationRoutingStrategy? strategy) {
  switch (strategy) {
    case NavigationRoutingStrategy.defaultBest:
      return RoutingStrategyDto.defaultBest;
    case NavigationRoutingStrategy.deltaToTargetDistance:
      return RoutingStrategyDto.deltaToTargetDistance;
    case NavigationRoutingStrategy.shorter:
      return RoutingStrategyDto.shorter;
    case null:
      return null;
  }
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

/// Converts route status from the Pigeon DTO format.
/// @nodoc
NavigationRouteStatus navigationRouteStatusFromDto(RouteStatusDto status) {
  switch (status) {
    case RouteStatusDto.internalError:
      return NavigationRouteStatus.internalError;
    case RouteStatusDto.statusOk:
      return NavigationRouteStatus.statusOk;
    case RouteStatusDto.routeNotFound:
      return NavigationRouteStatus.routeNotFound;
    case RouteStatusDto.networkError:
      return NavigationRouteStatus.networkError;
    case RouteStatusDto.quotaExceeded:
      return NavigationRouteStatus.quotaExceeded;
    case RouteStatusDto.apiKeyNotAuthorized:
      return NavigationRouteStatus.apiKeyNotAuthorized;
    case RouteStatusDto.statusCanceled:
      return NavigationRouteStatus.statusCanceled;
    case RouteStatusDto.duplicateWaypointsError:
      return NavigationRouteStatus.duplicateWaypointsError;
    case RouteStatusDto.noWaypointsError:
      return NavigationRouteStatus.noWaypointsError;
    case RouteStatusDto.locationUnavailable:
      return NavigationRouteStatus.locationUnavailable;
    case RouteStatusDto.waypointError:
      return NavigationRouteStatus.waypointError;
    case RouteStatusDto.travelModeUnsupported:
      return NavigationRouteStatus.travelModeUnsupported;
    case RouteStatusDto.unknown:
      return NavigationRouteStatus.unknown;
    case RouteStatusDto.locationUnknown:
      return NavigationRouteStatus.locationUnknown;
    case RouteStatusDto.quotaCheckFailed:
      return NavigationRouteStatus.quotaCheckFailed;
  }
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

/// Converts time and distance from the Pigeon DTO format.
/// @nodoc
NavigationTimeAndDistance navigationTimeAndDistanceFromDto(
    NavigationTimeAndDistanceDto td) {
  return NavigationTimeAndDistance(time: td.time, distance: td.distance);
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

/// Converts audio guidance settings to the Pigeon DTO format.
/// @nodoc
NavigationAudioGuidanceSettingsDto navigationAudioGuidanceSettingsToDto(
    NavigationAudioGuidanceSettings settings) {
  final AudioGuidanceTypeDto? guidanceType = (() {
    switch (settings.guidanceType) {
      case NavigationAudioGuidanceType.silent:
        return AudioGuidanceTypeDto.silent;
      case NavigationAudioGuidanceType.alertsAndGuidance:
        return AudioGuidanceTypeDto.alertsAndGuidance;
      case NavigationAudioGuidanceType.alertsOnly:
        return AudioGuidanceTypeDto.alertsOnly;
      case null:
        return null;
    }
  })();
  return NavigationAudioGuidanceSettingsDto(
    isBluetoothAudioEnabled: settings.isBluetoothAudioEnabled,
    isVibrationEnabled: settings.isVibrationEnabled,
    guidanceType: guidanceType,
  );
}
