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

import 'dart:io';

import 'package:flutter/material.dart';

import 'shared.dart';

void main() {
  final mapTypeVariants = getMapTypeVariants();

  // Patrol runs the tests in alphabetical order, add a prefix to the test
  // name to control the order with script:
  int testCounter = 0;
  String prefix(String name) {
    testCounter++;
    return 'IT${testCounter.toString().padLeft(2, '0')} $name';
  }

  patrol(prefix('Test session initialization errors'), (
    PatrolIntegrationTester $,
  ) async {
    await GoogleMapsNavigator.resetTermsAccepted();
    expect(await GoogleMapsNavigator.areTermsAccepted(), false);
    expect(await GoogleMapsNavigator.isInitialized(), false);

    // The session initialization fails if the terms have not been accepted.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      fail('Expected SessionInitializationException');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionInitializationException>());
      expect(
        (e as SessionInitializationException).code,
        SessionInitializationError.termsNotAccepted,
      );
    }
    expect(await GoogleMapsNavigator.isInitialized(), false);

    await checkTermsAndConditionsAcceptance($);

    // The session initialization fails if the location permissions have not been granted.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      fail('Expected SessionInitializationException');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionInitializationException>());
      expect(
        (e as SessionInitializationException).code,
        SessionInitializationError.locationPermissionMissing,
      );
    }
    expect(await GoogleMapsNavigator.isInitialized(), false);

    // Before the initialization different navigation actions should throw an exception.
    try {
      await GoogleMapsNavigator.isGuidanceRunning();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      await GoogleMapsNavigator.cleanup();
      fail('Expected SessionInitializationException');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      await GoogleMapsNavigator.startGuidance();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      await GoogleMapsNavigator.stopGuidance();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      final Destinations destinations = Destinations(
        waypoints: <NavigationWaypoint>[
          NavigationWaypoint.withLatLngTarget(
            title: 'California St & Jones St',
            target: const LatLng(latitude: 37.791424, longitude: -122.414139),
          ),
        ],
        displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
      );
      await GoogleMapsNavigator.setDestinations(destinations);
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      await GoogleMapsNavigator.clearDestinations();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      // Note: Testing deprecated continueToNextDestination for proper exception
      // handling.
      await GoogleMapsNavigator.continueToNextDestination();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      await GoogleMapsNavigator.getCurrentTimeAndDistance();
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    try {
      final NavigationAudioGuidanceSettings settings =
          NavigationAudioGuidanceSettings(isVibrationEnabled: true);
      await GoogleMapsNavigator.setAudioGuidance(settings);
      fail('Expected SessionNotInitializedException.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionNotInitializedException>());
    }

    // Grant location permission.
    await checkLocationDialogAcceptance($);

    // Now the initialization should finally succeed.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
    } on SessionInitializationException {
      fail('Expected the initialization to go through');
    }
    expect(await GoogleMapsNavigator.isInitialized(), true);

    try {
      await GoogleMapsNavigator.resetTermsAccepted();
      fail(
        'Expected the terms reset to fail after successful session creation.',
      );
    } on Exception catch (e) {
      expect(e, const TypeMatcher<ResetTermsAndConditionsException>());
    }

    try {
      await GoogleMapsNavigator.isGuidanceRunning();
    } on SessionNotInitializedException {
      fail(
        'Expected isGuidanceRunning() to succeed after the successful navigation initialization.',
      );
    }

    // Test that SDK version call returns non-empty version string.
    final String version = await GoogleMapsNavigator.getNavSDKVersion();
    expect(version.length, greaterThan(0));

    // Test initializing with abnormal termination reporting enabled.
    try {
      await GoogleMapsNavigator.initializeNavigationSession(
        abnormalTerminationReportingEnabled: false,
      );
    } on Exception {
      fail('Expected the initialization to go through');
    }
  });

  patrol(prefix('Test Maps initialization'), (PatrolIntegrationTester $) async {
    final ControllerCompleter<GoogleMapViewController> viewControllerCompleter =
        ControllerCompleter();

    const CameraPosition cameraPosition = CameraPosition(
      target: LatLng(latitude: 65, longitude: 25.5),
      zoom: 12,
    );
    const MapType mapType = MapType.satellite;
    const bool compassEnabled = false;
    const bool rotateGesturesEnabled = false;
    const bool scrollGesturesEnabled = false;
    const bool tiltGesturesEnabled = false;
    const bool zoomGesturesEnabled = false;
    const bool scrollGesturesEnabledDuringRotateOrZoom = false;
    const bool mapToolbarEnabled = false;
    const bool zoomControlsEnabled = false;
    const double minZoomPreference = 5.0;
    const double maxZoomPreference = 18.0;
    const NavigationUIEnabledPreference navigationUiEnabledPreference =
        NavigationUIEnabledPreference.disabled;
    const MapColorScheme mapColorScheme = MapColorScheme.dark;
    const NavigationForceNightMode forceNightMode =
        NavigationForceNightMode.forceNight;

    /// Display navigation view.
    final Key key = GlobalKey();

    switch (mapTypeVariants.currentValue!) {
      case TestMapType.navigationView:
        try {
          await checkLocationDialogAndTosAcceptance($);
          await GoogleMapsNavigator.initializeNavigationSession();
        } on SessionInitializationException {
          fail('Expected the initialization to go through');
        }
        expect(await GoogleMapsNavigator.isInitialized(), true);
        await pumpNavigationView(
          $,
          GoogleMapsNavigationView(
            key: key,
            onViewCreated: (GoogleMapViewController controller) {
              viewControllerCompleter.complete(controller);
            },
            initialCameraPosition: cameraPosition,
            initialMapType: mapType,
            initialCompassEnabled: compassEnabled,
            initialRotateGesturesEnabled: rotateGesturesEnabled,
            initialScrollGesturesEnabled: scrollGesturesEnabled,
            initialTiltGesturesEnabled: tiltGesturesEnabled,
            initialZoomGesturesEnabled: zoomGesturesEnabled,
            initialScrollGesturesEnabledDuringRotateOrZoom:
                scrollGesturesEnabledDuringRotateOrZoom,
            initialMapToolbarEnabled: mapToolbarEnabled,
            initialZoomControlsEnabled: zoomControlsEnabled,
            initialMinZoomPreference: minZoomPreference,
            initialMaxZoomPreference: maxZoomPreference,
            // ignore: avoid_redundant_argument_values
            initialNavigationUIEnabledPreference: navigationUiEnabledPreference,
            initialMapColorScheme: mapColorScheme,
            initialForceNightMode: forceNightMode,
          ),
        );
      case TestMapType.mapView:
        await pumpMapView(
          $,
          GoogleMapsMapView(
            key: key,
            onViewCreated: (GoogleMapViewController controller) {
              viewControllerCompleter.complete(controller);
            },
            initialCameraPosition: cameraPosition,
            initialMapType: mapType,
            initialCompassEnabled: compassEnabled,
            initialRotateGesturesEnabled: rotateGesturesEnabled,
            initialScrollGesturesEnabled: scrollGesturesEnabled,
            initialTiltGesturesEnabled: tiltGesturesEnabled,
            initialZoomGesturesEnabled: zoomGesturesEnabled,
            initialScrollGesturesEnabledDuringRotateOrZoom:
                scrollGesturesEnabledDuringRotateOrZoom,
            initialMapToolbarEnabled: mapToolbarEnabled,
            initialZoomControlsEnabled: zoomControlsEnabled,
            initialMinZoomPreference: minZoomPreference,
            initialMaxZoomPreference: maxZoomPreference,
            initialMapColorScheme: mapColorScheme,
          ),
        );
    }

    final GoogleMapViewController controller =
        await viewControllerCompleter.future;

    await controller.setMyLocationEnabled(false);

    final CameraPosition cameraOut = await controller.getCameraPosition();

    expect(
      cameraOut.target.latitude,
      closeTo(cameraPosition.target.latitude, 0.1),
      reason: 'Latitude value mismatch',
    );
    expect(
      cameraOut.target.longitude,
      closeTo(cameraPosition.target.longitude, 0.1),
      reason: 'Longitude value mismatch',
    );
    expect(
      cameraOut.zoom,
      closeTo(cameraPosition.zoom, 0.1),
      reason: 'Zoom value mismatch',
    );
    expect(await controller.getMapType(), mapType, reason: 'Map type mismatch');
    expect(
      await controller.settings.isCompassEnabled(),
      compassEnabled,
      reason: 'Compass enabled mismatch',
    );
    expect(
      await controller.settings.isRotateGesturesEnabled(),
      rotateGesturesEnabled,
      reason: 'Rotate gestures enabled mismatch',
    );
    expect(
      await controller.settings.isScrollGesturesEnabled(),
      scrollGesturesEnabled,
      reason: 'Scroll gestures enabled mismatch',
    );
    expect(
      await controller.settings.isTiltGesturesEnabled(),
      tiltGesturesEnabled,
      reason: 'Tilt gestures enabled mismatch',
    );
    expect(
      await controller.settings.isZoomGesturesEnabled(),
      zoomGesturesEnabled,
      reason: 'Zoom gestures enabled mismatch',
    );
    expect(
      await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
      scrollGesturesEnabledDuringRotateOrZoom,
      reason: 'Scroll gestures during rotate or zoom mismatch',
    );
    if (Platform.isAndroid) {
      expect(
        await controller.settings.isMapToolbarEnabled(),
        mapToolbarEnabled,
        reason: 'Map toolbar enabled mismatch',
      );
      expect(
        await controller.settings.isZoomControlsEnabled(),
        zoomControlsEnabled,
        reason: 'Zoom controls enabled mismatch',
      );
    }
    expect(
      await controller.getMinZoomPreference(),
      minZoomPreference,
      reason: 'Min zoom preference mismatch',
    );
    expect(
      await controller.getMaxZoomPreference(),
      maxZoomPreference,
      reason: 'Max zoom preference mismatch',
    );
    // Test map color scheme initial value
    expect(
      await controller.getMapColorScheme(),
      mapColorScheme,
      reason: 'Map color scheme mismatch',
    );

    if (mapTypeVariants.currentValue == TestMapType.navigationView) {
      expect(controller, isA<GoogleNavigationViewController>());
      var navViewController = controller as GoogleNavigationViewController;
      expect(
        await navViewController.isNavigationUIEnabled(),
        false,
        reason: 'Navigation UI enabled mismatch',
      );
      // Test force night mode initial value (navigation view only)
      expect(
        await navViewController.getForceNightMode(),
        forceNightMode,
        reason: 'Force night mode mismatch',
      );
    }
  }, variant: mapTypeVariants);
}
