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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../google_maps_navigation.dart';

/// Item used in the stroke pattern for a Polyline or the outline of a Polygon or Circle.
/// {@category Navigation View}
abstract class PatternItem {
  /// Convert [PatternItem] to [PatternItemDto];
  PatternItemDto toPatternItemDto();
}

/// Class representing a dash used in the stroke pattern for a [Polyline] or the outline of a [Polygon] or [Circle].
/// {@category Navigation View}
@immutable
class DashPattern implements PatternItem {
  /// Initialize [DashPattern] object.
  const DashPattern({required this.length});

  /// Length in pixels (non-negative).
  final double length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is DashPattern && length == other.length;
  }

  @override
  int get hashCode => length.hashCode;

  @override
  PatternItemDto toPatternItemDto() {
    return PatternItemDto(type: PatternTypeDto.dash, length: length);
  }
}

/// Class representing a dot used in the stroke pattern for a [Polyline] or the outline of a [Polygon] or [Circle].
/// {@category Navigation View}
@immutable
class DotPattern implements PatternItem {
  /// Initialize [DotPattern] object.
  const DotPattern();

  @override
  PatternItemDto toPatternItemDto() {
    return PatternItemDto(type: PatternTypeDto.dot);
  }
}

/// Class representing a gap used in the stroke pattern for a [Polyline] or the outline of a [Polygon] or [Circle].
/// {@category Navigation View}
@immutable
class GapPattern implements PatternItem {
  /// Initialize [GapPattern] object.
  const GapPattern({required this.length});

  /// Length in pixels (non-negative).
  final double length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GapPattern && length == other.length;
  }

  @override
  int get hashCode => length.hashCode;

  @override
  PatternItemDto toPatternItemDto() {
    return PatternItemDto(type: PatternTypeDto.gap, length: length);
  }
}
