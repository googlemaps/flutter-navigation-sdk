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

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'shared.dart';

void main() {
  final mapTypeVariants = getMapTypeVariants();
  CameraPosition expectedPosition = const CameraPosition();
  Completer<void> cameraMoveStartedCompleter = Completer<void>();
  Completer<void> cameraMoveCompleter = Completer<void>();
  Completer<void> cameraIdleCompleter = Completer<void>();
  late CameraPosition cameraMoveStartedPosition;
  late CameraPosition cameraMovePosition;
  late CameraPosition cameraIdlePosition;
  bool? followingMyLocationActive;
  CameraPosition? startedFollowingMyLocationPosition;
  CameraPosition? stoppedFollowingMyLocationPosition;
  const double latLngTestThreshold = 0.03;

  /// Define the camera event callback functions.
  void onCameraMoveStarted(CameraPosition position, bool gesture) {
    if (!cameraMoveStartedCompleter.isCompleted) {
      debugPrint('cameraMoveStarted event');
      cameraMoveStartedPosition = position;
      cameraMoveStartedCompleter.complete();
    }
  }

  void onCameraMove(CameraPosition position) {
    if (!cameraMoveCompleter.isCompleted) {
      debugPrint('cameraMoving event');
      cameraMovePosition = position;
      cameraMoveCompleter.complete();
    }
  }

  void onCameraIdle(CameraPosition position) {
    debugPrint('cameraIdle event');
    if (!cameraIdleCompleter.isCompleted) {
      cameraIdlePosition = position;
      cameraIdleCompleter.complete();
    }
  }

  void onCameraStartedFollowingLocation(CameraPosition position) {
    debugPrint('startedFollowingMyLocation event');
    startedFollowingMyLocationPosition = position;
    followingMyLocationActive = true;
  }

  void onCameraStoppedFollowingLocation(CameraPosition position) {
    debugPrint('stoppedFollowingMyLocation event');
    stoppedFollowingMyLocationPosition = position;
    followingMyLocationActive = false;
  }

  /// Reset the camera event completers.
  void resetCameraEventCompleters() {
    cameraMoveStartedCompleter = Completer<void>();
    cameraMoveCompleter = Completer<void>();
    cameraIdleCompleter = Completer<void>();
  }

  /// Reset the camera following state for test isolation.
  void resetCameraFollowingState() {
    followingMyLocationActive = null;
    startedFollowingMyLocationPosition = null;
    stoppedFollowingMyLocationPosition = null;
  }

  double distanceToNorth(double angle) {
    final double diff = (angle + 180) % 360 - 180;
    return (diff < -180 ? diff + 360 : diff).abs();
  }

  /// Define the predicate functions for waitForCameraPositionMatchingPredicate().
  ///
  /// Check the camera zoom values match each other within tolerance.
  bool checkZoomMatch(CameraPosition receivedPosition) {
    return (receivedPosition.zoom - expectedPosition.zoom).abs() <= 0.01 &&
        (receivedPosition.zoom - expectedPosition.zoom).abs() <= 0.01;
  }

  /// Check the received camera tilt value is less than or equal to the expected tilt value.
  bool checkTiltLessThanOrEqualTo(CameraPosition receivedPosition) {
    return receivedPosition.tilt <= expectedPosition.tilt;
  }

  /// Check the received camera tilt value is greater than or equal to the expected tilt value.
  bool checkTiltGreaterThanOrEqualTo(CameraPosition receivedPosition) {
    return receivedPosition.tilt >= expectedPosition.tilt;
  }

  /// Check the received camera bearing value is less than or equal to the expected bearing value.
  bool checkBearingLessThanOrEqualTo(CameraPosition receivedPosition) {
    return distanceToNorth(receivedPosition.bearing) <=
        expectedPosition.bearing;
  }

  /// Check that the received camera target value doesn't match the expected camera target value.
  bool checkCoordinatesDiffer(CameraPosition receivedPosition) {
    return receivedPosition.target != expectedPosition.target;
  }

  // Check that the received camera target value matches the expected camera target value.
  bool checkCoordinatesMatch(CameraPosition receivedPosition) {
    return (receivedPosition.target.latitude - expectedPosition.target.latitude)
                .abs() <=
            latLngTestThreshold &&
        (receivedPosition.target.longitude - expectedPosition.target.longitude)
                .abs() <=
            latLngTestThreshold;
  }

  /// Wait for cameraMoveStarted, cameraMove and cameraIdle events.
  Future<void> waitForCameraEvents(PatrolIntegrationTester $) async {
    await cameraMoveStartedCompleter.future;
    await cameraMoveCompleter.future;
    await cameraIdleCompleter.future;
    // Check the event positions are not empty.
    expect(
      cameraMoveStartedPosition,
      isNotNull,
      reason: 'cameraMoveStartedPosition is null',
    );
    expect(cameraMovePosition, isNotNull, reason: 'cameraMovePosition is null');
    expect(cameraIdlePosition, isNotNull, reason: 'cameraIdlePosition is null');
  }

  /// Check the camera coordinates match each other within tolerance.
  void checkCameraCoordinatesMatch(
    CameraPosition received,
    CameraPosition expected,
  ) {
    expect(
      received.target.latitude,
      closeTo(expected.target.latitude, latLngTestThreshold),
      reason: 'Latitude mismatch',
    );
    expect(
      received.target.longitude,
      closeTo(expected.target.longitude, latLngTestThreshold),
      reason: 'Longitude mismatch',
    );
  }

  patrol('Test camera modes', (PatrolIntegrationTester $) async {
    // Reset state for test isolation when running tests sequentially.
    resetCameraFollowingState();
    resetCameraEventCompleters();

    // Test that followMyLocation is not active and no stop or start events have come in.
    if (Platform.isAndroid) {
      expect(
        followingMyLocationActive,
        isNull,
        reason: 'followingMyLocationActive not null',
      );
      expect(
        startedFollowingMyLocationPosition,
        isNull,
        reason: 'startedFollowingMyLocationPosition not null',
      );
      expect(
        stoppedFollowingMyLocationPosition,
        isNull,
        reason: 'stoppedFollowingMyLocationPosition not null',
      );
    }

    /// Initialize navigation with the event listener functions.
    final GoogleNavigationViewController controller = await startNavigation(
      $,
      onCameraMoveStarted: onCameraMoveStarted,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      onCameraStartedFollowingLocation: onCameraStartedFollowingLocation,
      onCameraStoppedFollowingLocation: onCameraStoppedFollowingLocation,
    );

    // Test that the followMyLocation is active and onCameraStartedFollowingLocation event
    // has been received.
    if (Platform.isAndroid) {
      expect(followingMyLocationActive, true, reason: 'Not following location');
      expect(
        startedFollowingMyLocationPosition,
        isNotNull,
        reason: 'Start event missing',
      );
    }

    /// Define the getPosition function for waitForCameraPositionMatchingPredicate().
    Future<CameraPosition> getPosition() async {
      final CameraPosition position = await controller.getCameraPosition();
      return position;
    }

    /// Wait for followingMyLocationActive to reach the expected state.
    /// Returns the state if reached, null if timeout.
    Future<bool?> waitForFollowingMyLocationState(bool expectedState) async {
      return waitForValueMatchingPredicate<bool?>(
        $,
        () async => followingMyLocationActive,
        (bool? value) => value == expectedState,
        maxTries: 50,
        delayMs: 100,
      );
    }

    // Verify that the follow my location camera mode is active.
    Future<void> checkCameraFollowsLocation() async {
      final LatLng? currentLocation = await controller.getMyLocation();
      expectedPosition = CameraPosition(target: currentLocation!);
      // Wait until camera target matches my location target, fail if
      // it doesn't happen within the max retries (≈20s).
      final CameraPosition? followMyLocationCheck =
          await waitForValueMatchingPredicate(
            $,
            getPosition,
            checkCoordinatesMatch,
          );
      expect(
        followMyLocationCheck,
        isNotNull,
        reason: 'Camera not following location',
      );

      // Check that Android camera started following location events have come in.
      // Wait for the event since it may be delivered asynchronously.
      if (Platform.isAndroid) {
        final bool? state = await waitForFollowingMyLocationState(true);
        expect(state, true, reason: 'Not following location');
        expect(
          startedFollowingMyLocationPosition,
          isNotNull,
          reason: 'Start event missing',
        );
      }
    }

    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    // 1. Test default.
    //
    // The navigation follows the user's location in tilted mode.

    // Check the camera tilt value is over 40.
    expectedPosition = const CameraPosition(tilt: 40);

    // Wait until the camera tilt is greater than the expected tilt.
    CameraPosition? camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkTiltGreaterThanOrEqualTo,
    );
    expect(camera, isNotNull, reason: 'Tilt >= 40 timeout');

    $.log('Default tilt: ${camera!.tilt}');
    $.log('Default zoom: ${camera.zoom}');
    $.log('Default bearing: ${camera.bearing}');

    // Verify that the follow my location camera mode is active.
    await checkCameraFollowsLocation();

    // Strong tilting (Android 45, iOS 55 degrees)
    expect(camera.tilt, greaterThanOrEqualTo(40), reason: 'Tilt < 40');

    LatLng oldTarget = camera.target;
    double oldZoom = camera.zoom;

    // 2. Test CameraPerspective.topDownHeadingUp.
    expectedPosition = const CameraPosition(tilt: 0.1);
    await controller.followMyLocation(CameraPerspective.topDownHeadingUp);

    // Wait until the camera tilt is less than or equal the expected tilt.
    camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkTiltLessThanOrEqualTo,
    );
    expect(camera, isNotNull, reason: 'Tilt <= 0.1 timeout');

    $.log('topDownHeadingUp tilt: ${camera!.tilt}');
    $.log('topDownHeadingUp zoom: ${camera.zoom}');
    $.log('topDownHeadingUp bearing: ${camera.bearing}');

    // Verify that the follow my location camera mode is active.
    await checkCameraFollowsLocation();

    // No tilt when top-down.
    expect(camera.tilt, lessThanOrEqualTo(0.1), reason: 'Tilt > 0.1');

    // Wait until camera target has moved (follows users location).
    CameraPosition? cameraHasMoved = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkCoordinatesDiffer,
    );
    expect(cameraHasMoved, isNotNull, reason: 'Camera did not move');

    oldTarget = camera.target;

    // 3. Test CameraPerspective.topDownNorthUp
    expectedPosition = const CameraPosition(bearing: 1.0, tilt: 0.1);
    await controller.followMyLocation(CameraPerspective.topDownNorthUp);

    // Wait until the bearing & tilt are less than or equal to the expected bearing & tilt.
    // On iOS the random small tilt change caused occasional test failures.
    await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkTiltLessThanOrEqualTo,
    );
    camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkBearingLessThanOrEqualTo,
    );
    expect(camera, isNotNull, reason: 'Tilt/bearing timeout');

    $.log('topDownNorthUp tilt: ${camera!.tilt}');
    $.log('topDownNorthUp zoom: ${camera.zoom}');
    $.log('topDownNorthUp bearing: ${camera.bearing}');

    // Verify that the follow my location camera mode is active.
    await checkCameraFollowsLocation();

    // No tilt when top-down.
    expect(camera.tilt, lessThanOrEqualTo(0.1), reason: 'Tilt > 0.1');

    // North-up means zero bearing.
    // iOS reports 0 degrees, Android is more fuzzy e.g. 359.7 degrees.
    expect(
      distanceToNorth(camera.bearing),
      lessThanOrEqualTo(2.0),
      reason: 'Not north-up',
    );

    // Wait until camera target has moved (follows users location).
    cameraHasMoved = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkCoordinatesDiffer,
    );
    expect(cameraHasMoved, isNotNull, reason: 'Camera did not move');

    oldTarget = camera.target;

    // 4. Test CameraPerspective.tilted
    expectedPosition = const CameraPosition(tilt: 40);
    await controller.followMyLocation(CameraPerspective.tilted);

    // Wait until the tilt is greater than or equal to the expected tilt.
    camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkTiltGreaterThanOrEqualTo,
    );
    expect(camera, isNotNull, reason: 'Tilt >= 40 timeout');

    $.log('tilted tilt: ${camera!.tilt}');
    $.log('tilted zoom: ${camera.zoom}');
    $.log('tilted bearing: ${camera.bearing}');

    // Verify that the follow my location camera mode is active.
    await checkCameraFollowsLocation();

    // Repeat tests done with the default state above
    expect(camera.tilt, greaterThanOrEqualTo(40), reason: 'Tilt < 40');
    expect(
      distanceToNorth(camera.bearing),
      greaterThanOrEqualTo(0.01),
      reason: 'Bearing too low',
    );

    // Wait until camera target has moved (follows users location).
    cameraHasMoved = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkCoordinatesDiffer,
    );
    expect(cameraHasMoved, isNotNull, reason: 'Camera did not move');

    oldTarget = camera.target;
    oldZoom = camera.zoom;

    // 5. Test showRouteOverview().
    expectedPosition = const CameraPosition(tilt: 0.1, bearing: 1.0);
    await controller.showRouteOverview();

    // Wait until the tilt is less than or equal to the expected tilt.
    await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkTiltLessThanOrEqualTo,
    );

    // Wait until the bearing is north-up (close to 0).
    camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkBearingLessThanOrEqualTo,
    );

    $.log('showRouteOverview tilt: ${camera!.tilt}');
    $.log('showRouteOverview zoom: ${camera.zoom}');
    $.log('showRouteOverview bearing: ${camera.bearing}');

    // No tilt when in route overview.
    expect(camera.tilt, lessThanOrEqualTo(0.1), reason: 'Tilt > 0.1');

    // Expect zoom to be farthest away.
    expect(
      oldZoom,
      greaterThanOrEqualTo(camera.zoom),
      reason: 'Zoom not farthest',
    );

    // Route is shown north up.
    expect(
      distanceToNorth(camera.bearing),
      lessThanOrEqualTo(1.0),
      reason: 'Not north-up',
    );

    // Wait until camera target has moved (follows users location).
    cameraHasMoved = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkCoordinatesDiffer,
    );
    expect(cameraHasMoved, isNotNull, reason: 'Camera did not move');

    // 6. Test the optional follow my location parameter zoom level.
    // Note: We skip testing startedFollowingMyLocation event here because
    // showRouteOverview() in test 5 leaves the SDK's internal follow state
    // inconsistent, causing unreliable callback behavior.
    const double zoomLevel = 8.5;
    expectedPosition = const CameraPosition(zoom: zoomLevel);

    await controller.followMyLocation(
      CameraPerspective.tilted,
      zoomLevel: zoomLevel,
    );

    // Wait until the zoom roughly matches the provided zoom.
    camera = await waitForValueMatchingPredicate(
      $,
      getPosition,
      checkZoomMatch,
    );
    expect(camera, isNotNull, reason: 'Zoom timeout');
    expect(camera!.zoom, closeTo(zoomLevel, 0.01), reason: 'Zoom mismatch');

    oldTarget = camera.target;
    oldZoom = camera.zoom;

    // 7. Test camera move after followMyLocation.
    // Note: We skip testing stoppedFollowingMyLocation event here because
    // showRouteOverview() leaves the SDK's internal follow state inconsistent.
    resetCameraEventCompleters();

    // Stop followMyLocation.
    final CameraUpdate positionUpdate = CameraUpdate.newLatLng(
      LatLng(
        latitude: oldTarget.latitude + 0.5,
        longitude: oldTarget.longitude + 0.5,
      ),
    );
    await controller.moveCamera(positionUpdate);

    // Wait for cameraIdleEvent before doing doing the tests.
    await cameraIdleCompleter.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        fail('Future timed out');
      },
    );
    camera = await controller.getCameraPosition();

    // 8. Test cameraMoveStarted, cameraMove and cameraIdle events.
    await GoogleMapsNavigator.simulator.pauseSimulation();
    camera = await controller.getCameraPosition();
    resetCameraEventCompleters();

    final LatLng newTarget = LatLng(
      latitude: camera.target.latitude + 0.5,
      longitude: camera.target.longitude + 0.5,
    );

    // Define the target position.
    expectedPosition = CameraPosition(target: newTarget);
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(newTarget);

    // Move camera and wait for cameraMoveStarted, cameraMove
    // and cameraIdle events to come in.
    await controller.moveCamera(cameraUpdate);
    await waitForCameraEvents($);

    // Test that cameraMoveStartedEvent position coordinates are close to the start coordinates
    // and that the other values match within tolerance.
    // Skipped on iOS, because the received position is often the end position
    // instead of the start position. Bug in native SDK.
    if (Platform.isAndroid) {
      checkCameraCoordinatesMatch(cameraMoveStartedPosition, camera);
      expect(
        cameraMoveStartedPosition.bearing,
        closeTo(camera.bearing, 30),
        reason: 'Bearing mismatch',
      );
      expect(
        cameraMoveStartedPosition.tilt,
        camera.tilt,
        reason: 'Tilt mismatch',
      );
      expect(
        cameraMoveStartedPosition.zoom,
        closeTo(camera.zoom, 0.1),
        reason: 'Zoom mismatch',
      );
    }

    // Test that cameraMoveEvent position coordinates are between the start and the end coordinates
    // and that the other values match within tolerance.
    const double tolerance = 0.01;
    expect(
      cameraMovePosition.target.latitude,
      greaterThanOrEqualTo(camera.target.latitude - tolerance),
      reason: 'Latitude below range',
    );
    expect(
      cameraMovePosition.target.latitude,
      lessThanOrEqualTo(expectedPosition.target.latitude + tolerance),
      reason: 'Latitude above range',
    );
    expect(
      cameraMovePosition.target.longitude,
      greaterThanOrEqualTo(camera.target.longitude - tolerance),
      reason: 'Longitude below range',
    );
    expect(
      cameraMovePosition.target.longitude,
      lessThanOrEqualTo(expectedPosition.target.longitude + tolerance),
      reason: 'Longitude above range',
    );
    expect(
      cameraMovePosition.bearing,
      closeTo(camera.bearing, 30),
      reason: 'Bearing mismatch',
    );
    expect(cameraMovePosition.tilt, camera.tilt, reason: 'Tilt mismatch');
    expect(
      cameraMovePosition.zoom,
      closeTo(camera.zoom, 0.1),
      reason: 'Zoom mismatch',
    );

    // Test that cameraIdleEvent position coordinates are close to the provided coordinates
    // and that the other values match within tolerance.
    checkCameraCoordinatesMatch(cameraIdlePosition, expectedPosition);
    expect(
      cameraIdlePosition.bearing,
      closeTo(camera.bearing, 30),
      reason: 'Bearing mismatch',
    );
    expect(cameraIdlePosition.tilt, camera.tilt, reason: 'Tilt mismatch');
    expect(
      cameraIdlePosition.zoom,
      closeTo(camera.zoom, 0.1),
      reason: 'Zoom mismatch',
    );
  });

  patrol(
    'Test moveCamera() and animateCamera() with various options',
    (PatrolIntegrationTester $) async {
      // Reset state for test isolation when running tests sequentially.
      resetCameraFollowingState();
      resetCameraEventCompleters();

      const double startLat = startLocationLat + 1;
      const double startLng = startLocationLng + 1;
      const LatLng target = LatLng(
        latitude: startLat + 1,
        longitude: startLng + 1,
      );

      final CameraUpdate start = CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(latitude: startLat, longitude: startLng),
          zoom: 9,
        ),
      );

      /// Initialize view with the event listener functions.
      final GoogleMapViewController viewController =
          await getMapViewControllerForTestMapType(
            $,
            testMapType: mapTypeVariants.currentValue!,
            initializeNavigation: false,
            simulateLocation: false,
            onCameraIdle: onCameraIdle,
          );
      // Move camera back to the start.
      Future<void> moveCameraToStart() async {
        resetCameraEventCompleters();
        await viewController.moveCamera(start);
        await cameraIdleCompleter.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            fail('Future timed out');
          },
        );
      }

      // Move camera to the start position.
      await moveCameraToStart();

      // Create a wrapper for moveCamera() that waits until the move is finished.
      Future<void> moveCamera(CameraUpdate update) async {
        resetCameraEventCompleters();
        await viewController.moveCamera(update);
        await cameraIdleCompleter.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            fail('Future timed out');
          },
        );
      }

      // Create a wrapper for animateCamera() that waits until move is finished
      // using cameraIdle event on iOS and onFinished listener on Android.
      Future<void> animateCamera(CameraUpdate update) async {
        resetCameraEventCompleters();

        // Create onFinished callback function that is used on Android
        // to test that the callback comes in.
        void onFinished(bool finished) {
          expect(finished, true, reason: 'Animation not finished');
        }

        // Animate camera to the set position with reduced duration.
        await viewController.animateCamera(
          update,
          duration: const Duration(milliseconds: 50),
          onFinished: onFinished,
        );

        // Wait until the cameraIdle event comes in.
        await cameraIdleCompleter.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            fail('Future timed out');
          },
        );
      }

      final List<Future<void> Function(CameraUpdate update)> cameraMethods =
          <Future<void> Function(CameraUpdate update)>[
            moveCamera,
            animateCamera,
          ];

      final CameraUpdate updateCameraPosition = CameraUpdate.newCameraPosition(
        const CameraPosition(bearing: 5, target: target, tilt: 30, zoom: 20.0),
      );

      // Test the CameraUpdate.newCameraPosition() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateCameraPosition);

        // Test that the camera position matches the provided position.
        checkCameraCoordinatesMatch(
          cameraIdlePosition,
          updateCameraPosition.cameraPosition!,
        );
        expect(
          cameraIdlePosition.bearing,
          closeTo(updateCameraPosition.cameraPosition!.bearing, 0.1),
          reason: 'Bearing mismatch',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(updateCameraPosition.cameraPosition!.tilt, 0.1),
          reason: 'Tilt mismatch',
        );
        expect(
          cameraIdlePosition.zoom,
          closeTo(updateCameraPosition.cameraPosition!.zoom, 0.1),
          reason: 'Zoom mismatch',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateNewLatLng = CameraUpdate.newLatLng(target);

      // Test the CameraUpdate.newLatLng() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateNewLatLng);

        // Test that the camera target matches the provided target.
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(updateNewLatLng.latLng!.latitude, latLngTestThreshold),
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(updateNewLatLng.latLng!.longitude, latLngTestThreshold),
          reason: 'Longitude mismatch',
        );

        // Test that the other values haven't changed
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed',
        );
        expect(
          cameraIdlePosition.zoom,
          closeTo(start.cameraPosition!.zoom, 0.1),
          reason: 'Zoom changed',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateLatLngBounds = CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: target,
          northeast: LatLng(
            latitude: target.latitude + 1,
            longitude: target.longitude + 1,
          ),
        ),
      );

      // Test the CameraUpdate.newLatLngBounds() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateLatLngBounds);

        // Test that the camera target matches the centre of the LatLngBounds.
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(
            updateLatLngBounds.bounds!.center.latitude,
            latLngTestThreshold,
          ),
          reason: 'Latitude mismatch with bounds center',
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(
            updateLatLngBounds.bounds!.center.longitude,
            latLngTestThreshold,
          ),
          reason: 'Longitude mismatch with bounds center',
        );

        // Test that the other values, excluding zoom, haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateLatLngZoom = CameraUpdate.newLatLngZoom(
        target,
        12,
      );

      // Test the CameraUpdate.newLatLngZoom() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateLatLngZoom);

        // Test that the camera target and zoom match the provided target and zoom.
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(target.latitude, latLngTestThreshold),
          reason: 'Latitude mismatch',
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(target.longitude, latLngTestThreshold),
          reason: 'Longitude mismatch',
        );
        expect(
          cameraIdlePosition.zoom,
          closeTo(updateLatLngZoom.zoom!, 0.1),
          reason: 'Zoom mismatch',
        );

        // Test that the the other values haven't changed
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed',
        );

        await moveCameraToStart();
      }

      // Scroll to the northeast.
      final CameraUpdate updateScrollBy = CameraUpdate.scrollBy(300, -300);

      // Test the CameraUpdate.scrollBy() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateScrollBy);

        // Test that the camera position has moved to the northeast.
        expect(
          cameraIdlePosition.target.latitude,
          greaterThan(start.cameraPosition!.target.latitude),
          reason: 'Latitude did not increase',
        );
        expect(
          cameraIdlePosition.target.longitude,
          greaterThan(start.cameraPosition!.target.longitude),
          reason: 'Longitude did not increase',
        );

        // Test that the the other values haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed',
        );
        expect(
          cameraIdlePosition.zoom,
          closeTo(start.cameraPosition!.zoom, 0.1),
          reason: 'Zoom changed',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateZoomByAmount = CameraUpdate.zoomBy(
        5,
        focus: const Offset(50, 50),
      );

      // Test the CameraUpdate.zoomBy() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateZoomByAmount);

        // Test that the [focus] parameter caused the camera position to change.
        expect(
          cameraIdlePosition.target.latitude,
          isNot(closeTo(target.latitude, latLngTestThreshold)),
          reason: 'Focus did not shift lat',
        );
        expect(
          cameraIdlePosition.target.longitude,
          isNot(closeTo(target.longitude, latLngTestThreshold)),
          reason: 'Focus did not shift lng',
        );

        // Test that the zoom has changed to the specified value.
        expect(
          cameraIdlePosition.zoom,
          closeTo(
            start.cameraPosition!.zoom + updateZoomByAmount.zoomByAmount!,
            0.1,
          ),
          reason: 'Zoom mismatch',
        );

        // Test that the other values haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateZoomIn = CameraUpdate.zoomIn();

      // Test the CameraUpdate.zoomIn() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateZoomIn);

        // Test that the zoom has changed to the specified value.
        expect(
          cameraIdlePosition.zoom,
          closeTo(start.cameraPosition!.zoom + updateZoomIn.zoomByAmount!, 0.1),
          reason: 'Zoom mismatch after zoomIn',
        );

        // Test that the other values haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(start.cameraPosition!.target.latitude, latLngTestThreshold),
          reason: 'Latitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(start.cameraPosition!.target.longitude, latLngTestThreshold),
          reason: 'Longitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed unexpectedly',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateZoomOut = CameraUpdate.zoomOut();

      // Test the CameraUpdate.zoomOut() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateZoomOut);

        // Test that the zoom has changed to the specified value.
        expect(
          cameraIdlePosition.zoom,
          closeTo(
            start.cameraPosition!.zoom + updateZoomOut.zoomByAmount!,
            0.1,
          ),
          reason: 'Zoom mismatch after zoomOut',
        );

        // Test that the target and camera tilt haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(start.cameraPosition!.target.latitude, latLngTestThreshold),
          reason: 'Latitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(start.cameraPosition!.target.longitude, latLngTestThreshold),
          reason: 'Longitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed unexpectedly',
        );

        await moveCameraToStart();
      }

      final CameraUpdate updateZoomTo = CameraUpdate.zoomTo(11);

      // Test the CameraUpdate.zoomBy() with moveCamera and animateCamera commands.
      for (final Future<void> Function(CameraUpdate update) cameraMethod
          in cameraMethods) {
        await cameraMethod(updateZoomTo);

        // Test that the zoom has changed to the specified value.
        expect(
          cameraIdlePosition.zoom,
          closeTo(updateZoomTo.zoom!, 0.1),
          reason: 'Zoom mismatch after zoomTo',
        );

        // Test that the target and camera tilt haven't changed.
        expect(
          cameraIdlePosition.bearing,
          closeTo(start.cameraPosition!.bearing, 0.1),
          reason: 'Bearing changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.latitude,
          closeTo(start.cameraPosition!.target.latitude, latLngTestThreshold),
          reason: 'Latitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.target.longitude,
          closeTo(start.cameraPosition!.target.longitude, latLngTestThreshold),
          reason: 'Longitude changed unexpectedly',
        );
        expect(
          cameraIdlePosition.tilt,
          closeTo(start.cameraPosition!.tilt, 0.1),
          reason: 'Tilt changed unexpectedly',
        );

        await moveCameraToStart();
      }
    },
    variant: mapTypeVariants,
  );
}
