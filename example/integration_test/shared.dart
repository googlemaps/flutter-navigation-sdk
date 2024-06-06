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
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:patrol/patrol.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:google_navigation_flutter/google_navigation_flutter.dart';
export 'package:patrol/patrol.dart';

/// Location coordinates for starting position simulation in Finland - Näkkäläntie.
const double startLocationLat = 68.5938196099399;
const double startLocationLng = 23.510696979963722;

/// Timeout for tests in seconds.
const int testTimeoutSeconds = 240; // 4 minutes

const NativeAutomatorConfig _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20),
);

/// Create a wrapper [patrol] for [patrolTest] with custom options.
void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool skip = false,
  int timeoutSeconds = testTimeoutSeconds,
  NativeAutomatorConfig? nativeAutomatorConfig,
}) {
  /// The patrolTest skip functionality does not work as expected and can
  /// hang the test execution.
  /// https://github.com/leancodepl/patrol/issues/1690
  /// Skip the test manually for now.
  if (skip) {
    debugPrint('Skipping test: $description');
    return;
  }
  patrolTest(
    description,
    callback,
    skip: skip,
    timeout: Timeout(Duration(seconds: timeoutSeconds)),
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
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
    latitude: startLocationLat,
    longitude: startLocationLng,
  ));

  /// Set Destination.
  final Destinations destinations = Destinations(
    waypoints: <NavigationWaypoint>[
      NavigationWaypoint.withLatLngTarget(
        title: 'Finland - Leppäjärvi',
        target: const LatLng(
          latitude: 68.50680417455591,
          longitude: 23.310968509112517,
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

/// Start navigation without setting the destination.
///
/// Optionally simulate the starting location with [simulateLocation],
/// skip the initialization with [initializeNavigation] and set various
/// event callback listener functions.
Future<GoogleNavigationViewController> startNavigationWithoutDestination(
  PatrolIntegrationTester $, {
  bool initializeNavigation = true,
  bool simulateLocation = false,
  void Function(String)? onMarkerClicked,
  void Function(String)? onCircleClicked,
  void Function(LatLng)? onMapClicked,
  void Function(LatLng)? onMapLongClicked,
  void Function(String, LatLng)? onMarkerDrag,
  void Function(String, LatLng)? onMarkerDragEnd,
  void Function(String, LatLng)? onMarkerDragStart,
  void Function(String)? onMarkerInfoWindowClicked,
  void Function(String)? onMarkerInfoWindowClosed,
  void Function(String)? onMarkerInfoWindowLongClicked,
  void Function(MyLocationButtonClickedEvent)? onMyLocationButtonClicked,
  void Function(MyLocationClickedEvent)? onMyLocationClicked,
  void Function(bool)? onNavigationUIEnabledChanged,
  void Function(String)? onPolygonClicked,
  void Function(String)? onPolylineClicked,
  void Function(NavigationViewRecenterButtonClickedEvent)?
      onRecenterButtonClicked,
  void Function(CameraPosition)? onCameraIdle,
}) async {
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
      onMarkerClicked: onMarkerClicked,
      onCircleClicked: onCircleClicked,
      onMapClicked: onMapClicked,
      onMapLongClicked: onMapLongClicked,
      onMarkerDrag: onMarkerDrag,
      onMarkerDragEnd: onMarkerDragEnd,
      onMarkerDragStart: onMarkerDragStart,
      onMarkerInfoWindowClicked: onMarkerInfoWindowClicked,
      onMarkerInfoWindowClosed: onMarkerInfoWindowClosed,
      onMarkerInfoWindowLongClicked: onMarkerInfoWindowLongClicked,
      onMyLocationButtonClicked: onMyLocationButtonClicked,
      onMyLocationClicked: onMyLocationClicked,
      onNavigationUIEnabledChanged: onNavigationUIEnabledChanged,
      onPolygonClicked: onPolygonClicked,
      onPolylineClicked: onPolygonClicked,
      onRecenterButtonClicked: onRecenterButtonClicked,
    ),
  );

  final GoogleNavigationViewController controller =
      await controllerCompleter.future;
  await $.pumpAndSettle();

  if (initializeNavigation) {
    await GoogleMapsNavigator.initializeNavigationSession();
    await $.pumpAndSettle();
  }

  if (simulateLocation) {
    await GoogleMapsNavigator.simulator.setUserLocation(const LatLng(
      latitude: startLocationLat,
      longitude: startLocationLng,
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
