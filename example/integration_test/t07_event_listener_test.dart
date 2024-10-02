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

// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'shared.dart';

void main() {
  patrol('Test navigation OnRemainingTimeOrDistanceChanged event listener',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    final GoogleNavigationViewController navigationController =
        await startNavigationWithoutDestination($);

    /// Set up the listener and the test.
    final StreamSubscription<RemainingTimeOrDistanceChangedEvent> subscription =
        GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener(
            expectAsync1(
      (RemainingTimeOrDistanceChangedEvent event) {
        expectSync(event.remainingDistance, isA<double>());
        expectSync(event.remainingTime, isA<double>());

        /// Complete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
            title: 'California St & Jones St',
            target: const LatLng(
              latitude: 37.791424,
              longitude: -122.414139,
            )),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscription.
    await eventReceived.future;
    await subscription.cancel();
    await navigationController.clear();
  });

  patrol('Test NavInfoEvent listener', (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    final GoogleNavigationViewController navigationController =
        await startNavigationWithoutDestination($);

    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
            title: 'California St & Jones St',
            target: const LatLng(
              latitude: 37.791424,
              longitude: -122.414139,
            )),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Set up the listener and the test.
    final StreamSubscription<NavInfoEvent> subscription =
        GoogleMapsNavigator.setNavInfoListener(expectAsync1(
      (NavInfoEvent event) {
        expectSync(event.navInfo, isA<NavInfo>());

        /// Complete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscription.
    await eventReceived.future;
    await subscription.cancel();
    await navigationController.clear();
  });

  patrol('Test NavInfoEvent listener with numNextStepsToPreview value set to 1',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    final GoogleNavigationViewController navigationController =
        await startNavigationWithoutDestination($);
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
            title: 'California St & Jones St',
            target: const LatLng(
              latitude: 37.791424,
              longitude: -122.414139,
            )),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Set up the listener and the test.
    final StreamSubscription<NavInfoEvent> subscription =
        GoogleMapsNavigator.setNavInfoListener(
      expectAsync1(
        (NavInfoEvent event) {
          expectSync(event.navInfo, isA<NavInfo>());

          /// Complete the eventReceived completer only once.
          if (!eventReceived.isCompleted) {
            eventReceived.complete();
          }
        },
        max: -1,
      ),
      numNextStepsToPreview: 1,
    );

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscription.
    await eventReceived.future;
    await subscription.cancel();
    await navigationController.clear();
  });

  patrol('Test navigation OnRouteChanged event listener',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    await startNavigationWithoutDestination($);

    /// Set up the listener and the test.
    final StreamSubscription<void> subscription =
        GoogleMapsNavigator.setOnRouteChangedListener(expectAsync0(
      () {
        /// Complete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: const LatLng(
            latitude: 37.791424,
            longitude: -122.414139,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscription.
    await eventReceived.future;
    await subscription.cancel();
  });

  patrol('Test navigation RoadSnappedLocationUpdated event listener',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Sert up navigation.
    await startNavigationWithoutDestination($);

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: const LatLng(
            latitude: 37.791424,
            longitude: -122.414139,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Set up the listener and the test.
    final StreamSubscription<RoadSnappedLocationUpdatedEvent> subscription =
        await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
            expectAsync1(
      (RoadSnappedLocationUpdatedEvent event) {
        expectSync(event.location, isA<LatLng>());

        /// Complete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    /// Test setting the background location updates.
    if (Platform.isIOS) {
      await GoogleMapsNavigator.allowBackgroundLocationUpdates(true);
      await GoogleMapsNavigator.allowBackgroundLocationUpdates(false);
    } else if (Platform.isAndroid) {
      try {
        await GoogleMapsNavigator.allowBackgroundLocationUpdates(true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
    }

    /// Wait until the event is received and then test cancelling the subscription.
    await eventReceived.future;
    await subscription.cancel();
  });

  patrol('Test navigation onArrival and onSpeedingUpdated event listeners',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    await startNavigationWithoutDestination($);

    /// Set up the listeners and the tests.
    final StreamSubscription<OnArrivalEvent> onArrivalSubscription =
        GoogleMapsNavigator.setOnArrivalListener(expectAsync1(
      (OnArrivalEvent event) {
        expectSync(event.waypoint, isA<NavigationWaypoint>());

        /// Comoplete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));

    /// The events are not tested because there's currently no reliable way to trigger them.
    void speedingUpdated(SpeedingUpdatedEvent event) {
      debugPrint('SpeedingUpdated: $event');
    }

    /// This event isn't reveived with iOS in this test scenario so skipping
    /// the test that checks the event is received.
    final StreamSubscription<SpeedingUpdatedEvent>
        onSpeedingUpdatedSubscription =
        GoogleMapsNavigator.setSpeedingUpdatedListener(speedingUpdated);
    await $.pumpAndSettle();

    // Polk St & O'Farrell St
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.784985,
      longitude: -122.419577,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: const LatLng(
            latitude: 37.791424,
            longitude: -122.414139,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(SimulationOptions(
      speedMultiplier: 100,
    ));
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscriptions.
    await eventReceived.future;
    await onArrivalSubscription.cancel();
    await onSpeedingUpdatedSubscription.cancel();
  });

  patrol('Test navigation onRerouting and onGpsAvailability event listeners',
      (PatrolIntegrationTester $) async {
    final Completer<void> eventReceived = Completer<void>();

    /// Set up navigation.
    await startNavigationWithoutDestination($);

    /// Set up the rerouting listener with the test.
    final StreamSubscription<void> onReroutingSubscription =
        GoogleMapsNavigator.setOnReroutingListener(expectAsync0(
      () {
        /// Complete the eventReceived completer only once.
        if (!eventReceived.isCompleted) {
          eventReceived.complete();
        }
      },
      max: -1,
    ));
    await $.pumpAndSettle();

    /// The events are not tested because there's currently no reliable way to trigger them.
    void onGpsAvailability(GpsAvailabilityUpdatedEvent event) {
      debugPrint('GpsAvailabilityEvent: $event');
    }

    /// Set up the gpsAvailability listener with the test.
    final StreamSubscription<GpsAvailabilityUpdatedEvent>
        onGpsAvailabilitySubscription =
        await GoogleMapsNavigator.setOnGpsAvailabilityListener(
            onGpsAvailability);

    /// Simulate location.
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.790693,
      longitude: -122.4132157,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

    /// Create a waypoint for simulator.
    final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'Union Square',
        target: const LatLng(
          latitude: 37.788064586663126,
          longitude: -122.40751869021587,
        ),
      ),
    ];

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: const LatLng(
            latitude: 37.791424,
            longitude: -122.414139,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Start simulation to a different destination.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(waypoint,
            RoutingOptions(), SimulationOptions(speedMultiplier: 100));
    await $.pumpAndSettle();

    /// Wait until the event is received and then test cancelling the subscriptions.
    await eventReceived.future;
    await onReroutingSubscription.cancel();
    await onGpsAvailabilitySubscription.cancel();
  }, skip: !Platform.isAndroid);
}
