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

import 'package:flutter/material.dart';

import 'shared.dart';

void main() {
  patrol('Test enabling navigation UI', (PatrolIntegrationTester $) async {
    final ControllerCompleter<GoogleNavigationViewController>
    viewControllerCompleter = ControllerCompleter();

    /// For testing NavigationUIEnabledChanged
    bool navigationUIisEnabled = false;

    /// For testing PromptVisibilityChanged
    bool? promptVisible;

    await checkLocationDialogAndTosAcceptance($);

    /// The events are not tested because there's no reliable way to trigger them currently.
    void onRecenterButtonClicked(
      NavigationViewRecenterButtonClickedEvent event,
    ) {
      $.log('Re-center button clicked event: $event.');
    }

    /// For testing PromptVisibilityChanged
    void onPromptVisibilityChanged(bool promptVisible_) {
      $.log('Prompt visibility changed event: $promptVisible_.');
      promptVisible = promptVisible_;
    }

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          viewControllerCompleter.complete(controller);
        },
        onNavigationUIEnabledChanged: (bool isEnabled) {
          navigationUIisEnabled = isEnabled;
        },
        onRecenterButtonClicked: onRecenterButtonClicked,
        onPromptVisibilityChanged: onPromptVisibilityChanged,
      ),
    );

    final GoogleNavigationViewController viewController =
        await viewControllerCompleter.future;

    await viewController.setMyLocationEnabled(true);

    expect(
      await viewController.isNavigationUIEnabled(),
      false,
      reason:
          'isNavigationUIEnabled should return false when navigation is not yet initialized.',
    );
    waitForValueMatchingPredicate<bool>(
      $,
      () async => navigationUIisEnabled,
      (bool value) => value == false,
    );
    expect(navigationUIisEnabled, false);

    /// Initialize navigation.
    await GoogleMapsNavigator.initializeNavigationSession();

    expect(
      await viewController.isNavigationUIEnabled(),
      true,
      reason:
          'isNavigationUIEnabled should return true after navigation is initialized.',
    );
    waitForValueMatchingPredicate<bool>(
      $,
      () async => navigationUIisEnabled,
      (bool value) => value == true,
    );
    expect(
      navigationUIisEnabled,
      true,
      reason:
          'onNavigationUIEnabledChanged should be called after navigation is initialized with enabled state.',
    );

    await $.pumpAndSettle();

    /// Simulate location (1298 California St)
    await GoogleMapsNavigator.simulator.setUserLocation(
      const LatLng(latitude: 37.79136614772824, longitude: -122.41565900473043),
    );
    await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 1)));

    /// Set Destination.
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
    await $.pumpAndSettle();

    /// Start guidance.
    await GoogleMapsNavigator.startGuidance();
    await $.pumpAndSettle();

    /// Start simulation.
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    final List<bool> results = <bool>[false, true, false];

    /// Test enabling and disabling the navigation UI.
    for (final bool result in results) {
      await viewController.setNavigationUIEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled = await viewController.isNavigationUIEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('NavigationUIEnabled', result),
      );

      /// Test that NavigationUIEnabledChanged event works.
      waitForValueMatchingPredicate<bool>(
        $,
        () async => navigationUIisEnabled,
        (bool value) => value == result,
      );
      expect(navigationUIisEnabled, result);
    }

    /// Test enabling and disabling the header.
    for (final bool result in results) {
      await viewController.setNavigationHeaderEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled = await viewController.isNavigationHeaderEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('NavigationHeaderEnabled', result),
      );
    }

    /// Test enabling and disabling the footer.
    for (final bool result in results) {
      await viewController.setNavigationFooterEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled = await viewController.isNavigationFooterEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('NavigationFooterEnabled', result),
      );
    }

    /// Test enabling and disabling the trip progress bar.
    for (final bool result in results) {
      await viewController.setNavigationTripProgressBarEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled =
          await viewController.isNavigationTripProgressBarEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle(
          'NavigationTripProgressBarEnabled',
          result,
        ),
      );
    }

    /// Test enabling and disabling the speedometer.
    for (final bool result in results) {
      await viewController.setSpeedometerEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled = await viewController.isSpeedometerEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('SpeedometerEnabled', result),
      );
    }

    /// Test enabling and disabling the speed limit.
    for (final bool result in results) {
      await viewController.setSpeedLimitIconEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled = await viewController.isSpeedLimitIconEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('SpeedLimitIconEnabled', result),
      );
    }

    /// Test enabling and disabling the traffic incident cards.
    for (final bool result in results) {
      await viewController.setTrafficIncidentCardsEnabled(result);
      await $.pumpAndSettle();
      final bool isEnabled =
          await viewController.isTrafficIncidentCardsEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('TrafficIncidentCardsEnabled', result),
      );
    }

    /// Test enabling and disabling the recenter button.
    for (final bool result in results) {
      await viewController.setRecenterButtonEnabled(result);
      final bool isEnabled = await viewController.isRecenterButtonEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('RecenterButtonEnabled', result),
      );
    }

    /// Test enabling and disabling the report incident button.
    for (final bool result in results) {
      await viewController.setReportIncidentButtonEnabled(result);
      final bool isEnabled =
          await viewController.isReportIncidentButtonEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('ReportIncidentButtonEnabled', result),
      );
    }

    /// Test enabling and disabling the traffic prompts.
    for (final bool result in results) {
      await viewController.setTrafficPromptsEnabled(result);
      final bool isEnabled = await viewController.isTrafficPromptsEnabled();
      expect(
        isEnabled,
        result,
        reason: buildReasonForToggle('TrafficPromptsEnabled', result),
      );
    }

    /// Test incident reporting availability.
    final bool isIncidentReportingAvailable =
        await viewController.isIncidentReportingAvailable();
    $.log('Incident reporting available: $isIncidentReportingAvailable');
    expect(
      isIncidentReportingAvailable,
      true,
      reason:
          'Incident reporting should be available during navigation on tests.',
    );

    /// Test prompt visibility and incident reporting panel.
    if (isIncidentReportingAvailable) {
      // Reset prompt visibility state
      promptVisible = null;

      $.log('Opening incident reporting panel...');
      await viewController.showReportIncidentsPanel();
      await $.pumpAndSettle(timeout: const Duration(seconds: 2));

      /// Check if prompt visibility event was triggered
      waitForValueMatchingPredicate<bool?>(
        $,
        () async => promptVisible,
        (bool? value) => value == true,
        maxTries: 50, // Wait up to 5 seconds (50 * 100ms)
      );

      expect(
        promptVisible,
        true,
        reason:
            'Prompt visibility should be true when incident panel is shown.',
      );
    }

    await GoogleMapsNavigator.cleanup();
  });
}
