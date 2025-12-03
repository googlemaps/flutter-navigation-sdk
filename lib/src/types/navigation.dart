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

import 'lat_lng.dart';
import 'navigation_destinations.dart';

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

  @override
  String toString() =>
      'SpeedingUpdatedEvent('
      'percentageAboveLimit: $percentageAboveLimit, '
      'severity: $severity'
      ')';
}

/// RoadSnappedLocationUpdated event message.
/// {@category Navigation}
class RoadSnappedLocationUpdatedEvent {
  /// Initialize road snapped location updated event message.
  RoadSnappedLocationUpdatedEvent({required this.location});

  /// Coordinate of the updated location.
  final LatLng location;

  @override
  String toString() => 'RoadSnappedLocationUpdatedEvent(location: $location)';
}

/// RoadSnappedRawLocationUpdated event message (Android only).
/// {@category Navigation}
class RoadSnappedRawLocationUpdatedEvent {
  /// Initialize road snapped raw location updated event message.
  RoadSnappedRawLocationUpdatedEvent({required this.location});

  /// Coordinate of the updated location.
  final LatLng location;

  @override
  String toString() =>
      'RoadSnappedRawLocationUpdatedEvent(location: $location)';
}

/// GpsAvailabilityUpdated event message (Android only).
/// {@category Navigation}
@Deprecated(
  'Use getNavigationOnGpsAvailabilityChangeEventStream and GpsAvailabilityChangeEvent instead',
)
class GpsAvailabilityUpdatedEvent {
  /// Initialize GPS availability updated event message.
  GpsAvailabilityUpdatedEvent({required this.available});

  /// GPS availability.
  final bool available;

  @override
  String toString() => 'GpsAvailabilityUpdatedEvent(available: $available)';
}

/// GpsAvailabilityChange event message (Android only).
/// {@category Navigation}
class GpsAvailabilityChangeEvent {
  /// Initialize GPS availability change event message.
  GpsAvailabilityChangeEvent({
    required this.isGpsLost,
    required this.isGpsValidForNavigation,
  });

  /// Indicates a GPS signal or other sensors good enough for a reasonably certain location have been lost.
  ///
  /// This state is triggered after a short timeout (10 seconds) and serves as an early warning of potential signal issues.
  /// For example, the "Searching for GPS" UI message may be shown when this value is true.
  final bool isGpsLost;

  /// Indicates a GPS signal or other sensors are in general good enough for use in navigation.
  ///
  /// Note that this value takes into account the frequent failure of GPS at the start of nav,
  /// and doesn't become true until some time later.
  final bool isGpsValidForNavigation;

  @override
  String toString() =>
      'GpsAvailabilityChangeEvent('
      'isGpsLost: $isGpsLost, '
      'isGpsValidForNavigation: $isGpsValidForNavigation'
      ')';
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

  @override
  String toString() =>
      'RemainingTimeOrDistanceChangedEvent('
      'remainingDistance: $remainingDistance, '
      'remainingTime: $remainingTime'
      ')';
}

/// On arrival event message
/// {@category Navigation}
class OnArrivalEvent {
  /// Initialize with arrival waypoint.
  OnArrivalEvent({required this.waypoint});

  /// Arrival waypoint.
  final NavigationWaypoint waypoint;

  @override
  String toString() => 'OnArrivalEvent(waypoint: $waypoint)';
}
