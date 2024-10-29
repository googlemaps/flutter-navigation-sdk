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
  patrol('Test terms and conditions (TOS) dialog acceptance',
      (PatrolIntegrationTester $) async {
    // Grant the location permission.
    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
        $,
        GoogleMapsNavigationView(
            key: key,
            onViewCreated: (GoogleNavigationViewController controller) {}));

    /// Reset TOS acceptance.
    await GoogleMapsNavigator.resetTermsAccepted();
    expect(await GoogleMapsNavigator.areTermsAccepted(), false);

    /// Request native TOS dialog.
    final Future<bool> tosAccepted =
        GoogleMapsNavigator.showTermsAndConditionsDialog(
      'test_title',
      'test_company_name',
    );

    // Tap ok.
    if (Platform.isAndroid) {
      await $.native.tap(Selector(text: "Got It"));
    } else if (Platform.isIOS) {
      await $.native.tap(Selector(text: "OK"));
    } else {
      fail('Unsupported platform: ${Platform.operatingSystem}');
    }

    // Check that the results match.
    await tosAccepted.then((bool accept) {
      expect(accept, true);
    });
    expect(await GoogleMapsNavigator.areTermsAccepted(), true);

    // If terms have already been accepted another call to showTermsAndConditionsDialog()
    // should just return true without errors and without showing any dialogs.
    expect(await GoogleMapsNavigator.areTermsAccepted(), true);
    final bool redundantAccept =
        await GoogleMapsNavigator.showTermsAndConditionsDialog(
      'test_title',
      'test_company_name',
    );
    expect(redundantAccept, true);
  });

  patrol('Test driver awareness disclaimer (noTOS) acknowledgement',
      (PatrolIntegrationTester $) async {
    // Grant location permissions if not granted.
    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
        $,
        GoogleMapsNavigationView(
            key: key,
            onViewCreated: (GoogleNavigationViewController controller) {}));

    await GoogleMapsNavigator.resetTermsAccepted();

    if (Platform.isAndroid) {
      /// Request native TOS dialog
      final Future<bool> tosAccepted =
          GoogleMapsNavigator.showTermsAndConditionsDialog(
              'test_title', 'test_company_name',
              shouldOnlyShowDriverAwarenessDisclaimer: true);

      // Accept driver awareness disclaimer.
      if (Platform.isAndroid) {
        await $.native.tap(Selector(text: "Got It"));
      } else if (Platform.isIOS) {
        await $.native.tap(Selector(text: "OK"));
      } else {
        fail('Unsupported platform: ${Platform.operatingSystem}');
      }

      // Check that the results match.
      await tosAccepted.then((bool accept) {
        expect(accept, true);
      });
      expect(await GoogleMapsNavigator.areTermsAccepted(), true);

      /// Try to create navigation session.
      await GoogleMapsNavigator.initializeNavigationSession();

      // Check that the creation succeeded.
      expect(await GoogleMapsNavigator.isInitialized(), true);
    } else if (Platform.isIOS) {
      // Test that iOS throws unsupported error
      try {
        await GoogleMapsNavigator.showTermsAndConditionsDialog(
            'test_title', 'test_company_name',
            shouldOnlyShowDriverAwarenessDisclaimer: true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
    } else {
      fail('Unsupported platform: ${Platform.operatingSystem}');
    }
  });
}
