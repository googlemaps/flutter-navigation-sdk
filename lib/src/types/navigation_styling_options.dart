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

import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Styling options for the navigation UI on Android.
///
/// All color values use the Flutter [Color] class.
/// Text sizes are in float (sp) units.
/// All parameters are optional - if not provided, platform defaults will be used.
/// {@category Navigation View}
@immutable
class AndroidNavigationStylingOptions {
  /// Creates Android navigation styling options.
  const AndroidNavigationStylingOptions({
    this.primaryDayModeThemeColor,
    this.secondaryDayModeThemeColor,
    this.primaryNightModeThemeColor,
    this.secondaryNightModeThemeColor,
    this.headerLargeManeuverIconColor,
    this.headerSmallManeuverIconColor,
    this.headerNextStepTextColor,
    this.headerNextStepTextSize,
    this.headerDistanceValueTextColor,
    this.headerDistanceUnitsTextColor,
    this.headerDistanceValueTextSize,
    this.headerDistanceUnitsTextSize,
    this.headerInstructionsTextColor,
    this.headerInstructionsFirstRowTextSize,
    this.headerInstructionsSecondRowTextSize,
    this.headerGuidanceRecommendedLaneColor,
  });

  /// Primary theme color for day mode (used for header background).
  final Color? primaryDayModeThemeColor;

  /// Secondary theme color for day mode (used for footer background).
  final Color? secondaryDayModeThemeColor;

  /// Primary theme color for night mode (used for header background).
  final Color? primaryNightModeThemeColor;

  /// Secondary theme color for night mode (used for footer background).
  final Color? secondaryNightModeThemeColor;

  /// Color for the large maneuver icon in the header.
  final Color? headerLargeManeuverIconColor;

  /// Color for the small maneuver icon in the header.
  final Color? headerSmallManeuverIconColor;

  /// Text color for the "next step" text in the header.
  final Color? headerNextStepTextColor;

  /// Text size for the "next step" text in the header (in sp).
  final double? headerNextStepTextSize;

  /// Text color for the distance value in the header.
  final Color? headerDistanceValueTextColor;

  /// Text color for the distance units in the header.
  final Color? headerDistanceUnitsTextColor;

  /// Text size for the distance value in the header (in sp).
  final double? headerDistanceValueTextSize;

  /// Text size for the distance units in the header (in sp).
  final double? headerDistanceUnitsTextSize;

  /// Text color for the instructions in the header.
  final Color? headerInstructionsTextColor;

  /// Text size for the first row of instructions in the header (in sp).
  final double? headerInstructionsFirstRowTextSize;

  /// Text size for the second row of instructions in the header (in sp).
  final double? headerInstructionsSecondRowTextSize;

  /// Color for the recommended lane indicator in guidance.
  final Color? headerGuidanceRecommendedLaneColor;

  @override
  String toString() =>
      'AndroidNavigationStylingOptions('
      'primaryDayModeThemeColor: $primaryDayModeThemeColor, '
      'secondaryDayModeThemeColor: $secondaryDayModeThemeColor, '
      'primaryNightModeThemeColor: $primaryNightModeThemeColor, '
      'secondaryNightModeThemeColor: $secondaryNightModeThemeColor, '
      'headerLargeManeuverIconColor: $headerLargeManeuverIconColor, '
      'headerSmallManeuverIconColor: $headerSmallManeuverIconColor, '
      'headerNextStepTextColor: $headerNextStepTextColor, '
      'headerNextStepTextSize: $headerNextStepTextSize, '
      'headerDistanceValueTextColor: $headerDistanceValueTextColor, '
      'headerDistanceUnitsTextColor: $headerDistanceUnitsTextColor, '
      'headerDistanceValueTextSize: $headerDistanceValueTextSize, '
      'headerDistanceUnitsTextSize: $headerDistanceUnitsTextSize, '
      'headerInstructionsTextColor: $headerInstructionsTextColor, '
      'headerInstructionsFirstRowTextSize: $headerInstructionsFirstRowTextSize, '
      'headerInstructionsSecondRowTextSize: $headerInstructionsSecondRowTextSize, '
      'headerGuidanceRecommendedLaneColor: $headerGuidanceRecommendedLaneColor'
      ')';
}

