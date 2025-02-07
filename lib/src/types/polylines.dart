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

/// Polyline that has beed added to map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class Polyline {
  /// Construct [Polyline].
  const Polyline({required this.polylineId, required this.options});

  /// Identifies polyline.
  final String polylineId;

  /// Options for polyline.
  final PolylineOptions options;

  /// Create copy of [Polyline] with the specified options.
  Polyline copyWith({required PolylineOptions options}) {
    return Polyline(polylineId: polylineId, options: options);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Polyline &&
        polylineId == other.polylineId &&
        options == other.options;
  }

  @override
  int get hashCode => Object.hash(polylineId.hashCode, options.hashCode);
}

/// Defines PolylineOptions for a polyline.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class PolylineOptions {
  /// Initialize [PolylineOptions] object.
  const PolylineOptions({
    this.points = const <LatLng>[],
    this.clickable = false,
    this.geodesic = false,
    this.strokeColor = Colors.black,
    this.strokeJointType,
    this.strokePattern,
    this.strokeWidth = 10,
    this.visible = true,
    this.zIndex = 0,
    this.spans = const <StyleSpan>[],
  });

  /// Vertices of the polyline to be drawn.
  final List<LatLng>? points;

  /// Specifies whether this polyline is clickable.
  final bool? clickable;

  /// Specifies whether to draw each segment of this polyline as a geodesic.
  final bool? geodesic;

  /// Specifies the polyline's stroke color, as 32-bit ARGB.
  final Color? strokeColor;

  /// Specifies the joint type for all vertices of the polyline's outline.
  final StrokeJointType? strokeJointType;

  /// Specifies a stroke pattern for the polyline's outline.
  final List<PatternItem>? strokePattern;

  /// Specifies the polyline's stroke width, in display pixels.
  final double? strokeWidth;

  /// Specifies the visibility for the polyline.
  final bool? visible;

  /// Specifies the polyline's zIndex, i.e., the order in which it will be drawn.
  final double? zIndex;

  /// Specifies the style for a region in a polyline.
  final List<StyleSpan>? spans;

  /// Create copy of [PolylineOptions] with specified parameters.
  PolylineOptions copyWith({
    List<LatLng>? points,
    bool? clickable,
    bool? geodesic,
    Color? strokeColor,
    StrokeJointType? strokeJointType,
    List<PatternItem>? strokePattern,
    double? strokeWidth,
    bool? visible,
    double? zIndex,
    List<StyleSpan>? spans,
  }) {
    return PolylineOptions(
      points: points ?? this.points,
      clickable: clickable ?? this.clickable,
      geodesic: geodesic ?? this.geodesic,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeJointType: strokeJointType ?? this.strokeJointType,
      strokePattern: strokePattern ?? this.strokePattern,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      visible: visible ?? this.visible,
      zIndex: zIndex ?? this.zIndex,
      spans: spans ?? this.spans,
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
    return other is PolylineOptions &&
        listEquals(points, other.points) &&
        clickable == other.clickable &&
        geodesic == other.geodesic &&
        colorToInt(strokeColor) == colorToInt(other.strokeColor) &&
        strokeJointType == other.strokeJointType &&
        listEquals(strokePattern, other.strokePattern) &&
        strokeWidth == other.strokeWidth &&
        visible == other.visible &&
        zIndex == other.zIndex &&
        spans == other.spans;
  }

  @override
  int get hashCode => Object.hash(
        points.hashCode,
        clickable.hashCode,
        geodesic.hashCode,
        colorToInt(strokeColor),
        strokeJointType.hashCode,
        strokePattern.hashCode,
        strokeWidth.hashCode,
        visible.hashCode,
        zIndex.hashCode,
        spans.hashCode,
      );
}

/// Style for stroke of a polyline.
/// {@category Navigation View}
/// {@category Map View}
class StyleSpanStrokeStyle {
  /// Initialize with solid color.
  StyleSpanStrokeStyle.solidColor({
    required this.solidColor,
  });

  /// Initialize with gradient color.
  StyleSpanStrokeStyle.gradientColor({
    required this.fromColor,
    required this.toColor,
  });

  /// Solid color.
  int? solidColor;

  /// Gradient from color.
  int? fromColor;

  /// Gradient to color.
  int? toColor;
}

/// Style and length of a stroke on polyline.
/// {@category Navigation View}
/// {@category Map View}
class StyleSpan {
  /// Initialize with length and style.
  StyleSpan({
    required this.length,
    required this.style,
  });

  /// Length of a stroke.
  final double length;

  /// Style of a stroke.
  final StyleSpanStrokeStyle style;
}

/// Joint types for [Polyline] and outline of [Polygon].
/// {@category Navigation View}
/// {@category Map View}
enum StrokeJointType {
  /// Flat bevel on the outside of the joint.
  bevel,

  /// Mitered joint, with fixed pointed extrusion equal to half the stroke width on the outside of the joint.
  defaultJoint,

  /// Rounded on the outside of the joint by an arc of radius equal to half the stroke width, centered at the vertex.
  round
}

/// Event emitted when a polyline is clicked.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class PolylineClickedEvent {
  /// Initialize [PolylineClickedEvent] object.
  const PolylineClickedEvent({
    required this.polylineId,
  });

  /// Id of the polyline that has been tapped.
  final String polylineId;
}
