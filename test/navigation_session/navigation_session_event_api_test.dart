// Copyright 2025 Google LLC
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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

import '../helpers/mock_navigation_session_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Session Event Streams', () {
    late TestNavigationSessionAPIImpl testSessionApi;

    setUp(() {
      // Create test session API that allows direct DTO injection
      testSessionApi = TestNavigationSessionAPIImpl();
      testSessionApi.ensureSessionAPISetUp();
    });

    test('SpeedingUpdatedEvent stream delivers events', () async {
      final List<SpeedingUpdatedEvent> receivedEvents =
          <SpeedingUpdatedEvent>[];

      // Subscribe to the stream
      final StreamSubscription<SpeedingUpdatedEvent> subscription =
          testSessionApi.getNavigationSpeedingEventStream().listen((
            SpeedingUpdatedEvent event,
          ) {
            receivedEvents.add(event);
          });

      // Emit test events via DTO
      testSessionApi.testEventApi.onSpeedingUpdated(
        SpeedingUpdatedEventDto(
          percentageAboveLimit: 10.0,
          severity: SpeedAlertSeverityDto.minor,
        ),
      );
      testSessionApi.testEventApi.onSpeedingUpdated(
        SpeedingUpdatedEventDto(
          percentageAboveLimit: 25.0,
          severity: SpeedAlertSeverityDto.major,
        ),
      );

      // Wait for events to propagate
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Verify events were received and converted correctly
      expect(receivedEvents.length, 2);
      expect(receivedEvents[0].percentageAboveLimit, 10.0);
      expect(receivedEvents[0].severity, SpeedAlertSeverity.minor);
      expect(receivedEvents[1].percentageAboveLimit, 25.0);
      expect(receivedEvents[1].severity, SpeedAlertSeverity.major);

      await subscription.cancel();
    });

    test('OnArrivalEvent stream delivers events', () async {
      final List<OnArrivalEvent> receivedEvents = <OnArrivalEvent>[];

      final StreamSubscription<OnArrivalEvent> subscription = testSessionApi
          .getNavigationOnArrivalEventStream()
          .listen((OnArrivalEvent event) {
            receivedEvents.add(event);
          });

      // Create test waypoint DTO
      final NavigationWaypointDto waypointDto = NavigationWaypointDto(
        title: 'Test Destination',
        target: LatLngDto(latitude: 37.4220, longitude: -122.0841),
      );

      // Emit test event via DTO
      testSessionApi.testEventApi.onArrival(waypointDto);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents.length, 1);
      expect(receivedEvents[0].waypoint.title, 'Test Destination');
      expect(receivedEvents[0].waypoint.target?.latitude, 37.4220);

      await subscription.cancel();
    });

    test('RoadSnappedLocationUpdatedEvent stream delivers events', () async {
      final List<RoadSnappedLocationUpdatedEvent> receivedEvents =
          <RoadSnappedLocationUpdatedEvent>[];

      final StreamSubscription<RoadSnappedLocationUpdatedEvent> subscription =
          testSessionApi.getNavigationRoadSnappedLocationEventStream().listen((
            RoadSnappedLocationUpdatedEvent event,
          ) {
            receivedEvents.add(event);
          });

      // Emit test events via DTO
      testSessionApi.testEventApi.onRoadSnappedLocationUpdated(
        LatLngDto(latitude: 37.4220, longitude: -122.0841),
      );
      testSessionApi.testEventApi.onRoadSnappedLocationUpdated(
        LatLngDto(latitude: 37.4225, longitude: -122.0845),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents.length, 2);
      expect(receivedEvents[0].location.latitude, 37.4220);
      expect(receivedEvents[0].location.longitude, -122.0841);
      expect(receivedEvents[1].location.latitude, 37.4225);
      expect(receivedEvents[1].location.longitude, -122.0845);

      await subscription.cancel();
    });

    test('RoadSnappedRawLocationUpdatedEvent stream delivers events', () async {
      final List<RoadSnappedRawLocationUpdatedEvent> receivedEvents =
          <RoadSnappedRawLocationUpdatedEvent>[];

      final StreamSubscription<RoadSnappedRawLocationUpdatedEvent>
      subscription = testSessionApi
          .getNavigationRoadSnappedRawLocationEventStream()
          .listen((RoadSnappedRawLocationUpdatedEvent event) {
            receivedEvents.add(event);
          });

      // Emit test event via DTO
      testSessionApi.testEventApi.onRoadSnappedRawLocationUpdated(
        LatLngDto(latitude: 40.7128, longitude: -74.0060),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents.length, 1);
      expect(receivedEvents[0].location.latitude, 40.7128);
      expect(receivedEvents[0].location.longitude, -74.0060);

      await subscription.cancel();
    });

    test('GpsAvailabilityChangeEvent stream delivers events', () async {
      final List<GpsAvailabilityChangeEvent> receivedEvents =
          <GpsAvailabilityChangeEvent>[];

      final StreamSubscription<GpsAvailabilityChangeEvent> subscription =
          testSessionApi
              .getNavigationOnGpsAvailabilityChangeEventStream()
              .listen((GpsAvailabilityChangeEvent event) {
                receivedEvents.add(event);
              });

      // Emit test events via DTO
      testSessionApi.testEventApi.onGpsAvailabilityChange(
        GpsAvailabilityChangeEventDto(
          isGpsLost: false,
          isGpsValidForNavigation: true,
        ),
      );
      testSessionApi.testEventApi.onGpsAvailabilityChange(
        GpsAvailabilityChangeEventDto(
          isGpsLost: true,
          isGpsValidForNavigation: false,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents.length, 2);
      expect(receivedEvents[0].isGpsLost, false);
      expect(receivedEvents[0].isGpsValidForNavigation, true);
      expect(receivedEvents[1].isGpsLost, true);
      expect(receivedEvents[1].isGpsValidForNavigation, false);

      await subscription.cancel();
    });

    test(
      'RemainingTimeOrDistanceChangedEvent stream delivers events',
      () async {
        final List<RemainingTimeOrDistanceChangedEvent> receivedEvents =
            <RemainingTimeOrDistanceChangedEvent>[];

        final StreamSubscription<RemainingTimeOrDistanceChangedEvent>
        subscription = testSessionApi
            .getNavigationRemainingTimeOrDistanceChangedEventStream()
            .listen((RemainingTimeOrDistanceChangedEvent event) {
              receivedEvents.add(event);
            });

        // Emit test event via DTO
        testSessionApi.testEventApi.onRemainingTimeOrDistanceChanged(
          600.0, // remainingTime
          5000.0, // remainingDistance
          TrafficDelaySeverityDto.light,
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].remainingDistance, 5000.0);
        expect(receivedEvents[0].remainingTime, 600.0);
        expect(receivedEvents[0].delaySeverity, TrafficDelaySeverity.light);

        await subscription.cancel();
      },
    );

    test('Rerouting event stream delivers events', () async {
      int reroutingCount = 0;

      final StreamSubscription<void> subscription = testSessionApi
          .getNavigationOnReroutingEventStream()
          .listen((void event) {
            reroutingCount++;
          });

      // Emit rerouting events via testEventApi
      testSessionApi.testEventApi.onRerouting();
      testSessionApi.testEventApi.onRerouting();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(reroutingCount, 2);

      await subscription.cancel();
    });

    test('Traffic updated event stream delivers events', () async {
      int trafficUpdateCount = 0;

      final StreamSubscription<void> subscription = testSessionApi
          .getNavigationTrafficUpdatedEventStream()
          .listen((void event) {
            trafficUpdateCount++;
          });

      // Emit traffic update events via testEventApi
      testSessionApi.testEventApi.onTrafficUpdated();
      testSessionApi.testEventApi.onTrafficUpdated();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(trafficUpdateCount, 2);

      await subscription.cancel();
    });

    test('Route changed event stream delivers events', () async {
      int routeChangedCount = 0;

      final StreamSubscription<void> subscription = testSessionApi
          .getNavigationOnRouteChangedEventStream()
          .listen((void event) {
            routeChangedCount++;
          });

      // Emit route changed events via testEventApi
      testSessionApi.testEventApi.onRouteChanged();
      testSessionApi.testEventApi.onRouteChanged();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(routeChangedCount, 2);

      await subscription.cancel();
    });

    test('Multiple event types can be handled simultaneously', () async {
      int speedingEvents = 0;
      int arrivalEvents = 0;
      int reroutingEvents = 0;

      final StreamSubscription<SpeedingUpdatedEvent> speedingSub =
          testSessionApi.getNavigationSpeedingEventStream().listen((_) {
            speedingEvents++;
          });

      final StreamSubscription<OnArrivalEvent> arrivalSub = testSessionApi
          .getNavigationOnArrivalEventStream()
          .listen((_) {
            arrivalEvents++;
          });

      final StreamSubscription<void> reroutingSub = testSessionApi
          .getNavigationOnReroutingEventStream()
          .listen((_) {
            reroutingEvents++;
          });

      // Emit multiple different event types via testEventApi
      testSessionApi.testEventApi.onSpeedingUpdated(
        SpeedingUpdatedEventDto(
          percentageAboveLimit: 5.0,
          severity: SpeedAlertSeverityDto.minor,
        ),
      );
      testSessionApi.testEventApi.onArrival(
        NavigationWaypointDto(
          title: 'Test',
          target: LatLngDto(latitude: 0, longitude: 0),
        ),
      );
      testSessionApi.testEventApi.onRerouting();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(speedingEvents, 1);
      expect(arrivalEvents, 1);
      expect(reroutingEvents, 1);

      await speedingSub.cancel();
      await arrivalSub.cancel();
      await reroutingSub.cancel();
    });

    test('Stream filters out unrelated event types', () async {
      final List<SpeedingUpdatedEvent> speedingEvents =
          <SpeedingUpdatedEvent>[];

      final StreamSubscription<SpeedingUpdatedEvent> subscription =
          testSessionApi.getNavigationSpeedingEventStream().listen((
            SpeedingUpdatedEvent event,
          ) {
            speedingEvents.add(event);
          });

      // Emit speeding event and other unrelated events via testEventApi
      testSessionApi.testEventApi.onSpeedingUpdated(
        SpeedingUpdatedEventDto(
          percentageAboveLimit: 10.0,
          severity: SpeedAlertSeverityDto.minor,
        ),
      );
      testSessionApi.testEventApi.onRerouting(); // Should be filtered out
      testSessionApi.testEventApi.onTrafficUpdated(); // Should be filtered out
      testSessionApi.testEventApi.onSpeedingUpdated(
        SpeedingUpdatedEventDto(
          percentageAboveLimit: 20.0,
          severity: SpeedAlertSeverityDto.major,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Should only receive the speeding events
      expect(speedingEvents.length, 2);
      expect(speedingEvents[0].percentageAboveLimit, 10.0);
      expect(speedingEvents[1].percentageAboveLimit, 20.0);

      await subscription.cancel();
    });

    test('NavInfo event stream delivers events', () async {
      final List<NavInfoEvent> receivedEvents = <NavInfoEvent>[];

      final StreamSubscription<NavInfoEvent> subscription = testSessionApi
          .getNavInfoStream()
          .listen((NavInfoEvent event) {
            receivedEvents.add(event);
          });

      // Create test NavInfo DTO
      final NavInfoDto navInfoDto = NavInfoDto(
        currentStep: StepInfoDto(
          distanceFromPrevStepMeters: 100,
          timeFromPrevStepSeconds: 60,
          drivingSide: DrivingSideDto.left,
          exitNumber: '42',
          fullInstructions: 'Turn left at Main St',
          fullRoadName: 'Main Street',
          simpleRoadName: 'Main St',
          roundaboutTurnNumber: null,
          stepNumber: 1,
          lanes: <LaneDto>[],
          maneuver: ManeuverDto.turnLeft,
        ),
        remainingSteps: <StepInfoDto>[],
        routeChanged: false,
        distanceToCurrentStepMeters: 50,
        distanceToFinalDestinationMeters: 5000,
        distanceToNextDestinationMeters: 2500,
        timeToCurrentStepSeconds: 30,
        timeToFinalDestinationSeconds: 600,
        timeToNextDestinationSeconds: 300,
        navState: NavStateDto.enroute,
      );

      // Emit test event via DTO
      testSessionApi.testEventApi.onNavInfo(navInfoDto);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(receivedEvents.length, 1);
      expect(receivedEvents[0].navInfo.distanceToFinalDestinationMeters, 5000);
      expect(receivedEvents[0].navInfo.timeToFinalDestinationSeconds, 600);
      expect(
        receivedEvents[0].navInfo.currentStep?.fullInstructions,
        'Turn left at Main St',
      );
      expect(receivedEvents[0].navInfo.navState, NavState.enroute);

      await subscription.cancel();
    });

    test('NewNavigationSession event stream delivers events', () async {
      int newSessionCount = 0;

      final StreamSubscription<void> subscription = testSessionApi
          .getNewNavigationSessionEventStream()
          .listen((void event) {
            newSessionCount++;
          });

      // Emit new session events via testEventApi
      testSessionApi.testEventApi.onNewNavigationSession();
      testSessionApi.testEventApi.onNewNavigationSession();

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(newSessionCount, 2);

      await subscription.cancel();
    });

    test(
      'GpsAvailabilityUpdatedEvent stream delivers events (deprecated)',
      () async {
        final List<GpsAvailabilityUpdatedEvent> receivedEvents =
            <GpsAvailabilityUpdatedEvent>[];

        // ignore: deprecated_member_use_from_same_package
        final StreamSubscription<GpsAvailabilityUpdatedEvent> subscription =
            testSessionApi
                // ignore: deprecated_member_use_from_same_package
                .getNavigationOnGpsAvailabilityUpdateEventStream()
                .listen((GpsAvailabilityUpdatedEvent event) {
                  receivedEvents.add(event);
                });

        // Emit test events via DTO
        testSessionApi.testEventApi.onGpsAvailabilityUpdate(true);
        testSessionApi.testEventApi.onGpsAvailabilityUpdate(false);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(receivedEvents.length, 2);
        expect(receivedEvents[0].available, true);
        expect(receivedEvents[1].available, false);

        await subscription.cancel();
      },
    );
  });
}
