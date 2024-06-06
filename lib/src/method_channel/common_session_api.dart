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
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../google_navigation_flutter.dart';
import '../google_navigation_flutter_platform_interface.dart';
import 'convert/navigation_waypoint.dart';
import 'method_channel.dart';

/// @nodoc
/// CommonNavigationSessionAPI handles navigation session API
/// actions that are common to both iOS and Android.
mixin CommonNavigationSessionAPI implements NavigationSessionAPIInterface {
  bool _sessionApiHasBeenSetUp = false;

  /// Navigation session pigeon API.
  final NavigationSessionApi _sessionApi = NavigationSessionApi();

  /// Stream controllers for events.
  final StreamController<Object> _sessionEventStreamController =
      StreamController<Object>.broadcast();

  /// This function ensures that the event API has been setup. This should be
  /// called when initializing navigation session.
  void ensureSessionAPISetUp() {
    if (!_sessionApiHasBeenSetUp) {
      NavigationSessionEventApi.setup(
        NavigationSessionEventApiImpl(
          sessionEventStreamController: _sessionEventStreamController,
        ),
      );
      _sessionApiHasBeenSetUp = true;
    }
  }

  /// Creates navigation session in the native platform and returns navigation session controller.
  @override
  Future<void> createNavigationSession(
      bool abnormalTerminationReportingEnabled) async {
    // Setup session API streams.
    ensureSessionAPISetUp();
    try {
      // Create native navigation session manager.
      await _sessionApi
          .createNavigationSession(abnormalTerminationReportingEnabled);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'notAuthorized':
          throw const SessionInitializationException(
              SessionInitializationError.notAuthorized);
        case 'locationPermissionMissing':
          throw const SessionInitializationException(
              SessionInitializationError.locationPermissionMissing);
        case 'termsNotAccepted':
          throw const SessionInitializationException(
              SessionInitializationError.termsNotAccepted);
        default:
          rethrow;
      }
    }
  }

  @override
  Future<bool> isInitialized() async {
    return _sessionApi.isInitialized();
  }

  @override
  Future<void> cleanup() async {
    try {
      return await _sessionApi.cleanup();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Show terms and conditions dialog.
  @override
  Future<bool> showTermsAndConditionsDialog(String title, String companyName,
      bool shouldOnlyShowDriverAwarenessDisclaimer) async {
    try {
      return await _sessionApi.showTermsAndConditionsDialog(
          title, companyName, shouldOnlyShowDriverAwarenessDisclaimer);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'notSupported':
          if (Platform.isIOS && shouldOnlyShowDriverAwarenessDisclaimer) {
            throw UnsupportedError(
                'Driver awareness disclaimer is currently not supported on iOS.');
          } else {
            rethrow;
          }
        default:
          rethrow;
      }
    }
  }

  /// Check if terms of service has been accepted.
  @override
  Future<bool> areTermsAccepted() {
    return _sessionApi.areTermsAccepted();
  }

  /// Resets terms of service acceptance state.
  @override
  Future<void> resetTermsAccepted() async {
    try {
      return await _sessionApi.resetTermsAccepted();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'termsResetNotAllowed':
          throw const ResetTermsAndConditionsException();
        default:
          rethrow;
      }
    }
  }

  @override
  Future<String> getNavSDKVersion() {
    try {
      return _sessionApi.getNavSDKVersion();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  @override
  Future<bool> isGuidanceRunning() async {
    try {
      return await _sessionApi.isGuidanceRunning();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Starts navigation guidance.
  @override
  Future<void> startGuidance() async {
    try {
      return await _sessionApi.startGuidance();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Stops navigation guidance.
  @override
  Future<void> stopGuidance() async {
    try {
      return await _sessionApi.stopGuidance();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Sets destination waypoints and other settings.
  @override
  Future<NavigationRouteStatus> setDestinations(Destinations msg) async {
    try {
      final RouteStatusDto status =
          await _sessionApi.setDestinations(msg.toDto());

      return status.toNavigationRouteStatus();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        case 'routeTokenMalformed':
          throw const RouteTokenMalformedException();
        default:
          rethrow;
      }
    }
  }

  /// Clears destinations.
  @override
  Future<void> clearDestinations() async {
    try {
      return await _sessionApi.clearDestinations();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Continues to next waypoint.
  @override
  Future<NavigationWaypoint?> continueToNextDestination() async {
    try {
      final NavigationWaypointDto? waypointDto =
          await _sessionApi.continueToNextDestination();
      if (waypointDto == null) {
        return null;
      }
      return waypointDto.toNavigationWaypoint();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Gets current time and distance left.
  @override
  Future<NavigationTimeAndDistance> getCurrentTimeAndDistance() async {
    try {
      final NavigationTimeAndDistanceDto timeAndDistance =
          await _sessionApi.getCurrentTimeAndDistance();
      return timeAndDistance.toNavigationTimeAndDistance();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Sets audio guidance settings.
  @override
  Future<void> setAudioGuidance(
      NavigationAudioGuidanceSettings settings) async {
    try {
      return await _sessionApi.setAudioGuidance(settings.toDto());
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Sets user location for simulation.
  @override
  Future<void> setUserLocation(LatLng location) async {
    try {
      return await _sessionApi.setUserLocation(location.toDto());
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Unsets previously set user location for the simulation.
  @override
  Future<void> removeUserLocation() async {
    try {
      return await _sessionApi.removeUserLocation();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Simulates locations along existing route.
  @override
  Future<void> simulateLocationsAlongExistingRoute() async {
    try {
      return await _sessionApi.simulateLocationsAlongExistingRoute();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Simulates locations along existing route with simulation options.
  @override
  Future<void> simulateLocationsAlongExistingRouteWithOptions(
      SimulationOptions options) async {
    try {
      return await _sessionApi.simulateLocationsAlongExistingRouteWithOptions(
          simulationOptionsToDto(options));
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Simulates locations along new route.
  @override
  Future<NavigationRouteStatus> simulateLocationsAlongNewRoute(
      List<NavigationWaypoint> waypoints) async {
    try {
      final RouteStatusDto routeStatus =
          await _sessionApi.simulateLocationsAlongNewRoute(waypoints.map(
        (NavigationWaypoint e) {
          return e.toDto();
        },
      ).toList());
      return routeStatus.toNavigationRouteStatus();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Simulates locations along new route with routing and simulation options.
  @override
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
          List<NavigationWaypoint> waypoints,
          RoutingOptions routingOptions,
          SimulationOptions simulationOptions) async {
    try {
      final RouteStatusDto routeStatus = await _sessionApi
          .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
        waypoints.map(
          (NavigationWaypoint e) {
            return e.toDto();
          },
        ).toList(),
        routingOptions.toDto(),
        simulationOptionsToDto(simulationOptions),
      );
      return routeStatus.toNavigationRouteStatus();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Simulates locations along new route with routing options.
  @override
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingOptions(
          List<NavigationWaypoint> waypoints,
          RoutingOptions routingOptions) async {
    try {
      final RouteStatusDto routeStatus =
          await _sessionApi.simulateLocationsAlongNewRouteWithRoutingOptions(
        waypoints.map(
          (NavigationWaypoint e) {
            return e.toDto();
          },
        ).toList(),
        routingOptions.toDto(),
      );
      return routeStatus.toNavigationRouteStatus();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Pauses simulation.
  @override
  Future<void> pauseSimulation() async {
    try {
      return await _sessionApi.pauseSimulation();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Resumes simulation.
  @override
  Future<void> resumeSimulation() async {
    try {
      return await _sessionApi.resumeSimulation();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Sets state of allow background location updates. (iOS only)
  @override
  Future<void> allowBackgroundLocationUpdates(bool allow) async {
    try {
      return await _sessionApi.allowBackgroundLocationUpdates(allow);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Enables road snapped location updates.
  @override
  Future<void> enableRoadSnappedLocationUpdates() async {
    try {
      return await _sessionApi.enableRoadSnappedLocationUpdates();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Disables road snapped location updates.
  @override
  Future<void> disableRoadSnappedLocationUpdates() async {
    try {
      return await _sessionApi.disableRoadSnappedLocationUpdates();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Enables navigation info updates.
  @override
  Future<void> enableTurnByTurnNavigationEvents(
      int? numNextStepsToPreview) async {
    try {
      return await _sessionApi
          .enableTurnByTurnNavigationEvents(numNextStepsToPreview);
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Disables navigation info updates.
  @override
  Future<void> disableTurnByTurnNavigationEvents() async {
    try {
      return await _sessionApi.disableTurnByTurnNavigationEvents();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Get route segments.
  @override
  Future<List<RouteSegment>> getRouteSegments() async {
    try {
      final List<RouteSegmentDto?> routeSegments =
          await _sessionApi.getRouteSegments();
      return routeSegments
          .where((RouteSegmentDto? p) => p != null)
          .cast<RouteSegmentDto>()
          .map((RouteSegmentDto s) => s.toRouteSegment())
          .toList();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Get traveled route.
  @override
  Future<List<LatLng>> getTraveledRoute() async {
    try {
      final List<LatLngDto?> traveledRoute =
          await _sessionApi.getTraveledRoute();
      return traveledRoute
          .where((LatLngDto? p) => p != null)
          .cast<LatLngDto>()
          .map((LatLngDto p) =>
              LatLng(latitude: p.latitude, longitude: p.longitude))
          .toList();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Get current route segment.
  @override
  Future<RouteSegment?> getCurrentRouteSegment() async {
    try {
      final RouteSegmentDto? currentRouteSegment =
          await _sessionApi.getCurrentRouteSegment();
      return currentRouteSegment?.toRouteSegment();
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'sessionNotInitialized':
          throw const SessionNotInitializedException();
        default:
          rethrow;
      }
    }
  }

  /// Get event stream for speeding.
  @override
  Stream<SpeedingUpdatedEvent> getNavigationSpeedingEventStream() {
    return _sessionEventStreamController.stream
        .whereType<SpeedingUpdatedEventDto>()
        .map((SpeedingUpdatedEventDto event) => event.toSpeedingUpdatedEvent());
  }

  /// Get event stream for road snapped location updates.
  @override
  Stream<RoadSnappedLocationUpdatedEvent>
      getNavigationRoadSnappedLocationEventStream() {
    return _sessionEventStreamController.stream
        .whereType<RoadSnappedLocationUpdatedEvent>();
  }

  /// Get event stream for road snapped location updates.
  @override
  Stream<RoadSnappedRawLocationUpdatedEvent>
      getNavigationRoadSnappedRawLocationEventStream() {
    return _sessionEventStreamController.stream
        .whereType<RoadSnappedRawLocationUpdatedEvent>();
  }

  /// Get navigation on arrival event stream from the navigation session.
  @override
  Stream<OnArrivalEvent> getNavigationOnArrivalEventStream() {
    return _sessionEventStreamController.stream.whereType<OnArrivalEvent>();
  }

  /// Get navigation on rerouting event stream from the navigation session.
  @override
  Stream<void> getNavigationOnReroutingEventStream() {
    return _sessionEventStreamController.stream
        .whereType<_ReroutingEvent>()
        .map((_ReroutingEvent event) => ());
  }

  /// Get navigation on GPS availability update event stream from the navigation session.
  @override
  Stream<GpsAvailabilityUpdatedEvent>
      getNavigationOnGpsAvailabilityUpdateEventStream() {
    return _sessionEventStreamController.stream
        .whereType<GpsAvailabilityUpdatedEvent>();
  }

  /// Get navigation traffic updated event stream from the navigation session.
  @override
  Stream<void> getNavigationTrafficUpdatedEventStream() {
    return _sessionEventStreamController.stream
        .whereType<_TrafficUpdatedEvent>()
        .map((_TrafficUpdatedEvent event) => ());
  }

  /// Get navigation on route changed event stream from the navigation session.
  @override
  Stream<void> getNavigationOnRouteChangedEventStream() {
    return _sessionEventStreamController.stream
        .whereType<_RouteChangedEvent>()
        .map((_RouteChangedEvent event) => ());
  }

  /// Get navigation remaining time or distance event stream from the navigation session.
  @override
  Stream<RemainingTimeOrDistanceChangedEvent>
      getNavigationRemainingTimeOrDistanceChangedEventStream() {
    return _sessionEventStreamController.stream
        .whereType<RemainingTimeOrDistanceChangedEvent>();
  }

  @override
  Future<void> registerRemainingTimeOrDistanceChangedListener(
      int remainingTimeThresholdSeconds, int remainingDistanceThresholdMeters) {
    return _sessionApi.registerRemainingTimeOrDistanceChangedListener(
        remainingTimeThresholdSeconds, remainingDistanceThresholdMeters);
  }

  /// Get navigation info event stream from the navigation session.
  @override
  Stream<NavInfoEvent> getNavInfoStream() {
    return _sessionEventStreamController.stream.whereType<NavInfoEvent>();
  }
}

/// Implementation for navigation session event API event handling.
class NavigationSessionEventApiImpl implements NavigationSessionEventApi {
  /// Initialize implementation for NavigationSessionEventApi.
  const NavigationSessionEventApiImpl({
    required this.sessionEventStreamController,
  });

  /// Stream for navigation view events.
  final StreamController<Object> sessionEventStreamController;

  @override
  void onSpeedingUpdated(SpeedingUpdatedEventDto event) {
    sessionEventStreamController.add(event);
  }

  @override
  void onArrival(NavigationWaypointDto waypoint) {
    sessionEventStreamController
        .add(OnArrivalEvent(waypoint: waypoint.toNavigationWaypoint()));
  }

  @override
  void onRerouting() {
    sessionEventStreamController.add(_ReroutingEvent());
  }

  @override
  void onGpsAvailabilityUpdate(bool available) {
    sessionEventStreamController
        .add(GpsAvailabilityUpdatedEvent(available: available));
  }

  @override
  void onRouteChanged() {
    sessionEventStreamController.add(_RouteChangedEvent());
  }

  @override
  void onTrafficUpdated() {
    sessionEventStreamController.add(_TrafficUpdatedEvent());
  }

  @override
  void onRoadSnappedLocationUpdated(LatLngDto location) {
    sessionEventStreamController
        .add(RoadSnappedLocationUpdatedEvent(location: location.toLatLng()));
  }

  // Android only.
  @override
  void onRoadSnappedRawLocationUpdated(LatLngDto location) {
    sessionEventStreamController
        .add(RoadSnappedRawLocationUpdatedEvent(location: location.toLatLng()));
  }

  @override
  void onRemainingTimeOrDistanceChanged(
      double remainingTime, double remainingDistance) {
    sessionEventStreamController.add(RemainingTimeOrDistanceChangedEvent(
        remainingTime: remainingTime, remainingDistance: remainingDistance));
  }

  @override
  void onNavInfo(NavInfoDto navInfo) {
    sessionEventStreamController
        .add(NavInfoEvent(navInfo: navInfo.toNavInfo()));
  }
}

/// Event wrapper for a route update events.
class _RouteChangedEvent {}

/// Event wrapper for a rerouting events.
class _ReroutingEvent {}

/// Event wrapper for a traffic updated events.
class _TrafficUpdatedEvent {}
