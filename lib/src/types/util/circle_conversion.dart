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

import '../../../google_maps_navigation.dart';
import 'marker_conversion.dart';
import 'polyline_conversion.dart';

/// [Circle] convert extension.
extension ConvertCircle on Circle {
  /// Convert [Circle] to [CircleDto].
  CircleDto toDto() {
    return CircleDto(circleId: circleId, options: options.toDto());
  }
}

/// [CircleOptions] convert extension.
extension ConvertCircleOptions on CircleOptions {
  /// Convert [CircleOptions] to [CircleOptionsDto].
  CircleOptionsDto toDto() {
    return CircleOptionsDto(
        position: position.toDto(),
        radius: radius,
        strokePattern:
            strokePattern.map((PatternItem e) => e.toPatternItemDto()).toList(),
        clickable: clickable,
        fillColor: fillColor.value,
        strokeColor: strokeColor.value,
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex);
  }
}

/// [CircleDto] convert extension.
extension ConvertCircleDto on CircleDto {
  /// Convert [CircleDto] to [Circle].
  Circle toCircle() {
    return Circle(circleId: circleId, options: options.toCircleOptions());
  }
}

/// [CircleOptionsDto] convert extension.
extension ConvertCircleOptionsDto on CircleOptionsDto {
  /// Convert [CircleOptionsDto] to [CircleOptions].
  CircleOptions toCircleOptions() {
    return CircleOptions(
        position: position.toLatLng(),
        radius: radius,
        clickable: clickable,
        fillColor: Color(fillColor),
        strokeColor: Color(strokeColor),
        strokeWidth: strokeWidth,
        strokePattern: strokePattern
            .map((PatternItemDto? e) => e?.toPatternItem())
            .whereType<PatternItem>()
            .toList(),
        visible: visible,
        zIndex: zIndex);
  }
}
