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
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'shared.dart';

void main() {
  final mapTypeVariants = getMapTypeVariants();
  patrol('Marker tests', (PatrolIntegrationTester $) async {
    void onMarkerClicked(String event) {
      debugPrint('Marker clicked event: $event.');
    }

    /// The events are not tested because there's currently no reliable way to trigger them.
    void onMarkerDrag(String event, LatLng coordinates) {
      debugPrint('Marker dragged event: $event. Coorinates: $coordinates.');
    }

    /// The events are not tested because there's currently no reliable way to trigger them.
    void onMarkerInfoWindowAction(String event) {
      debugPrint('Marker dragged event: $event.');
    }

    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
      $,
      testMapType: mapTypeVariants.currentValue!,
      onMarkerClicked: onMarkerClicked,
      onMarkerDrag: onMarkerDrag,
      onMarkerDragEnd: onMarkerDrag,
      onMarkerDragStart: onMarkerDrag,
      onMarkerInfoWindowClicked: onMarkerInfoWindowAction,
      onMarkerInfoWindowClosed: onMarkerInfoWindowAction,
      onMarkerInfoWindowLongClicked: onMarkerInfoWindowAction,
    );

    // markerOne options.
    const MarkerOptions markerOneOptions = MarkerOptions(
      position:
          LatLng(latitude: 60.34856639667419, longitude: 25.03459821831162),
      infoWindow: InfoWindow(
        title: 'Helsinki Office',
        snippet: 'markerOne',
      ),
    );

    // Add marker and save response to [addedMarkersList].
    final List<Marker?> addedMarkersList =
        await viewController.addMarkers(<MarkerOptions>[markerOneOptions]);
    expect(addedMarkersList.length, 1);
    final Marker? addedMarker = addedMarkersList.first;

    // Get markers and save them to [getMarkerList].
    final List<Marker?> getMarkersList = await viewController.getMarkers();
    expect(getMarkersList.length, 1);
    final Marker? getMarker = getMarkersList.first;

    List<Marker> markers = <Marker>[addedMarker!, getMarker!];

    /// Test MarkerOptions default values against addedMarker and getMarkers responses.
    for (final Marker marker in markers) {
      expect(marker.options.alpha, 1.0);
      expect(marker.options.anchor.u, 0.5);
      expect(marker.options.anchor.v, 1.0);
      expect(marker.options.draggable, false);
      expect(marker.options.flat, false);
      expect(marker.options.icon, ImageDescriptor.defaultImage);
      expect(marker.options.consumeTapEvents, false);
      expect(marker.options.position, markerOneOptions.position);
      expect(marker.options.rotation, 0.0);
      expect(
          marker.options.infoWindow.title, markerOneOptions.infoWindow.title);
      expect(marker.options.infoWindow.snippet,
          markerOneOptions.infoWindow.snippet);
      expect(marker.options.infoWindow.anchor.u, 0.5);
      expect(marker.options.infoWindow.anchor.v, 0.0);
      expect(marker.options.visible, true);
      expect(marker.options.zIndex, 0.0);
    }

    /// Create a marker icon.
    final ByteData imageBytes = await rootBundle.load('assets/marker1.png');
    final ImageDescriptor customIcon =
        await registerBitmapImage(bitmap: imageBytes, imagePixelRatio: 2);

    // markerTwo options.
    final MarkerOptions markerTwoOptions = MarkerOptions(
      alpha: 0.5,
      anchor: const MarkerAnchor(u: 0.1, v: 0.2),
      draggable: true,
      flat: true,
      icon: customIcon,
      consumeTapEvents: true,
      position: const LatLng(
          latitude: 65.01193816057041, longitude: 25.46790635614996),
      rotation: 70,
      infoWindow: const InfoWindow(
        title: 'Oulu Office',
        snippet: 'markerTwo',
        anchor: MarkerAnchor(u: 0.3, v: 0.4),
      ),
      visible: false,
      zIndex: 2,
    );

    final Marker markerTwo = addedMarker.copyWith(options: markerTwoOptions);

    // Update marker and save response.
    final List<Marker?> updatedMarkersList =
        await viewController.updateMarkers(<Marker>[markerTwo]);
    expect(updatedMarkersList.length, 1);
    final Marker? updatedMarker = updatedMarkersList.first;

    // Get updated markers and save them to [getUpdatedMarkerList].
    final List<Marker?> getUpdatedMarkersList =
        await viewController.getMarkers();
    expect(getUpdatedMarkersList.length, 1);
    final Marker? getUpdatedMarker = getUpdatedMarkersList.first;

    const double tolerance = 0.0000001;
    markers = <Marker>[updatedMarker!, getUpdatedMarker!];

    /// Test updated marker options against updateMarkers and getMarkers responses.
    for (final Marker marker in markers) {
      expect(marker.markerId, addedMarker.markerId);
      expect(marker.options.alpha, markerTwoOptions.alpha);
      expect(marker.options.anchor.u,
          closeTo(markerTwoOptions.anchor.u, tolerance));
      expect(marker.options.anchor.v,
          closeTo(markerTwoOptions.anchor.v, tolerance));
      expect(marker.options.draggable, markerTwoOptions.draggable);
      expect(marker.options.flat, markerTwoOptions.flat);
      expect(marker.options.icon, markerTwoOptions.icon);
      expect(
          marker.options.consumeTapEvents, markerTwoOptions.consumeTapEvents);
      expect(marker.options.infoWindow.anchor.u,
          closeTo(markerTwoOptions.infoWindow.anchor.u, tolerance));
      expect(marker.options.infoWindow.anchor.v,
          closeTo(markerTwoOptions.infoWindow.anchor.v, tolerance));
      expect(marker.options.position, markerTwoOptions.position);
      expect(marker.options.rotation, markerTwoOptions.rotation);
      expect(marker.options.infoWindow.snippet,
          markerTwoOptions.infoWindow.snippet);
      expect(
          marker.options.infoWindow.title, markerTwoOptions.infoWindow.title);
      expect(marker.options.visible, markerTwoOptions.visible);
      expect(marker.options.zIndex, markerTwoOptions.zIndex);
    }

    // markerThree options.
    const MarkerOptions markerThreeOptions = MarkerOptions(
      position:
          LatLng(latitude: 62.25743381335948, longitude: 25.779330148583174),
      infoWindow: InfoWindow(
        title: 'Jyväskylä',
        snippet: 'markerThree',
      ),
    );

    /// Test addMarkers() adds markers in correct order.
    final List<Marker?> removeMarkerList =
        await viewController.addMarkers(<MarkerOptions>[
      markerThreeOptions,
      markerOneOptions,
    ]);

    final List<Marker?> getRemoveMarkerList = await viewController.getMarkers();

    expect(removeMarkerList.length, 2);
    expect(removeMarkerList.first!.options.infoWindow.title, 'Jyväskylä');
    expect(removeMarkerList.last!.options.infoWindow.title, 'Helsinki Office');
    expect(getRemoveMarkerList.length, 3);
    expect(getRemoveMarkerList.first!.options.infoWindow.title, 'Oulu Office');
    expect(
        getRemoveMarkerList.last!.options.infoWindow.title, 'Helsinki Office');

    /// Test removeMarkers() removes correct markers.
    // Remove the first marker = ouluOffice marker.
    final Marker firstMarker = getRemoveMarkerList.first!;
    await viewController.removeMarkers(<Marker>[firstMarker]);
    List<Marker?> getRemovedMarkerList = await viewController.getMarkers();
    expect(getRemovedMarkerList.length, 2);
    expect(getRemovedMarkerList.first!.options.infoWindow.title, 'Jyväskylä');
    expect(
        getRemovedMarkerList.last!.options.infoWindow.title, 'Helsinki Office');

    /// Test that trying to remove or update a marker that doesn't exist
    /// throws error.
    try {
      await viewController.removeMarkers(<Marker>[firstMarker]);
      fail('Expected removeMarkers() to fail with MarkerNotFoundException.');
    } on MarkerNotFoundException catch (e) {
      expect(e, isNotNull);
    }
    try {
      await viewController.updateMarkers(<Marker>[firstMarker]);
      fail('Expected updateMarkers() to fail with MarkerNotFoundException.');
    } on MarkerNotFoundException catch (e) {
      expect(e, isNotNull);
    }

    // Remove Helsinki office marker.
    await viewController.removeMarkers(<Marker>[removeMarkerList.last!]);
    getRemovedMarkerList = await viewController.getMarkers();
    expect(getRemovedMarkerList.length, 1);
    expect(getRemovedMarkerList.first!.options.infoWindow.title, 'Jyväskylä');

    // Add two markers.
    List<Marker?> clearMarkerList = await viewController
        .addMarkers(<MarkerOptions>[markerOneOptions, markerTwoOptions]);
    List<Marker?> getClearMarkerList = await viewController.getMarkers();

    expect(clearMarkerList.length, 2);
    expect(clearMarkerList.first!.options.infoWindow.title, 'Helsinki Office');
    expect(clearMarkerList.last!.options.infoWindow.title, 'Oulu Office');
    expect(getClearMarkerList.length, 3);
    expect(getClearMarkerList.first!.options.infoWindow.title, 'Jyväskylä');
    expect(getClearMarkerList.last!.options.infoWindow.title, 'Oulu Office');

    /// Remove the middle marker and test the order stays.
    await viewController.removeMarkers(<Marker>[getClearMarkerList[1]!]);

    getClearMarkerList = await viewController.getMarkers();
    expect(getClearMarkerList.length, 2);
    expect(getClearMarkerList.first!.options.infoWindow.title, 'Jyväskylä');
    expect(getClearMarkerList.last!.options.infoWindow.title, 'Oulu Office');

    /// Test clearMarkers() function works.
    await viewController.clearMarkers();

    getClearMarkerList = await viewController.getMarkers();
    expect(getClearMarkerList, isEmpty);

    /// Test clear() function clears also markers.
    clearMarkerList = await viewController
        .addMarkers(<MarkerOptions>[markerOneOptions, markerTwoOptions]);
    getClearMarkerList = await viewController.getMarkers();
    expect(clearMarkerList.length, 2);
    expect(getClearMarkerList.length, 2);

    await viewController.clear();
    getClearMarkerList = await viewController.getMarkers();
    expect(getClearMarkerList, isEmpty);
  }, variant: mapTypeVariants);

  patrol('Test polylines', (PatrolIntegrationTester $) async {
    /// The events are not tested because there's currently no reliable way to trigger them.
    void onPolylineClicked(String event) {
      debugPrint('Polyline clicked event: $event.');
    }

    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
      $,
      testMapType: mapTypeVariants.currentValue!,
      onPolylineClicked: onPolylineClicked,
    );

    await viewController.addPolylines(
      <PolylineOptions>[
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 60.186492, longitude: 24.929471),
            LatLng(latitude: 60.286492, longitude: 25.929471)
          ],
          clickable: true,
          geodesic: true,
          strokeColor: Colors.red,
          strokeWidth: 5.0,
        ),
      ],
    );

    /// Test that received polylines match the ones that were added.
    final List<Polyline?> polylines = await viewController.getPolylines();
    expect(polylines.length, 1);
    expect(
        polylines[0]!.options.points!.first.latitude, closeTo(60.186492, 0.01));
    expect(polylines[0]!.options.points!.first.longitude,
        closeTo(24.929471, 0.01));
    expect(polylines[0]!.options.points![1].latitude, closeTo(60.286492, 0.01));
    expect(
        polylines[0]!.options.points![1].longitude, closeTo(25.929471, 0.01));
    expect(polylines[0]!.options.clickable, true);
    expect(polylines[0]!.options.geodesic, true);
    expect(
        colorToInt(polylines[0]!.options.strokeColor!), colorToInt(Colors.red));
    expect(polylines[0]!.options.strokeWidth, 5.0);

    /// iOS doesn't have strokeJointTypes
    if (Platform.isIOS) {
      expect(polylines[0]!.options.strokeJointType, null);
    } else if (Platform.isAndroid) {
      expect(
          polylines[0]!.options.strokeJointType, StrokeJointType.defaultJoint);
    }
    expect(polylines[0]!.options.strokePattern, null);
    expect(polylines[0]!.options.visible, true);
    expect(polylines[0]!.options.zIndex, 0);
    expect(polylines[0]!.options.spans, <StyleSpan>[]);

    await viewController.clearPolylines();

    /// Test updating polylines
    await viewController.addPolylines(
      <PolylineOptions>[
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 60.186492, longitude: 24.929471),
            LatLng(latitude: 60.286492, longitude: 25.929471),
          ],
        )
      ],
    );

    /// Test that polylines were ceated with default values.
    final List<Polyline?> receivedPolylines =
        await viewController.getPolylines();
    expect(receivedPolylines.length, 1);
    expect(receivedPolylines[0]!.options.geodesic, false);
    expect(receivedPolylines[0]!.options.clickable, false);
    expect(colorToInt(receivedPolylines[0]!.options.strokeColor!),
        colorToInt(Colors.black));
    expect(receivedPolylines[0]!.options.strokeWidth, 10.0);

    /// iOS doesn't have strokeJointTypes
    if (Platform.isIOS) {
      expect(polylines[0]!.options.strokeJointType, null);
    } else if (Platform.isAndroid) {
      expect(
          polylines[0]!.options.strokeJointType, StrokeJointType.defaultJoint);
    }
    expect(receivedPolylines[0]!.options.strokePattern, null);
    expect(receivedPolylines[0]!.options.visible, true);
    expect(receivedPolylines[0]!.options.zIndex, 0);
    expect(receivedPolylines[0]!.options.spans, <StyleSpan>[]);

    final Polyline updatedPolyline = Polyline(
      polylineId: receivedPolylines[0]!.polylineId,
      options: const PolylineOptions(
        points: <LatLng>[
          LatLng(latitude: 60.186492, longitude: 24.929471),
          LatLng(latitude: 60.286492, longitude: 25.929471)
        ],
        clickable: true,
        geodesic: true,
      ),
    );

    await viewController.updatePolylines(<Polyline>[updatedPolyline]);

    final List<Polyline?> receivedPolylines2 =
        await viewController.getPolylines();
    expect(receivedPolylines2.length, 1);
    expect(receivedPolylines2[0]!.options.geodesic, true);
    expect(receivedPolylines2[0]!.options.clickable, true);

    await viewController.clearPolylines();

    /// Test deleting polylines.
    await viewController.addPolylines(
      <PolylineOptions>[
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 60.186492, longitude: 24.929471),
            LatLng(latitude: 60.286492, longitude: 25.929471),
          ],
        ),
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 61.186492, longitude: 22.929471),
            LatLng(latitude: 61.286492, longitude: 22.929471),
          ],
        )
      ],
    );

    final List<Polyline?> receivedPolylines3 =
        await viewController.getPolylines();
    expect(receivedPolylines3.length, 2);

    await viewController.removePolylines(<Polyline>[receivedPolylines3[0]!]);

    final List<Polyline?> receivedPolylines4 =
        await viewController.getPolylines();
    expect(receivedPolylines4.length, 1);

    /// Test that right polyline was removed.
    expect(
        receivedPolylines4[0]!.polylineId, receivedPolylines3[1]!.polylineId);

    /// Test that trying to remove or update a polyline that doesn't exist
    /// throws error.
    try {
      await viewController.removePolylines(<Polyline>[receivedPolylines3[0]!]);
      fail(
          'Expected removePolylines() to fail with PolylineNotFoundException.');
    } on PolylineNotFoundException catch (e) {
      expect(e, isNotNull);
    }
    try {
      await viewController.updatePolylines(<Polyline>[receivedPolylines3[0]!]);
      fail('Expected updatePolylines to fail with PolylineNotFoundException.');
    } on PolylineNotFoundException catch (e) {
      expect(e, isNotNull);
    }

    await viewController.clearPolylines();

    /// Test clearning all polylines.
    await viewController.addPolylines(
      <PolylineOptions>[
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 60.186492, longitude: 24.929471),
            LatLng(latitude: 60.286492, longitude: 25.929471),
          ],
        ),
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 61.186492, longitude: 22.929471),
            LatLng(latitude: 61.286492, longitude: 22.929471),
          ],
        )
      ],
    );

    final List<Polyline?> receivedPolylines5 =
        await viewController.getPolylines();
    expect(receivedPolylines5.length, 2);

    await viewController.clearPolylines();

    final List<Polyline?> receivedPolylines6 =
        await viewController.getPolylines();
    expect(receivedPolylines6.length, 0);

    /// Test clearing all polylines with clear().
    await viewController.addPolylines(
      <PolylineOptions>[
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 60.186492, longitude: 24.929471),
            LatLng(latitude: 60.286492, longitude: 25.929471),
          ],
        ),
        const PolylineOptions(
          points: <LatLng>[
            LatLng(latitude: 61.186492, longitude: 22.929471),
            LatLng(latitude: 61.286492, longitude: 22.929471),
          ],
        )
      ],
    );

    final List<Polyline?> receivedPolylines7 =
        await viewController.getPolylines();
    expect(receivedPolylines7.length, 2);

    await viewController.clear();

    final List<Polyline?> receivedPolylines8 =
        await viewController.getPolylines();
    expect(receivedPolylines8.length, 0);
  }, variant: mapTypeVariants);

  patrol('Polygon tests', (PatrolIntegrationTester $) async {
    void onPolygonClicked(String event) {
      /// The events are not tested because there's currently no reliable way to trigger them.
      debugPrint('Polygon clicked event: $event.');
    }

    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType($,
            testMapType: mapTypeVariants.currentValue!,
            onPolygonClicked: onPolygonClicked);

    /// Creates square, 4 coordinates, from top left and bottom right coordinates.
    List<LatLng> createSquare(LatLng topLeft, LatLng bottomRight) {
      return <LatLng>[
        topLeft,
        LatLng(latitude: topLeft.latitude, longitude: bottomRight.longitude),
        bottomRight,
        LatLng(latitude: bottomRight.latitude, longitude: topLeft.longitude)
      ];
    }

    // Add square polygon on the current camera position.
    final CameraPosition position = await viewController.getCameraPosition();

    // Calculate suitable offset for coordinates from the current zoom level.
    final double offset = (30.0 - position.zoom) * 0.04;

    /// Creates list of 2 coordinates, for two opposite corners of the square.
    /// Each point is offset away from the center point.
    final LatLng topLeft = LatLng(
        latitude: position.target.latitude + offset,
        longitude: position.target.longitude - offset);
    final LatLng bottomRight = LatLng(
        latitude: position.target.latitude - offset,
        longitude: position.target.longitude + offset);

    final List<LatLng> points = createSquare(topLeft, bottomRight);

    // Get min and max coordinates from the existing polygon.
    final double minLatitude = points.map((LatLng e) => e.latitude).reduce(min);
    final double maxLatitude = points.map((LatLng e) => e.latitude).reduce(max);
    final double minLongitude =
        points.map((LatLng e) => e.longitude).reduce(min);
    final double maxLongitude =
        points.map((LatLng e) => e.longitude).reduce(max);
    final double width = maxLatitude - minLatitude;

    // Create hole that is 40% of the total rectangle width,
    // hole will be 10% of width away from the bottom right corner.
    final LatLng holeTopLeft = LatLng(
        latitude: minLatitude + (width * 0.1),
        longitude: minLongitude + (width * 0.1));
    final LatLng holeBottomRight = LatLng(
        latitude: minLatitude + (width * 0.4),
        longitude: minLongitude + (width * 0.4));
    final List<LatLng> hole1 = createSquare(holeTopLeft, holeBottomRight);

    // Create hole that is 40% of the total rectangle width,
    // hole will be 10% of width away from the top left corner.
    final LatLng holeTopLeft2 = LatLng(
        latitude: maxLatitude - (width * 0.1),
        longitude: maxLongitude - (width * 0.1));
    final LatLng holeBottomRight2 = LatLng(
        latitude: maxLatitude - (width * 0.4),
        longitude: maxLongitude - (width * 0.4));
    final List<LatLng> hole2 = createSquare(holeTopLeft2, holeBottomRight2);
    final List<List<LatLng>> holes = <List<LatLng>>[hole1, hole2];

    final PolygonOptions options = PolygonOptions(points: points, holes: holes);
    final List<Polygon?> polygons =
        await viewController.addPolygons(<PolygonOptions>[options]);
    List<Polygon?> getPolygons = await viewController.getPolygons();

    /// There's automatically extra LatLng point added on Android if the
    /// last LatLng value of the list doesn't match the first one.
    if (Platform.isAndroid) {
      getPolygons[0]!.options.points.removeLast();
      getPolygons[0]!.options.holes[0].removeLast();
      getPolygons[0]!.options.holes[1].removeLast();
    }
    final List<Polygon> polygonList = <Polygon>[polygons[0]!, getPolygons[0]!];

    /// Test PolygonOptions default values against addPolygons and getPolygons responses.
    for (final Polygon polygon in polygonList) {
      expect(polygon.polygonId, 'Polygon_0');
      expect(polygon.options.points, options.points);
      expect(polygon.options.holes, options.holes);

      // Default values.
      expect(polygon.options.clickable, false);
      expect(colorToInt(polygon.options.fillColor), colorToInt(Colors.black));
      expect(polygon.options.geodesic, false);
      expect(colorToInt(polygon.options.strokeColor), colorToInt(Colors.black));
      expect(polygon.options.strokeWidth, 10);
      expect(polygon.options.visible, true);
      expect(polygon.options.zIndex, 0);
    }

    final LatLng updatedTopLeft = LatLng(
        latitude: topLeft.latitude + 1, longitude: topLeft.longitude + 1);
    final LatLng updatedBottomRight = LatLng(
        latitude: bottomRight.latitude + 1,
        longitude: bottomRight.longitude + 1);
    final LatLng updatedHoleTopLeft = LatLng(
        latitude: holeTopLeft.latitude + 1,
        longitude: holeTopLeft.longitude + 1);
    final LatLng updatedHoleBottomRight = LatLng(
        latitude: holeBottomRight.latitude + 1,
        longitude: holeBottomRight.longitude + 1);
    final LatLng updatedHoleTopLeft2 = LatLng(
        latitude: holeTopLeft.latitude + 1,
        longitude: holeTopLeft.longitude + 1);
    final LatLng updatedHoleBottomRight2 = LatLng(
        latitude: holeBottomRight2.latitude + 1,
        longitude: holeBottomRight2.longitude + 1);

    final List<LatLng> updatedPoints =
        createSquare(updatedTopLeft, updatedBottomRight);
    final List<LatLng> updatedHole =
        createSquare(updatedHoleTopLeft, updatedHoleBottomRight);
    final List<LatLng> updatedHole2 =
        createSquare(updatedHoleTopLeft2, updatedHoleBottomRight2);
    final List<List<LatLng>> updatedHoles = <List<LatLng>>[
      updatedHole,
      updatedHole2
    ];

    /// New polygon options with non-default values.
    final PolygonOptions updatedOptions = PolygonOptions(
      points: updatedPoints,
      holes: updatedHoles,
      clickable: true,
      fillColor: Colors.white,
      geodesic: true,
      strokeColor: Colors.white,
      strokeWidth: 15,
      visible: false,
      zIndex: 1,
    );

    final Polygon updatedPolygon =
        polygons.first!.copyWith(options: updatedOptions);

    /// Update polygons with new options and check polygon is updated
    /// and not duplicated.
    final List<Polygon?> updatedPolygons =
        await viewController.updatePolygons(<Polygon>[updatedPolygon]);
    expect(updatedPolygons.length, 1);

    /// Get updated polygons.
    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 1);

    /// There's automatically extra LatLng point added on Android if the
    /// last LatLng value of the list doesn't match the first one.
    if (Platform.isAndroid) {
      getPolygons[0]!.options.points.removeLast();
      getPolygons[0]!.options.holes[0].removeLast();
      getPolygons[0]!.options.holes[1].removeLast();
    }

    final List<Polygon> updatedPolygonList = <Polygon>[
      updatedPolygons[0]!,
      getPolygons[0]!
    ];

    /// Test PolygonOptions updated values against updatePolygons and getPolygons responses.
    for (final Polygon updatedPolygon in updatedPolygonList) {
      expect(updatedPolygon.polygonId, 'Polygon_0');
      expect(updatedPolygon.options.points, updatedOptions.points);
      expect(updatedPolygon.options.holes, updatedOptions.holes);
      expect(updatedPolygon.options.clickable, updatedOptions.clickable);
      expect(colorToInt(updatedPolygon.options.fillColor),
          colorToInt(updatedOptions.fillColor));
      expect(updatedPolygon.options.geodesic, updatedOptions.geodesic);
      expect(colorToInt(updatedPolygon.options.strokeColor),
          colorToInt(updatedOptions.strokeColor));
      expect(updatedPolygon.options.strokeWidth, updatedOptions.strokeWidth);
      expect(updatedPolygon.options.visible, updatedOptions.visible);
      expect(updatedPolygon.options.zIndex, updatedOptions.zIndex);
    }

    /// Add a second polygon with the updated options and test order
    /// and custom options.
    final List<Polygon?> polygons2 =
        await viewController.addPolygons(<PolygonOptions>[updatedOptions]);
    expect(polygons2.length, 1);
    expect(polygons2[0]!.polygonId, 'Polygon_1');

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 2);
    expect(getPolygons[0]!.polygonId, 'Polygon_0');
    expect(getPolygons[1]!.polygonId, 'Polygon_1');

    final List<Polygon> polygonList2 = <Polygon>[
      polygons2[0]!,
      getPolygons[1]!,
    ];

    for (final Polygon polygon in polygonList2) {
      expect(polygon.options.clickable, updatedOptions.clickable);
      expect(colorToInt(polygon.options.fillColor),
          colorToInt(updatedOptions.fillColor));
      expect(polygon.options.geodesic, updatedOptions.geodesic);
      expect(colorToInt(polygon.options.strokeColor),
          colorToInt(updatedOptions.strokeColor));
      expect(polygon.options.strokeWidth, updatedOptions.strokeWidth);
      expect(polygon.options.visible, updatedOptions.visible);
      expect(polygon.options.zIndex, updatedOptions.zIndex);
    }

    /// Add third polygon with original options.
    final List<Polygon?> polygons3 =
        await viewController.addPolygons(<PolygonOptions>[options]);
    expect(polygons3.length, 1);
    expect(polygons3[0]!.polygonId, 'Polygon_2');

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 3);
    expect(getPolygons[0]!.polygonId, 'Polygon_0');
    expect(getPolygons[1]!.polygonId, 'Polygon_1');
    expect(getPolygons[2]!.polygonId, 'Polygon_2');

    /// Test removing the first polygon.
    await viewController.removePolygons(<Polygon>[getPolygons.first!]);

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 2);
    expect(getPolygons[0]!.polygonId, 'Polygon_1');
    expect(getPolygons[1]!.polygonId, 'Polygon_2');

    /// Test removing the last polygon.
    await viewController.removePolygons(<Polygon>[getPolygons.last!]);

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 1);
    expect(getPolygons[0]!.polygonId, 'Polygon_1');

    /// Add multiple polygons to test clearPolygons().
    final List<Polygon?> polygons4 = await viewController
        .addPolygons(<PolygonOptions>[updatedOptions, options, options]);

    expect(polygons4.length, 3);
    expect(polygons4[0]!.polygonId, 'Polygon_3');
    expect(polygons4[1]!.polygonId, 'Polygon_4');
    expect(polygons4[2]!.polygonId, 'Polygon_5');

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 4);
    expect(getPolygons[0]!.polygonId, 'Polygon_1');
    expect(getPolygons[1]!.polygonId, 'Polygon_3');
    expect(getPolygons[2]!.polygonId, 'Polygon_4');
    expect(getPolygons[3]!.polygonId, 'Polygon_5');

    /// Test clearPolygons().
    await viewController.clearPolygons();
    getPolygons = await viewController.getPolygons();
    expect(getPolygons, isEmpty);

    /// Add polygons to test clear().
    final List<Polygon?> polygons5 =
        await viewController.addPolygons(<PolygonOptions>[
      updatedOptions,
      options,
      options,
      updatedOptions,
      options,
    ]);

    expect(polygons5.length, 5);

    getPolygons = await viewController.getPolygons();
    expect(getPolygons.length, 5);

    /// Test that trying to remove or update a polyline that doesn't exist
    /// throws error.
    try {
      await viewController.removePolygons(<Polygon>[updatedPolygon]);
      fail('Expected removePolylines() to fail with PolygonNotFoundException.');
    } on PolygonNotFoundException catch (e) {
      expect(e, isNotNull);
    }
    try {
      await viewController.updatePolygons(<Polygon>[updatedPolygon]);
      fail('Expected updatePolylines() to fail with PolygonNotFoundException');
    } on PolygonNotFoundException catch (e) {
      expect(e, isNotNull);
    }

    /// Test clear() removes all polygons.
    await viewController.clear();

    getPolygons = await viewController.getPolygons();
    expect(getPolygons, isEmpty);
  }, variant: mapTypeVariants);

  patrol('Circle tests', (PatrolIntegrationTester $) async {
    void onCircleClicked(String event) {
      /// The events are not tested because there's currently no reliable way to trigger them.
      debugPrint('Circle clicked event: $event.');
    }

    /// Get viewController for the test type (navigation map or regular map).
    ///
    debugPrint('Circle tests, ${mapTypeVariants.currentValue!}');

    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType($,
            testMapType: mapTypeVariants.currentValue!,
            onCircleClicked: onCircleClicked);

    // Add circle on the current camera position.
    final CameraPosition position = await viewController.getCameraPosition();

    final CircleOptions options =
        CircleOptions(position: position.target, radius: 5000);
    final List<Circle?> circles =
        await viewController.addCircles(<CircleOptions>[options]);
    List<Circle?> getCircles = await viewController.getCircles();

    final List<Circle> circleList = <Circle>[circles[0]!, getCircles[0]!];

    /// Test CircleOptions default values against addCircles and getCircles responses.
    for (final Circle circle in circleList) {
      expect(circle.circleId, 'Circle_0');
      expect(circle.options.position, options.position);
      expect(circle.options.radius, options.radius);

      // Default values.
      expect(circle.options.clickable, false);
      expect(colorToInt(circle.options.fillColor), colorToInt(Colors.black));
      expect(colorToInt(circle.options.strokeColor), colorToInt(Colors.black));
      expect(circle.options.strokeWidth, 10);
      expect(circle.options.strokePattern, circle.options.strokePattern);
      expect(circle.options.visible, true);
      expect(circle.options.zIndex, 0);
    }

    final LatLng updatedPosition = LatLng(
        latitude: position.target.latitude + 1,
        longitude: position.target.longitude + 1);

    /// New circle options with non-default values.
    final CircleOptions updatedOptions = CircleOptions(
      position: updatedPosition,
      radius: 50000,
      clickable: true,
      fillColor: Colors.white,
      strokeColor: Colors.white,
      strokeWidth: 15,
      visible: false,
      zIndex: 1,
    );

    final Circle updatedCircle =
        circles.first!.copyWith(options: updatedOptions);

    /// Update circles with new options and check circle is updated
    /// and not duplicated.
    final List<Circle?> updatedCircles =
        await viewController.updateCircles(<Circle>[updatedCircle]);
    expect(updatedCircles.length, 1);

    /// Get updated circles.
    getCircles = await viewController.getCircles();
    expect(getCircles.length, 1);

    final List<Circle> updatedCircleList = <Circle>[
      updatedCircles[0]!,
      getCircles[0]!
    ];

    /// Test CircleOptions updated values against updateCircles and getCircles responses.
    for (final Circle updatedCircle in updatedCircleList) {
      expect(updatedCircle.circleId, 'Circle_0');
      expect(updatedCircle.options.position, updatedOptions.position);
      expect(updatedCircle.options.radius, updatedOptions.radius);
      expect(updatedCircle.options.clickable, updatedOptions.clickable);
      expect(colorToInt(updatedCircle.options.fillColor),
          colorToInt(updatedOptions.fillColor));
      expect(colorToInt(updatedCircle.options.strokeColor),
          colorToInt(updatedOptions.strokeColor));
      expect(updatedCircle.options.strokeWidth, updatedOptions.strokeWidth);
      expect(updatedCircle.options.strokePattern, updatedOptions.strokePattern);
      expect(updatedCircle.options.visible, updatedOptions.visible);
      expect(updatedCircle.options.zIndex, updatedOptions.zIndex);
    }

    /// Add a second circle with the updated options and test order
    /// and custom options.
    final List<Circle?> circles2 =
        await viewController.addCircles(<CircleOptions>[updatedOptions]);
    expect(circles2.length, 1);
    expect(circles2[0]!.circleId, 'Circle_1');

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 2);
    expect(getCircles[0]!.circleId, 'Circle_0');
    expect(getCircles[1]!.circleId, 'Circle_1');

    final List<Circle> circleList2 = <Circle>[
      circles2[0]!,
      getCircles[1]!,
    ];

    for (final Circle circle in circleList2) {
      expect(circle.options.position, updatedOptions.position);
      expect(circle.options.radius, updatedOptions.radius);
      expect(circle.options.clickable, updatedOptions.clickable);
      expect(colorToInt(circle.options.fillColor),
          colorToInt(updatedOptions.fillColor));
      expect(circle.options.strokePattern, updatedOptions.strokePattern);
      expect(colorToInt(circle.options.strokeColor),
          colorToInt(updatedOptions.strokeColor));
      expect(circle.options.strokeWidth, updatedOptions.strokeWidth);
      expect(circle.options.visible, updatedOptions.visible);
      expect(circle.options.zIndex, updatedOptions.zIndex);
    }

    /// Add third circle with original options.
    final List<Circle?> circles3 =
        await viewController.addCircles(<CircleOptions>[options]);
    expect(circles3.length, 1);
    expect(circles3[0]!.circleId, 'Circle_2');

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 3);
    expect(getCircles[0]!.circleId, 'Circle_0');
    expect(getCircles[1]!.circleId, 'Circle_1');
    expect(getCircles[2]!.circleId, 'Circle_2');

    /// Test removing the first circle.
    await viewController.removeCircles(<Circle>[getCircles.first!]);

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 2);
    expect(getCircles[0]!.circleId, 'Circle_1');
    expect(getCircles[1]!.circleId, 'Circle_2');

    /// Test removing the last circle.
    await viewController.removeCircles(<Circle>[getCircles.last!]);

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 1);
    expect(getCircles[0]!.circleId, 'Circle_1');

    /// Add multiple circles to test clearCircles().
    final List<Circle?> circles4 = await viewController
        .addCircles(<CircleOptions>[updatedOptions, options, options]);

    expect(circles4.length, 3);
    expect(circles4[0]!.circleId, 'Circle_3');
    expect(circles4[1]!.circleId, 'Circle_4');
    expect(circles4[2]!.circleId, 'Circle_5');

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 4);
    expect(getCircles[0]!.circleId, 'Circle_1');
    expect(getCircles[1]!.circleId, 'Circle_3');
    expect(getCircles[2]!.circleId, 'Circle_4');
    expect(getCircles[3]!.circleId, 'Circle_5');

    /// Test clearCircles().
    await viewController.clearCircles();
    getCircles = await viewController.getCircles();
    expect(getCircles, isEmpty);

    /// Add circles to test clear().
    final List<Circle?> circles5 =
        await viewController.addCircles(<CircleOptions>[
      updatedOptions,
      options,
      options,
      updatedOptions,
      options,
    ]);

    expect(circles5.length, 5);

    getCircles = await viewController.getCircles();
    expect(getCircles.length, 5);

    /// Test clear() removes all circles.
    await viewController.clear();

    getCircles = await viewController.getCircles();
    expect(getCircles, isEmpty);

    /// Test CircleNotFoundException error on removeCircles().
    try {
      await viewController.removeCircles(<Circle>[updatedCircle]);
      fail('Expected PlatformException');
    } on CircleNotFoundException catch (e) {
      expect(e, isNotNull);
    }
  }, variant: mapTypeVariants);
}
