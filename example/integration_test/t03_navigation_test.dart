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
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_navigation/src/google_maps_navigation_platform_interface.dart';
import 'package:google_maps_navigation/src/inspector/inspector_platform.dart';
import 'shared.dart';

void main() {
  GoogleMapsNavigationPlatform.instance.enableDebugInspection();

  final GoogleNavigationInspectorPlatform inspector =
      GoogleNavigationInspectorPlatform.instance!;

  bool isPhysicalDevice = false;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    deviceInfo.iosInfo.then((IosDeviceInfo info) {
      isPhysicalDevice = info.isPhysicalDevice;
      debugPrint('isPhysicalDevice: $isPhysicalDevice');
    });
  }

  patrol(
      'Test navigation guidance for a single destination with location updates',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    final Completer<void> hasArrived = Completer<void>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    /// Specify tolerance and navigation start and end coordinates.
    const double tolerance = 0.0005;
    const double startX = 68.59381960993993,
        startY = 23.510696979963722,
        endX = 68.60079240808535,
        endY = 23.527946512754752;

    /// Finish executing the tests once onArrival event comes in
    /// and test that the guidance stops.
    Future<void> onArrivalEvent(OnArrivalEvent msg) async {
      hasArrived.complete();
      await GoogleMapsNavigator.stopGuidance();
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);

    /// Simulate location.
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: startX,
      longitude: startY,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Näkkäläntie',
          target: const LatLng(
            latitude: endX,
            longitude: endY,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    expect(await GoogleMapsNavigator.isGuidanceRunning(), false);

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Test that the received coordinates fit between start and end location coordinates within tolerance.
    void onLocationEvent(RoadSnappedLocationUpdatedEvent msg) {
      debugPrint(
          'LatLngSingle: ${msg.location.latitude}, ${msg.location.longitude}');
      expectSync(
          msg.location.latitude, greaterThanOrEqualTo(startX - tolerance));
      expectSync(msg.location.latitude, lessThanOrEqualTo(endX + tolerance));
      expectSync(
          msg.location.longitude, greaterThanOrEqualTo(startY - tolerance));
      expectSync(msg.location.longitude, lessThanOrEqualTo(endY + tolerance));
    }

    await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
        onLocationEvent);

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(SimulationOptions(
      speedMultiplier: 10,
    ));

    expect(await GoogleMapsNavigator.isGuidanceRunning(), true);
    await hasArrived.future;
    expect(await GoogleMapsNavigator.isGuidanceRunning(), false);
  });

  patrol(
      'Test navigation guidance for multiple destinations with location updates',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    final Completer<void> navigationFinished = Completer<void>();
    int arrivalEventCount = 0;

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    /// Specify tolerance and navigation start and end coordinates.
    const double tolerance = 0.0005;
    const double startX = 68.59381960993993,
        startY = 23.510696979963722,
        midX = 68.59781164189049,
        midY = 23.520303427087182,
        endX = 68.60079240808535,
        endY = 23.527946512754752;

    Future<void> onArrivalEvent(OnArrivalEvent msg) async {
      arrivalEventCount += 1;
      await GoogleMapsNavigator.continueToNextDestination();

      /// Finish executing the tests once 2 onArrival events come in.
      /// Test the guidance stops on last Arrival.
      if (arrivalEventCount == 2) {
        navigationFinished.complete();
      }
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: startX,
      longitude: startY,
    ));

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Näkkäläntie 1st stop',
          target: const LatLng(
            latitude: midX,
            longitude: midY,
          ),
        ),
        NavigationWaypoint.withLatLngTarget(
          title: 'Näkkäläntie 2nd stop',
          target: const LatLng(
            latitude: endX,
            longitude: endY,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    expect(await GoogleMapsNavigator.isGuidanceRunning(), false);

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Test that the received coordinates fit between start and end location coordinates within tolerance.
    void onLocationEvent(RoadSnappedLocationUpdatedEvent msg) {
      /// Sometimes on Android, the simulator "overshoots" and passes the destination
      /// with high speedMultiplier.
      if (arrivalEventCount < 2) {
        expectSync(
            msg.location.latitude, greaterThanOrEqualTo(startX - tolerance));
        expectSync(msg.location.latitude, lessThanOrEqualTo(endX + tolerance));
        expectSync(
            msg.location.longitude, greaterThanOrEqualTo(startY - tolerance));
        expectSync(msg.location.longitude, lessThanOrEqualTo(endY + tolerance));
      }
    }

    await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
        onLocationEvent);

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(SimulationOptions(
      speedMultiplier: 10,
    ));

    expect(await GoogleMapsNavigator.isGuidanceRunning(), true);
    await navigationFinished.future;
    expect(await GoogleMapsNavigator.isGuidanceRunning(), false);
  });

  patrol(
      'Test location updates when not actively navigating (simulateAlongNewRoute)',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    final Completer<void> finishTest = Completer<void>();
    bool hasArrived = false;

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    /// Specify tolerance and navigation start and end coordinates.
    const double tolerance = 0.001;
    const double startX = 68.59381960993993,
        startY = 23.510696979963722,
        endX = 68.60079240808535,
        endY = 23.527946512754752;

    /// Simulate location.
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: startX,
      longitude: startY,
    ));

    /// Create a waypoint.
    final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'Näkkäläntie',
        target: const LatLng(
          latitude: endX,
          longitude: endY,
        ),
      ),
    ];

    /// Test that the received coordinates fit between start and end location coordinates within tolerance.
    /// End the test when user arrives to the end location coordinates within tolerance.
    void onLocationEvent(RoadSnappedLocationUpdatedEvent msg) {
      if ((!hasArrived) &&
          (endX - msg.location.latitude <= tolerance) &&
          (endY - msg.location.longitude <= tolerance)) {
        hasArrived = true;
        finishTest.complete();
      } else {
        expectSync(
            msg.location.latitude, greaterThanOrEqualTo(startX - tolerance));
        expectSync(msg.location.latitude, lessThanOrEqualTo(endX + tolerance));
        expectSync(
            msg.location.longitude, greaterThanOrEqualTo(startY - tolerance));
        expectSync(msg.location.longitude, lessThanOrEqualTo(endY + tolerance));
      }
    }

    await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
        onLocationEvent);

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
            waypoint,
            RoutingOptions(routingStrategy: NavigationRoutingStrategy.shorter),
            SimulationOptions(speedMultiplier: 10));

    await finishTest.future;
  });

  patrol('Test that the navigation and updates stop onArrival',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
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

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(SimulationOptions(
      speedMultiplier: 100,
    ));
    await $.pumpAndSettle();

    /// Test that guidance ends after onArrival.
    void onArrivalEvent(OnArrivalEvent msg) {
      expect(GoogleMapsNavigator.isGuidanceRunning(), false);
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);
  });

  // Skip test on iOS simulator.
  if (Platform.isIOS && !isPhysicalDevice) {
  } else {
    patrol('Test that onNetworkError is received when no network connection.',
        (PatrolIntegrationTester $) async {
      final Completer<GoogleNavigationViewController> viewControllerCompleter =
          Completer<GoogleNavigationViewController>();

      // Accept ToS and grant location permission if not accepted/granted.
      await checkLocationDialogAndTosAcceptance($);

      /// Display navigation view.
      final Key key = GlobalKey();
      await pumpNavigationView(
        $,
        GoogleMapsNavigationView(
          key: key,
          onViewCreated: (GoogleNavigationViewController controller) {
            controller.enableMyLocation(enabled: true);
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

      /// Create a waypoint.
      final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(
            latitude: 37.791957,
            longitude: -122.412529,
          ),
        ),
      ];

      /// Set Destination.
      final Destinations destinations = Destinations(
        waypoints: waypoint,
        displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
      );

      /// Cut network connection.
      await $.native.disableCellular();
      await $.native.disableWifi();

      /// Test that the error is received.
      final NavigationRouteStatus routeStatus =
          await GoogleMapsNavigator.setDestinations(destinations);
      expect(routeStatus, equals(NavigationRouteStatus.networkError));

      final NavigationRouteStatus routeStatusSim = await GoogleMapsNavigator
          .simulator
          .simulateLocationsAlongNewRoute(waypoint);
      expect(routeStatusSim, equals(NavigationRouteStatus.networkError));

      /// Re-enable network connection.
      await $.native.enableCellular();
      await $.native.enableWifi();
    });
  }

  patrol('Test that routeNotFound error is received when no route is found.',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
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

    /// Create a waypoint.
    final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'Kiviniemi',
        target: const LatLng(
          latitude: 70.06006451782844,
          longitude: 27.390062785112185,
        ),
      ),
    ];

    /// Set Destination to another continent.
    final Destinations destinations = Destinations(
      waypoints: waypoint,
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    /// Test that the error is received.
    final NavigationRouteStatus routeStatus =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(routeStatus, equals(NavigationRouteStatus.routeNotFound));

    final NavigationRouteStatus routeStatusSim = await GoogleMapsNavigator
        .simulator
        .simulateLocationsAlongNewRoute(waypoint);
    expect(routeStatusSim, equals(NavigationRouteStatus.routeNotFound));
  });

  patrol('Test route structures during navigation',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();
    final Completer<void> hasArrived = Completer<void>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    await viewControllerCompleter.future;

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    /// Finish executing the tests once onArrival event comes in.
    void onArrivalEvent(OnArrivalEvent msg) {
      hasArrived.complete();
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);

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

    final List<RouteSegment> beginRouteSegments =
        await GoogleMapsNavigator.getRouteSegments();
    final RouteSegment? beginCurrentSegment =
        await GoogleMapsNavigator.getCurrentRouteSegment();
    final List<LatLng> beginTraveledRoute =
        await GoogleMapsNavigator.getTraveledRoute();

    /// The route segments list is not empty.
    expect(beginRouteSegments.length, greaterThan(0));

    /// The current route segment.
    expect(beginCurrentSegment, isNotNull);

    /// Start simulation.
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(SimulationOptions(
      speedMultiplier: 30,
    ));
    await $.pumpAndSettle();

    await hasArrived.future;

    // Values after arrival
    final List<LatLng> endTraveledRoute =
        await GoogleMapsNavigator.getTraveledRoute();
    final RouteSegment? endSegment =
        await GoogleMapsNavigator.getCurrentRouteSegment();

    /// Traveled route is different than in the beginning
    expect(endTraveledRoute.length, greaterThan(beginTraveledRoute.length));

    /// Check that the last segment is near target destination.
    expect(endSegment!.destinationLatLng.longitude, greaterThan(-122.413));
    expect(endSegment.destinationLatLng.longitude, lessThan(-122.411));
  });

  patrol('Test that the navigation session is attached to existing map',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    bool isSessionAttached;
    final GoogleNavigationViewController viewController =
        await viewControllerCompleter.future;
    final int viewId = viewController.getViewId();
    if (Platform.isIOS) {
      isSessionAttached = await inspector.isViewAttachedToSession(viewId);
      expect(isSessionAttached, false);
    }

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();
    isSessionAttached = await inspector.isViewAttachedToSession(viewId);
    expect(isSessionAttached, true);
  });

  patrol('Test that the map attaches existing navigation session to itself',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    // Accept ToS and grant location permission if not accepted/granted.
    await checkLocationDialogAndTosAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          controller.enableMyLocation(enabled: true);
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();

    final GoogleNavigationViewController viewController =
        await viewControllerCompleter.future;
    final int viewId = viewController.getViewId();
    final bool isSessionAttached = await GoogleNavigationInspectorPlatform
        .instance!
        .isViewAttachedToSession(viewId);
    expect(isSessionAttached, true);
  });
}
