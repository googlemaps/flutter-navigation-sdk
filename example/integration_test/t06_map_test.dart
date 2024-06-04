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
  patrol('Test map types', (PatrolIntegrationTester $) async {
    /// Set up navigation.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

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

  patrol('Test platform view creation params',
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

  patrol('Test map UI settings', (PatrolIntegrationTester $) async {
    /// The events are not tested because there's currently no reliable way to trigger them.
    void onMyLocationButtonClicked(MyLocationButtonClickedEvent event) {
      debugPrint('My location button clicked event: currently $event');
    }

    /// The events are not tested because there's no reliable way to trigger them currently.
    void onMyLocationClicked(MyLocationClickedEvent event) {
      debugPrint('My location clicked event: currently $event');
    }

    /// The events are not tested because there's no reliable way to trigger them currently.
    void onMapLongClicked(LatLng coordinates) {
      debugPrint(
          'Map clicked event lat: ${coordinates.latitude}, lng: ${coordinates.longitude}.');
    }

    /// Set up navigation without initialization to test isMyLocationEnabled
    /// is false before initialization is done. Test the onMapClicked event
    /// and setting the other callback functions.
    final GoogleNavigationViewController controller =
        await startNavigationWithoutDestination(
      $,
      initializeNavigation: false,
      onMapClicked: expectAsync1((LatLng msg) {
        expectSync(msg, isA<LatLng>());
      }, max: 1),
      onMapLongClicked: onMapLongClicked,
      onMyLocationButtonClicked: onMyLocationButtonClicked,
      onMyLocationClicked: onMyLocationClicked,
    );

    /// Test that the onMapClicked event comes in.
    await $.native.tapAt(const Offset(0.5, 0.5));

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
    if (Platform.isAndroid) {
      expect(await controller.settings.isMapToolbarEnabled(), true);
    }

    final List<bool> results = <bool>[true, false, true];
    for (final bool result in results) {
      await controller.setMyLocationEnabled(result);
      expect(await controller.isMyLocationEnabled(), result);

      await controller.settings.setMyLocationButtonEnabled(result);
      expect(await controller.settings.isMyLocationButtonEnabled(), result);

      await controller.settings.setZoomGesturesEnabled(result);
      expect(await controller.settings.isZoomGesturesEnabled(), result);

      await controller.settings.setCompassEnabled(result);
      expect(await controller.settings.isCompassEnabled(), result);

      await controller.settings.setRotateGesturesEnabled(result);
      expect(await controller.settings.isRotateGesturesEnabled(), result);

      await controller.settings.setScrollGesturesEnabled(result);
      expect(await controller.settings.isScrollGesturesEnabled(), result);

      await controller.settings
          .setScrollGesturesDuringRotateOrZoomEnabled(result);
      expect(
          await controller.settings.isScrollGesturesEnabledDuringRotateOrZoom(),
          result);

      await controller.settings.setTiltGesturesEnabled(result);
      expect(await controller.settings.isTiltGesturesEnabled(), result);

      await controller.settings.setTrafficEnabled(result);
      expect(await controller.settings.isTrafficEnabled(), result);

      if (Platform.isAndroid) {
        await controller.settings.setZoomControlsEnabled(result);
        expect(await controller.settings.isZoomControlsEnabled(), result);

        await controller.settings.setMapToolbarEnabled(result);
        expect(await controller.settings.isMapToolbarEnabled(), result);
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
        await controller.settings.setZoomControlsEnabled(true);
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
        await controller.settings.setMapToolbarEnabled(true);
        fail('Expected to get UnsupportedError');
      } on Object catch (e) {
        expect(e, const TypeMatcher<UnsupportedError>());
      }
    }
  });

  patrol('Test map style', (PatrolIntegrationTester $) async {
    /// Set up navigation.
    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

    // Test that valid json doens't throw exception.
    await viewController.setMapStyle(
        '[{"elementType":"geometry","stylers":[{"color":"#ffffff"}]}]');

    // Test that null value doesn't throw exception.
    await viewController.setMapStyle(null);

    // Test that invalid json throws exception.
    try {
      await viewController.setMapStyle('not_json');
      fail('expected to get MapStyleException');
    } on MapStyleException catch (e) {
      expect(e, isNotNull);
    }
  });

  patrol('Test min max zoom level', (PatrolIntegrationTester $) async {
    /// For some reason the functionality works on Android example app, but it doesn't work
    /// during the testing. Will skip Android testing for now.
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

    // Test that valid zoom values don't throw exception.
    await viewController.setMinZoomPreference(10);
    await viewController.setMaxZoomPreference(11);

    // Test that min max values were changed.
    double newMinZoomPreference = await viewController.getMinZoomPreference();
    double newMaxZoomPreference = await viewController.getMaxZoomPreference();

    expect(newMinZoomPreference, 10.0);
    expect(newMaxZoomPreference, 11.0);

    // Reset zoom limits.
    await viewController.resetMinMaxZoomPreference();

    // Test that min max values were reset.
    final double resetedMinZoom = await viewController.getMinZoomPreference();
    final double resetedMaxZoom = await viewController.getMaxZoomPreference();

    expect(resetedMinZoom, isNot(10.0));
    expect(resetedMaxZoom, isNot(11.0));

    // Test that invalid value throws exception.
    try {
      await viewController.setMinZoomPreference(40);
      fail('expected to get ZoomPreferenceException');
    } on MinZoomRangeException catch (e) {
      expect(e, isNotNull);
    }
    try {
      await viewController.setMaxZoomPreference(1);
      fail('expected to get ZoomPreferenceException');
    } on MaxZoomRangeException catch (e) {
      expect(e, isNotNull);
    }

    // Try to set out of bounds values.
    await viewController.setMinZoomPreference(0);
    await viewController.setMaxZoomPreference(50);

    newMinZoomPreference = await viewController.getMinZoomPreference();
    newMaxZoomPreference = await viewController.getMaxZoomPreference();

    // Expect the same values. The actual zoom level will be limited by the map.
    expect(newMinZoomPreference, 0.0);
    expect(newMaxZoomPreference, 50.0);
  });
}
