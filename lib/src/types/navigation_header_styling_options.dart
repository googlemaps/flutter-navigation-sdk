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

/// Background colors for the native navigation header.
/// {@category Navigation View}
class NavigationHeaderStylingOptions {
  /// Creates navigation header styling options.
  const NavigationHeaderStylingOptions({
    this.primaryDayModeBackgroundColor,
    this.secondaryDayModeBackgroundColor,
    this.primaryNightModeBackgroundColor,
    this.secondaryNightModeBackgroundColor,
  });

  /// Background color of the primary header area in day mode.
  final Color? primaryDayModeBackgroundColor;

  /// Background color of the secondary header area in day mode.
  final Color? secondaryDayModeBackgroundColor;

  /// Background color of the primary header area in night mode.
  final Color? primaryNightModeBackgroundColor;

  /// Background color of the secondary header area in night mode.
  final Color? secondaryNightModeBackgroundColor;

  /// Returns a copy with selected fields replaced.
  NavigationHeaderStylingOptions copyWith({
    Color? primaryDayModeBackgroundColor,
    Color? secondaryDayModeBackgroundColor,
    Color? primaryNightModeBackgroundColor,
    Color? secondaryNightModeBackgroundColor,
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
            secondaryNightModeBackgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    primaryDayModeBackgroundColor,
    secondaryDayModeBackgroundColor,
    primaryNightModeBackgroundColor,
    secondaryNightModeBackgroundColor,
  );

  @override
  String toString() {
    return 'NavigationHeaderStylingOptions('
        'primaryDayModeBackgroundColor: $primaryDayModeBackgroundColor, '
        'secondaryDayModeBackgroundColor: $secondaryDayModeBackgroundColor, '
        'primaryNightModeBackgroundColor: $primaryNightModeBackgroundColor, '
        'secondaryNightModeBackgroundColor: $secondaryNightModeBackgroundColor'
        ')';
  }
}
