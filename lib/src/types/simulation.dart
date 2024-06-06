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

/// RoadSnappedRawLocationUpdated event message (Android only).
/// {@category Navigation}
class RoadSnappedRawLocationUpdatedEvent {
  /// Initialize road snapped raw location updated event message.
  RoadSnappedRawLocationUpdatedEvent({
    required this.location,
  });

  /// Coordinate of the updated location.
  final LatLng location;
}

/// GpsAvailabilityUpdated event message (Android only).
/// {@category Navigation}
class GpsAvailabilityUpdatedEvent {
  /// Initialize GPS availability updated event message.
  GpsAvailabilityUpdatedEvent({required this.available});

  /// GPS availability.
  final bool available;
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
