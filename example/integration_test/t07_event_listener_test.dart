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
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.setMyLocationEnabled(true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    await checkTermsAndConditionsAcceptance($);

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();

    /// Set up the listener and the test.
    GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener(
        expectAsync1(
      (RemainingTimeOrDistanceChangedEvent event) {},
      count: 1,
      max: -1,
    ));
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
            title: 'Grace Cathedral',
            target: const LatLng(
              latitude: 37.791957,
              longitude: -122.412529,
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
  });

  patrol('Test navigation OnRouteChanged event listener',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.setMyLocationEnabled(true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    await checkTermsAndConditionsAcceptance($);

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();

    /// Set up the listener and the test.
    GoogleMapsNavigator.setOnRouteChangedListener(expectAsync0(
      () {},
      count: 1,
      max: -1,
    ));
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(
            latitude: 37.791957,
            longitude: -122.412529,
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
  });

  patrol('Test navigation RoadSnappedLocationUpdated event listener',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.setMyLocationEnabled(true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(
            latitude: 37.791957,
            longitude: -122.412529,
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
    await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
        expectAsync1(
      (RoadSnappedLocationUpdatedEvent event) {},
      count: 1,
      max: -1,
    ));

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
    await $.pumpAndSettle();

    if (Platform.isAndroid) {
      try {
        await GoogleMapsNavigator.allowBackgroundLocationUpdates(true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
    }
  });

  patrol('Test navigation onArrival event listener',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.setMyLocationEnabled(true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();

    /// Set up the listener and the test.
    GoogleMapsNavigator.setOnArrivalListener(expectAsync1(
      (OnArrivalEvent event) {},
      count: 1,
      max: -1,
    ));
    await $.pumpAndSettle();

    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.790693,
      longitude: -122.4132157,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(
            latitude: 37.791957,
            longitude: -122.412529,
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
  });

  /// Rerouting listener is Android only.
  if (Platform.isAndroid) {
    patrol('Test navigation onRerouting event listener',
        (PatrolIntegrationTester $) async {
      final Completer<GoogleNavigationViewController> viewControllerCompleter =
          Completer<GoogleNavigationViewController>();

      await checkLocationDialogAndTosAcceptance($);

      /// Display navigation view.
      final Key key = GlobalKey();
      await pumpNavigationView(
        $,
        GoogleMapsNavigationView(
          key: key,
          onViewCreated: (GoogleNavigationViewController controller) {
            controller.setMyLocationEnabled(true);
            viewControllerCompleter.complete(controller);
          },
        ),
      );

      await viewControllerCompleter.future;

      /// Initialize navigation and set up the rerouting listener with the test.
      await GoogleMapsNavigator.initializeNavigationSession();
      GoogleMapsNavigator.setOnReroutingListener(expectAsync1(
        (OnArrivalEvent event) {},
        count: 1,
        max: -1,
      ));
      await $.pumpAndSettle();

      /// Simulate location.
      await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
        latitude: 37.790693,
        longitude: -122.4132157,
      ));

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
            title: 'Grace Cathedral',
            target: const LatLng(
              latitude: 37.791957,
              longitude: -122.412529,
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
          .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
              waypoint,
              RoutingOptions(),
              SimulationOptions(speedMultiplier: 100));
      await $.pumpAndSettle();
    });
  }
}