/// Styling options for the navigation UI on iOS.
///
/// All color values use the Flutter [Color] class.
/// All parameters are optional - if not provided, platform defaults will be used.
/// {@category Navigation View}
@immutable
class IOSNavigationStylingOptions {
  /// Creates iOS navigation styling options.
  const IOSNavigationStylingOptions({
    this.navigationHeaderPrimaryBackgroundColor,
    this.navigationHeaderSecondaryBackgroundColor,
    this.navigationHeaderPrimaryBackgroundColorNightMode,
    this.navigationHeaderSecondaryBackgroundColorNightMode,
    this.navigationHeaderLargeManeuverIconColor,
    this.navigationHeaderSmallManeuverIconColor,
    this.navigationHeaderGuidanceRecommendedLaneColor,
    this.navigationHeaderNextStepTextColor,
    this.navigationHeaderDistanceValueTextColor,
    this.navigationHeaderDistanceUnitsTextColor,
    this.navigationHeaderInstructionsTextColor,
  });

  /// Primary header background color for day mode.
  final Color? navigationHeaderPrimaryBackgroundColor;

  /// Secondary header background color for day mode.
  final Color? navigationHeaderSecondaryBackgroundColor;

  /// Primary header background color for night mode.
  final Color? navigationHeaderPrimaryBackgroundColorNightMode;

  /// Secondary header background color for night mode.
  final Color? navigationHeaderSecondaryBackgroundColorNightMode;

  /// Color for the large maneuver icon in the navigation header.
  final Color? navigationHeaderLargeManeuverIconColor;

  /// Color for the small maneuver icon in the navigation header.
  final Color? navigationHeaderSmallManeuverIconColor;

  /// Color for the recommended lane indicator in guidance.
  final Color? navigationHeaderGuidanceRecommendedLaneColor;

  /// Text color for the "next step" text in the navigation header.
  final Color? navigationHeaderNextStepTextColor;

  /// Text color for the distance value in the navigation header.
  final Color? navigationHeaderDistanceValueTextColor;

  /// Text color for the distance units in the navigation header.
  final Color? navigationHeaderDistanceUnitsTextColor;

  /// Text color for the instructions in the navigation header.
  final Color? navigationHeaderInstructionsTextColor;

  @override
  String toString() =>
      'IOSNavigationStylingOptions('
      'navigationHeaderPrimaryBackgroundColor: $navigationHeaderPrimaryBackgroundColor, '
      'navigationHeaderSecondaryBackgroundColor: $navigationHeaderSecondaryBackgroundColor, '
      'navigationHeaderPrimaryBackgroundColorNightMode: $navigationHeaderPrimaryBackgroundColorNightMode, '
      'navigationHeaderSecondaryBackgroundColorNightMode: $navigationHeaderSecondaryBackgroundColorNightMode, '
      'navigationHeaderLargeManeuverIconColor: $navigationHeaderLargeManeuverIconColor, '
      'navigationHeaderSmallManeuverIconColor: $navigationHeaderSmallManeuverIconColor, '
      'navigationHeaderGuidanceRecommendedLaneColor: $navigationHeaderGuidanceRecommendedLaneColor, '
      'navigationHeaderNextStepTextColor: $navigationHeaderNextStepTextColor, '
      'navigationHeaderDistanceValueTextColor: $navigationHeaderDistanceValueTextColor, '
      'navigationHeaderDistanceUnitsTextColor: $navigationHeaderDistanceUnitsTextColor, '
      'navigationHeaderInstructionsTextColor: $navigationHeaderInstructionsTextColor'
      ')';
}
