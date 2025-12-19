// Copyright 2025 Google LLC
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

void main() {
  group('TermsAndConditionsUIParams tests', () {
    test('converts to DTO correctly with all parameters', () {
      const params = TermsAndConditionsUIParams(
        backgroundColor: Color(0xFFFFFFFF),
        titleColor: Color(0xFF1976D2),
        mainTextColor: Color(0xFF212121),
        acceptButtonTextColor: Color(0xFF4CAF50),
        cancelButtonTextColor: Color(0xFFF44336),
      );

      final dto = params.toDto();

      expect(dto.backgroundColor, 0xFFFFFFFF);
      expect(dto.titleColor, 0xFF1976D2);
      expect(dto.mainTextColor, 0xFF212121);
      expect(dto.acceptButtonTextColor, 0xFF4CAF50);
      expect(dto.cancelButtonTextColor, 0xFFF44336);
    });

    test('converts to DTO correctly with null parameters', () {
      const params = TermsAndConditionsUIParams();

      final dto = params.toDto();

      expect(dto.backgroundColor, null);
      expect(dto.titleColor, null);
      expect(dto.mainTextColor, null);
      expect(dto.acceptButtonTextColor, null);
      expect(dto.cancelButtonTextColor, null);
    });
  });
}
