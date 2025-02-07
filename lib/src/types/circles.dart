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

import '../../google_navigation_flutter.dart';
import '../utils/color.dart';

/// Circle that has beed added to map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class Circle {
  /// Construct [Circle].
  const Circle({required this.circleId, required this.options});

  /// Identifies circle.
  final String circleId;

  /// Options for circle.
  final CircleOptions options;

  /// Create copy of [Circle] with the specified options.
  Circle copyWith({required CircleOptions options}) {
    return Circle(circleId: circleId, options: options);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Circle &&
        circleId == other.circleId &&
        options == other.options;
  }

  @override
  int get hashCode => Object.hash(circleId.hashCode, options.hashCode);
}

/// Defines CircleOptions for a circle.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class CircleOptions {
  /// Initialize [CircleOptions] object.
  const CircleOptions({
    this.position = const LatLng(latitude: 0.0, longitude: 0.0),
    this.radius = 0.0,
    this.strokeWidth = 10,
    this.strokeColor = Colors.black,
    this.strokePattern = const <PatternItem>[],
    this.fillColor = Colors.black,
    this.zIndex = 0.0,
    this.visible = true,
    this.clickable = false,
  });

  /// Specifies the circle's position in coordinates.
  final LatLng position;

  /// Specifies the radius of the circle in meters.
  final double radius;

  /// Specifies the circle's stroke width, in display pixels.
  final double strokeWidth;

  /// Specifies the circle's stroke color, as 32-bit ARGB.
  final Color strokeColor;

  /// Specifies a stroke pattern for the circle's outline.
  /// Android only property.
  final List<PatternItem> strokePattern;

  /// Specifies the fill color for the circle.
  final Color fillColor;

  /// Specifies the circle's zIndex, i.e., the order in which it will be drawn.
  final double zIndex;

  /// Specifies the visibility for the circle.
  final bool visible;

  /// Specifies whether this circle is clickable.
  final bool clickable;

  /// Create copy of [CircleOptions] with specified parameters.
  CircleOptions copyWith({
    LatLng? position,
    double? radius,
    double? strokeWidth,
    Color? strokeColor,
    List<PatternItem>? strokePattern,
    Color? fillColor,
    double? zIndex,
    bool? visible,
    bool? clickable,
  }) {
    return CircleOptions(
      position: position ?? this.position,
      radius: radius ?? this.radius,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeColor: strokeColor ?? this.strokeColor,
      strokePattern: strokePattern ?? this.strokePattern,
      fillColor: fillColor ?? this.fillColor,
      zIndex: zIndex ?? this.zIndex,
      visible: visible ?? this.visible,
      clickable: clickable ?? this.clickable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CircleOptions &&
        position == other.position &&
        radius == other.radius &&
        strokeWidth == other.strokeWidth &&
        colorToInt(strokeColor) == colorToInt(other.strokeColor) &&
        listEquals(strokePattern, other.strokePattern) &&
        colorToInt(fillColor) == colorToInt(other.fillColor) &&
        clickable == other.clickable &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => Object.hash(
      position.hashCode,
      radius.hashCode,
      strokeWidth.hashCode,
      colorToInt(strokeColor),
      strokePattern.hashCode,
      colorToInt(fillColor),
      clickable.hashCode,
      visible.hashCode,
      zIndex.hashCode);
}

/// Event emitted when a circle is clicked.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class CircleClickedEvent {
  /// Initialize [CircleClickedEvent] object.
  const CircleClickedEvent({
    required this.circleId,
  });

  /// Id of the circle that has been tapped.
  final String circleId;
}
