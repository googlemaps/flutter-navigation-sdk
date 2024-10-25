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

  /// Is the navigation trip progress bar enabled.
  Future<bool> isNavigationTripProgressBarEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationTripProgressBarEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation trip progress bar.
  ///
  /// By default, the navigation trip progress bar is disabled.
  Future<void> setNavigationTripProgressBarEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance
        .setNavigationTripProgressBarEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Is the navigation header enabled.
  Future<bool> isNavigationHeaderEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationHeaderEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation header.
  ///
  /// By default, the navigation header is enabled.
  Future<void> setNavigationHeaderEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationHeaderEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Is the navigation footer enabled.
  Future<bool> isNavigationFooterEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationFooterEnabled(viewId: getViewId());
  }

  /// Enable or disable the navigation footer.
  ///
  /// By default, the navigation footer is enabled.
  ///
  /// Also known as ETA card, for example in Android
  /// calls [setEtaCardEnabled().](https://developers.google.com/maps/documentation/navigation/android-sdk/v1/reference/com/google/android/libraries/navigation/NavigationView#setEtaCardEnabled(boolean))
  Future<void> setNavigationFooterEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setNavigationFooterEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Can the speed limit indication be displayed.
  Future<bool> isSpeedLimitIconEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedLimitIconEnabled(viewId: getViewId());
  }

  /// Allow showing the speed limit indicator.
  ///
  /// By default, the speed limit is not displayed.
  Future<void> setSpeedLimitIconEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedLimitIconEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Can the speedometer be displayed.
  Future<bool> isSpeedometerEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isSpeedometerEnabled(viewId: getViewId());
  }

  /// Allow showing the speedometer.
  ///
  /// By default, the speedometer is not displayed.
  Future<void> setSpeedometerEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setSpeedometerEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Are the incident cards displayed.
  Future<bool> isTrafficIncidentCardsEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isTrafficIncidentCardsEnabled(viewId: getViewId());
  }

  /// Enable or disable showing of the incident cards.
  ///
  /// By default, the incident cards are shown.
  Future<void> setTrafficIncidentCardsEnabled(bool enabled) {
    return GoogleMapsNavigationPlatform.instance.setTrafficIncidentCardsEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Check if the navigation user interface is shown.
  Future<bool> isNavigationUIEnabled() {
    return GoogleMapsNavigationPlatform.instance
        .isNavigationUIEnabled(viewId: getViewId());
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
    return GoogleMapsNavigationPlatform.instance.setNavigationUIEnabled(
      viewId: getViewId(),
      enabled: enabled,
    );
  }

  /// Move the map camera to show the route overview.
  ///
  /// See also [followMyLocation] and [animateCamera].
  Future<void> showRouteOverview() {
    return GoogleMapsNavigationPlatform.instance.showRouteOverview(
      viewId: getViewId(),
    );
  }
}
