// Copyright 2025 Google LLC
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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../helpers/mock_map_view_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestMapViewAPIImpl testMapViewApi;

  setUp(() {
    // Create test map view API that allows direct DTO injection
    testMapViewApi = TestMapViewAPIImpl();
    testMapViewApi.ensureViewAPISetUp();
  });

  group('Navigation UI Events', () {
    const int testViewId = 1;

    test(
      'onNavigationUIEnabledChanged fires and delivers correct data',
      () async {
        final List<NavigationUIEnabledChangedEvent> receivedEvents =
            <NavigationUIEnabledChangedEvent>[];
        final StreamSubscription<NavigationUIEnabledChangedEvent> subscription =
            testMapViewApi
                .getNavigationUIEnabledChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
          testViewId,
          true,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].navigationUIEnabled, true);

        await subscription.cancel();
      },
    );

    test('navigation UI events do not fire after listener removal', () async {
      final List<NavigationUIEnabledChangedEvent> receivedEvents =
          <NavigationUIEnabledChangedEvent>[];
      final StreamSubscription<NavigationUIEnabledChangedEvent> subscription =
          testMapViewApi
              .getNavigationUIEnabledChangedEventStream(viewId: testViewId)
              .listen(receivedEvents.add);

      testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
        testViewId,
        true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(receivedEvents.length, 1);

      await subscription.cancel();

      testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
        testViewId,
        false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(receivedEvents.length, 1);
    });
  });

  group('Prompt Visibility Events', () {
    const int testViewId = 1;

    test('onPromptVisibilityChanged fires and delivers correct data', () async {
      final List<PromptVisibilityChangedEvent> receivedEvents =
          <PromptVisibilityChangedEvent>[];
      final StreamSubscription<PromptVisibilityChangedEvent> subscription =
          testMapViewApi
              .getPromptVisibilityChangedEventStream(viewId: testViewId)
              .listen(receivedEvents.add);

      testMapViewApi.testEventApi.onPromptVisibilityChanged(testViewId, true);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(receivedEvents.length, 1);
      expect(receivedEvents[0].promptVisible, true);

      await subscription.cancel();
    });

    test(
      'prompt visibility events do not fire after listener removal',
      () async {
        final List<PromptVisibilityChangedEvent> receivedEvents =
            <PromptVisibilityChangedEvent>[];
        final StreamSubscription<PromptVisibilityChangedEvent> subscription =
            testMapViewApi
                .getPromptVisibilityChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onPromptVisibilityChanged(testViewId, true);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onPromptVisibilityChanged(
          testViewId,
          false,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      },
    );
  });
}
