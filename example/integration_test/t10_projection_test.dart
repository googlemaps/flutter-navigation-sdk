// Copyright 2026 Google LLC
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

import 'shared.dart';

/// Tolerance for projection round-trip tests.
///
/// This tolerance accounts for precision loss during coordinate conversion,
/// particularly on Android where `android.graphics.Point` uses `int` (not `double`)
/// for X and Y screen coordinates, causing rounding during the conversion.
const double projectionTolerance = 0.001;

void main() {
  final mapTypeVariants = getMapTypeVariants();
  Completer<void> cameraIdleCompleter = Completer<void>();

  void onCameraIdle(CameraPosition position) {
    if (!cameraIdleCompleter.isCompleted) {
      cameraIdleCompleter.complete();
    }
  }

  void resetCameraIdleCompleter() {
    cameraIdleCompleter = Completer<void>();
  }

  patrol('Test projection round-trip conversion', (
    PatrolIntegrationTester $,
  ) async {
    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
          $,
          testMapType: mapTypeVariants.currentValue!,
          initializeNavigation: false,
          simulateLocation: false,
          onCameraIdle: onCameraIdle,
        );

    // Move camera to a known position with no tilt for accurate projection
    const LatLng targetLatLng = LatLng(
      latitude: startLocationLat,
      longitude: startLocationLng,
    );
    final CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
      const CameraPosition(target: targetLatLng, zoom: 15, tilt: 0, bearing: 0),
    );

    resetCameraIdleCompleter();
    await viewController.moveCamera(cameraUpdate);
    await cameraIdleCompleter.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        fail('Camera move timed out');
      },
    );

    // Test round-trip: LatLng -> ScreenCoordinate -> LatLng
    const LatLng originalLatLng = targetLatLng;

    // Convert LatLng to ScreenCoordinate
    final ScreenCoordinate screenCoord = await viewController
        .getScreenCoordinate(originalLatLng);

    // Convert back to LatLng
    final LatLng convertedLatLng = await viewController.getLatLng(screenCoord);

    // The converted LatLng should be very close to the original
    expect(
      convertedLatLng.latitude,
      closeTo(originalLatLng.latitude, projectionTolerance),
    );
    expect(
      convertedLatLng.longitude,
      closeTo(originalLatLng.longitude, projectionTolerance),
    );
  }, variant: mapTypeVariants);

  patrol('Test projection with different camera positions', (
    PatrolIntegrationTester $,
  ) async {
    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
          $,
          testMapType: mapTypeVariants.currentValue!,
          initializeNavigation: false,
          simulateLocation: false,
          onCameraIdle: onCameraIdle,
        );

    // Test with different zoom levels
    final List<double> zoomLevels = <double>[5, 10, 15, 18];

    for (final double zoom in zoomLevels) {
      const LatLng targetLatLng = LatLng(
        latitude: startLocationLat,
        longitude: startLocationLng,
      );
      final CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(
        CameraPosition(target: targetLatLng, zoom: zoom, tilt: 0, bearing: 0),
      );

      resetCameraIdleCompleter();
      await viewController.moveCamera(cameraUpdate);
      await cameraIdleCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          fail('Camera move timed out at zoom $zoom');
        },
      );

      // Get screen coordinate for center
      final ScreenCoordinate screenCoord = await viewController
          .getScreenCoordinate(targetLatLng);

      // Convert back and verify round-trip
      final LatLng convertedLatLng = await viewController.getLatLng(
        screenCoord,
      );

      expect(
        convertedLatLng.latitude,
        closeTo(targetLatLng.latitude, projectionTolerance),
        reason: 'Latitude should match at zoom $zoom',
      );
      expect(
        convertedLatLng.longitude,
        closeTo(targetLatLng.longitude, projectionTolerance),
        reason: 'Longitude should match at zoom $zoom',
      );
    }
  }, variant: mapTypeVariants);
}
