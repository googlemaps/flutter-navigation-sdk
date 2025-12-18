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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

import '../helpers/mock_auto_api.dart';
import '../helpers/mock_navigation_platform.dart';
import '../helpers/mock_map_view_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NavigationViewState Event Listener Integration Tests', () {
    late TestMapViewAPIImpl testMapViewApi;
    late GoogleMapsNavigationPlatform testPlatform;

    setUp(() {
      // Create test map view API that allows direct DTO injection
      testMapViewApi = TestMapViewAPIImpl();
      testMapViewApi.ensureViewAPISetUp();

      // Create test platform instance with our test MapViewAPI
      testPlatform = TestGoogleMapsNavigationPlatform(
        TestNavigationSessionAPIImpl(),
        testMapViewApi,
        TestAutoMapViewAPIImpl(),
        ImageRegistryAPIImpl(),
      );

      // Set as the active platform instance
      GoogleMapsNavigationPlatform.instance = testPlatform;
    });

    // Helper function to get the view ID from the test platform
    int getViewId() {
      final int? viewId = TestGoogleMapsNavigationPlatform.lastCreatedViewId;
      if (viewId == null) {
        throw StateError('No view has been created yet');
      }
      return viewId;
    }

    testWidgets('onNavigationUIEnabledChanged callback receives event', (
      WidgetTester tester,
    ) async {
      bool? receivedNavigationUIEnabled;

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsNavigationView(
            onViewCreated: (_) {},
            onNavigationUIEnabledChanged: (bool navigationUIEnabled) {
              receivedNavigationUIEnabled = navigationUIEnabled;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Test navigation UI enabled
      testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
        testViewId,
        true,
      );

      await tester.pump();

      expect(receivedNavigationUIEnabled, true);

      // Test navigation UI disabled
      testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
        testViewId,
        false,
      );

      await tester.pump();

      expect(receivedNavigationUIEnabled, false);
    });

    testWidgets('onPromptVisibilityChanged callback receives event', (
      WidgetTester tester,
    ) async {
      bool? receivedPromptVisible;

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsNavigationView(
            onViewCreated: (_) {},
            onPromptVisibilityChanged: (bool promptVisible) {
              receivedPromptVisible = promptVisible;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Test prompt visible
      testMapViewApi.testEventApi.onPromptVisibilityChanged(testViewId, true);

      await tester.pump();

      expect(receivedPromptVisible, true);

      // Test prompt hidden
      testMapViewApi.testEventApi.onPromptVisibilityChanged(testViewId, false);

      await tester.pump();

      expect(receivedPromptVisible, false);
    });

    testWidgets('onRecenterButtonClicked callback receives event', (
      WidgetTester tester,
    ) async {
      bool recenterButtonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsNavigationView(
            onViewCreated: (_) {},
            onRecenterButtonClicked:
                (NavigationViewRecenterButtonClickedEvent event) {
                  recenterButtonClicked = true;
                },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onRecenterButtonClicked(testViewId);

      await tester.pump();

      expect(recenterButtonClicked, true);
    });

    testWidgets('map view and navigation-specific events work together', (
      WidgetTester tester,
    ) async {
      // Test both inherited map view events and navigation-specific events
      LatLng? receivedMapClick;
      String? receivedMarkerId;
      bool? navigationUIEnabled;
      bool? promptVisible;
      bool recenterClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsNavigationView(
            onViewCreated: (_) {},
            onMapClicked: (LatLng latLng) {
              receivedMapClick = latLng;
            },
            onMarkerClicked: (String markerId) {
              receivedMarkerId = markerId;
            },
            onNavigationUIEnabledChanged: (bool enabled) {
              navigationUIEnabled = enabled;
            },
            onPromptVisibilityChanged: (bool visible) {
              promptVisible = visible;
            },
            onRecenterButtonClicked:
                (NavigationViewRecenterButtonClickedEvent event) {
                  recenterClicked = true;
                },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Fire both map view and navigation-specific events
      testMapViewApi.testEventApi.onMapClickEvent(
        testViewId,
        LatLngDto(latitude: 1.0, longitude: 2.0),
      );
      testMapViewApi.testEventApi.onMarkerEvent(
        testViewId,
        'marker1',
        MarkerEventTypeDto.clicked,
      );
      testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
        testViewId,
        true,
      );
      testMapViewApi.testEventApi.onPromptVisibilityChanged(testViewId, true);
      testMapViewApi.testEventApi.onRecenterButtonClicked(testViewId);

      await tester.pump();

      // Verify all callbacks were called
      expect(receivedMapClick, isNotNull);
      expect(receivedMarkerId, 'marker1');
      expect(navigationUIEnabled, true);
      expect(promptVisible, true);
      expect(recenterClicked, true);
    });

    testWidgets(
      'navigation-specific callbacks not registered do not cause errors',
      (WidgetTester tester) async {
        // Create view without navigation-specific callbacks
        await tester.pumpWidget(
          MaterialApp(
            home: GoogleMapsNavigationView(
              onViewCreated: (_) {},
              // No navigation-specific callbacks registered
            ),
          ),
        );

        await tester.pumpAndSettle();

        final int testViewId = getViewId();

        // Fire navigation-specific events - should not throw errors
        expect(() {
          testMapViewApi.testEventApi.onNavigationUIEnabledChanged(
            testViewId,
            true,
          );
          testMapViewApi.testEventApi.onPromptVisibilityChanged(
            testViewId,
            true,
          );
          testMapViewApi.testEventApi.onRecenterButtonClicked(testViewId);
        }, returnsNormally);

        await tester.pump();
      },
    );
  });
}
