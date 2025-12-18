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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

import '../helpers/mock_auto_api.dart';
import '../helpers/mock_navigation_platform.dart';
import '../helpers/mock_map_view_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoMapView Event Listener Tests', () {
    late TestAutoMapViewAPIImpl testAutoApi;
    late GoogleMapsNavigationPlatform testPlatform;

    setUp(() {
      // Create test auto API that allows direct DTO injection
      testAutoApi = TestAutoMapViewAPIImpl();

      // Create test platform instance with our test AutoAPI
      testPlatform = TestGoogleMapsNavigationPlatform(
        TestNavigationSessionAPIImpl(),
        TestMapViewAPIImpl(),
        testAutoApi,
        ImageRegistryAPIImpl(),
      );

      // Set as the active platform instance
      GoogleMapsNavigationPlatform.instance = testPlatform;
    });

    test('CustomNavigationAutoEvent stream receives events', () async {
      CustomNavigationAutoEvent? receivedEvent;
      const String testEventName = 'test_event';
      const String testEventData = 'test_data';

      // Subscribe directly to the test API's stream
      testAutoApi.getCustomNavigationAutoEventStream().listen((
        CustomNavigationAutoEvent event,
      ) {
        receivedEvent = event;
      });
      await Future<void>.delayed(Duration.zero);

      // Inject event via test API
      testAutoApi.testEventApi.onCustomNavigationAutoEvent(
        testEventName,
        testEventData,
      );
      await Future<void>.delayed(Duration.zero);

      // Verify event was received
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.event, testEventName);
      expect(receivedEvent!.data, testEventData);
    });

    test('AutoScreenAvailabilityChangedEvent stream receives events', () async {
      AutoScreenAvailabilityChangedEvent? receivedEvent;
      const bool testAvailability = true;

      // Subscribe directly to the test API's stream
      testAutoApi.getAutoScreenAvailabilityChangedEventStream().listen((
        AutoScreenAvailabilityChangedEvent event,
      ) {
        receivedEvent = event;
      });
      await Future<void>.delayed(Duration.zero);

      // Inject event via test API
      testAutoApi.testEventApi.onAutoScreenAvailabilityChanged(
        testAvailability,
      );
      await Future<void>.delayed(Duration.zero);

      // Verify event was received
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.isAvailable, testAvailability);
    });

    test('Multiple CustomNavigationAutoEvent events are received', () async {
      final List<CustomNavigationAutoEvent> receivedEvents =
          <CustomNavigationAutoEvent>[];

      // Subscribe directly to the test API's stream
      testAutoApi.getCustomNavigationAutoEventStream().listen((
        CustomNavigationAutoEvent event,
      ) {
        receivedEvents.add(event);
      });
      await Future<void>.delayed(Duration.zero);

      // Inject multiple events
      testAutoApi.testEventApi.onCustomNavigationAutoEvent('event1', 'data1');
      testAutoApi.testEventApi.onCustomNavigationAutoEvent('event2', 'data2');
      testAutoApi.testEventApi.onCustomNavigationAutoEvent('event3', 'data3');
      await Future<void>.delayed(Duration.zero);

      // Verify all events were received
      expect(receivedEvents.length, 3);
      expect(receivedEvents[0].event, 'event1');
      expect(receivedEvents[0].data, 'data1');
      expect(receivedEvents[1].event, 'event2');
      expect(receivedEvents[1].data, 'data2');
      expect(receivedEvents[2].event, 'event3');
      expect(receivedEvents[2].data, 'data3');
    });

    test(
      'Multiple AutoScreenAvailabilityChangedEvent events are received',
      () async {
        final List<AutoScreenAvailabilityChangedEvent> receivedEvents =
            <AutoScreenAvailabilityChangedEvent>[];

        // Subscribe directly to the test API's stream
        testAutoApi.getAutoScreenAvailabilityChangedEventStream().listen((
          AutoScreenAvailabilityChangedEvent event,
        ) {
          receivedEvents.add(event);
        });
        await Future<void>.delayed(Duration.zero);

        // Inject multiple events with different availability states
        testAutoApi.testEventApi.onAutoScreenAvailabilityChanged(true);
        testAutoApi.testEventApi.onAutoScreenAvailabilityChanged(false);
        testAutoApi.testEventApi.onAutoScreenAvailabilityChanged(true);
        await Future<void>.delayed(Duration.zero);

        // Verify all events were received
        expect(receivedEvents.length, 3);
        expect(receivedEvents[0].isAvailable, true);
        expect(receivedEvents[1].isAvailable, false);
        expect(receivedEvents[2].isAvailable, true);
      },
    );
  });
}
