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

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

void main() {
  group('Shape options default colors', () {
    test('circle stroke and fill default to opaque black', () {
      const CircleOptions options = CircleOptions();

      expect(options.strokeColor, const Color(0xFF000000));
      expect(options.fillColor, const Color(0xFF000000));
    });

    test('polygon stroke and fill default to opaque black', () {
      const PolygonOptions options = PolygonOptions();

      expect(options.strokeColor, const Color(0xFF000000));
      expect(options.fillColor, const Color(0xFF000000));
    });

    test('polyline stroke defaults to opaque black', () {
      const PolylineOptions options = PolylineOptions();

      expect(options.strokeColor, const Color(0xFF000000));
    });
  });
}
