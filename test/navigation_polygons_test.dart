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
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';
import 'package:google_navigation_flutter/src/utils/color.dart';

void main() {
  late Polygon polygon;
  late PolygonDto navigationViewPolygon;

  setUp(() {
    polygon = const Polygon(
        polygonId: 'Polygon_0',
        options: PolygonOptions(
            points: <LatLng>[
              LatLng(latitude: 10.0, longitude: 20.0),
              LatLng(latitude: 30.0, longitude: 40.0),
              LatLng(latitude: 50.0, longitude: 60.0)
            ],
            holes: <List<LatLng>>[
              <LatLng>[
                LatLng(latitude: 60.0, longitude: 70.0),
                LatLng(latitude: 80.0, longitude: 90.0)
              ],
              <LatLng>[
                LatLng(latitude: 30.0, longitude: 40.0),
                LatLng(latitude: 50.0, longitude: 60.0)
              ]
            ],
            clickable: true,
            fillColor: Colors.amber,
            geodesic: true,
            strokeColor: Colors.blue,
            strokeWidth: 4,
            zIndex: 3));

    navigationViewPolygon = PolygonDto(
        polygonId: 'Polygon_0',
        options: PolygonOptionsDto(
            points: <LatLngDto>[
              LatLngDto(latitude: 10.0, longitude: 20.0),
              LatLngDto(latitude: 30.0, longitude: 40.0),
              LatLngDto(latitude: 50.0, longitude: 60.0)
            ],
            holes: <PolygonHoleDto?>[
              PolygonHoleDto(points: <LatLngDto?>[
                LatLngDto(latitude: 60.0, longitude: 70.0),
                LatLngDto(latitude: 80.0, longitude: 90.0)
              ]),
              PolygonHoleDto(points: <LatLngDto?>[
                LatLngDto(latitude: 30.0, longitude: 40.0),
                LatLngDto(latitude: 50.0, longitude: 60.0)
              ])
            ],
            clickable: true,
            fillColor: colorToInt(Colors.amber)!,
            geodesic: true,
            strokeColor: colorToInt(Colors.blue)!,
            strokeWidth: 4,
            visible: true,
            zIndex: 3));
  });

  group('Polygon conversion tests', () {
    test('test Polygon conversion from app facing to pigeon format', () {
      final PolygonDto converted = polygon.toDto();

      expect(converted.polygonId, 'Polygon_0');

      // Check points conversion
      expect(converted.options.points.length, 3);
      expect(converted.options.points[0]?.latitude, 10.0);
      expect(converted.options.points[0]?.longitude, 20.0);
      expect(converted.options.points[1]?.latitude, 30.0);
      expect(converted.options.points[1]?.longitude, 40.0);
      expect(converted.options.points[2]?.latitude, 50.0);
      expect(converted.options.points[2]?.longitude, 60.0);

      // Check holes conversion
      expect(converted.options.holes[0]?.points[0]?.latitude, 60);
      expect(converted.options.holes[0]?.points[0]?.longitude, 70);
      expect(converted.options.holes[0]?.points[1]?.latitude, 80);
      expect(converted.options.holes[0]?.points[1]?.longitude, 90);
      expect(converted.options.holes[1]?.points[0]?.latitude, 30);
      expect(converted.options.holes[1]?.points[0]?.longitude, 40);
      expect(converted.options.holes[1]?.points[1]?.latitude, 50);
      expect(converted.options.holes[1]?.points[1]?.longitude, 60);

      // Other parameters
      expect(converted.options.clickable, true);
      expect(converted.options.fillColor, colorToInt(Colors.amber));
      expect(converted.options.geodesic, true);
      expect(converted.options.strokeColor, colorToInt(Colors.blue));
      expect(converted.options.strokeWidth, 4);
      expect(converted.options.visible, true);
      expect(converted.options.zIndex, 3);
    });

    test('test Polygon conversion from pigeon to app facing format', () {
      final Polygon converted = navigationViewPolygon.toPolygon();

      expect(converted.polygonId, 'Polygon_0');

      // Check points conversion
      expect(converted.options.points.length, 3);
      expect(converted.options.points[0].latitude, 10.0);
      expect(converted.options.points[0].longitude, 20.0);
      expect(converted.options.points[1].latitude, 30.0);
      expect(converted.options.points[1].longitude, 40.0);
      expect(converted.options.points[2].latitude, 50.0);
      expect(converted.options.points[2].longitude, 60.0);

      // Check holes conversion
      expect(converted.options.holes[0][0].latitude, 60);
      expect(converted.options.holes[0][0].longitude, 70);
      expect(converted.options.holes[0][1].latitude, 80);
      expect(converted.options.holes[0][1].longitude, 90);
      expect(converted.options.holes[1][0].latitude, 30);
      expect(converted.options.holes[1][0].longitude, 40);
      expect(converted.options.holes[1][1].latitude, 50);
      expect(converted.options.holes[1][1].longitude, 60);

      // Other parameters
      expect(converted.options.clickable, true);
      expect(colorToInt(converted.options.fillColor), colorToInt(Colors.amber));
      expect(converted.options.geodesic, true);
      expect(
          colorToInt(converted.options.strokeColor), colorToInt(Colors.blue));
      expect(converted.options.strokeWidth, 4);
      expect(converted.options.visible, true);
      expect(converted.options.zIndex, 3);
    });
  });
}
