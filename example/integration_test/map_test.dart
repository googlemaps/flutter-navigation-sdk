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
  patrolTest('Test map types', (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    final GoogleNavigationViewController viewController =
        await viewControllerCompleter.future;

    // Test default type.
    expect(await viewController.getMapType(), MapType.normal);

    final List<MapType> types = <MapType>[
      MapType.satellite,
      MapType.terrain,
      MapType.hybrid,
      MapType.normal,
    ];

    for (final MapType type in types) {
      await viewController.setMapType(mapType: type);
      expect(await viewController.getMapType(), type);
    }
  });

  patrolTest('Test platform view creation params',
      (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> controllerCompleter =
        Completer<GoogleNavigationViewController>();

    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        initialMapType: MapType.hybrid,
        initialCompassEnabled: false,
        initialRotateGesturesEnabled: false,
        initialScrollGesturesEnabled: false,
        initialTiltGesturesEnabled: false,
        initialZoomGesturesEnabled: false,
        initialZoomControlsEnabled: false,
        initialScrollGesturesEnabledDuringRotateOrZoom: false,
        initialMapToolbarEnabled: false,
        onViewCreated: (GoogleNavigationViewController viewController) {
          controllerCompleter.complete(viewController);
        },
      ),
    );

    final GoogleNavigationViewController controller =
        await controllerCompleter.future;

    /// Test the value initialization succeeded
    expect(await controller.getMapType(), MapType.hybrid);
    expect(await controller.settings.isCompassEnabled(), false);
    expect(await controller.settings.isRotateGesturesEnabled(), false);
    expect(await controller.settings.isScrollGesturesEnabled(), false);
    expect(await controller.settings.isTiltGesturesEnabled(), false);
    expect(await controller.settings.isZoomGesturesEnabled(), false);
    expect(
        await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
        false);

    if (Platform.isAndroid) {
      expect(await controller.settings.isZoomControlsEnabled(), false);
      expect(await controller.settings.isMapToolbarEnabled(), false);
    }
  });

  patrolTest('Test map UI settings', (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> controllerCompleter =
        Completer<GoogleNavigationViewController>();

    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController viewController) {
          controllerCompleter.complete(viewController);
        },
      ),
    );

    final GoogleNavigationViewController controller =
        await controllerCompleter.future;

    /// Test the default values match with what has been documented in the
    /// API documentation in google_maps_navigation.dart file.
    expect(await controller.isMyLocationEnabled(), false);
    expect(await controller.settings.isMyLocationButtonEnabled(), true);
    expect(await controller.settings.isZoomGesturesEnabled(), true);
    expect(await controller.settings.isCompassEnabled(), true);
    expect(await controller.settings.isRotateGesturesEnabled(), true);
    expect(await controller.settings.isScrollGesturesEnabled(), true);
    expect(
        await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
        true);
    expect(await controller.settings.isTiltGesturesEnabled(), true);

    final List<bool> results = <bool>[true, false, true];
    for (final bool result in results) {
      await controller.enableMyLocation(enabled: result);
      expect(await controller.isMyLocationEnabled(), result);

      await controller.settings.enableMyLocationButton(enabled: result);
      expect(await controller.settings.isMyLocationButtonEnabled(), result);

      await controller.settings.enableZoomGestures(enabled: result);
      expect(await controller.settings.isZoomGesturesEnabled(), result);

      await controller.settings.enableCompass(enabled: result);
      expect(await controller.settings.isCompassEnabled(), result);

      await controller.settings.enableRotateGestures(enabled: result);
      expect(await controller.settings.isRotateGesturesEnabled(), result);

      await controller.settings.enableScrollGestures(enabled: result);
      expect(await controller.settings.isScrollGesturesEnabled(), result);

      await controller.settings
          .enableScrollGesturesDuringRotateOrZoom(enabled: result);
      expect(
          await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
          result);

      await controller.settings.enableTiltGestures(enabled: result);
      expect(await controller.settings.isTiltGesturesEnabled(), result);

      await controller.settings.enableTraffic(enabled: result);
      expect(await controller.settings.isTrafficEnabled(), result);

      if (Platform.isAndroid) {
        await controller.settings.enableZoomControls(enabled: result);
        expect(await controller.settings.isZoomControlsEnabled(), result);
      }
    }

    // Test methods not supported on iOS
    if (Platform.isIOS) {
      try {
        await controller.settings.isZoomControlsEnabled();
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
      try {
        await controller.settings.enableZoomControls(enabled: true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
      try {
        await controller.settings.isMapToolbarEnabled();
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
      try {
        await controller.settings.enableMapToolbar(enabled: true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
    }
  });

  patrolTest('Test map style', (PatrolIntegrationTester $) async {
    final Completer<GoogleNavigationViewController> viewControllerCompleter =
        Completer<GoogleNavigationViewController>();

    await checkLocationDialogAcceptance($);

    /// Display navigation view.
    final Key key = GlobalKey();
    await pumpNavigationView(
      $,
      GoogleMapsNavigationView(
        key: key,
        onViewCreated: (GoogleNavigationViewController controller) {
          viewControllerCompleter.complete(controller);
        },
      ),
    );

    final GoogleNavigationViewController viewController =
        await viewControllerCompleter.future;

    // Test that valid json doens't throw exception.
    await viewController.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#ffffff"}]}]');

    // Test that null value doens't throw exception.
    await viewController.setMapStyle(null);

    // Test that invalid json throws exception.
    try {
      await viewController.setMapStyle('not_json');
      fail('expected to get MapStyleException');
    } on MapStyleException catch (e) {
      expect(e, isNotNull);
    }
  });
}
