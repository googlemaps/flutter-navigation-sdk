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

import 'dart:ui';

import '../../../google_navigation_flutter.dart';
import '../../utils/color.dart';
import '../method_channel.dart';

/// [Polygon] convert extension.
/// @nodoc
extension ConvertPolygon on Polygon {
  /// Convert [Polygon] to [PolygonDto].
  PolygonDto toDto() {
    return PolygonDto(polygonId: polygonId, options: options.toDto());
  }
}

/// [PolygonOptions] convert extension.
/// @nodoc
extension ConvertPolygonOptions on PolygonOptions {
  /// Convert [PolygonOptions] to [PolygonOptionsDto].
  PolygonOptionsDto toDto() {
    return PolygonOptionsDto(
        points: points.map((LatLng point) => point.toDto()).toList(),
        holes: holes
            .map((List<LatLng> e) =>
                PolygonHoleDto(points: e.map((LatLng e) => e.toDto()).toList()))
            .toList(),
        clickable: clickable,
        fillColor: colorToInt(fillColor)!,
        geodesic: geodesic,
        strokeColor: colorToInt(strokeColor)!,
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex);
  }
}

/// [PolygonDto] convert extension.
/// @nodoc
extension ConvertPolygonDto on PolygonDto {
  /// Convert [PolygonDto] to [Polygon].
  Polygon toPolygon() {
    return Polygon(polygonId: polygonId, options: options.toPolygonOptions());
  }
}

/// [PolygonOptionsDto] convert extension.
/// @nodoc
extension ConvertPolygonOptionsDto on PolygonOptionsDto {
  /// Convert [PolygonOptionsDto] to [PolygonOptions].
  PolygonOptions toPolygonOptions() {
    return PolygonOptions(
        points: _convertPoints(points),
        holes: _convertHoles(holes),
        clickable: clickable,
        fillColor: Color(fillColor),
        geodesic: geodesic,
        strokeColor: Color(strokeColor),
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex);
  }

  List<List<LatLng>> _convertHoles(List<PolygonHoleDto?> holes) {
    return holes
        .whereType<PolygonHoleDto>()
        .map((PolygonHoleDto e) => _convertPoints(e.points))
        .toList();
  }

  List<LatLng> _convertPoints(List<LatLngDto?> points) {
    return points
        .whereType<LatLngDto>()
        .map((LatLngDto point) => point.toLatLng())
        .toList();
  }
}
