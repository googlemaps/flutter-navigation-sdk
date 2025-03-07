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
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/inspector/inspector_platform.dart';
import 'shared.dart';

void main() {
  GoogleMapsNavigationPlatform.instance.enableDebugInspection();

  final GoogleNavigationInspectorPlatform inspector =
      GoogleNavigationInspectorPlatform.instance!;

  /// Start location coordinates in Finland (Näkkäläntie).
  const double startLat = startLocationLat;
  const double startLng = startLocationLng;

  /// Contains info if the test is running on a physical device.
  /// This value is set on setUpAll method.
  late bool isPhysicalDevice;

  setUpAll(() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    isPhysicalDevice = (Platform.isAndroid
        ? (await deviceInfo.androidInfo).isPhysicalDevice
        : (await deviceInfo.iosInfo).isPhysicalDevice);
    debugPrint('isPhysicalDevice: $isPhysicalDevice');
  });

  Future<void> setSimulatedUserLocationWithCheck(
    PatrolIntegrationTester $,
    GoogleNavigationViewController viewController,
    double startLat,
    double startLng,
    double tolerance,
  ) async {
    // Simulate location
    await GoogleMapsNavigator.simulator.setUserLocation(LatLng(
      latitude: startLat,
      longitude: startLng,
    ));
    await $.pumpAndSettle(timeout: const Duration(milliseconds: 500));

    final LatLng? currentLocation =
        await waitForValueMatchingPredicate<LatLng?>(
            $, viewController.getMyLocation, (LatLng? location) {
      if (location == null) return false;

      bool isCloseTo(double a, double b) {
        var diff = a - b;
        if (diff < 0) diff = -diff;
        return diff <= tolerance;
      }

      return isCloseTo(location.latitude, startLat) &&
          isCloseTo(location.longitude, startLng);
    });

    expect(currentLocation, isNotNull);
    expect(currentLocation?.latitude, closeTo(startLat, tolerance));
    expect(currentLocation?.longitude, closeTo(startLng, tolerance));
  }

  patrol('Test navigating to a single destination',
      (PatrolIntegrationTester $) async {
    final Completer<void> hasArrived = Completer<void>();

    /// Set up navigation view and controller.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    /// Set audio guidance settings.
    /// Cannot be verified, because native SDK lacks getter methods,
    /// but exercise the API for basic sanity testing
    final NavigationAudioGuidanceSettings settings =
        NavigationAudioGuidanceSettings(
      isBluetoothAudioEnabled: true,
      isVibrationEnabled: true,
      guidanceType: NavigationAudioGuidanceType.alertsAndGuidance,
    );
    await GoogleMapsNavigator.setAudioGuidance(settings);

    /// Specify tolerance and navigation end coordinates.
    const double tolerance = 0.001;
    const double endLat = 68.59451829688189, endLng = 23.512277951523007;

    /// Finish executing the tests once onArrival event comes in
    /// and test that the guidance stops.
    Future<void> onArrivalEvent(OnArrivalEvent msg) async {
      hasArrived.complete();
      await GoogleMapsNavigator.stopGuidance();
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);

    /// Simulate location and test it.
    await setSimulatedUserLocationWithCheck(
        $, viewController, startLat, startLng, tolerance);

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Näkkäläntie',
          target: const LatLng(
            latitude: endLat,
            longitude: endLng,
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
        msg.location.latitude,
        greaterThanOrEqualTo(startLat - tolerance),
      );
      expectSync(
        msg.location.latitude,
        lessThanOrEqualTo(endLat + tolerance),
      );
      expectSync(
        msg.location.longitude,
        greaterThanOrEqualTo(startLng - tolerance),
      );
      expectSync(
        msg.location.longitude,
        lessThanOrEqualTo(endLng + tolerance),
      );
    }

    await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
        onLocationEvent);

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    expect(await GoogleMapsNavigator.isGuidanceRunning(), true);
    await hasArrived.future;
    expect(await GoogleMapsNavigator.isGuidanceRunning(), false);

    await GoogleMapsNavigator.cleanup();
  });

  patrol(
    'Test navigating to multiple destinations',
    (PatrolIntegrationTester $) async {
      final Completer<void> navigationFinished = Completer<void>();
      int arrivalEventCount = 0;

      /// Set up navigation view and controller.
      final GoogleNavigationViewController viewController =
          await startNavigationWithoutDestination($);

      /// Set audio guidance settings.
      /// Cannot be verified, because native SDK lacks getter methods,
      /// but exercise the API for basic sanity testing
      final NavigationAudioGuidanceSettings settings =
          NavigationAudioGuidanceSettings(
        isBluetoothAudioEnabled: false,
        isVibrationEnabled: false,
        guidanceType: NavigationAudioGuidanceType.alertsOnly,
      );
      await GoogleMapsNavigator.setAudioGuidance(settings);

      /// Specify tolerance and navigation destination coordinates.
      const double tolerance = 0.001;
      const double midLat = 68.59781164189049,
          midLon = 23.520303427087182,
          endLat = 68.60079240808535,
          endLng = 23.527946512754752;

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

      /// Simulate location and test it.
      await setSimulatedUserLocationWithCheck(
          $, viewController, startLat, startLng, tolerance);

      /// Set Destination.
      final Destinations destinations = Destinations(
        waypoints: <NavigationWaypoint>[
          NavigationWaypoint.withLatLngTarget(
            title: 'Näkkäläntie 1st stop',
            target: const LatLng(
              latitude: midLat,
              longitude: midLon,
            ),
          ),
          NavigationWaypoint.withLatLngTarget(
            title: 'Näkkäläntie 2nd stop',
            target: const LatLng(
              latitude: endLat,
              longitude: endLng,
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
            msg.location.latitude,
            greaterThanOrEqualTo(startLat - tolerance),
          );
          expectSync(
            msg.location.latitude,
            lessThanOrEqualTo(endLat + tolerance),
          );
          expectSync(
            msg.location.longitude,
            greaterThanOrEqualTo(startLng - tolerance),
          );
          expectSync(
            msg.location.longitude,
            lessThanOrEqualTo(endLng + tolerance),
          );
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

      await GoogleMapsNavigator.cleanup();
    },
    // TODO(jokerttu): Skipping Android as this fails on Android emulator on CI.
    skip: Platform.isAndroid,
  );

  patrol('Test simulation along new route', (PatrolIntegrationTester $) async {
    int loopIteration = 1;

    /// Set up navigation view and controller.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    /// Specify tolerance and navigation end coordinates.
    const double tolerance = 0.001;
    const double endLat = 68.59451829688189, endLng = 23.512277951523007;

    /// Create a waypoint.
    final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'Näkkäläntie',
        target: const LatLng(
          latitude: endLat,
          longitude: endLng,
        ),
      ),
    ];

    /// Create a simulator1 wrapper function for simulating locations along new route
    /// with routing options.
    Future<NavigationRouteStatus> simulator1() {
      return GoogleMapsNavigator.simulator
          .simulateLocationsAlongNewRoute(waypoint);
    }

    /// Create a simulator2 wrapper function for simulating locations along new route
    /// with routing options.
    Future<NavigationRouteStatus> simulator2() {
      return GoogleMapsNavigator.simulator
          .simulateLocationsAlongNewRouteWithRoutingOptions(
        waypoint,
        RoutingOptions(
          alternateRoutesStrategy: NavigationAlternateRoutesStrategy.one,
          routingStrategy: NavigationRoutingStrategy.shorter,
          targetDistanceMeters: <int>[100],
          travelMode: NavigationTravelMode.driving,
          avoidTolls: true,
          avoidFerries: true,
          avoidHighways: true,
          locationTimeoutMs: 5000,
        ),
      );
    }

    /// Create a simulator3 wrapper function for simulating locations along new route
    /// with routing options.
    Future<NavigationRouteStatus> simulator3() {
      return GoogleMapsNavigator.simulator
          .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
        waypoint,
        RoutingOptions(
          alternateRoutesStrategy: NavigationAlternateRoutesStrategy.none,
          routingStrategy: NavigationRoutingStrategy.shorter,
          targetDistanceMeters: <int>[100],
          travelMode: NavigationTravelMode.walking,
          avoidTolls: false,
          avoidFerries: false,
          avoidHighways: false,
          locationTimeoutMs: 5000,
        ),
        SimulationOptions(speedMultiplier: 20),
      );
    }

    /// Create a simulator4 wrapper function for simulating locations along new route
    /// with updated routing and simulation options.
    Future<NavigationRouteStatus> simulator4() {
      return GoogleMapsNavigator.simulator
          .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
        waypoint,
        RoutingOptions(
          alternateRoutesStrategy: NavigationAlternateRoutesStrategy.all,
          routingStrategy: NavigationRoutingStrategy.defaultBest,
          targetDistanceMeters: <int>[100],
          travelMode: NavigationTravelMode.driving,
          avoidTolls: true,
          avoidFerries: true,
          avoidHighways: true,
          locationTimeoutMs: 2500,
        ),
        SimulationOptions(speedMultiplier: 10),
      );
    }

    final List<Future<NavigationRouteStatus> Function()> simulatorTypes =
        <Future<NavigationRouteStatus> Function()>[
      simulator1,
      simulator2,
      simulator3,
      simulator4
    ];

    /// Test that the different simulator types work.
    for (final Future<NavigationRouteStatus> Function() simulatorType
        in simulatorTypes) {
      bool hasArrived = false;
      final Completer<void> finishTest = Completer<void>();
      debugPrint('Starting loop with simulator$loopIteration.');
      loopIteration += 1;

      /// Initialize navigation if iOS.
      /// On iOS .cleanup() destroys the initialization.
      if (Platform.isIOS) {
        await GoogleMapsNavigator.initializeNavigationSession();
        await $.pumpAndSettle();
      }

      /// Simulate location and test it.
      await setSimulatedUserLocationWithCheck(
          $, viewController, startLat, startLng, tolerance);

      /// Test that the received coordinates fit between start and end location coordinates within tolerance.
      /// End the test when user arrives to the end location coordinates within tolerance.
      void onLocationEvent(RoadSnappedLocationUpdatedEvent msg) {
        debugPrint(
            'LatLngSimulator: ${msg.location.latitude}, ${msg.location.longitude}.');
        if ((!hasArrived) &&
            (endLat - msg.location.latitude <= tolerance) &&
            (endLng - msg.location.longitude <= tolerance)) {
          hasArrived = true;
          finishTest.complete();
        } else {
          expectSync(
            msg.location.latitude,
            greaterThanOrEqualTo(startLat - tolerance),
          );
          expectSync(
            msg.location.latitude,
            lessThanOrEqualTo(endLat + tolerance),
          );
          expectSync(
            msg.location.longitude,
            greaterThanOrEqualTo(startLng - tolerance),
          );
          expectSync(
            msg.location.longitude,
            lessThanOrEqualTo(endLng + tolerance),
          );
        }
      }

      final StreamSubscription<RoadSnappedLocationUpdatedEvent> subscription =
          await GoogleMapsNavigator.setRoadSnappedLocationUpdatedListener(
              onLocationEvent);
      debugPrint('Listener initialized.');

      /// Start simulation and wait for the arrival.
      final NavigationRouteStatus status = await simulatorType();
      expect(status, NavigationRouteStatus.statusOk);
      debugPrint('Simulation along the route started.');
      await finishTest.future;
      debugPrint('Loop with simulator$loopIteration finished.');

      await GoogleMapsNavigator.cleanup();
      await subscription.cancel();
      await $.pumpAndSettle();
    }
  });

  patrol('Test simulating the location', (PatrolIntegrationTester $) async {
    /// Set up navigation view and controller.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    /// Specify tolerance and navigation end coordinates.
    const double endLat = 68.60338455021943, endLng = 23.548804200724454;

    /// Use the helper function to simulate and test location
    const double tolerance = 0.001;
    await setSimulatedUserLocationWithCheck(
        $, viewController, startLat, startLng, tolerance);

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Näkkäläntie',
          target: const LatLng(
            latitude: endLat,
            longitude: endLng,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);
    await $.pumpAndSettle();

    /// Start guidance and simulation along the route.
    await GoogleMapsNavigator.startGuidance();
    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(
            SimulationOptions(speedMultiplier: 5));

    /// Test pausing simulation.
    const double movedTolerance = 0.001;
    await GoogleMapsNavigator.simulator.pauseSimulation();
    final LatLng? location1 = await viewController.getMyLocation();
    await $.pumpAndSettle(duration: const Duration(seconds: 1));
    final LatLng? location2 = await viewController.getMyLocation();
    expect(location1!.latitude, closeTo(location2!.latitude, movedTolerance));
    expect(location1.longitude, closeTo(location2.longitude, movedTolerance));

    /// Test resuming the simulation.
    await GoogleMapsNavigator.simulator.resumeSimulation();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
    final LatLng? location3 = await viewController.getMyLocation();
    expect(location1.latitude,
        isNot(closeTo(location3!.latitude, movedTolerance)));
    expect(location1.longitude,
        isNot(closeTo(location3.longitude, movedTolerance)));
  });

  patrol(
    'Test removing user the simulated location',
    (PatrolIntegrationTester $) async {
      if (!isPhysicalDevice) {
        // Skipping test on emulated devices as these do not properly get real
        // location updates, causing flaky tests on CI.
        debugPrint('Skipping test on emulated device.');
        return;
      }

      /// Set up navigation view and controller.
      final GoogleNavigationViewController viewController =
          await startNavigationWithoutDestination($);

      /// Use the helper function to simulate and test location
      const double tolerance = 0.001;
      await setSimulatedUserLocationWithCheck(
          $, viewController, startLat, startLng, tolerance);

      await GoogleMapsNavigator.simulator.removeUserLocation();

      // Wait for a while to let the map to update to not simulated location.
      await $.pumpAndSettle(duration: const Duration(seconds: 5));

      LatLng? currentLocation = await viewController.getMyLocation();
      expect(currentLocation!.latitude, isNot(closeTo(startLat, tolerance)));
      expect(currentLocation.longitude, isNot(closeTo(startLng, tolerance)));
    },
  );

  patrol('Test that the navigation and updates stop onArrival',
      (PatrolIntegrationTester $) async {
    /// Set up navigation view and controller.
    await startNavigationWithoutDestination($);

    /// Set audio guidance settings.
    /// Cannot be verified, because native SDK lacks getter methods,
    /// but exercise the API for basic sanity testing
    final NavigationAudioGuidanceSettings settings =
        NavigationAudioGuidanceSettings(
      isBluetoothAudioEnabled: false,
      isVibrationEnabled: true,
      guidanceType: NavigationAudioGuidanceType.silent,
    );
    await GoogleMapsNavigator.setAudioGuidance(settings);

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

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

    /// Test that guidance ends after onArrival.
    void onArrivalEvent(OnArrivalEvent msg) {
      expect(GoogleMapsNavigator.isGuidanceRunning(), false);
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);
  });

  patrol('Test network error during navigation',
      (PatrolIntegrationTester $) async {
    if (Platform.isIOS && !isPhysicalDevice) {
      // Skipping test on emulated devices as these do not properly get real
      // location updates, causing flaky tests on CI.
      debugPrint('Skipping test on emulated device on iOS.');
      return;
    }

    /// Set up navigation view and controller.
    await startNavigationWithoutDestination($);

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    /// Create a waypoint.
    final List<NavigationWaypoint> waypoint = <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'California St & Jones St',
        target: const LatLng(
          latitude: 37.791424,
          longitude: -122.414139,
        ),
      ),
    ];

    /// Set Destination.
    final Destinations destinations = Destinations(
      waypoints: waypoint,
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    try {
      /// Cut network connection.
      await $.native.disableCellular();
      await $.native.disableWifi();

      // Wait a while to ensure network is down.
      await $.pumpAndSettle(duration: const Duration(seconds: 1));

      /// Test that the error is received.
      final NavigationRouteStatus routeStatus =
          await GoogleMapsNavigator.setDestinations(destinations);
      expect(routeStatus, equals(NavigationRouteStatus.networkError),
          reason: 'setDestinations did not return networkError');

      final NavigationRouteStatus routeStatusSim = await GoogleMapsNavigator
          .simulator
          .simulateLocationsAlongNewRoute(waypoint);
      expect(routeStatusSim, equals(NavigationRouteStatus.networkError),
          reason: 'simulateLocationsAlongNewRoute did not return networkError');
    } finally {
      /// Re-enable network connection.
      await $.native.enableCellular();
      await $.native.enableWifi();
    }
  });

  patrol('Test route not found errors', (PatrolIntegrationTester $) async {
    /// Set up navigation view and controller.
    await startNavigationWithoutDestination($);

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 37.79136614772824,
      longitude: -122.41565900473043,
    ));
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

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

  patrol('Test route structures', (PatrolIntegrationTester $) async {
    final Completer<void> hasArrived = Completer<void>();

    /// Set up navigation view and controller.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    /// Finish executing the tests once onArrival event comes in.
    void onArrivalEvent(OnArrivalEvent msg) {
      hasArrived.complete();
    }

    GoogleMapsNavigator.setOnArrivalListener(onArrivalEvent);

    /// Simulate location (1298 California St)
    const double tolerance = 0.001;
    await setSimulatedUserLocationWithCheck(
        $, viewController, 37.79136614772824, -122.41565900473043, tolerance);

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
    await $.pumpAndSettle(timeout: const Duration(seconds: 1));

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
    expect(beginCurrentSegment, isNotNull, reason: 'Current segment is null.');

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
    expect(endSegment!.destinationLatLng.longitude, closeTo(-122.412, 0.002));
  });

  patrol('Test that the navigation session is attached to existing map',
      (PatrolIntegrationTester $) async {
    bool isSessionAttached;

    /// Set up navigation view and controller without initializing navigation.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($, initializeNavigation: false);

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
    /// Set up navigation view and controller.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    final int viewId = viewController.getViewId();
    final bool isSessionAttached = await GoogleNavigationInspectorPlatform
        .instance!
        .isViewAttachedToSession(viewId);
    expect(isSessionAttached, true);
  });

  patrol('Test routing options and display options',
      (PatrolIntegrationTester $) async {
    /// Set up navigation view and controller.
    await startNavigationWithoutDestination($, simulateLocation: true);

    /// Specify navigation end coordinates.
    const double endX = 68.60079240808535, endY = 23.527946512754752;

    /// Set Destination, routing options and display options.
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
      routingOptions: RoutingOptions(
        alternateRoutesStrategy: NavigationAlternateRoutesStrategy.none,
        routingStrategy: NavigationRoutingStrategy.shorter,
        targetDistanceMeters: <int>[1000],
        travelMode: NavigationTravelMode.walking,
        avoidTolls: true,
        avoidFerries: true,
        avoidHighways: true,
        locationTimeoutMs: 2500,
      ),
      displayOptions: NavigationDisplayOptions(
        showDestinationMarkers: false,
        showStopSigns: false,
        showTrafficLights: false,
      ),
    );
    NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    final bool guidanceRunning = await GoogleMapsNavigator.isGuidanceRunning();
    expect(guidanceRunning, true);
    await $.pumpAndSettle();

    /// Test the time and Distace for walking travelmode.
    NavigationTimeAndDistance timeAndDistance =
        await GoogleMapsNavigator.getCurrentTimeAndDistance();
    expect(timeAndDistance.time, closeTo(1000, 600));
    expect(timeAndDistance.distance, closeTo(1048, 200));

    /// Test clearing the destination.
    await GoogleMapsNavigator.clearDestinations();
    List<RouteSegment?> getRoute = await GoogleMapsNavigator.getRouteSegments();
    expect(getRoute, isEmpty);

    /// Create destinations2 with updated routing and display options.
    final Destinations destinations2 = Destinations(
      waypoints: destinations.waypoints,
      routingOptions: RoutingOptions(
        alternateRoutesStrategy: NavigationAlternateRoutesStrategy.one,
        routingStrategy: NavigationRoutingStrategy.deltaToTargetDistance,
        targetDistanceMeters: <int>[1050],
        travelMode: NavigationTravelMode.driving,
        avoidTolls: false,
        avoidFerries: false,
        avoidHighways: false,
        locationTimeoutMs: 5000,
      ),
      displayOptions: NavigationDisplayOptions(
        showDestinationMarkers: true,
        showStopSigns: true,
        showTrafficLights: true,
      ),
    );
    status = await GoogleMapsNavigator.setDestinations(destinations2);
    expect(status, NavigationRouteStatus.statusOk);

    /// Test the time and Distace for driving travelmode.
    timeAndDistance = await GoogleMapsNavigator.getCurrentTimeAndDistance();
    expect(timeAndDistance.time, closeTo(80, 150));
    expect(timeAndDistance.distance, closeTo(1048, 200));

    /// Test clearing the destination.
    await GoogleMapsNavigator.clearDestinations();
    getRoute = await GoogleMapsNavigator.getRouteSegments();
    expect(getRoute, isEmpty);

    /// Create destinations3 with updated routing options.
    final Destinations destinations3 = Destinations(
      waypoints: destinations.waypoints,
      routingOptions: RoutingOptions(
        alternateRoutesStrategy: NavigationAlternateRoutesStrategy.all,
        routingStrategy: NavigationRoutingStrategy.defaultBest,
        travelMode: NavigationTravelMode.cycling,
      ),
      displayOptions: destinations.displayOptions,
    );
    status = await GoogleMapsNavigator.setDestinations(destinations3);
    expect(status, NavigationRouteStatus.statusOk);

    /// Test the time and distace for cycling travelmode.
    timeAndDistance = await GoogleMapsNavigator.getCurrentTimeAndDistance();
    expect(timeAndDistance.time, closeTo(180, 100));
    expect(timeAndDistance.distance, closeTo(1048, 200));
  });
}
