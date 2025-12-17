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

  group('MapViewState Event Listener Integration Tests', () {
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

    testWidgets('onMapClicked callback receives event', (
      WidgetTester tester,
    ) async {
      LatLng? receivedLatLng;
      const LatLng testLatLng = LatLng(latitude: 37.4220, longitude: -122.0841);

      // Build the map view with onMapClicked callback
      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onMapClicked: (LatLng latLng) {
              receivedLatLng = latLng;
            },
          ),
        ),
      );

      // Wait for the widget to initialize (post-frame callbacks to complete)
      await tester.pumpAndSettle();

      // Get the actual view ID that was assigned
      final int testViewId = getViewId();

      // Simulate platform event
      testMapViewApi.testEventApi.onMapClickEvent(
        testViewId,
        LatLngDto(
          latitude: testLatLng.latitude,
          longitude: testLatLng.longitude,
        ),
      );

      // Wait for event to propagate
      await tester.pump();

      // Verify callback was called with correct data
      expect(receivedLatLng, isNotNull);
      expect(receivedLatLng!.latitude, testLatLng.latitude);
      expect(receivedLatLng!.longitude, testLatLng.longitude);
    });

    testWidgets('onMapLongClicked callback receives event', (
      WidgetTester tester,
    ) async {
      LatLng? receivedLatLng;
      const LatLng testLatLng = LatLng(latitude: 40.7128, longitude: -74.0060);

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onMapLongClicked: (LatLng latLng) {
              receivedLatLng = latLng;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onMapLongClickEvent(
        testViewId,
        LatLngDto(
          latitude: testLatLng.latitude,
          longitude: testLatLng.longitude,
        ),
      );

      await tester.pump();

      expect(receivedLatLng, isNotNull);
      expect(receivedLatLng!.latitude, testLatLng.latitude);
      expect(receivedLatLng!.longitude, testLatLng.longitude);
    });

    testWidgets('onMarkerClicked callback receives event', (
      WidgetTester tester,
    ) async {
      String? receivedMarkerId;
      const String testMarkerId = 'marker123';

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onMarkerClicked: (String markerId) {
              receivedMarkerId = markerId;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onMarkerEvent(
        testViewId,
        testMarkerId,
        MarkerEventTypeDto.clicked,
      );

      await tester.pump();

      expect(receivedMarkerId, testMarkerId);
    });

    testWidgets('onMarkerDrag callbacks receive events for all drag types', (
      WidgetTester tester,
    ) async {
      String? receivedDragMarkerId;
      LatLng? receivedDragPosition;
      String? receivedDragStartMarkerId;
      LatLng? receivedDragStartPosition;
      String? receivedDragEndMarkerId;
      LatLng? receivedDragEndPosition;

      const String testMarkerId = 'dragMarker';
      const LatLng testStartPosition = LatLng(
        latitude: 37.4220,
        longitude: -122.0841,
      );
      const LatLng testDragPosition = LatLng(
        latitude: 37.4225,
        longitude: -122.0845,
      );
      const LatLng testEndPosition = LatLng(
        latitude: 37.4230,
        longitude: -122.0850,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onMarkerDragStart: (String markerId, LatLng position) {
              receivedDragStartMarkerId = markerId;
              receivedDragStartPosition = position;
            },
            onMarkerDrag: (String markerId, LatLng position) {
              receivedDragMarkerId = markerId;
              receivedDragPosition = position;
            },
            onMarkerDragEnd: (String markerId, LatLng position) {
              receivedDragEndMarkerId = markerId;
              receivedDragEndPosition = position;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Test dragStart event
      testMapViewApi.testEventApi.onMarkerDragEvent(
        testViewId,
        testMarkerId,
        MarkerDragEventTypeDto.dragStart,
        LatLngDto(
          latitude: testStartPosition.latitude,
          longitude: testStartPosition.longitude,
        ),
      );

      await tester.pump();

      expect(receivedDragStartMarkerId, testMarkerId);
      expect(receivedDragStartPosition, isNotNull);
      expect(receivedDragStartPosition!.latitude, testStartPosition.latitude);
      expect(receivedDragStartPosition!.longitude, testStartPosition.longitude);

      // Test drag event
      testMapViewApi.testEventApi.onMarkerDragEvent(
        testViewId,
        testMarkerId,
        MarkerDragEventTypeDto.drag,
        LatLngDto(
          latitude: testDragPosition.latitude,
          longitude: testDragPosition.longitude,
        ),
      );

      await tester.pump();

      expect(receivedDragMarkerId, testMarkerId);
      expect(receivedDragPosition, isNotNull);
      expect(receivedDragPosition!.latitude, testDragPosition.latitude);
      expect(receivedDragPosition!.longitude, testDragPosition.longitude);

      // Test dragEnd event
      testMapViewApi.testEventApi.onMarkerDragEvent(
        testViewId,
        testMarkerId,
        MarkerDragEventTypeDto.dragEnd,
        LatLngDto(
          latitude: testEndPosition.latitude,
          longitude: testEndPosition.longitude,
        ),
      );

      await tester.pump();

      expect(receivedDragEndMarkerId, testMarkerId);
      expect(receivedDragEndPosition, isNotNull);
      expect(receivedDragEndPosition!.latitude, testEndPosition.latitude);
      expect(receivedDragEndPosition!.longitude, testEndPosition.longitude);
    });

    testWidgets('onPolygonClicked callback receives event', (
      WidgetTester tester,
    ) async {
      String? receivedPolygonId;
      const String testPolygonId = 'polygon123';

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onPolygonClicked: (String polygonId) {
              receivedPolygonId = polygonId;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onPolygonClicked(testViewId, testPolygonId);

      await tester.pump();

      expect(receivedPolygonId, testPolygonId);
    });

    testWidgets('onPolylineClicked callback receives event', (
      WidgetTester tester,
    ) async {
      String? receivedPolylineId;
      const String testPolylineId = 'polyline456';

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onPolylineClicked: (String polylineId) {
              receivedPolylineId = polylineId;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onPolylineClicked(testViewId, testPolylineId);

      await tester.pump();

      expect(receivedPolylineId, testPolylineId);
    });

    testWidgets('onCircleClicked callback receives event', (
      WidgetTester tester,
    ) async {
      String? receivedCircleId;
      const String testCircleId = 'circle789';

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onCircleClicked: (String circleId) {
              receivedCircleId = circleId;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onCircleClicked(testViewId, testCircleId);

      await tester.pump();

      expect(receivedCircleId, testCircleId);
    });

    testWidgets('onPoiClicked callback receives event', (
      WidgetTester tester,
    ) async {
      PointOfInterest? receivedPoi;
      const PointOfInterest testPoi = PointOfInterest(
        placeID: 'place1',
        name: 'Test Place',
        latLng: LatLng(latitude: 37.4220936, longitude: -122.083922),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onPoiClicked: (PointOfInterest poi) {
              receivedPoi = poi;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onPoiClick(
        testViewId,
        PointOfInterestDto(
          placeID: testPoi.placeID,
          name: testPoi.name,
          latLng: LatLngDto(
            latitude: testPoi.latLng.latitude,
            longitude: testPoi.latLng.longitude,
          ),
        ),
      );

      await tester.pump();

      expect(receivedPoi, isNotNull);
      expect(receivedPoi!.placeID, testPoi.placeID);
      expect(receivedPoi!.name, testPoi.name);
      expect(receivedPoi!.latLng.latitude, testPoi.latLng.latitude);
      expect(receivedPoi!.latLng.longitude, testPoi.latLng.longitude);
    });

    testWidgets('onCameraMove callback receives event', (
      WidgetTester tester,
    ) async {
      CameraPosition? receivedPosition;
      const CameraPosition testPosition = CameraPosition(
        bearing: 90.0,
        target: LatLng(latitude: 37.4220, longitude: -122.0841),
        tilt: 45.0,
        zoom: 15.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onCameraMove: (CameraPosition position) {
              receivedPosition = position;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      testMapViewApi.testEventApi.onCameraChanged(
        testViewId,
        CameraEventTypeDto.onCameraMove,
        CameraPositionDto(
          bearing: testPosition.bearing,
          target: LatLngDto(
            latitude: testPosition.target.latitude,
            longitude: testPosition.target.longitude,
          ),
          tilt: testPosition.tilt,
          zoom: testPosition.zoom,
        ),
      );

      await tester.pump();

      expect(receivedPosition, isNotNull);
      expect(receivedPosition!.bearing, testPosition.bearing);
      expect(receivedPosition!.target.latitude, testPosition.target.latitude);
      expect(receivedPosition!.tilt, testPosition.tilt);
      expect(receivedPosition!.zoom, testPosition.zoom);
    });

    testWidgets('multiple event callbacks work simultaneously', (
      WidgetTester tester,
    ) async {
      LatLng? receivedMapClick;
      String? receivedMarkerId;
      String? receivedPolygonId;

      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            onMapClicked: (LatLng latLng) {
              receivedMapClick = latLng;
            },
            onMarkerClicked: (String markerId) {
              receivedMarkerId = markerId;
            },
            onPolygonClicked: (String polygonId) {
              receivedPolygonId = polygonId;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Fire multiple different events
      testMapViewApi.testEventApi.onMapClickEvent(
        testViewId,
        LatLngDto(latitude: 1.0, longitude: 2.0),
      );
      testMapViewApi.testEventApi.onMarkerEvent(
        testViewId,
        'marker1',
        MarkerEventTypeDto.clicked,
      );
      testMapViewApi.testEventApi.onPolygonClicked(testViewId, 'polygon1');

      await tester.pump();

      // Verify all callbacks were called
      expect(receivedMapClick, isNotNull);
      expect(receivedMarkerId, 'marker1');
      expect(receivedPolygonId, 'polygon1');
    });

    testWidgets('callbacks not registered do not cause errors', (
      WidgetTester tester,
    ) async {
      // Create view without any callbacks
      await tester.pumpWidget(
        MaterialApp(
          home: GoogleMapsMapView(
            onViewCreated: (_) {},
            // No event callbacks registered
          ),
        ),
      );

      await tester.pumpAndSettle();

      final int testViewId = getViewId();

      // Fire events - should not throw errors
      expect(() {
        testMapViewApi.testEventApi.onMapClickEvent(
          testViewId,
          LatLngDto(latitude: 1.0, longitude: 2.0),
        );
        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker1',
          MarkerEventTypeDto.clicked,
        );
      }, returnsNormally);

      await tester.pump();
    });
  });
}
