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

import 'package:flutter/widgets.dart';

import '../method_channel/messages.g.dart';

/// Styling options for the native navigation header.
///
/// Text size properties are currently supported on Android only. On iOS they
/// are ignored.
/// {@category Navigation View}
class NavigationHeaderStylingOptions {
  /// Creates navigation header styling options.
  const NavigationHeaderStylingOptions({
    this.primaryDayModeBackgroundColor,
    this.secondaryDayModeBackgroundColor,
    this.primaryNightModeBackgroundColor,
    this.secondaryNightModeBackgroundColor,
    this.largeManeuverIconColor,
    this.smallManeuverIconColor,
    this.nextStepTextColor,
    this.nextStepTextSize,
    this.distanceValueTextColor,
    this.distanceUnitsTextColor,
    this.distanceValueTextSize,
    this.distanceUnitsTextSize,
    this.instructionsTextColor,
    this.instructionsFirstRowTextSize,
    this.instructionsSecondRowTextSize,
    this.guidanceRecommendedLaneColor,
  });

  /// Background color of the primary header area in day mode.
  final Color? primaryDayModeBackgroundColor;

  /// Background color of the secondary header area in day mode.
  final Color? secondaryDayModeBackgroundColor;

  /// Background color of the primary header area in night mode.
  final Color? primaryNightModeBackgroundColor;

  /// Background color of the secondary header area in night mode.
  final Color? secondaryNightModeBackgroundColor;

  /// Color of the large maneuver icon in the header.
  final Color? largeManeuverIconColor;

  /// Color of the small maneuver icon in the header.
  final Color? smallManeuverIconColor;

  /// Color of the next-step text in the header.
  final Color? nextStepTextColor;

  /// Size of the next-step text in logical pixels.
  ///
  /// Android only. Ignored on iOS.
  final double? nextStepTextSize;

  /// Color of the distance value text in the header.
  final Color? distanceValueTextColor;

  /// Color of the distance units text in the header.
  final Color? distanceUnitsTextColor;

  /// Size of the distance value text in logical pixels.
  ///
  /// Android only. Ignored on iOS.
  final double? distanceValueTextSize;

  /// Size of the distance units text in logical pixels.
  ///
  /// Android only. Ignored on iOS.
  final double? distanceUnitsTextSize;

  /// Color of the instructions text in the header.
  final Color? instructionsTextColor;

  /// Size of the first row of the instructions text in logical pixels.
  ///
  /// Android only. Ignored on iOS.
  final double? instructionsFirstRowTextSize;

  /// Size of the second row of the instructions text in logical pixels.
  ///
  /// Android only. Ignored on iOS.
  final double? instructionsSecondRowTextSize;

  /// Color of the recommended lane highlight in the header.
  final Color? guidanceRecommendedLaneColor;

  /// Returns a copy with selected fields replaced.
  NavigationHeaderStylingOptions copyWith({
    Color? primaryDayModeBackgroundColor,
    Color? secondaryDayModeBackgroundColor,
    Color? primaryNightModeBackgroundColor,
    Color? secondaryNightModeBackgroundColor,
    Color? largeManeuverIconColor,
    Color? smallManeuverIconColor,
    Color? nextStepTextColor,
    double? nextStepTextSize,
    Color? distanceValueTextColor,
    Color? distanceUnitsTextColor,
    double? distanceValueTextSize,
    double? distanceUnitsTextSize,
    Color? instructionsTextColor,
    double? instructionsFirstRowTextSize,
    double? instructionsSecondRowTextSize,
    Color? guidanceRecommendedLaneColor,
  }) {
    return NavigationHeaderStylingOptions(
      primaryDayModeBackgroundColor:
          primaryDayModeBackgroundColor ?? this.primaryDayModeBackgroundColor,
      secondaryDayModeBackgroundColor:
          secondaryDayModeBackgroundColor ??
          this.secondaryDayModeBackgroundColor,
      primaryNightModeBackgroundColor:
          primaryNightModeBackgroundColor ??
          this.primaryNightModeBackgroundColor,
      secondaryNightModeBackgroundColor:
          secondaryNightModeBackgroundColor ??
          this.secondaryNightModeBackgroundColor,
      largeManeuverIconColor:
          largeManeuverIconColor ?? this.largeManeuverIconColor,
      smallManeuverIconColor:
          smallManeuverIconColor ?? this.smallManeuverIconColor,
      nextStepTextColor: nextStepTextColor ?? this.nextStepTextColor,
      nextStepTextSize: nextStepTextSize ?? this.nextStepTextSize,
      distanceValueTextColor:
          distanceValueTextColor ?? this.distanceValueTextColor,
      distanceUnitsTextColor:
          distanceUnitsTextColor ?? this.distanceUnitsTextColor,
      distanceValueTextSize:
          distanceValueTextSize ?? this.distanceValueTextSize,
      distanceUnitsTextSize:
          distanceUnitsTextSize ?? this.distanceUnitsTextSize,
      instructionsTextColor:
          instructionsTextColor ?? this.instructionsTextColor,
      instructionsFirstRowTextSize:
          instructionsFirstRowTextSize ?? this.instructionsFirstRowTextSize,
      instructionsSecondRowTextSize:
          instructionsSecondRowTextSize ?? this.instructionsSecondRowTextSize,
      guidanceRecommendedLaneColor:
          guidanceRecommendedLaneColor ?? this.guidanceRecommendedLaneColor,
    );
  }

