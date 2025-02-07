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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../google_navigation_flutter.dart';
import '../utils/color.dart';

/// Polygon that has beed added to map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class Polygon {
  /// Construct [Polygon].
  const Polygon({required this.polygonId, required this.options});

  /// Identifies the polygon.
  final String polygonId;

  /// Options for the polygon.
  final PolygonOptions options;

  /// Create copy of [Polygon] with the specified options.
  Polygon copyWith({required PolygonOptions options}) {
    return Polygon(polygonId: polygonId, options: options);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Polygon &&
        polygonId == other.polygonId &&
        options == other.options;
  }

  @override
  int get hashCode => Object.hash(polygonId.hashCode, options.hashCode);
}

/// Defines PolygonOptions for a polygon.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class PolygonOptions {
  /// Initialize [PolygonOptions] object.
  const PolygonOptions(
      {this.points = const <LatLng>[],
      this.holes = const <List<LatLng>>[],
      this.clickable = false,
      this.fillColor = Colors.black,
      this.geodesic = false,
      this.strokeColor = Colors.black,
      this.strokeWidth = 10,
      this.visible = true,
      this.zIndex = 0});

  /// Vertices of the polygon to be drawn.
  ///
  /// By default, points list is empty.
  final List<LatLng> points;

  /// List of areas that will be excluded from polygon.
  ///
  /// By default, holes list is empty.
  final List<List<LatLng>> holes;

  /// Specifies whether this polygon is clickable.
  ///
  /// By default, clickable is false.
  final bool clickable;

  /// Specifies the polygon's fill color.
  ///
  /// By default, fillColor is [Colors.black].
  final Color fillColor;

  /// Specifies whether to draw each segment of this polygon as a geodesic.
  ///
  /// By default, geodesic is false.
  final bool geodesic;

  /// Specifies the polygon's stroke color.
  ///
  /// By default, strokeColor is [Colors.black].
  final Color strokeColor;

  /// Specifies the polygon's stroke width, in display pixels.
  ///
  /// By default, strokeWidth is 10.
  final double strokeWidth;

  /// Specifies the visibility for the polygon.
  ///
  /// By default, visible is true.
  final bool visible;

  /// Specifies the polygon's zIndex, i.e., the order in which it will be drawn.
  ///
  /// By default, zIndex is 0.
  final double zIndex;

  /// Create copy of [PolygonOptions] with specified parameters.
  PolygonOptions copyWith(
      {List<LatLng>? points,
      List<List<LatLng>>? holes,
      bool? clickable,
      Color? fillColor,
      bool? geodesic,
      Color? strokeColor,
      double? strokeWidth,
      bool? visible,
      double? zIndex}) {
    return PolygonOptions(
        points: points ?? this.points,
        holes: holes ?? this.holes,
        clickable: clickable ?? this.clickable,
        fillColor: fillColor ?? this.fillColor,
        geodesic: geodesic ?? this.geodesic,
        strokeColor: strokeColor ?? this.strokeColor,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        visible: visible ?? this.visible,
        zIndex: zIndex ?? this.zIndex);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PolygonOptions &&
        listEquals(points, other.points) &&
        const DeepCollectionEquality().equals(holes, other.holes) &&
        clickable == other.clickable &&
        colorToInt(fillColor) == colorToInt(other.fillColor) &&
        geodesic == other.geodesic &&
        colorToInt(strokeColor) == colorToInt(other.strokeColor) &&
        strokeWidth == other.strokeWidth &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => Object.hash(
      points.hashCode,
      holes.hashCode,
      clickable.hashCode,
      colorToInt(fillColor),
      geodesic.hashCode,
      colorToInt(strokeColor),
      strokeWidth.hashCode,
      visible.hashCode,
      zIndex.hashCode);
}

/// Event emitted when a polygon is clicked.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class PolygonClickedEvent {
  /// Initialize [PolygonClickedEvent] object.
  const PolygonClickedEvent({
    required this.polygonId,
  });

  /// Id of the polygon that has been tapped.
  final String polygonId;
}
