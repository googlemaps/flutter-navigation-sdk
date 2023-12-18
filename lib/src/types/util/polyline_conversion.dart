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

/// [Polyline] convert extension.
extension ConvertPolyline on Polyline {
  /// Convert [Polyline] to [NavigationViewPolyline].
  PolylineDto toNavigationViewPolyline() {
    return PolylineDto(
        polylineId: polylineId, options: options.toPolylineOptionsDto());
  }
}

/// [PolylineOptions] convert extension.
extension ConvertPolylineOptions on PolylineOptions {
  /// Convert [PolylineOptions] to [PolylineOptionsDto].
  PolylineOptionsDto toPolylineOptionsDto() {
    return PolylineOptionsDto(
      points: points?.map((LatLng point) => point.toDto()).toList(),
      clickable: clickable,
      geodesic: geodesic,
      strokeColor: strokeColor?.value,
      strokeJointType: strokeJointType?.toStrokeJointTypeDto(),
      strokePattern:
          strokePattern?.map((PatternItem e) => e.toPatternItemDto()).toList(),
      strokeWidth: strokeWidth,
      visible: visible,
      zIndex: zIndex,
      spans:
          spans?.map((StyleSpan s) => s.toNavigationViewStyleSpan()).toList() ??
              <StyleSpanDto>[],
    );
  }
}

/// [StyleSpan] convert extension.
extension ConvertStyleSpan on StyleSpan {
  /// Convert [StyleSpan] to [NavigationViewStyleSpan].
  StyleSpanDto toNavigationViewStyleSpan() {
    return StyleSpanDto(
      length: length,
      style: StyleSpanStrokeStyleDto(
        fromColor: style.fromColor,
        toColor: style.toColor,
        solidColor: style.solidColor,
      ),
    );
  }
}

/// [StrokeJointType] convert extension.
extension ConvertStrokeJointType on StrokeJointType {
  /// Convert [StrokeJointType] to [StrokeJointTypeDto].
  StrokeJointTypeDto toStrokeJointTypeDto() {
    switch (this) {
      case StrokeJointType.bevel:
        return StrokeJointTypeDto.bevel;
      case StrokeJointType.defaultJoint:
        return StrokeJointTypeDto.defaultJoint;
      case StrokeJointType.round:
        return StrokeJointTypeDto.round;
    }
  }
}

/// [PolylineDto] convert extension.
extension ConvertNavigationViewPolyline on PolylineDto {
  /// Convert [PolylineDto] to [Polyline].
  Polyline toPolyline() {
    return Polyline(
      polylineId: polylineId,
      options: options.toPolylineOptions(),
    );
  }
}

/// [PolylineOptionsDto] convert extension.
extension ConvertPolylineOptionsDto on PolylineOptionsDto {
  /// Convert [PolylineOptionsDto] to [PolylineOptions].
  PolylineOptions toPolylineOptions() {
    return PolylineOptions(
        points: points
            ?.map((LatLngDto? point) => point?.toLatLng())
            .whereType<LatLng>()
            .toList(),
        clickable: clickable,
        geodesic: geodesic,
        strokeColor: strokeColor != null ? Color(strokeColor!) : null,
        strokeJointType: strokeJointType?.toStrokeJointType(),
        strokePattern: strokePattern
            ?.map((PatternItemDto? e) => e?.toPatternItem())
            .whereType<PatternItem>()
            .toList(),
        strokeWidth: strokeWidth,
        visible: visible,
        zIndex: zIndex);
  }
}

/// [StrokeJointTypeDto] convert extension.
extension ConvertStrokeJointTypeDto on StrokeJointTypeDto {
  /// Convert [StrokeJointTypeDto] to [StrokeJointType].
  StrokeJointType toStrokeJointType() {
    switch (this) {
      case StrokeJointTypeDto.bevel:
        return StrokeJointType.bevel;
      case StrokeJointTypeDto.defaultJoint:
        return StrokeJointType.defaultJoint;
      case StrokeJointTypeDto.round:
        return StrokeJointType.round;
    }
  }
}

/// [PatternItemDto] convert extension.
extension ConvertPatternItemDto on PatternItemDto {
  /// Convert [PatternItemDto] to [PatternItem].
  PatternItem toPatternItem() {
    switch (type) {
      case PatternTypeDto.dash:
        return DashPattern(length: length!);
      case PatternTypeDto.dot:
        return const DotPattern();
      case PatternTypeDto.gap:
        return GapPattern(length: length!);
    }
  }
}
