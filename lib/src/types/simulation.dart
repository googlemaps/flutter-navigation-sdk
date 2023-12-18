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

/// Type for speed alert severity.
/// {@category Navigation}
enum SpeedAlertSeverity {
  /// Unknown severity.
  unknown,

  /// Not speeding severity.
  notSpeeding,

  /// Minor speeding severity.
  minor,

  /// Major speeding severity.
  major,
}

/// SpeedingUpdated event message.
/// {@category Navigation}
class SpeedingUpdatedEvent {
  /// Initialize speeding updated event message.
  SpeedingUpdatedEvent({
    required this.percentageAboveLimit,
    required this.severity,
  });

  /// Percentage above speed limit.
  final double percentageAboveLimit;

  /// Severity of the speeding.
  final SpeedAlertSeverity severity;
}

/// RoadSnappedLocationUpdated event message.
/// {@category Navigation}
class RoadSnappedLocationUpdatedEvent {
  /// Initialize road snapped location updated event message.
  RoadSnappedLocationUpdatedEvent({
    required this.location,
  });

  /// Coordinate of the updated location.
  final LatLng location;
}

/// RoadSnappedRawLocationUpdated event message.
/// {@category Navigation}
class RoadSnappedRawLocationUpdatedEvent {
  /// Initialize road snapped raw location updated event message.
  RoadSnappedRawLocationUpdatedEvent({
    required this.coordinate,
  });

  /// Coordinate of the updated location.
  final LatLng? coordinate;
}

/// Navigation simulation options.
/// {@category Navigation}
class SimulationOptions {
  /// Initialize navigation simulation options.
  SimulationOptions({
    required this.speedMultiplier,
  });

  /// Speed multiplier.
  final double speedMultiplier;
}

/// Converts speed alert severity from DTO
/// @nodoc
SpeedAlertSeverity navigationSpeedAlertSeverityFromDto(
    SpeedAlertSeverityDto severity) {
  switch (severity) {
    case SpeedAlertSeverityDto.unknown:
      return SpeedAlertSeverity.unknown;
    case SpeedAlertSeverityDto.notSpeeding:
      return SpeedAlertSeverity.notSpeeding;
    case SpeedAlertSeverityDto.minor:
      return SpeedAlertSeverity.minor;
    case SpeedAlertSeverityDto.major:
      return SpeedAlertSeverity.major;
  }
}

/// Converts navigation options to the Pigeon DTO format.
/// @nodoc
SimulationOptionsDto simulationOptionsToDto(SimulationOptions options) {
  return SimulationOptionsDto(speedMultiplier: options.speedMultiplier);
}

/// Converts speeding updated event message from Pigeon DTO.
/// @nodoc
SpeedingUpdatedEvent speedingUpdatedEventFromDto(SpeedingUpdatedEventDto msg) {
  return SpeedingUpdatedEvent(
      percentageAboveLimit: msg.percentageAboveLimit,
      severity: navigationSpeedAlertSeverityFromDto(msg.severity));
}

/// Converts road snapped location updated event message from Pigeon DTO.
/// @nodoc
RoadSnappedLocationUpdatedEvent roadSnappedLocationUpdatedEventFromDto(
    RoadSnappedLocationUpdatedEventDto msg) {
  return RoadSnappedLocationUpdatedEvent(
      location: LatLng(
          latitude: msg.location.latitude, longitude: msg.location.longitude));
}

/// Converts road snapped raw location updated event message from Pigeon DTO.
/// @nodoc
RoadSnappedRawLocationUpdatedEvent roadSnappedRawLocationUpdatedEventFromDto(
    RoadSnappedRawLocationUpdatedEventDto msg) {
  if (msg.location != null) {
    return RoadSnappedRawLocationUpdatedEvent(
      coordinate: LatLng(
          latitude: msg.location!.latitude, longitude: msg.location!.longitude),
    );
  } else {
    return RoadSnappedRawLocationUpdatedEvent(
      coordinate: null,
    );
  }
}

/// Remaining time or distance change event message.
/// {@category Navigation}
class RemainingTimeOrDistanceChangedEvent {
  /// Initialize with remaining distance in meters and remaining time in seconds.
  RemainingTimeOrDistanceChangedEvent({
    required this.remainingDistance,
    required this.remainingTime,
  });

  /// Remaining distance in meters.
  final double remainingDistance;

  /// Remaining time in seconds.
  final double remainingTime;
}

/// On arrival event message
/// {@category Navigation}
class OnArrivalEvent {
  /// Initialize with arrival waypoint.
  OnArrivalEvent({
    required this.waypoint,
  });

  /// Arrival waypoint.
  final NavigationWaypoint waypoint;
}

/// Converts remaining distance or remaining time changed event from Pigeon DTO.
/// @nodoc
RemainingTimeOrDistanceChangedEvent remainingTimeOrDistanceChangedEventFromDto(
    RemainingTimeOrDistanceChangedEventDto msg) {
  return RemainingTimeOrDistanceChangedEvent(
    remainingDistance: msg.remainingDistance,
    remainingTime: msg.remainingTime,
  );
}
