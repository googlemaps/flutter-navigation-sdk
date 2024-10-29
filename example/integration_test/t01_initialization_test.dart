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
  patrol('C01 - Test session initialization errors',
      (PatrolIntegrationTester $) async {
    await GoogleMapsNavigator.resetTermsAccepted();
    expect(await GoogleMapsNavigator.areTermsAccepted(), false);
    expect(await GoogleMapsNavigator.isInitialized(), false);

    // The session initialization fails if the terms have not been accepted.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      fail('Expected SessionInitializationException');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionInitializationException>());
      expect((e as SessionInitializationException).code,
          SessionInitializationError.termsNotAccepted);
    }
    expect(await GoogleMapsNavigator.isInitialized(), false);

    await checkTermsAndConditionsAcceptance($);

    // The session initialization fails if the location permissions have not been granted.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      fail('Expected SessionInitializationException');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<SessionInitializationException>());
      expect((e as SessionInitializationException).code,
          SessionInitializationError.locationPermissionMissing);
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
                target: const LatLng(
                  latitude: 37.791424,
                  longitude: -122.414139,
                )),
          ],
          displayOptions:
              NavigationDisplayOptions(showDestinationMarkers: false));
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
          'Expected the terms reset to fail after successful session creation.');
    } on Exception catch (e) {
      expect(e, const TypeMatcher<ResetTermsAndConditionsException>());
    }

    try {
      await GoogleMapsNavigator.isGuidanceRunning();
    } on SessionNotInitializedException {
      fail(
          'Expected isGuidanceRunning() to succeed after the successful navigation initialization.');
    }

    // Test that SDK version call returns non-empty version string.
    final String version = await GoogleMapsNavigator.getNavSDKVersion();
    expect(version.length, greaterThan(0));

    // Test initializing with abnormal termination reporting enabled.
    try {
      await GoogleMapsNavigator.initializeNavigationSession(
          abnormalTerminationReportingEnabled: false);
    } on Exception {
      fail('Expected the initialization to go through');
    }
  });

  patrol('C02 - Test Maps initialization', (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkTermsAndConditionsAcceptance($);
    await checkLocationDialogAcceptance($);

    // Now the initialization should finally succeed.
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
    } on SessionInitializationException {
      fail('Expected the initialization to go through');
    }
    expect(await GoogleMapsNavigator.isInitialized(), true);

    const CameraPosition cameraPosition =
        CameraPosition(target: LatLng(latitude: 65, longitude: 25.5), zoom: 12);
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
        NavigationUIEnabledPreference.automatic;

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
      ),
    );

    final GoogleNavigationViewController controller =
        await viewControllerCompleter.future;
    final CameraPosition cameraOut = await controller.getCameraPosition();

    expect(cameraOut.target.latitude,
        closeTo(cameraPosition.target.latitude, 0.1));
    expect(cameraOut.target.longitude,
        closeTo(cameraPosition.target.longitude, 0.1));
    expect(cameraOut.zoom, closeTo(cameraPosition.zoom, 0.1));
    expect(await controller.getMapType(), mapType);
    expect(await controller.settings.isCompassEnabled(), compassEnabled);
    expect(await controller.settings.isRotateGesturesEnabled(),
        rotateGesturesEnabled);
    expect(await controller.settings.isScrollGesturesEnabled(),
        scrollGesturesEnabled);
    expect(
        await controller.settings.isTiltGesturesEnabled(), tiltGesturesEnabled);
    expect(
        await controller.settings.isZoomGesturesEnabled(), zoomGesturesEnabled);
    expect(
        await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
        scrollGesturesEnabledDuringRotateOrZoom);
    if (Platform.isAndroid) {
      expect(
          await controller.settings.isMapToolbarEnabled(), mapToolbarEnabled);
      expect(await controller.settings.isZoomControlsEnabled(),
          zoomControlsEnabled);
    }
    expect(await controller.getMinZoomPreference(), minZoomPreference);
    expect(await controller.getMaxZoomPreference(), maxZoomPreference);
    expect(await controller.isNavigationUIEnabled(), true);
  });

  patrol('C03 - Test Maps initialization without navigation',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleMapViewController> viewControllerCompleter =
        Completer<GoogleMapViewController>();

    const CameraPosition cameraPosition =
        CameraPosition(target: LatLng(latitude: 65, longitude: 25.5), zoom: 12);
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

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpMapView(
      $,
      GoogleMapsMapView(
        key: key,
        onViewCreated: (GoogleMapViewController controller) {
          controller.setMyLocationEnabled(true);
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
      ),
    );

    final GoogleMapViewController controller =
        await viewControllerCompleter.future;
    final CameraPosition cameraOut = await controller.getCameraPosition();

    expect(cameraOut.target.latitude,
        closeTo(cameraPosition.target.latitude, 0.1));
    expect(cameraOut.target.longitude,
        closeTo(cameraPosition.target.longitude, 0.1));
    expect(cameraOut.zoom, closeTo(cameraPosition.zoom, 0.1));
    expect(await controller.getMapType(), mapType);
    expect(await controller.settings.isCompassEnabled(), compassEnabled);
    expect(await controller.settings.isRotateGesturesEnabled(),
        rotateGesturesEnabled);
    expect(await controller.settings.isScrollGesturesEnabled(),
        scrollGesturesEnabled);
    expect(
        await controller.settings.isTiltGesturesEnabled(), tiltGesturesEnabled);
    expect(
        await controller.settings.isZoomGesturesEnabled(), zoomGesturesEnabled);
    expect(
        await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
        scrollGesturesEnabledDuringRotateOrZoom);
    if (Platform.isAndroid) {
      expect(
          await controller.settings.isMapToolbarEnabled(), mapToolbarEnabled);
      expect(await controller.settings.isZoomControlsEnabled(),
          zoomControlsEnabled);
    }
    expect(await controller.getMinZoomPreference(), minZoomPreference);
    expect(await controller.getMaxZoomPreference(), maxZoomPreference);
  });
}
