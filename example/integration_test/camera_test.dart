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
  Future<void> checkCameraFollowsLocation(
      CameraPosition camera, GoogleNavigationViewController controller) async {
    // Check the camera location is close to my location (locationThreshold = ~200m)
    final LatLng? myLocation = await controller.getMyLocation();
    expect(myLocation, isNotNull);
    expect(camera.target.latitude, closeTo(myLocation!.latitude, 0.02));
    expect(camera.target.longitude, closeTo(myLocation.longitude, 0.02));
  }

  patrolTest('Test camera modes', (PatrolIntegrationTester $) async {
    /// Initialize navigation.
    final GoogleNavigationViewController controller = await startNavigation($);

    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    await controller.followMyLocation(CameraPerspective.tilted);

    double distanceToNorth(double angle) {
      final double diff = (angle + 180) % 360 - 180;
      return (diff < -180 ? diff + 360 : diff).abs();
    }

    // 1. Test default.
    //
    // The navigation follows the user's location in tilted mode.
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));
    CameraPosition camera = await controller.getCameraPosition();

    debugPrint('Default tilt: ${camera.tilt}');
    debugPrint('Default zoom: ${camera.zoom}');
    debugPrint('Default bearing: ${camera.bearing}');

    // Verify that the follow my locate camera mode is active.
    await checkCameraFollowsLocation(camera, controller);

    // Strong tilting (Android 45, iOS 55 degrees)
    expect(camera.tilt, greaterThanOrEqualTo(40));

    // Zoomed map (Android 18, iOS 17.25)
    expect(camera.zoom, greaterThanOrEqualTo(16));

    LatLng oldTarget = camera.target;
    double oldZoom = camera.zoom;

    // 2. Test CameraPerspective.topDownHeadingUp.
    await controller.followMyLocation(CameraPerspective.topDownHeadingUp);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    camera = await controller.getCameraPosition();

    debugPrint('topDownHeadingUp tilt: ${camera.tilt}');
    debugPrint('topDownHeadingUp zoom: ${camera.zoom}');
    debugPrint('topDownHeadingUp bearing: ${camera.bearing}');

    // Verify that the follow my locate camera mode is active.
    await checkCameraFollowsLocation(camera, controller);

    // No tilt when top-down.
    expect(camera.tilt, lessThanOrEqualTo(0.1));

    // The camera target should have moved.
    expect(camera.target != oldTarget, true);

    oldTarget = camera.target;

    // 3. Test CameraPerspective.topDownNorthUp
    await controller.followMyLocation(CameraPerspective.topDownNorthUp);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    camera = await controller.getCameraPosition();

    debugPrint('topDownNorthUp tilt: ${camera.tilt}');
    debugPrint('topDownNorthUp zoom: ${camera.zoom}');
    debugPrint('topDownNorthUp bearing: ${camera.bearing}');

    // Verify that the follow my locate camera mode is active.
    await checkCameraFollowsLocation(camera, controller);

    // No tilt when top-down.
    expect(camera.tilt, lessThanOrEqualTo(0.1));

    // Expect zoom to be farther.
    expect(oldZoom, greaterThanOrEqualTo(camera.zoom));

    // North-up means zero bearing.
    // iOS reports 0 degrees, Android is more fuzzy e.g. 359.7 degrees.
    expect(distanceToNorth(camera.bearing), lessThanOrEqualTo(2.0));

    // The camera target should have moved again.
    expect(camera.target != oldTarget, true);

    oldTarget = camera.target;

    // 4. Test CameraPerspective.tilted
    await controller.followMyLocation(CameraPerspective.tilted);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    camera = await controller.getCameraPosition();

    debugPrint('tilted tilt: ${camera.tilt}');
    debugPrint('tilted zoom: ${camera.zoom}');
    debugPrint('tilted bearing: ${camera.bearing}');

    // Verify that the follow my locate camera mode is active.
    await checkCameraFollowsLocation(camera, controller);

    // Repeat tests done with the default state above
    expect(camera.tilt, greaterThanOrEqualTo(40));
    expect(camera.zoom, greaterThanOrEqualTo(16));
    expect(distanceToNorth(camera.bearing), greaterThanOrEqualTo(0.01));

    // The camera target should have moved again.
    expect(camera.target != oldTarget, true);

    oldTarget = camera.target;
    oldZoom = camera.zoom;

    // 5. Test showRouteOverview().
    await controller.showRouteOverview();
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    camera = await controller.getCameraPosition();

    debugPrint('showRouteOverview tilt: ${camera.tilt}');
    debugPrint('showRouteOverview zoom: ${camera.zoom}');
    debugPrint('showRouteOverview bearing: ${camera.bearing}');

    // No tilt when in route overview.
    expect(camera.tilt, lessThanOrEqualTo(0.1));

    // Expect zoom to be farthest away.
    expect(oldZoom, greaterThanOrEqualTo(camera.zoom));

    // Route is shown north up.
    expect(distanceToNorth(camera.bearing), lessThanOrEqualTo(1.0));

    // The camera target should have moved again.
    expect(camera.target != oldTarget, true);

    // 6. Test  the optional follow my location parameter zoom level
    const double zoomLevel = 8.5;
    await controller.followMyLocation(CameraPerspective.tilted,
        zoomLevel: zoomLevel);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));
    camera = await controller.getCameraPosition();
    expect(camera.zoom, closeTo(zoomLevel, 0.01));
  });

  patrolTest(
      'Test using the recenter button to move the camera during navigation',
      (PatrolIntegrationTester $) async {
    /// Initialize navigation.
    final GoogleNavigationViewController controller = await startNavigation($);
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    // Reset the camera to my location.
    await controller.followMyLocation(CameraPerspective.tilted);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    // Check the camera location is close to my location
    CameraPosition camera = await controller.getCameraPosition();
    await checkCameraFollowsLocation(camera, controller);

    // Check the re-center button is enabled
    final bool isEnabled = await controller.isRecenterButtonEnabled();
    expect(isEnabled, true);

    /// Move camera away to reveal the re-center button.
    final CameraUpdate updateCameraPosition =
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
      latitude: camera.target.latitude + 0.2,
      longitude: camera.target.longitude + 0.2,
    )));
    await controller.moveCamera(updateCameraPosition);
    await $.pumpAndSettle(duration: const Duration(milliseconds: 500));

    // Verify the distance is considerable 0.05 ~= 5.6km
    camera = await controller.getCameraPosition();
    final LatLng? myLocation = await controller.getMyLocation();
    expect(myLocation, isNotNull);
    expect(camera.target.latitude - myLocation!.latitude, greaterThan(0.05));
    expect(camera.target.longitude - myLocation.longitude, greaterThan(0.05));

    // Tap the button to re-center the camera to my location.
    if (Platform.isAndroid) {
      await $.native.tap(Selector(text: 'Re-center'));
    } else if (Platform.isIOS) {
      await $.native.tap(Selector(text: 'RE-CENTER'));
    } else {
      fail('Unsupported platform: ${Platform.operatingSystem}');
    }
    await $.pumpAndSettle(duration: const Duration(milliseconds: 3000));

    /// Verify the camera matches my location again.
    camera = await controller.getCameraPosition();
    await checkCameraFollowsLocation(camera, controller);
  });
}
