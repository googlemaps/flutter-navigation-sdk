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
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

import '../helpers/mock_map_view_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestMapViewAPIImpl testMapViewApi;

  setUp(() {
    // Create test map view API that allows direct DTO injection
    testMapViewApi = TestMapViewAPIImpl();
    testMapViewApi.ensureViewAPISetUp();
  });

  group('Event Listener Tests', () {
    const int testViewId = 1;

    group('Map Click Events', () {
      test('onMapClickEvent fires and delivers correct data', () async {
        final List<MapClickEvent> receivedEvents = <MapClickEvent>[];

        // Listen to map click event stream
        final StreamSubscription<MapClickEvent> subscription = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        // Simulate platform event by adding to the stream
        final LatLngDto testLatLng = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);

        // Wait for event to propagate
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].target.latitude, testLatLng.latitude);
        expect(receivedEvents[0].target.longitude, testLatLng.longitude);

        await subscription.cancel();
      });

      test('onMapLongClickEvent fires and delivers correct data', () async {
        final List<MapLongClickEvent> receivedEvents = <MapLongClickEvent>[];

        final StreamSubscription<MapLongClickEvent> subscription =
            testMapViewApi
                .getMapLongClickEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final LatLngDto testLatLng = LatLngDto(
          latitude: 40.7128,
          longitude: -74.0060,
        );
        testMapViewApi.testEventApi.onMapLongClickEvent(testViewId, testLatLng);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].target.latitude, testLatLng.latitude);
        expect(receivedEvents[0].target.longitude, testLatLng.longitude);

        await subscription.cancel();
      });

      test('map click events do not fire after listener removal', () async {
        final List<MapClickEvent> receivedEvents = <MapClickEvent>[];

        final StreamSubscription<MapClickEvent> subscription = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        // Fire event while listener is active
        final LatLngDto testLatLng = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        // Cancel subscription
        await subscription.cancel();

        // Fire event after listener removal
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Should still be 1 (no new event received)
        expect(receivedEvents.length, 1);
      });
    });

    group('Marker Events', () {
      test('onMarkerEvent fires with clicked event', () async {
        final List<MarkerEvent> receivedEvents = <MarkerEvent>[];
        final StreamSubscription<MarkerEvent> subscription = testMapViewApi
            .getMarkerEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker123',
          MarkerEventTypeDto.clicked,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].markerId, 'marker123');
        expect(receivedEvents[0].eventType, MarkerEventType.clicked);

        await subscription.cancel();
      });

      test('onMarkerEvent fires with info window events', () async {
        final List<MarkerEvent> receivedEvents = <MarkerEvent>[];
        final StreamSubscription<MarkerEvent> subscription = testMapViewApi
            .getMarkerEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        // Test info window clicked
        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker456',
          MarkerEventTypeDto.infoWindowClicked,
        );

        // Test info window closed
        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker789',
          MarkerEventTypeDto.infoWindowClosed,
        );

        // Test info window long clicked
        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker101',
          MarkerEventTypeDto.infoWindowLongClicked,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 3);
        expect(receivedEvents[0].eventType, MarkerEventType.infoWindowClicked);
        expect(receivedEvents[1].eventType, MarkerEventType.infoWindowClosed);
        expect(
          receivedEvents[2].eventType,
          MarkerEventType.infoWindowLongClicked,
        );

        await subscription.cancel();
      });

      test('marker events do not fire after listener removal', () async {
        final List<MarkerEvent> receivedEvents = <MarkerEvent>[];
        final StreamSubscription<MarkerEvent> subscription = testMapViewApi
            .getMarkerEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker1',
          MarkerEventTypeDto.clicked,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onMarkerEvent(
          testViewId,
          'marker2',
          MarkerEventTypeDto.clicked,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Marker Drag Events', () {
      test('onMarkerDragEvent fires with drag start', () async {
        final List<MarkerDragEvent> receivedEvents = <MarkerDragEvent>[];
        final StreamSubscription<MarkerDragEvent> subscription = testMapViewApi
            .getMarkerDragEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final LatLngDto position = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMarkerDragEvent(
          testViewId,
          'dragMarker1',
          MarkerDragEventTypeDto.dragStart,
          position,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].markerId, 'dragMarker1');
        expect(receivedEvents[0].eventType, MarkerDragEventType.dragStart);
        expect(receivedEvents[0].position.latitude, position.latitude);
        expect(receivedEvents[0].position.longitude, position.longitude);

        await subscription.cancel();
      });

      test('onMarkerDragEvent fires with drag', () async {
        final List<MarkerDragEvent> receivedEvents = <MarkerDragEvent>[];
        final StreamSubscription<MarkerDragEvent> subscription = testMapViewApi
            .getMarkerDragEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final LatLngDto position = LatLngDto(
          latitude: 37.4225,
          longitude: -122.0845,
        );
        testMapViewApi.testEventApi.onMarkerDragEvent(
          testViewId,
          'dragMarker2',
          MarkerDragEventTypeDto.drag,
          position,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].eventType, MarkerDragEventType.drag);
        expect(receivedEvents[0].position.latitude, position.latitude);

        await subscription.cancel();
      });

      test('onMarkerDragEvent fires with drag end', () async {
        final List<MarkerDragEvent> receivedEvents = <MarkerDragEvent>[];
        final StreamSubscription<MarkerDragEvent> subscription = testMapViewApi
            .getMarkerDragEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final LatLngDto position = LatLngDto(
          latitude: 37.4230,
          longitude: -122.0850,
        );
        testMapViewApi.testEventApi.onMarkerDragEvent(
          testViewId,
          'dragMarker3',
          MarkerDragEventTypeDto.dragEnd,
          position,
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].eventType, MarkerDragEventType.dragEnd);
        expect(receivedEvents[0].position.latitude, position.latitude);

        await subscription.cancel();
      });

      test('marker drag events do not fire after listener removal', () async {
        final List<MarkerDragEvent> receivedEvents = <MarkerDragEvent>[];
        final StreamSubscription<MarkerDragEvent> subscription = testMapViewApi
            .getMarkerDragEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final LatLngDto position = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMarkerDragEvent(
          testViewId,
          'marker1',
          MarkerDragEventTypeDto.drag,
          position,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onMarkerDragEvent(
          testViewId,
          'marker2',
          MarkerDragEventTypeDto.drag,
          position,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Polygon Events', () {
      test('onPolygonClicked fires and delivers correct data', () async {
        final List<PolygonClickedEvent> receivedEvents =
            <PolygonClickedEvent>[];
        final StreamSubscription<PolygonClickedEvent> subscription =
            testMapViewApi
                .getPolygonClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onPolygonClicked(testViewId, 'polygon123');

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].polygonId, 'polygon123');

        await subscription.cancel();
      });

      test('polygon events do not fire after listener removal', () async {
        final List<PolygonClickedEvent> receivedEvents =
            <PolygonClickedEvent>[];
        final StreamSubscription<PolygonClickedEvent> subscription =
            testMapViewApi
                .getPolygonClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onPolygonClicked(testViewId, 'polygon1');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onPolygonClicked(testViewId, 'polygon2');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Polyline Events', () {
      test('onPolylineClicked fires and delivers correct data', () async {
        final List<PolylineClickedEvent> receivedEvents =
            <PolylineClickedEvent>[];
        final StreamSubscription<PolylineClickedEvent> subscription =
            testMapViewApi
                .getPolylineClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onPolylineClicked(
          testViewId,
          'polyline456',
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].polylineId, 'polyline456');

        await subscription.cancel();
      });

      test('polyline events do not fire after listener removal', () async {
        final List<PolylineClickedEvent> receivedEvents =
            <PolylineClickedEvent>[];
        final StreamSubscription<PolylineClickedEvent> subscription =
            testMapViewApi
                .getPolylineClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onPolylineClicked(testViewId, 'polyline1');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onPolylineClicked(testViewId, 'polyline2');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Circle Events', () {
      test('onCircleClicked fires and delivers correct data', () async {
        final List<CircleClickedEvent> receivedEvents = <CircleClickedEvent>[];
        final StreamSubscription<CircleClickedEvent> subscription =
            testMapViewApi
                .getCircleClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onCircleClicked(testViewId, 'circle789');

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].circleId, 'circle789');

        await subscription.cancel();
      });

      test('circle events do not fire after listener removal', () async {
        final List<CircleClickedEvent> receivedEvents = <CircleClickedEvent>[];
        final StreamSubscription<CircleClickedEvent> subscription =
            testMapViewApi
                .getCircleClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onCircleClicked(testViewId, 'circle1');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onCircleClicked(testViewId, 'circle2');
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('POI Click Events', () {
      test('onPoiClick fires and delivers correct data', () async {
        final List<PoiClickedEvent> receivedEvents = <PoiClickedEvent>[];
        final StreamSubscription<PoiClickedEvent> subscription = testMapViewApi
            .getPoiClickedEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final PointOfInterest poi = PointOfInterest(
          placeID: 'place1',
          name: 'Test Place',
          latLng: const LatLng(latitude: 37.4220936, longitude: -122.083922),
        );
        testMapViewApi.testEventApi.onPoiClick(
          testViewId,
          PointOfInterestDto(
            placeID: poi.placeID,
            name: poi.name,
            latLng: LatLngDto(
              latitude: poi.latLng.latitude,
              longitude: poi.latLng.longitude,
            ),
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].pointOfInterest.placeID, poi.placeID);
        expect(receivedEvents[0].pointOfInterest.name, poi.name);
        expect(
          receivedEvents[0].pointOfInterest.latLng.latitude,
          poi.latLng.latitude,
        );
        expect(
          receivedEvents[0].pointOfInterest.latLng.longitude,
          poi.latLng.longitude,
        );

        await subscription.cancel();
      });

      test('POI events do not fire after listener removal', () async {
        final List<PoiClickedEvent> receivedEvents = <PoiClickedEvent>[];
        final StreamSubscription<PoiClickedEvent> subscription = testMapViewApi
            .getPoiClickedEventStream(viewId: testViewId)
            .listen(receivedEvents.add);

        final PointOfInterest poi = PointOfInterest(
          placeID: 'place1',
          name: 'Place 1',
          latLng: const LatLng(latitude: 37.4220, longitude: -122.0841),
        );
        testMapViewApi.testEventApi.onPoiClick(
          testViewId,
          PointOfInterestDto(
            placeID: poi.placeID,
            name: poi.name,
            latLng: LatLngDto(
              latitude: poi.latLng.latitude,
              longitude: poi.latLng.longitude,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onPoiClick(
          testViewId,
          PointOfInterestDto(
            placeID: poi.placeID,
            name: poi.name,
            latLng: LatLngDto(
              latitude: poi.latLng.latitude,
              longitude: poi.latLng.longitude,
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('My Location Events', () {
      test('onMyLocationClicked fires', () async {
        final List<MyLocationClickedEvent> receivedEvents =
            <MyLocationClickedEvent>[];
        final StreamSubscription<MyLocationClickedEvent> subscription =
            testMapViewApi
                .getMyLocationClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onMyLocationClicked(testViewId);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);

        await subscription.cancel();
      });

      test('onMyLocationButtonClicked fires', () async {
        final List<MyLocationButtonClickedEvent> receivedEvents =
            <MyLocationButtonClickedEvent>[];
        final StreamSubscription<MyLocationButtonClickedEvent> subscription =
            testMapViewApi
                .getMyLocationButtonClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onMyLocationButtonClicked(testViewId);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);

        await subscription.cancel();
      });

      test('my location events do not fire after listener removal', () async {
        final List<MyLocationClickedEvent> receivedEvents =
            <MyLocationClickedEvent>[];
        final StreamSubscription<MyLocationClickedEvent> subscription =
            testMapViewApi
                .getMyLocationClickedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        testMapViewApi.testEventApi.onMyLocationClicked(testViewId);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onMyLocationClicked(testViewId);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Camera Changed Events', () {
      test('onCameraChanged fires with move started', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 90.0,
          target: const LatLng(latitude: 37.4220, longitude: -122.0841),
          tilt: 45.0,
          zoom: 15.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.moveStartedByApi,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].eventType, CameraEventType.moveStartedByApi);
        expect(receivedEvents[0].position.bearing, cameraPosition.bearing);
        expect(
          receivedEvents[0].position.target.latitude,
          cameraPosition.target.latitude,
        );

        await subscription.cancel();
      });

      test('onCameraChanged fires with on move', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 0.0,
          target: const LatLng(latitude: 40.7128, longitude: -74.0060),
          tilt: 0.0,
          zoom: 12.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraMove,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].eventType, CameraEventType.onCameraMove);
        expect(receivedEvents[0].position.zoom, cameraPosition.zoom);

        await subscription.cancel();
      });

      test('onCameraChanged fires with on camera idle', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 180.0,
          target: const LatLng(latitude: 51.5074, longitude: -0.1278),
          tilt: 30.0,
          zoom: 10.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraIdle,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(receivedEvents[0].eventType, CameraEventType.onCameraIdle);
        expect(receivedEvents[0].position.tilt, cameraPosition.tilt);

        await subscription.cancel();
      });

      test('onCameraChanged fires with started following location', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 0.0,
          target: const LatLng(latitude: 37.7749, longitude: -122.4194),
          tilt: 0.0,
          zoom: 14.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraStartedFollowingLocation,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(
          receivedEvents[0].eventType,
          CameraEventType.onCameraStartedFollowingLocation,
        );
        expect(
          receivedEvents[0].position.target.latitude,
          cameraPosition.target.latitude,
        );

        await subscription.cancel();
      });

      test('onCameraChanged fires with stopped following location', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 0.0,
          target: const LatLng(latitude: 34.0522, longitude: -118.2437),
          tilt: 0.0,
          zoom: 13.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraStoppedFollowingLocation,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 1);
        expect(
          receivedEvents[0].eventType,
          CameraEventType.onCameraStoppedFollowingLocation,
        );
        expect(
          receivedEvents[0].position.target.longitude,
          cameraPosition.target.longitude,
        );

        await subscription.cancel();
      });

      test('onCameraChanged fires with all event types', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 0.0,
          target: const LatLng(latitude: 37.4220, longitude: -122.0841),
          tilt: 0.0,
          zoom: 15.0,
        );

        // Test all camera event types
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.moveStartedByApi,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.moveStartedByGesture,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraMove,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraIdle,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraStartedFollowingLocation,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraStoppedFollowingLocation,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents.length, 6);
        expect(receivedEvents[0].eventType, CameraEventType.moveStartedByApi);
        expect(
          receivedEvents[1].eventType,
          CameraEventType.moveStartedByGesture,
        );
        expect(receivedEvents[2].eventType, CameraEventType.onCameraMove);
        expect(receivedEvents[3].eventType, CameraEventType.onCameraIdle);
        expect(
          receivedEvents[4].eventType,
          CameraEventType.onCameraStartedFollowingLocation,
        );
        expect(
          receivedEvents[5].eventType,
          CameraEventType.onCameraStoppedFollowingLocation,
        );

        await subscription.cancel();
      });

      test('camera events do not fire after listener removal', () async {
        final List<CameraChangedEvent> receivedEvents = <CameraChangedEvent>[];
        final StreamSubscription<CameraChangedEvent> subscription =
            testMapViewApi
                .getCameraChangedEventStream(viewId: testViewId)
                .listen(receivedEvents.add);

        final CameraPosition cameraPosition = CameraPosition(
          bearing: 0.0,
          target: const LatLng(latitude: 37.4220, longitude: -122.0841),
          tilt: 0.0,
          zoom: 15.0,
        );
        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraMove,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);

        await subscription.cancel();

        testMapViewApi.testEventApi.onCameraChanged(
          testViewId,
          CameraEventTypeDto.onCameraMove,
          CameraPositionDto(
            bearing: cameraPosition.bearing,
            target: LatLngDto(
              latitude: cameraPosition.target.latitude,
              longitude: cameraPosition.target.longitude,
            ),
            tilt: cameraPosition.tilt,
            zoom: cameraPosition.zoom,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(receivedEvents.length, 1);
      });
    });

    group('Multiple Listeners', () {
      test('multiple listeners can receive the same event', () async {
        final List<MapClickEvent> receivedEvents1 = <MapClickEvent>[];
        final List<MapClickEvent> receivedEvents2 = <MapClickEvent>[];
        final StreamSubscription<MapClickEvent> subscription1 = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents1.add);

        final StreamSubscription<MapClickEvent> subscription2 = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents2.add);

        final LatLngDto testLatLng = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents1.length, 1);
        expect(receivedEvents2.length, 1);
        expect(
          receivedEvents1[0].target.latitude,
          receivedEvents2[0].target.latitude,
        );

        await subscription1.cancel();
        await subscription2.cancel();
      });

      test('removing one listener does not affect other listeners', () async {
        final List<MapClickEvent> receivedEvents1 = <MapClickEvent>[];
        final List<MapClickEvent> receivedEvents2 = <MapClickEvent>[];
        final StreamSubscription<MapClickEvent> subscription1 = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents1.add);

        final StreamSubscription<MapClickEvent> subscription2 = testMapViewApi
            .getMapClickEventStream(viewId: testViewId)
            .listen(receivedEvents2.add);

        final LatLngDto testLatLng = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEvents1.length, 1);
        expect(receivedEvents2.length, 1);

        // Cancel first listener
        await subscription1.cancel();

        // Fire another event
        testMapViewApi.testEventApi.onMapClickEvent(testViewId, testLatLng);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // First listener should not receive new event
        expect(receivedEvents1.length, 1);
        // Second listener should receive new event
        expect(receivedEvents2.length, 2);

        await subscription2.cancel();
      });
    });

    group('View ID Filtering', () {
      test('events are filtered by view ID', () async {
        final List<MapClickEvent> receivedEventsView1 = <MapClickEvent>[];
        final List<MapClickEvent> receivedEventsView2 = <MapClickEvent>[];
        const int viewId1 = 1;
        const int viewId2 = 2;

        final StreamSubscription<MapClickEvent> subscription1 = testMapViewApi
            .getMapClickEventStream(viewId: viewId1)
            .listen(receivedEventsView1.add);

        final StreamSubscription<MapClickEvent> subscription2 = testMapViewApi
            .getMapClickEventStream(viewId: viewId2)
            .listen(receivedEventsView2.add);

        final LatLngDto testLatLng1 = LatLngDto(
          latitude: 37.4220,
          longitude: -122.0841,
        );
        final LatLngDto testLatLng2 = LatLngDto(
          latitude: 40.7128,
          longitude: -74.0060,
        );

        // Fire event for view 1
        testMapViewApi.testEventApi.onMapClickEvent(viewId1, testLatLng1);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEventsView1.length, 1);
        expect(receivedEventsView2.length, 0);

        // Fire event for view 2
        testMapViewApi.testEventApi.onMapClickEvent(viewId2, testLatLng2);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(receivedEventsView1.length, 1);
        expect(receivedEventsView2.length, 1);

        expect(receivedEventsView1[0].target.latitude, testLatLng1.latitude);
        expect(receivedEventsView2[0].target.latitude, testLatLng2.latitude);

        await subscription1.cancel();
        await subscription2.cancel();
      });
    });
  });
}
