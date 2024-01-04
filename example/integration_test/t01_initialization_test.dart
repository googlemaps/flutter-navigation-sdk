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

import 'shared.dart';

void main() {
  patrol('Test session initialization errors',
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
                title: 'Grace Cathedral',
                target: const LatLng(
                  latitude: 37.791957,
                  longitude: -122.412529,
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
  });
}