  /// Converts this object to a pigeon DTO.
  NavigationHeaderStylingOptionsDto toDto() {
    return NavigationHeaderStylingOptionsDto(
      primaryDayModeBackgroundColor: primaryDayModeBackgroundColor?.toARGB32(),
      secondaryDayModeBackgroundColor: secondaryDayModeBackgroundColor
          ?.toARGB32(),
      primaryNightModeBackgroundColor: primaryNightModeBackgroundColor
          ?.toARGB32(),
      secondaryNightModeBackgroundColor: secondaryNightModeBackgroundColor
          ?.toARGB32(),
      largeManeuverIconColor: largeManeuverIconColor?.toARGB32(),
      smallManeuverIconColor: smallManeuverIconColor?.toARGB32(),
      nextStepTextColor: nextStepTextColor?.toARGB32(),
      nextStepTextSize: nextStepTextSize,
      distanceValueTextColor: distanceValueTextColor?.toARGB32(),
      distanceUnitsTextColor: distanceUnitsTextColor?.toARGB32(),
      distanceValueTextSize: distanceValueTextSize,
      distanceUnitsTextSize: distanceUnitsTextSize,
      instructionsTextColor: instructionsTextColor?.toARGB32(),
      instructionsFirstRowTextSize: instructionsFirstRowTextSize,
      instructionsSecondRowTextSize: instructionsSecondRowTextSize,
      guidanceRecommendedLaneColor: guidanceRecommendedLaneColor?.toARGB32(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NavigationHeaderStylingOptions &&
        other.primaryDayModeBackgroundColor == primaryDayModeBackgroundColor &&
        other.secondaryDayModeBackgroundColor ==
            secondaryDayModeBackgroundColor &&
        other.primaryNightModeBackgroundColor ==
            primaryNightModeBackgroundColor &&
        other.secondaryNightModeBackgroundColor ==
            secondaryNightModeBackgroundColor &&
        other.largeManeuverIconColor == largeManeuverIconColor &&
        other.smallManeuverIconColor == smallManeuverIconColor &&
        other.nextStepTextColor == nextStepTextColor &&
        other.nextStepTextSize == nextStepTextSize &&
        other.distanceValueTextColor == distanceValueTextColor &&
        other.distanceUnitsTextColor == distanceUnitsTextColor &&
        other.distanceValueTextSize == distanceValueTextSize &&
        other.distanceUnitsTextSize == distanceUnitsTextSize &&
        other.instructionsTextColor == instructionsTextColor &&
        other.instructionsFirstRowTextSize == instructionsFirstRowTextSize &&
        other.instructionsSecondRowTextSize == instructionsSecondRowTextSize &&
        other.guidanceRecommendedLaneColor == guidanceRecommendedLaneColor;
  }

  @override
  int get hashCode => Object.hash(
    primaryDayModeBackgroundColor,
    secondaryDayModeBackgroundColor,
    primaryNightModeBackgroundColor,
    secondaryNightModeBackgroundColor,
    largeManeuverIconColor,
    smallManeuverIconColor,
    nextStepTextColor,
    nextStepTextSize,
    distanceValueTextColor,
    distanceUnitsTextColor,
    distanceValueTextSize,
    distanceUnitsTextSize,
    instructionsTextColor,
    instructionsFirstRowTextSize,
    instructionsSecondRowTextSize,
    guidanceRecommendedLaneColor,
  );

  @override
  String toString() {
    return 'NavigationHeaderStylingOptions('
        'primaryDayModeBackgroundColor: $primaryDayModeBackgroundColor, '
        'secondaryDayModeBackgroundColor: $secondaryDayModeBackgroundColor, '
        'primaryNightModeBackgroundColor: $primaryNightModeBackgroundColor, '
        'secondaryNightModeBackgroundColor: $secondaryNightModeBackgroundColor, '
        'largeManeuverIconColor: $largeManeuverIconColor, '
        'smallManeuverIconColor: $smallManeuverIconColor, '
        'nextStepTextColor: $nextStepTextColor, '
        'nextStepTextSize: $nextStepTextSize, '
        'distanceValueTextColor: $distanceValueTextColor, '
        'distanceUnitsTextColor: $distanceUnitsTextColor, '
        'distanceValueTextSize: $distanceValueTextSize, '
        'distanceUnitsTextSize: $distanceUnitsTextSize, '
        'instructionsTextColor: $instructionsTextColor, '
        'instructionsFirstRowTextSize: $instructionsFirstRowTextSize, '
        'instructionsSecondRowTextSize: $instructionsSecondRowTextSize, '
        'guidanceRecommendedLaneColor: $guidanceRecommendedLaneColor'
        ')';
  }
}
