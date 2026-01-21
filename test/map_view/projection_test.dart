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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Projection DTO conversion tests', () {
    test('LatLng round-trip conversion', () {
      const LatLng original = LatLng(latitude: 35.6762, longitude: 139.6503);
      final LatLngDto dto = original.toDto();
      final LatLng converted = dto.toLatLng();

      expect(converted.latitude, original.latitude);
      expect(converted.longitude, original.longitude);
    });

    test('ScreenCoordinate round-trip conversion', () {
      const ScreenCoordinate original = ScreenCoordinate(x: 640.5, y: 480.25);
      final ScreenCoordinateDto dto = original.toDto();
      final ScreenCoordinate converted = dto.toScreenCoordinate();

      expect(converted.x, original.x);
      expect(converted.y, original.y);
    });
  });
}
