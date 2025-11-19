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

import 'package:flutter/material.dart';
import 'shared.dart';

void main() {
  patrol('Test guidance notifications enable and disable', (
    PatrolIntegrationTester $,
  ) async {
    // Initialize the navigator
    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {},
      ),
    );

    // Initialize navigation session
    await GoogleMapsNavigator.initializeNavigationSession();
    expect(await GoogleMapsNavigator.isInitialized(), true);

    // Test default state - should be enabled by default on most platforms
    final bool initialState =
        await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    $.log('Initial guidance notifications state: $initialState');

    // Test enabling guidance notifications
    await GoogleMapsNavigator.setGuidanceNotificationsEnabled(true);
    bool currentState =
        await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(
      currentState,
      true,
      reason: 'Guidance notifications should be enabled',
    );
    $.log('Successfully enabled guidance notifications');

    // Test disabling guidance notifications
    await GoogleMapsNavigator.setGuidanceNotificationsEnabled(false);
    currentState = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(
      currentState,
      false,
      reason: 'Guidance notifications should be disabled',
    );
    $.log('Successfully disabled guidance notifications');

    // Test re-enabling guidance notifications
    await GoogleMapsNavigator.setGuidanceNotificationsEnabled(true);
    currentState = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(
      currentState,
      true,
      reason: 'Guidance notifications should be enabled again',
    );
    $.log('Successfully re-enabled guidance notifications');
  });

  patrol('Test guidance notifications state persistence', (
    PatrolIntegrationTester $,
  ) async {
    // Initialize the navigator
    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {},
      ),
    );

    // Initialize navigation session
    await GoogleMapsNavigator.initializeNavigationSession();
    expect(await GoogleMapsNavigator.isInitialized(), true);

    // Set to a known state (disabled)
    await GoogleMapsNavigator.setGuidanceNotificationsEnabled(false);
    bool state = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(state, false, reason: 'Initial state should be disabled');

    // Verify state is still disabled
    state = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(state, false, reason: 'State should persist as disabled');
    $.log('State persisted correctly as disabled');

    // Change to enabled
    await GoogleMapsNavigator.setGuidanceNotificationsEnabled(true);
    state = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(state, true, reason: 'State should be enabled');

    // Verify state is still enabled
    state = await GoogleMapsNavigator.getGuidanceNotificationsEnabled();
    expect(state, true, reason: 'State should persist as enabled');
    $.log('State persisted correctly as enabled');
  });
}
