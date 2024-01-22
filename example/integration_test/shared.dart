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

// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_navigation/google_maps_navigation.dart';
import 'package:patrol/patrol.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:google_maps_navigation/google_maps_navigation.dart';
export 'package:patrol/patrol.dart';

const NativeAutomatorConfig _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20),
);

/// Create a wrapper [patrol] for [patrolTest] with custom options.
void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  NativeAutomatorConfig? nativeAutomatorConfig,
}) {
  patrolTest(
    description,
    timeout: const Timeout(
        Duration(seconds: 240)), // Add a 4 minute timeout to tests.
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    skip: skip,
    callback,
  );
}

/// Pumps a [navigationView] widget in tester [$] and then waits until it settles.
Future<void> pumpNavigationView(
    PatrolIntegrationTester $, GoogleMapsNavigationView navigationView) async {
  await $.pumpWidget(wrapNavigationView(navigationView));
  await $.pumpAndSettle();
}

/// Wraps a [navigationView] in widgets.
Widget wrapNavigationView(GoogleMapsNavigationView navigationView) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: navigationView,
      ),
    ),
  );
}

Future<void> checkTermsAndConditionsAcceptance(
    PatrolIntegrationTester $) async {
  if (!await GoogleMapsNavigator.areTermsAccepted()) {
    /// Request native TOS dialog.
    final Future<bool> tosAccepted =
        GoogleMapsNavigator.showTermsAndConditionsDialog(
      'test_title',
      'test_company_name',
    );

    await $.pumpAndSettle();
    // Tap accept or cancel.
    if (Platform.isAndroid) {
      await $.native.tap(Selector(text: 'Yes, I am in'));
    } else if (Platform.isIOS) {
      await $.native.tap(Selector(text: "YES, I'M IN"));
    } else {
      fail('Unsupported platform: ${Platform.operatingSystem}');
    }
    // Verify the TOS was accepted
    await tosAccepted.then((bool accept) {
      expect(accept, true);
    });
  }
}

/// Grant location permissions if not granted.
Future<void> checkLocationDialogAcceptance(PatrolIntegrationTester $) async {
  if (!await Permission.locationWhenInUse.isGranted) {
    /// Request native location permission dialog.q
    final Future<PermissionStatus> locationGranted =
        Permission.locationWhenInUse.request();

    // Grant location permission.
    await $.native.grantPermissionWhenInUse();

    // Check that the location permission is granted.
    await locationGranted.then((PermissionStatus status) async {
      expect(status, PermissionStatus.granted);
    });
  }
}

/// Accept ToS and grant location permission if not accepted/granted.
Future<void> checkLocationDialogAndTosAcceptance(
    PatrolIntegrationTester $) async {
  await checkTermsAndConditionsAcceptance($);
  await checkLocationDialogAcceptance($);
}

Future<GoogleNavigationViewController> startNavigation(
    PatrolIntegrationTester $,
    {void Function(CameraPosition, bool)? onCameraMoveStarted,
    void Function(CameraPosition)? onCameraMove,
    void Function(CameraPosition)? onCameraIdle,
    void Function(CameraPosition)? onCameraStartedFollowingLocation,
    void Function(CameraPosition)? onCameraStoppedFollowingLocation}) async {
  final Completer<GoogleNavigationViewController> controllerCompleter =
      Completer<GoogleNavigationViewController>();

  await checkLocationDialogAndTosAcceptance($);

  final Key key = GlobalKey();
  await pumpNavigationView(
    $,
    GoogleMapsNavigationView(
      key: key,
      onViewCreated: (GoogleNavigationViewController viewController) {
        controllerCompleter.complete(viewController);
      },
      onCameraMoveStarted: onCameraMoveStarted,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      onCameraStartedFollowingLocation: onCameraStartedFollowingLocation,
      onCameraStoppedFollowingLocation: onCameraStoppedFollowingLocation,
    ),
  );

  final GoogleNavigationViewController controller =
      await controllerCompleter.future;

  await GoogleMapsNavigator.initializeNavigationSession();
  await $.pumpAndSettle();

  await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
    latitude: 38.012087,
    longitude: -120.270701,
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

  expect(await GoogleMapsNavigator.isGuidanceRunning(), true);

  return controller;
}

/// Start navigation without setting the destination and optionally
/// simulating starting location with [simulateLocation] and skipping
/// initialization with [initializeNavigation].
Future<GoogleNavigationViewController> startNavigationWithoutDestination(
    PatrolIntegrationTester $,
    {bool initializeNavigation = true,
    bool simulateLocation = false}) async {
  final Completer<GoogleNavigationViewController> controllerCompleter =
      Completer<GoogleNavigationViewController>();

  await checkLocationDialogAndTosAcceptance($);

  final Key key = GlobalKey();
  await pumpNavigationView(
    $,
    GoogleMapsNavigationView(
      key: key,
      onViewCreated: (GoogleNavigationViewController viewController) {
        controllerCompleter.complete(viewController);
      },
    ),
  );

  final GoogleNavigationViewController controller =
      await controllerCompleter.future;

  if (initializeNavigation) {
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();
  }

  if (simulateLocation) {
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: 68.59381960993993,
      longitude: 23.510696979963722,
    ));
  }

  return controller;
}

/// A function that waits until a certain condition is met, e.g. until the camera moves where intended.
///
/// The function constantly sends the Value objects from [getValue] function
/// to the provided [predicate] function until the [predicate] function returns true.
/// Then the function returns that Value. If [maxTries] are reached without
/// predicate returning true, null is returned.
Future<Value?> waitForValueMatchingPredicate<Value>(PatrolIntegrationTester $,
    Future<Value> Function() getValue, bool Function(Value) predicate,
    {int maxTries = 200, int delayMs = 100}) async {
  for (int i = 0; i < maxTries; i++) {
    final Value currentValue = await getValue();
    if (predicate(currentValue)) {
      return currentValue;
    }
    await $.pump(Duration(milliseconds: delayMs));
  }
  return null;
}
