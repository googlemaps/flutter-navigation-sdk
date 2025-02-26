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
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'google_navigation_flutter_test.mocks.dart';
import 'messages_test.g.dart';

@GenerateMocks(
    <Type>[TestNavigationSessionApi, TestMapViewApi, TestImageRegistryApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  void onNavigationViewCreated(GoogleNavigationViewController controller) {}
  void onMapViewCreated(GoogleMapViewController controller) {}

  late MockTestNavigationSessionApi sessionMockApi;
  late MockTestMapViewApi viewMockApi;
  late MockTestImageRegistryApi imageRegistryMockApi;

  final List<GoogleMapsNavigationPlatform> platforms =
      <GoogleMapsNavigationPlatform>[
    GoogleMapsNavigationAndroid(
      AndroidNavigationSessionAPIImpl(),
      MapViewAPIImpl(),
      AutoMapViewAPIImpl(),
      ImageRegistryAPIImpl(),
    ),
    GoogleMapsNavigationIOS(
      NavigationSessionAPIImpl(),
      MapViewAPIImpl(),
      AutoMapViewAPIImpl(),
      ImageRegistryAPIImpl(),
    ),
  ];

  setUp(() {
    sessionMockApi = MockTestNavigationSessionApi();
    viewMockApi = MockTestMapViewApi();
    imageRegistryMockApi = MockTestImageRegistryApi();
    TestNavigationSessionApi.setup(sessionMockApi);
    TestMapViewApi.setup(viewMockApi);
    TestImageRegistryApi.setup(imageRegistryMockApi);
  });

  void verifyEnabled(VerificationResult result, bool enabled) {
    final bool enabledOut = result.captured[1] as bool;
    expect(enabledOut, enabled);
  }

  for (final GoogleMapsNavigationPlatform platform in platforms) {
    group(platform.runtimeType, () {
      setUp(() {
        GoogleMapsNavigationPlatform.instance = platform;
      });

      testWidgets('renders Google Maps Navigation View',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GoogleMapsNavigationView(
              onViewCreated: onNavigationViewCreated,
            ),
          ),
        );
        expect(find.byType(GoogleMapsNavigationView), findsOneWidget);
      });

      testWidgets('renders Google Maps View', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GoogleMapsMapView(
              onViewCreated: onMapViewCreated,
            ),
          ),
        );
        expect(find.byType(GoogleMapsMapView), findsOneWidget);
      });

      group('Navigation view API', () {
        test('Await map ready api call', () async {
          // Mock api response
          when(viewMockApi.awaitMapReady(any))
              .thenAnswer((Invocation _) async => ());

          // Await map ready
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .awaitMapReady(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.awaitMapReady(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify message
          expect(viewId, 0);
        });

        testWidgets('Test camera position and modes',
            (WidgetTester tester) async {
          const int viewIdIn = 1;
          final GoogleNavigationViewController controller =
              GoogleNavigationViewController(viewIdIn);

          final LatLngDto targetIn = LatLngDto(latitude: 5.0, longitude: 6.0);
          final CameraPositionDto positionIn = CameraPositionDto(
              bearing: 20, target: targetIn, tilt: 30, zoom: 2.0);
          when(viewMockApi.getCameraPosition(any)).thenReturn(positionIn);

          // Get camera position

          final CameraPosition positionOut =
              await controller.getCameraPosition();
          final VerificationResult result =
              verify(viewMockApi.getCameraPosition(captureAny));
          final int viewIdOut = result.captured[0] as int;

          expect(viewIdOut, viewIdIn);
          expect(positionIn.bearing, positionOut.bearing);
          expect(positionIn.target.latitude, positionOut.target.latitude);
          expect(positionIn.target.longitude, positionOut.target.longitude);
          expect(positionIn.tilt, positionOut.tilt);
          expect(positionIn.zoom, positionOut.zoom);

          // Follow my position without zoom level

          CameraPerspective perspectiveIn = CameraPerspective.topDownHeadingUp;
          await controller.followMyLocation(perspectiveIn);
          VerificationResult perspectiveResult = verify(
              viewMockApi.followMyLocation(captureAny, captureAny, captureAny));
          CameraPerspectiveDto perspective =
              perspectiveResult.captured[1] as CameraPerspectiveDto;
          double? zoomLevelOut = perspectiveResult.captured[2] as double?;
          expect(perspectiveIn.toDto(), perspective);
          expect(zoomLevelOut, null);

          // Follow my position with zoom level

          perspectiveIn = CameraPerspective.topDownHeadingUp;
          const double zoomLevelIn = 5.0;
          await controller.followMyLocation(perspectiveIn,
              zoomLevel: zoomLevelIn);
          perspectiveResult = verify(
              viewMockApi.followMyLocation(captureAny, captureAny, captureAny));
          perspective = perspectiveResult.captured[1] as CameraPerspectiveDto;
          zoomLevelOut = perspectiveResult.captured[2] as double?;
          expect(perspectiveIn.toDto(), perspective);
          expect(zoomLevelOut, 5.0);
        });

        testWidgets('Test camera animations', (WidgetTester tester) async {
          const int viewId = 1;
          final GoogleNavigationViewController controller =
              GoogleNavigationViewController(viewId);

          final LatLngDto targetIn = LatLngDto(latitude: 5.0, longitude: 6.0);
          final CameraPositionDto positionIn = CameraPositionDto(
              bearing: 20, target: targetIn, tilt: 30, zoom: 2.0);
          when(viewMockApi.getCameraPosition(any)).thenReturn(positionIn);

          // Animate camera to camera position

          const LatLng latLngIn = LatLng(latitude: 5.0, longitude: 6.0);
          const int durationMsec = 600;
          const Duration duration = Duration(milliseconds: durationMsec);

          when(viewMockApi.animateCameraToCameraPosition(any, any, any))
              .thenAnswer((Invocation _) async => true);

          const CameraPosition positionIn2 =
              CameraPosition(bearing: 20, target: latLngIn, tilt: 30);
          await controller.animateCamera(
              CameraUpdate.newCameraPosition(positionIn2),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          VerificationResult result = verify(
              viewMockApi.animateCameraToCameraPosition(
                  captureAny, captureAny, captureAny));
          final CameraPositionDto positionOut2 =
              result.captured[1] as CameraPositionDto;

          expect(viewId, result.captured[0] as int);
          expect(positionIn2.bearing, positionOut2.bearing);
          expect(positionIn2.target.latitude, positionOut2.target.latitude);
          expect(positionIn2.target.longitude, positionOut2.target.longitude);
          expect(positionIn2.tilt, positionOut2.tilt);
          expect(positionIn2.zoom, positionOut2.zoom);
          expect(durationMsec, result.captured[2] as int);

          // Animate camera to co-ordinates

          when(viewMockApi.animateCameraToLatLng(any, any, any))
              .thenAnswer((Invocation _) async => true);

          await controller.animateCamera(CameraUpdate.newLatLng(latLngIn),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraToLatLng(
              captureAny, captureAny, captureAny));
          final LatLngDto latLngOut = result.captured[1] as LatLngDto;

          expect(viewId, result.captured[0] as int);
          expect(latLngIn.latitude, latLngOut.latitude);
          expect(latLngIn.longitude, latLngOut.longitude);
          expect(durationMsec, result.captured[2] as int);

          // Animate camera to co-ordinate bounds

          when(viewMockApi.animateCameraToLatLngBounds(any, any, any, any))
              .thenAnswer((Invocation _) async => true);

          const LatLng latLngIn2 = LatLng(latitude: 7.0, longitude: 9.0);
          final LatLngBounds boundsIn =
              LatLngBounds(southwest: latLngIn, northeast: latLngIn2);
          const double paddingIn = 2.0;
          await controller.animateCamera(
              CameraUpdate.newLatLngBounds(boundsIn, padding: paddingIn),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraToLatLngBounds(
              captureAny, captureAny, captureAny, captureAny));
          final LatLngBoundsDto boundsOut =
              result.captured[1] as LatLngBoundsDto;

          expect(viewId, result.captured[0] as int);
          expect(boundsIn.southwest.latitude, boundsOut.southwest.latitude);
          expect(boundsIn.southwest.longitude, boundsOut.southwest.longitude);
          expect(boundsIn.northeast.latitude, boundsOut.northeast.latitude);
          expect(boundsIn.northeast.longitude, boundsOut.northeast.longitude);
          expect(paddingIn, result.captured[2] as double);
          expect(durationMsec, result.captured[3] as int);

          // Animate camera to co-ordinates and zoom

          when(viewMockApi.animateCameraToLatLngZoom(any, any, any, any))
              .thenAnswer((Invocation _) async => true);

          const double zoomIn = 4.0;
          await controller.animateCamera(
              CameraUpdate.newLatLngZoom(latLngIn, zoomIn),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraToLatLngZoom(
              captureAny, captureAny, captureAny, captureAny));
          final LatLngDto latLngOut2 = result.captured[1] as LatLngDto;

          expect(viewId, result.captured[0] as int);
          expect(latLngIn.latitude, latLngOut2.latitude);
          expect(latLngIn.longitude, latLngOut2.longitude);
          expect(zoomIn, result.captured[2] as double);
          expect(durationMsec, result.captured[3] as int);

          // Animate camera by scrolling

          when(viewMockApi.animateCameraByScroll(any, any, any, any))
              .thenAnswer((Invocation _) async => true);

          const double scrollByDx = 4.0;
          const double scrollByDy = 5.0;
          await controller.animateCamera(
              CameraUpdate.scrollBy(scrollByDx, scrollByDy),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraByScroll(
              captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(scrollByDx, result.captured[1] as double);
          expect(scrollByDy, result.captured[2] as double);
          expect(durationMsec, result.captured[3] as int);

          // Animate camera by zoom

          when(viewMockApi.animateCameraByZoom(any, any, any, any, any))
              .thenAnswer((Invocation _) async => true);

          const double zoomBy = 2.0;
          const Offset focusIn = Offset(3.0, 4.0);
          await controller.animateCamera(
              CameraUpdate.zoomBy(zoomBy, focus: focusIn),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraByZoom(
              captureAny, captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(zoomBy, result.captured[1] as double);
          expect(focusIn.dx, result.captured[2] as double);
          expect(focusIn.dy, result.captured[3] as double);
          expect(durationMsec, result.captured[4] as int);

          // Animate camera by zooming in

          // Calls the same viewMockApi.animateCameraByZoom() that has already been mocked
          await controller.animateCamera(CameraUpdate.zoomIn(),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraByZoom(
              captureAny, captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(1.0 /* zoom by 1.0 */, result.captured[1] as double);
          expect(null /* focus dx not used */, result.captured[2] as double?);
          expect(null /* focus xy not used */, result.captured[3] as double?);
          expect(durationMsec, result.captured[4] as int);

          // Animate camera by zooming out

          await controller.animateCamera(CameraUpdate.zoomOut(),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraByZoom(
              captureAny, captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(-1.0, result.captured[1] as double);
          expect(null /* focus dx not used */, result.captured[2] as double?);
          expect(null /* focus xy not used */, result.captured[3] as double?);
          expect(durationMsec, result.captured[4] as int);

          // Animate camera by a fixed zoom value

          when(viewMockApi.animateCameraToZoom(any, any, any))
              .thenAnswer((Invocation _) async => true);

          await controller.animateCamera(CameraUpdate.zoomTo(zoomIn),
              duration: duration, onFinished: (bool success) {
            expect(success, true);
          });

          result = verify(viewMockApi.animateCameraToZoom(
              captureAny, captureAny, captureAny));
          expect(viewId, result.captured[0] as int);
          expect(zoomIn, result.captured[1] as double);
          expect(durationMsec, result.captured[2] as int);
        });

        testWidgets('Test camera movement', (WidgetTester tester) async {
          const int viewId = 1;
          final GoogleNavigationViewController controller =
              GoogleNavigationViewController(viewId);

          final LatLngDto targetIn = LatLngDto(latitude: 5.0, longitude: 6.0);
          final CameraPositionDto positionIn = CameraPositionDto(
              bearing: 20, target: targetIn, tilt: 30, zoom: 2.0);
          when(viewMockApi.getCameraPosition(any)).thenReturn(positionIn);

          // Move camera to camera position

          const LatLng latLngIn = LatLng(latitude: 5.0, longitude: 6.0);

          const CameraPosition positionIn2 =
              CameraPosition(bearing: 20, target: latLngIn, tilt: 30);
          await controller
              .moveCamera(CameraUpdate.newCameraPosition(positionIn2));

          VerificationResult result = verify(
              viewMockApi.moveCameraToCameraPosition(captureAny, captureAny));
          final CameraPositionDto positionOut2 =
              result.captured[1] as CameraPositionDto;

          expect(viewId, result.captured[0] as int);
          expect(positionIn2.bearing, positionOut2.bearing);
          expect(positionIn2.target.latitude, positionOut2.target.latitude);
          expect(positionIn2.target.longitude, positionOut2.target.longitude);
          expect(positionIn2.tilt, positionOut2.tilt);
          expect(positionIn2.zoom, positionOut2.zoom);

          // Move camera to co-ordinates

          await controller.moveCamera(CameraUpdate.newLatLng(latLngIn));

          result =
              verify(viewMockApi.moveCameraToLatLng(captureAny, captureAny));
          final LatLngDto latLngOut = result.captured[1] as LatLngDto;

          expect(viewId, result.captured[0] as int);
          expect(latLngIn.latitude, latLngOut.latitude);
          expect(latLngIn.longitude, latLngOut.longitude);

          // Move camera to co-ordinate bounds

          const LatLng latLngIn2 = LatLng(latitude: 7.0, longitude: 9.0);

          final LatLngBounds boundsIn =
              LatLngBounds(southwest: latLngIn, northeast: latLngIn2);
          const double paddingIn = 2.0;
          await controller.moveCamera(
              CameraUpdate.newLatLngBounds(boundsIn, padding: paddingIn));

          result = verify(viewMockApi.moveCameraToLatLngBounds(
              captureAny, captureAny, captureAny));
          final LatLngBoundsDto boundsOut =
              result.captured[1] as LatLngBoundsDto;

          expect(viewId, result.captured[0] as int);
          expect(boundsIn.southwest.latitude, boundsOut.southwest.latitude);
          expect(boundsIn.southwest.longitude, boundsOut.southwest.longitude);
          expect(boundsIn.northeast.latitude, boundsOut.northeast.latitude);
          expect(boundsIn.northeast.longitude, boundsOut.northeast.longitude);
          expect(paddingIn, result.captured[2] as double);

          // Move camera to co-ordinates and zoom

          const double zoomIn = 4.0;
          await controller
              .moveCamera(CameraUpdate.newLatLngZoom(latLngIn, zoomIn));

          result = verify(viewMockApi.moveCameraToLatLngZoom(
              captureAny, captureAny, captureAny));
          final LatLngDto latLngOut2 = result.captured[1] as LatLngDto;

          expect(viewId, result.captured[0] as int);
          expect(latLngIn.latitude, latLngOut2.latitude);
          expect(latLngIn.longitude, latLngOut2.longitude);
          expect(zoomIn, result.captured[2] as double);

          // Move camera by scrolling

          const double scrollByDx = 4.0;
          const double scrollByDy = 5.0;
          await controller
              .moveCamera(CameraUpdate.scrollBy(scrollByDx, scrollByDy));

          result = verify(viewMockApi.moveCameraByScroll(
              captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(scrollByDx, result.captured[1] as double);
          expect(scrollByDy, result.captured[2] as double);

          // Move camera by zoom

          const double zoomBy = 2.0;
          const Offset focusIn = Offset(3.0, 4.0);
          await controller
              .moveCamera(CameraUpdate.zoomBy(zoomBy, focus: focusIn));

          result = verify(viewMockApi.moveCameraByZoom(
              captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(zoomBy, result.captured[1] as double);
          expect(focusIn.dx, result.captured[2] as double);
          expect(focusIn.dy, result.captured[3] as double);

          // Move camera by zooming in

          await controller.moveCamera(CameraUpdate.zoomIn());

          result = verify(viewMockApi.moveCameraByZoom(
              captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(1.0 /* zoom by 1.0 */, result.captured[1] as double);
          expect(null /* focus dx not used */, result.captured[2] as double?);
          expect(null /* focus xy not used */, result.captured[3] as double?);

          // Move camera by zooming out

          await controller.moveCamera(CameraUpdate.zoomOut());

          result = verify(viewMockApi.moveCameraByZoom(
              captureAny, captureAny, captureAny, captureAny));

          expect(viewId, result.captured[0] as int);
          expect(-1.0, result.captured[1] as double);
          expect(null /* focus dx not used */, result.captured[2] as double?);
          expect(null /* focus xy not used */, result.captured[3] as double?);

          // Move camera by a fixed zoom value

          await controller.moveCamera(CameraUpdate.zoomTo(zoomIn));

          result = verify(viewMockApi.moveCameraToZoom(captureAny, captureAny));
          expect(viewId, result.captured[0] as int);
          expect(zoomIn, result.captured[1] as double);
        });

        testWidgets('Test map UI elements', (WidgetTester tester) async {
          const int viewId = 1;
          final GoogleNavigationViewController controller =
              GoogleNavigationViewController(viewId);

          // Mock UI element visibility getters.
          when(viewMockApi.isMyLocationEnabled(any)).thenReturn(true);
          when(viewMockApi.isMyLocationButtonEnabled(any)).thenReturn(true);
          when(viewMockApi.isZoomGesturesEnabled(any)).thenReturn(true);
          when(viewMockApi.isZoomControlsEnabled(any)).thenReturn(true);
          when(viewMockApi.isCompassEnabled(any)).thenReturn(true);
          when(viewMockApi.isRotateGesturesEnabled(any)).thenReturn(true);
          when(viewMockApi.isScrollGesturesEnabled(any)).thenReturn(true);
          when(viewMockApi.isScrollGesturesEnabledDuringRotateOrZoom(any))
              .thenReturn(true);
          when(viewMockApi.isTiltGesturesEnabled(any)).thenReturn(true);
          when(viewMockApi.isMapToolbarEnabled(any)).thenReturn(true);

          // Test UI element visibility getter return values.
          expect(await controller.isMyLocationEnabled(), true);
          expect(await controller.settings.isMyLocationButtonEnabled(), true);
          expect(await controller.settings.isZoomGesturesEnabled(), true);
          expect(await controller.settings.isZoomControlsEnabled(), true);
          expect(await controller.settings.isCompassEnabled(), true);
          expect(await controller.settings.isRotateGesturesEnabled(), true);
          expect(await controller.settings.isScrollGesturesEnabled(), true);
          expect(
              await controller.settings
                  .isScrollGesturesEnabledDuringRotateOrZoom(),
              true);
          expect(await controller.settings.isTiltGesturesEnabled(), true);
          expect(await controller.settings.isMapToolbarEnabled(), true);

          // Verify calls went through to the platform side.
          verify(viewMockApi.isMyLocationEnabled(captureAny));
          verify(viewMockApi.isMyLocationButtonEnabled(captureAny));
          verify(viewMockApi.isZoomGesturesEnabled(captureAny));
          verify(viewMockApi.isZoomControlsEnabled(captureAny));
          verify(viewMockApi.isCompassEnabled(captureAny));
          verify(viewMockApi.isRotateGesturesEnabled(captureAny));
          verify(viewMockApi.isScrollGesturesEnabled(captureAny));
          verify(viewMockApi
              .isScrollGesturesEnabledDuringRotateOrZoom(captureAny));
          verify(viewMockApi.isTiltGesturesEnabled(captureAny));
          verify(viewMockApi.isMapToolbarEnabled(captureAny));

          // Call UI element visibility setters.
          await controller.setMyLocationEnabled(true);
          await controller.settings.setMyLocationButtonEnabled(true);
          await controller.settings.setZoomGesturesEnabled(true);
          await controller.settings.setZoomControlsEnabled(true);
          await controller.settings.setCompassEnabled(true);
          await controller.settings.setRotateGesturesEnabled(true);
          await controller.settings.setScrollGesturesEnabled(true);
          await controller.settings
              .setScrollGesturesDuringRotateOrZoomEnabled(true);
          await controller.settings.setTiltGesturesEnabled(true);
          await controller.settings.setMapToolbarEnabled(true);

          // Verify getters went through with the right parameters.
          verifyEnabled(
              verify(viewMockApi.setMyLocationEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(viewMockApi.setMyLocationButtonEnabled(
                  captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(
                  viewMockApi.setZoomGesturesEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(
                  viewMockApi.setZoomControlsEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(viewMockApi.setCompassEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(
                  viewMockApi.setRotateGesturesEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(
                  viewMockApi.setScrollGesturesEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(viewMockApi.setScrollGesturesDuringRotateOrZoomEnabled(
                  captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(
                  viewMockApi.setTiltGesturesEnabled(captureAny, captureAny)),
              true);
          verifyEnabled(
              verify(viewMockApi.setMapToolbarEnabled(captureAny, captureAny)),
              true);
        });

        test('set padding for map', () async {
          // Create padding
          EdgeInsets insets =
              const EdgeInsets.only(left: 5, right: 10, top: 15, bottom: 20);

          // Mock api response
          when(viewMockApi.setPadding(any, any))
              .thenAnswer((Invocation _) async => ());

          // Set padding
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .setPadding(viewId: 0, padding: insets);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.setPadding(captureAny, captureAny));
          final MapPaddingDto paddingMessage =
              result.captured[1] as MapPaddingDto;

          // Verify message
          expect(insets.left, paddingMessage.left);
          expect(insets.right, paddingMessage.right);
          expect(insets.top, paddingMessage.top);
          expect(insets.bottom, paddingMessage.bottom);
        });

        test('get padding from map', () async {
          // Create padding
          EdgeInsets insets =
              const EdgeInsets.only(top: 5, left: 10, bottom: 15, right: 20);

          // Mock api response
          final MapPaddingDto messagePadding =
              MapPaddingDto(top: 5, left: 10, bottom: 15, right: 20);
          when(viewMockApi.getPadding(any))
              .thenAnswer((Invocation _) => messagePadding);

          // Get padding
          final EdgeInsets paddingOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .getPadding(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.getPadding(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify response padding
          expect(viewId, 0);
          expect(insets, paddingOut);
        });
      });

      group('Navigation session API', () {
        test('Test terms and conditions flows', () async {
          // Show terms and conditions.
          const String title = 'Title';
          const String companyName = 'Temp co.';
          const bool showDriverAwareness = true;
          when(sessionMockApi.showTermsAndConditionsDialog(any, any, any))
              .thenAnswer((Invocation _) async => true);
          final bool accepted =
              await GoogleMapsNavigator.showTermsAndConditionsDialog(
                  title, companyName,
                  shouldOnlyShowDriverAwarenessDisclaimer: showDriverAwareness);
          expect(accepted, true);

          final VerificationResult result = verify(
              sessionMockApi.showTermsAndConditionsDialog(
                  captureAny, captureAny, captureAny));
          expect(result.captured[0] as String, title);
          expect(result.captured[1] as String, companyName);
          expect(result.captured[2] as bool, showDriverAwareness);

          // Reset terms and conditions.
          await GoogleMapsNavigator.resetTermsAccepted();
          verify(sessionMockApi.resetTermsAccepted());

          // Are terms accepted.
          when(sessionMockApi.areTermsAccepted()).thenReturn(true);
          await GoogleMapsNavigator.areTermsAccepted();
          expect(sessionMockApi.areTermsAccepted(), true);
        });

        test('Test navigation session', () async {
          // Initialize session and session controller.
          await GoogleMapsNavigator.initializeNavigationSession(
              abnormalTerminationReportingEnabled: false);
          VerificationResult result = verify(
              sessionMockApi.createNavigationSession(captureAny, captureAny));
          expect(result.captured[0] as bool, false);

          // Start/stop guidance.

          await GoogleMapsNavigator.startGuidance();
          verify(sessionMockApi.startGuidance());

          await GoogleMapsNavigator.stopGuidance();
          verify(sessionMockApi.stopGuidance());

          // Location updates.
          if (platform is GoogleMapsNavigationIOS) {
            await GoogleMapsNavigator.allowBackgroundLocationUpdates(true);
            final VerificationResult backgroundResult = verify(
                sessionMockApi.allowBackgroundLocationUpdates(captureAny));
            expect(backgroundResult.captured[0] as bool, true);
          } else if (platform is GoogleMapsNavigationAndroid) {
            expect(
                () => GoogleMapsNavigator.allowBackgroundLocationUpdates(true),
                throwsUnsupportedError);
          }

          // Continue to the next destination.
          final NavigationWaypointDto waypointIn = NavigationWaypointDto(
              title: 'Title',
              target: LatLngDto(latitude: 0.4, longitude: 0.5),
              placeID: 'id',
              preferSameSideOfRoad: true,
              preferredSegmentHeading: 50);

          when(sessionMockApi.continueToNextDestination())
              .thenReturn(waypointIn);
          final NavigationWaypoint? waypointOut =
              await GoogleMapsNavigator.continueToNextDestination();
          expect(waypointOut, isNotNull);
          if (waypointOut != null) {
            expect(waypointIn.title, waypointOut.title);
            expect(waypointIn.target?.latitude, waypointOut.target?.latitude);
            expect(waypointIn.target?.longitude, waypointOut.target?.longitude);
            expect(waypointIn.placeID, waypointOut.placeID);
            expect(waypointIn.preferSameSideOfRoad,
                waypointOut.preferSameSideOfRoad);
            expect(waypointIn.preferredSegmentHeading,
                waypointOut.preferredSegmentHeading);
          }

          // Set destinations.

          final NavigationDisplayOptions navigationDisplayOptionsIn =
              NavigationDisplayOptions(
                  showDestinationMarkers: false,
                  showStopSigns: true,
                  showTrafficLights: true);

          final RoutingOptions routingOptionsIn = RoutingOptions(
            alternateRoutesStrategy: NavigationAlternateRoutesStrategy.all,
            routingStrategy: NavigationRoutingStrategy.defaultBest,
            targetDistanceMeters: <int?>[1, 1, 1],
            avoidFerries: true,
            avoidHighways: true,
            avoidTolls: true,
            locationTimeoutMs: 5000,
          );

          final NavigationWaypoint destinationWaypointIn =
              NavigationWaypoint.withLatLngTarget(
            title: 'title',
            target: const LatLng(latitude: 5.0, longitude: 6.0),
          );
          final Destinations destinationIn = Destinations(
              waypoints: <NavigationWaypoint>[destinationWaypointIn],
              displayOptions: navigationDisplayOptionsIn,
              routingOptions: routingOptionsIn);

          const RouteStatusDto statusIn = RouteStatusDto.quotaExceeded;
          when(sessionMockApi.setDestinations(any))
              .thenAnswer((Invocation _) async => statusIn);

          final NavigationRouteStatus statusOut =
              await GoogleMapsNavigator.setDestinations(destinationIn);
          expect(statusOut, NavigationRouteStatus.quotaExceeded);
          result = verify(sessionMockApi.setDestinations(captureAny));
          final DestinationsDto destinationOut =
              result.captured[0] as DestinationsDto;
          final NavigationWaypointDto? destinationWaypointOut =
              destinationOut.waypoints[0];
          expect(destinationWaypointOut, isNotNull);
          if (destinationWaypointOut != null) {
            expect(destinationWaypointIn.title, destinationWaypointOut.title);
            expect(destinationWaypointIn.target?.latitude,
                destinationWaypointOut.target?.latitude);
            expect(destinationWaypointIn.target?.longitude,
                destinationWaypointOut.target?.longitude);
          }
          expect(destinationIn.displayOptions.showDestinationMarkers,
              destinationOut.displayOptions.showDestinationMarkers);
          expect(destinationIn.displayOptions.showStopSigns,
              destinationOut.displayOptions.showStopSigns);
          expect(destinationIn.displayOptions.showTrafficLights,
              destinationOut.displayOptions.showTrafficLights);

          expect(AlternateRoutesStrategyDto.all,
              destinationOut.routingOptions!.alternateRoutesStrategy);
          expect(RoutingStrategyDto.defaultBest,
              destinationOut.routingOptions!.routingStrategy);
          expect(destinationIn.routingOptions!.avoidFerries,
              destinationOut.routingOptions!.avoidFerries);
          expect(destinationIn.routingOptions!.avoidHighways,
              destinationOut.routingOptions!.avoidHighways);
          expect(destinationIn.routingOptions!.avoidTolls,
              destinationOut.routingOptions!.avoidTolls);
          expect(destinationIn.routingOptions!.locationTimeoutMs,
              destinationOut.routingOptions!.locationTimeoutMs);

          // Get current time and distance.
          final NavigationTimeAndDistanceDto timeAndDistanceIn =
              NavigationTimeAndDistanceDto(time: 5.0, distance: 6.0);
          when(sessionMockApi.getCurrentTimeAndDistance())
              .thenReturn(timeAndDistanceIn);
          final NavigationTimeAndDistance timeAndDistanceOut =
              await GoogleMapsNavigator.getCurrentTimeAndDistance();
          expect(timeAndDistanceIn.time, timeAndDistanceOut.time);
          expect(timeAndDistanceIn.distance, timeAndDistanceOut.distance);

          final NavigationAudioGuidanceSettings settingsIn =
              NavigationAudioGuidanceSettings(
                  isBluetoothAudioEnabled: true,
                  isVibrationEnabled: true,
                  guidanceType: NavigationAudioGuidanceType.alertsOnly);

          // Set audio guidance.
          await GoogleMapsNavigator.setAudioGuidance(settingsIn);
          final VerificationResult settingsResult =
              verify(sessionMockApi.setAudioGuidance(captureAny));
          final NavigationAudioGuidanceSettingsDto settingsOut =
              settingsResult.captured[0] as NavigationAudioGuidanceSettingsDto;
          expect(settingsIn.isBluetoothAudioEnabled,
              settingsOut.isBluetoothAudioEnabled);
          expect(settingsIn.isVibrationEnabled, settingsOut.isVibrationEnabled);
          expect(settingsOut.guidanceType, AudioGuidanceTypeDto.alertsOnly);
        });

        test('Test navigation simulator', () async {
          // Pause/resume simulation.

          await GoogleMapsNavigator.simulator.pauseSimulation();
          verify(sessionMockApi.pauseSimulation());

          await GoogleMapsNavigator.simulator.resumeSimulation();
          verify(sessionMockApi.resumeSimulation());

          // Control user location.

          const LatLng pointIn = LatLng(latitude: 0.4, longitude: 0.5);
          await GoogleMapsNavigator.simulator.setUserLocation(pointIn);
          final VerificationResult result =
              verify(sessionMockApi.setUserLocation(captureAny));
          final LatLngDto pointOut = result.captured[0] as LatLngDto;
          expect(pointIn.latitude, pointOut.latitude);
          expect(pointIn.longitude, pointOut.longitude);

          await GoogleMapsNavigator.simulator.removeUserLocation();
          verify(sessionMockApi.removeUserLocation());

          // Simulate locations.

          await GoogleMapsNavigator.simulator
              .simulateLocationsAlongExistingRoute();
          verify(sessionMockApi.simulateLocationsAlongExistingRoute());

          await GoogleMapsNavigator.simulator
              .simulateLocationsAlongExistingRoute();
          verify(sessionMockApi.simulateLocationsAlongExistingRoute());

          final SimulationOptions simOptionsIn =
              SimulationOptions(speedMultiplier: 5.5);
          await GoogleMapsNavigator.simulator
              .simulateLocationsAlongExistingRouteWithOptions(simOptionsIn);
          final VerificationResult optionsResult = verify(sessionMockApi
              .simulateLocationsAlongExistingRouteWithOptions(captureAny));
          final SimulationOptionsDto optionsOut =
              optionsResult.captured[0] as SimulationOptionsDto;
          expect(simOptionsIn.speedMultiplier, optionsOut.speedMultiplier);

          // Simulate the locations along a new route.

          final NavigationWaypoint waypointIn =
              NavigationWaypoint.withLatLngTarget(
            title: 'title',
            target: const LatLng(latitude: 5.0, longitude: 6.0),
          );

          when(sessionMockApi.simulateLocationsAlongNewRoute(any))
              .thenAnswer((Invocation _) async => RouteStatusDto.statusOk);

          final NavigationRouteStatus statusOut = await GoogleMapsNavigator
              .simulator
              .simulateLocationsAlongNewRoute(<NavigationWaypoint>[waypointIn]);
          expect(statusOut, NavigationRouteStatus.statusOk);

          final VerificationResult routeResult =
              verify(sessionMockApi.simulateLocationsAlongNewRoute(captureAny));
          final List<NavigationWaypointDto?> waypoints =
              routeResult.captured[0] as List<NavigationWaypointDto?>;
          final NavigationWaypointDto? waypointOut = waypoints[0];
          expect(waypointIn.title, waypointOut?.title);
          expect(waypointIn.target?.latitude, waypointOut?.target?.latitude);
          expect(waypointIn.target?.longitude, waypointOut?.target?.longitude);

          // Simulate the locations along a new route with routing options.

          final RoutingOptions routingOptionsIn = RoutingOptions(
              alternateRoutesStrategy: NavigationAlternateRoutesStrategy.none,
              routingStrategy: NavigationRoutingStrategy.deltaToTargetDistance,
              targetDistanceMeters: <int?>[1, 1, 1],
              travelMode: NavigationTravelMode.taxi,
              avoidTolls: true,
              avoidFerries: true,
              avoidHighways: true,
              locationTimeoutMs: 10000);

          when(sessionMockApi.simulateLocationsAlongNewRouteWithRoutingOptions(
                  any, any))
              .thenAnswer(
                  (Invocation _) async => RouteStatusDto.statusCanceled);

          final NavigationRouteStatus statusOut2 = await GoogleMapsNavigator
              .simulator
              .simulateLocationsAlongNewRouteWithRoutingOptions(
                  <NavigationWaypoint>[waypointIn], routingOptionsIn);
          expect(statusOut2, NavigationRouteStatus.statusCanceled);

          final VerificationResult routeResult2 = verify(
              sessionMockApi.simulateLocationsAlongNewRouteWithRoutingOptions(
                  captureAny, captureAny));

          final List<NavigationWaypointDto?> waypoints2 =
              routeResult2.captured[0] as List<NavigationWaypointDto?>;
          final NavigationWaypointDto? waypointOut2 = waypoints2[0];
          expect(waypointIn.title, waypointOut2?.title);
          expect(waypointIn.target?.latitude, waypointOut2?.target?.latitude);
          expect(waypointIn.target?.longitude, waypointOut2?.target?.longitude);

          final RoutingOptionsDto routingOptionsOut =
              routeResult2.captured[1] as RoutingOptionsDto;
          expect(routingOptionsOut.alternateRoutesStrategy,
              AlternateRoutesStrategyDto.none);
          expect(routingOptionsOut.routingStrategy,
              RoutingStrategyDto.deltaToTargetDistance);
          expect(routingOptionsOut.targetDistanceMeters, <int?>[1, 1, 1]);
          expect(routingOptionsOut.travelMode, TravelModeDto.taxi);
          expect(routingOptionsOut.avoidTolls, true);
          expect(routingOptionsOut.avoidFerries, true);
          expect(routingOptionsOut.avoidHighways, true);
          expect(routingOptionsOut.locationTimeoutMs, 10000);

          // Simulate the locations along a new route with routing and simulation options.

          when(sessionMockApi
                  .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
                      any, any, any))
              .thenAnswer((Invocation _) async => RouteStatusDto.statusOk);
          final NavigationRouteStatus statusOut3 = await GoogleMapsNavigator
              .simulator
              .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
                  <NavigationWaypoint>[waypointIn],
                  routingOptionsIn,
                  simOptionsIn);
          expect(statusOut3, NavigationRouteStatus.statusOk);

          final VerificationResult routeResult3 = verify(sessionMockApi
              .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
                  captureAny, captureAny, captureAny));

          final List<NavigationWaypointDto?> waypoints3 =
              routeResult3.captured[0] as List<NavigationWaypointDto?>;
          final NavigationWaypointDto? waypointOut3 = waypoints3[0];
          expect(waypointIn.title, waypointOut3?.title);
          expect(waypointIn.target?.latitude, waypointOut3?.target?.latitude);
          expect(waypointIn.target?.longitude, waypointOut3?.target?.longitude);

          final RoutingOptionsDto routingOptionsOut2 =
              routeResult3.captured[1] as RoutingOptionsDto;
          expect(routingOptionsOut2.alternateRoutesStrategy,
              AlternateRoutesStrategyDto.none);
          expect(routingOptionsOut2.routingStrategy,
              RoutingStrategyDto.deltaToTargetDistance);
          expect(routingOptionsOut2.targetDistanceMeters, <int?>[1, 1, 1]);
          expect(routingOptionsOut2.travelMode, TravelModeDto.taxi);
          expect(routingOptionsOut2.avoidTolls, true);
          expect(routingOptionsOut2.avoidFerries, true);
          expect(routingOptionsOut2.avoidHighways, true);
          expect(routingOptionsOut2.locationTimeoutMs, 10000);

          final SimulationOptionsDto simOptionsOut =
              routeResult3.captured[2] as SimulationOptionsDto;
          expect(simOptionsIn.speedMultiplier, simOptionsOut.speedMultiplier);
        });
      });

      group('Markers', () {
        test('get markers', () async {
          // Create marker
          const Marker marker =
              Marker(markerId: 'Marker_0', options: MarkerOptions());

          // Mock api response
          final MarkerDto messageMarker =
              MarkerDto(markerId: 'Marker_0', options: marker.options.toDto());
          when(viewMockApi.getMarkers(any))
              .thenAnswer((Invocation _) => <MarkerDto>[messageMarker]);

          // Get markers
          final List<Marker?> markersOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .getMarkers(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.getMarkers(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify response polygon options
          expect(viewId, 0);
          expect(marker.options, markersOut[0]!.options);
        });

        test('add marker', () async {
          // Create options
          const MarkerOptions optionsIn = MarkerOptions(
              alpha: 0.5,
              anchor: MarkerAnchor(u: 0.1, v: 0.2),
              draggable: true,
              flat: true,
              consumeTapEvents: true,
              position: LatLng(latitude: 50, longitude: 60),
              rotation: 70,
              infoWindow: InfoWindow(title: 'Title', snippet: 'Snippet'),
              zIndex: 2);

          // Mock api response
          final MarkerDto markerIn =
              MarkerDto(markerId: 'Marker_0', options: optionsIn.toDto());
          when(viewMockApi.addMarkers(any, any))
              .thenAnswer((Invocation _) => <MarkerDto>[markerIn]);

          // Add marker
          final List<Marker?> markersOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .addMarkers(viewId: 0, markerOptions: <MarkerOptions>[optionsIn]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.addMarkers(captureAny, captureAny));
          final List<MarkerDto?> markersInMessage =
              result.captured[1] as List<MarkerDto?>;

          // Verify message and response marker options
          expect(markerIn.markerId, markersInMessage[0]?.markerId);
          expect(optionsIn, markersInMessage[0]?.options.toMarkerOptions());
          expect(optionsIn, markersOut[0]!.options);
        });

        test('update marker', () async {
          // Create marker
          const Marker marker =
              Marker(markerId: 'Marker_0', options: MarkerOptions());

          // Mock api response
          final MarkerDto messageMarker =
              MarkerDto(markerId: 'Marker_0', options: marker.options.toDto());
          when(viewMockApi.updateMarkers(any, any))
              .thenAnswer((Invocation _) => <MarkerDto>[messageMarker]);

          // Edit marker
          final List<Marker?> markersOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .updateMarkers(viewId: 0, markers: <Marker>[marker]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.updateMarkers(captureAny, captureAny));
          final List<MarkerDto?> markersInMessage =
              result.captured[1] as List<MarkerDto?>;

          // Verify message and response marker options
          expect(marker.markerId, markersInMessage[0]?.markerId);
          expect(
              marker.options, markersInMessage[0]?.options.toMarkerOptions());
          expect(marker.options, markersOut[0]!.options);
        });

        test('remove marker', () async {
          // Create marker
          const Marker marker =
              Marker(markerId: 'Marker_0', options: MarkerOptions());

          // Mock api response
          when(viewMockApi.removeMarkers(any, any))
              .thenAnswer((Invocation _) => ());

          // Remove marker
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .removeMarkers(viewId: 0, markers: <Marker>[marker]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.removeMarkers(captureAny, captureAny));
          final List<MarkerDto?> markersInMessage =
              result.captured[1] as List<MarkerDto?>;

          // Verify message
          expect(marker.markerId, markersInMessage[0]?.markerId);
        });

        test('clear markers', () async {
          // Mock api response
          when(viewMockApi.clearMarkers(any))
              .thenAnswer((Invocation _) async => ());

          // Clear map
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .clearMarkers(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.clearMarkers(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify message
          expect(0, viewId);
        });

        test('clear map', () async {
          // Mock api response
          when(viewMockApi.clear(any)).thenAnswer((Invocation _) async => ());

          // Clear map
          await GoogleMapsNavigationPlatform.instance.viewAPI.clear(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.clear(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify message
          expect(0, viewId);
        });
      });

      group('Polygons', () {
        test('get polygons', () async {
          // Create polygon
          const Polygon polygon =
              Polygon(polygonId: 'Polygon_0', options: PolygonOptions());

          // Mock api response
          final PolygonDto messagePolygon = PolygonDto(
              polygonId: 'Polygon_0', options: polygon.options.toDto());
          when(viewMockApi.getPolygons(any))
              .thenAnswer((Invocation _) => <PolygonDto>[messagePolygon]);

          // Get polygons
          final List<Polygon?> polygonsOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .getPolygons(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.getPolygons(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify response polygon options
          expect(viewId, 0);
          expect(polygon.options, polygonsOut[0]!.options);
        });

        test('add polygon', () async {
          // Create options
          const PolygonOptions optionsIn = PolygonOptions(
              points: <LatLng>[
                LatLng(latitude: 40.0, longitude: 50.0)
              ],
              holes: <List<LatLng>>[
                <LatLng>[LatLng(latitude: 60.0, longitude: 70.0)]
              ],
              clickable: true,
              fillColor: Colors.amber,
              geodesic: true,
              strokeColor: Colors.cyan,
              strokeWidth: 4,
              zIndex: 3);

          // Mock api response
          final PolygonDto polygonIn =
              PolygonDto(polygonId: 'Polygon_0', options: optionsIn.toDto());
          when(viewMockApi.addPolygons(any, any))
              .thenAnswer((Invocation _) => <PolygonDto>[polygonIn]);

          // Add polygon
          final List<Polygon?> polygonsOut =
              await GoogleMapsNavigationPlatform.instance.viewAPI.addPolygons(
                  viewId: 0, polygonOptions: <PolygonOptions>[optionsIn]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.addPolygons(captureAny, captureAny));
          final List<PolygonDto?> polygonsInMessage =
              result.captured[1] as List<PolygonDto?>;

          // Verify message and response polygon options
          expect(polygonIn.polygonId, polygonsInMessage[0]?.polygonId);
          expect(optionsIn, polygonsInMessage[0]?.options.toPolygonOptions());
          expect(optionsIn, polygonsOut[0]!.options);
        });

        test('update polygon', () async {
          // Create polygon
          const Polygon polygon =
              Polygon(polygonId: 'Polygon_0', options: PolygonOptions());

          // Mock api response
          final PolygonDto messagePolygon = PolygonDto(
              polygonId: 'Polygon_0', options: polygon.options.toDto());
          when(viewMockApi.updatePolygons(any, any))
              .thenAnswer((Invocation _) => <PolygonDto>[messagePolygon]);

          // Edit polygon
          final List<Polygon?> polygonsOut = await GoogleMapsNavigationPlatform
              .instance.viewAPI
              .updatePolygons(viewId: 0, polygons: <Polygon>[polygon]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.updatePolygons(captureAny, captureAny));
          final List<PolygonDto?> polygonsInMessage =
              result.captured[1] as List<PolygonDto?>;

          // Verify message and response polygon options
          expect(polygon.polygonId, polygonsInMessage[0]?.polygonId);
          expect(polygon.options,
              polygonsInMessage[0]?.options.toPolygonOptions());
          expect(polygon.options, polygonsOut[0]!.options);
        });

        test('remove polygon', () async {
          // Create polygon
          const Polygon polygon =
              Polygon(polygonId: 'Polygon_0', options: PolygonOptions());

          // Mock api response
          when(viewMockApi.removePolygons(any, any))
              .thenAnswer((Invocation _) async => ());

          // Remove polygon
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .removePolygons(viewId: 0, polygons: <Polygon>[polygon]);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.removePolygons(captureAny, captureAny));
          final List<PolygonDto?> polygonsInMessage =
              result.captured[1] as List<PolygonDto?>;

          // Verify message
          expect(polygon.polygonId, polygonsInMessage[0]?.polygonId);
        });

        test('clear polygons', () async {
          // Mock api response
          when(viewMockApi.clearPolygons(any))
              .thenAnswer((Invocation _) async => ());

          // Clear map
          await GoogleMapsNavigationPlatform.instance.viewAPI
              .clearPolygons(viewId: 0);

          // Verify correct message sent from view api
          final VerificationResult result =
              verify(viewMockApi.clearPolygons(captureAny));
          final int viewId = result.captured[0] as int;

          // Verify message
          expect(viewId, 0);
        });
      });
    });
  }
}
