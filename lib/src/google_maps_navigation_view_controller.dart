// Copyright 2024 Google LLC
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

import 'package:meta/meta.dart';

import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

/// Navigation View Controller class to handle navigation view events.
/// {@category Navigation View}
class GoogleNavigationViewController extends GoogleMapViewController {
  /// Basic constructor.
  ///
  /// Don't create this directly, but access through
  /// [GoogleMapsNavigationView.onViewCreated] callback.
  GoogleNavigationViewController(super.viewId);

  /// Checks if the navigation trip progress bar is enabled.
  Future<bool> isNavigationTripProgressBarEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isNavigationTripProgressBarEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation trip progress bar.
  ///
  /// By default, the navigation trip progress bar is disabled.
  /// This feature is experimental and may change in the future.
  @experimental
  Future<void> setNavigationTripProgressBarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setNavigationTripProgressBarEnabled(
          viewId: getViewId(),
          enabled: enabled,
        );
  }

  /// Checks if the navigation header is enabled.
  Future<bool> isNavigationHeaderEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isNavigationHeaderEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation header.
  ///
  /// By default, the navigation header is enabled.
  Future<void> setNavigationHeaderEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setNavigationHeaderEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Checks if the navigation footer is enabled.
  Future<bool> isNavigationFooterEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isNavigationFooterEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation footer.
  ///
  /// By default, the navigation footer is enabled.
  ///
  /// Also known as ETA card, for example in Android
  /// calls [setEtaCardEnabled().](https://developers.google.com/maps/documentation/navigation/android-sdk/v1/reference/com/google/android/libraries/navigation/NavigationView#setEtaCardEnabled(boolean))
  Future<void> setNavigationFooterEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setNavigationFooterEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Can the speed limit indication be displayed.
  Future<bool> isSpeedLimitIconEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isSpeedLimitIconEnabled(viewId: getViewId());
  }

  /// Allow showing the speed limit indicator.
  ///
  /// By default, the speed limit is not displayed.
  Future<void> setSpeedLimitIconEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setSpeedLimitIconEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Can the speedometer be displayed.
  Future<bool> isSpeedometerEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI.isSpeedometerEnabled(
      viewId: getViewId(),
    );
  }

  /// Allow showing the speedometer.
  ///
  /// By default, the speedometer is not displayed.
  Future<void> setSpeedometerEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.setSpeedometerEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Are the incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTrafficIncidentCardsEnabled(viewId: getViewId());
  }

  /// Enable or disable showing of the incident cards.
  ///
  /// By default, the incident cards are shown.
  Future<void> setTrafficIncidentCardsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTrafficIncidentCardsEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Checks if the report incident button is shown.
  Future<bool> isReportIncidentButtonEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isReportIncidentButtonEnabled(viewId: getViewId());
  }

  /// Enable or disable showing of the report incident button.
  ///
  /// By default, the report incident button is shown.
  Future<void> setReportIncidentButtonEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setReportIncidentButtonEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Checks if incident reporting is currently available.
  ///
  /// Returns true if the user can report incidents at the current time,
  /// false otherwise.
  /// This feature is experimental and may change in the future.
  @experimental
  Future<bool> isIncidentReportingAvailable() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isIncidentReportingAvailable(viewId: getViewId());
  }

  /// Presents a panel allowing users to report an incident.
  ///
  /// This method displays the incident reporting UI where users can select
  /// and report various types of incidents along the route.
  /// This feature is experimental and may change in the future.
  @experimental
  Future<void> showReportIncidentsPanel() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .showReportIncidentsPanel(viewId: getViewId());
  }

  /// Are the traffic prompts shown.
  Future<bool> isTrafficPromptsEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .isTrafficPromptsEnabled(viewId: getViewId());
  }

  /// Enable or disable showing of the traffic prompts.
  ///
  /// By default, the traffic prompts are shown.
  Future<void> setTrafficPromptsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setTrafficPromptsEnabled(viewId: getViewId(), enabled: enabled);
  }

  /// Check if the navigation user interface is shown.
  Future<bool> isNavigationUIEnabled() {
    return GoogleMapsNavigationPlatform.instance.viewAPI.isNavigationUIEnabled(
      viewId: getViewId(),
    );
  }

  /// Show or hide the navigation user interface shown on top of the map.
  ///
  /// When enabled also actives [followMyLocation] camera mode.
  ///
  /// Disabling hides routes on iOS, but on Android the routes stay visible.
  ///
  /// By default, the navigation UI is enabled when the session has been
  /// initialized with [GoogleMapsNavigator.initializeNavigationSession].
  ///
  /// Fails on Android if the navigation session has not been initialized,
  /// and on iOS if the terms and conditions have not been accepted.
  Future<void> setNavigationUIEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.setNavigationUIEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Move the map camera to show the route overview.
  ///
  /// See also [followMyLocation] and [animateCamera].
  Future<void> showRouteOverview() {
    return GoogleMapsNavigationPlatform.instance.viewAPI.showRouteOverview(
      viewId: getViewId(),
    );
  }

  /// Gets the current force night mode setting from the navigation view.
  ///
  /// Returns the current [NavigationForceNightMode] setting which controls
  /// the navigation UI lighting mode.
  Future<NavigationForceNightMode> getForceNightMode() async {
    return GoogleMapsNavigationPlatform.instance.viewAPI.getForceNightMode(
      viewId: getViewId(),
    );
  }

  /// Sets the force night mode for the navigation UI and map tiles.
  ///
  /// **When navigation UI is enabled:** This setting controls both the
  /// navigation UI elements (turn-by-turn guidance, route preview, etc.) and
  /// the map tile colors. Using [GoogleMapViewController.setMapColorScheme]
  /// will have no effect.
  ///
  /// **When navigation UI is disabled:** This setting has no effect. Use
  /// [GoogleMapViewController.setMapColorScheme] to control the map tile colors
  /// instead.
  ///
  /// Example usage:
  /// ```dart
  /// // Force night mode (when navigation UI is enabled)
  /// await controller.setForceNightMode(NavigationForceNightMode.forceNight);
  ///
  /// // Let SDK automatically determine day or night
  /// await controller.setForceNightMode(NavigationForceNightMode.auto);
  /// ```
  ///
  /// See also:
  /// - [NavigationForceNightMode] for available options
  /// - [GoogleMapViewController.setMapColorScheme] for controlling map tile
  ///   colors when navigation UI is disabled
  Future<void> setForceNightMode(NavigationForceNightMode forceNightMode) {
    return GoogleMapsNavigationPlatform.instance.viewAPI.setForceNightMode(
      viewId: getViewId(),
      forceNightMode: forceNightMode,
    );
  }

  /// Sets the styling options for the navigation UI on Android.
  ///
  /// This method allows customizing the appearance of the navigation header
  /// and footer, including colors for day and night mode, text colors,
  /// text sizes, and icon colors.
  ///
  /// This method only has effect on Android platform. On iOS, it does nothing.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.setAndroidNavigationStylingOptions(
  ///   AndroidNavigationStylingOptions(
  ///     primaryDayModeThemeColor: Colors.blue,
  ///     secondaryDayModeThemeColor: Colors.lightBlue,
  ///     primaryNightModeThemeColor: Colors.indigo,
  ///     secondaryNightModeThemeColor: Colors.deepPurple,
  ///   ),
  /// );
  /// ```
  ///
  /// See also:
  /// - [AndroidNavigationStylingOptions] for all available styling options
  /// - [setIOSNavigationStylingOptions] for iOS styling
  Future<void> setAndroidNavigationStylingOptions(
    AndroidNavigationStylingOptions options,
  ) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setAndroidNavigationStylingOptions(
          viewId: getViewId(),
          options: options,
        );
  }

  /// Sets the styling options for the navigation UI on iOS.
  ///
  /// This method allows customizing the appearance of the navigation header,
  /// including background colors for day and night mode, text colors,
  /// and icon colors.
  ///
  /// This method only has effect on iOS platform. On Android, it does nothing.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.setIOSNavigationStylingOptions(
  ///   IOSNavigationStylingOptions(
  ///     navigationHeaderPrimaryBackgroundColor: Colors.blue,
  ///     navigationHeaderSecondaryBackgroundColor: Colors.lightBlue,
  ///     navigationHeaderPrimaryBackgroundColorNightMode: Colors.indigo,
  ///     navigationHeaderSecondaryBackgroundColorNightMode: Colors.deepPurple,
  ///   ),
  /// );
  /// ```
  ///
  /// See also:
  /// - [IOSNavigationStylingOptions] for all available styling options
  /// - [setAndroidNavigationStylingOptions] for Android styling
  Future<void> setIOSNavigationStylingOptions(
    IOSNavigationStylingOptions options,
  ) {
    return GoogleMapsNavigationPlatform.instance.viewAPI
        .setIOSNavigationStylingOptions(viewId: getViewId(), options: options);
  }
}
