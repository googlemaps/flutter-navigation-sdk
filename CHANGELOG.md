## [0.3.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.2.3-beta...v0.3.0) (2024-06-05)

### Features

* update pubspec to prepare for 0.3.0 release ([#97](https://github.com/googlemaps/flutter-navigation-sdk/issues/97)) ([0114353](https://github.com/googlemaps/flutter-navigation-sdk/commit/011435382b8573b78fa21d25b27a8ccd524c9b88))
* update README.md to prepare for publishing package to pub.dev


## [0.4.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.3.0...v0.4.0) (2024-10-30)


### Features

* standalone classic mapview ([#181](https://github.com/googlemaps/flutter-navigation-sdk/issues/181)) ([e85f590](https://github.com/googlemaps/flutter-navigation-sdk/commit/e85f59070639a9ad97e970b8e9df25d54b938293))
* update navigation sdk versions (iOS -&gt; 9.1.2, Android -> 6.0.0) and min iOS version to 15 ([#177](https://github.com/googlemaps/flutter-navigation-sdk/issues/177)) ([fa9eb88](https://github.com/googlemaps/flutter-navigation-sdk/commit/fa9eb880247496a2a583011853e5b9a6cbc953be))


### Bug Fixes

* make ios map view array thread safe ([#180](https://github.com/googlemaps/flutter-navigation-sdk/issues/180)) ([8f0283f](https://github.com/googlemaps/flutter-navigation-sdk/commit/8f0283ffc8885fa085b8c47edeeb2b6c44693e14))
* showStopLights and showDestinationMarkers functionality on iOS ([#178](https://github.com/googlemaps/flutter-navigation-sdk/issues/178)) ([d882837](https://github.com/googlemaps/flutter-navigation-sdk/commit/d882837589b380b29fbdb6c4d823ef2844394f11))

## 0.2.3-beta

This is the beta release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

- Updates minimum supported SDK version to Flutter 3.22.1/Dart 3.4.
- Update patrol version to 3.7.2

## 0.2.2-beta

This is the beta release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

**Key Features:**
- Added GoogleMapsNavigator.setNavInfoListener method for registering a listener for navigation info update events (Turn-by-Turn navigation).

## 0.2.1-beta

This is the beta release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

**Key Features:**
- Added a CI configuration for these jobs:
  - Flutter analyze
  - Format
  - Unit tests for Dart, Android and iOS
  - Build Android and iOS
  - Integration tests for Android and iOS
  - License header check
- Added a dependabot configuration
- Added more integration tests, mostly for event listeners
- Improved the reliability of some flaky integration tests

## 0.2.0-beta

This is the beta release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

**Key Features:**
- `setDestinations` now supports a `RouteTokenOptions` parameter.
- Added support for custom marker icons:
  - `registerBitmapImage` to register `ImageDescriptor`.
  - `unregisterImage` to unregister `ImageDescriptor`.
  - Registered `ImageDescriptor` can be used as icon for `MarkerOptions`.
- Added following event listeners:
  - `onNavigationUIEnabledChanged`
  - `onMyLocationClicked`
  - `onMyLocationButtonClicked`
  - `onCameraMoveStarted`
  - `onCameraMove`
  - `onCameraIdle`
  - `onCameraStartedFollowingLocation`
  - `onCameraStoppedFollowingLocation`
- Added `setConsumeMyLocationButtonClickEventsEnabled` method to control if the default my location button click event should be consumed by the plugin or not.
- Added the following methods to control zoom level preferences of the map: `setMinZoomPreference`, `setMaxZoomPreference`,
`getMinZoomPreference`, `getMaxZoomPreference` and `resetMinMaxZoomPreference`.
- Added `GoogleMapsNavigator.getNavSDKVersion()` method to fetch the Navigation SDK version
- `GoogleMapsNavigator.initializeNavigationSession()` now accepts optional parameter `abnormalTerminationReportingEnabled` to enable/disable reporting abnormal SDK terminations such as app crashes
- Improved error handling and reporting.

**BREAKING CHANGES:**
- **GoogleNavigationViewController** Following gesture and UI option setters have been renamed:
  - `enableNavigationUI({required bool})` to `setNavigationUIEnabled(bool)`
  - `enableNavigationHeader({required bool})` to `setNavigationHeaderEnabled(bool)`
  - `enableNavigationFooter({required bool})` to `setNavigationFooterEnabled(bool)`
  - `enableNavigationTripProgressBar({required bool})` to `setNavigationTripProgressBarEnabled(bool)`
  - `enableSpeedLimitIcon({required bool})` to `setSpeedLimitIconEnabled(bool)`
  - `enableSpeedometer({required bool})` to `setSpeedometerEnabled(bool)`
  - `enableMyLocation({required bool})` to `setMyLocationEnabled(bool)`
  - `enableMyLocationButton({required bool})` to `setMyLocationButtonEnabled(bool)`
  - `enableRecenterButton({required bool})` to `setRecenterButtonEnabled(bool)`
  - `enableZoomGestures({required bool}) setZoomGesturesEnabled(bool)`
  - `enableZoomControls({required bool})` to `setZoomControlsEnabled(bool)`
  - `enableCompass({required bool})` to `setCompassEnabled(bool)`
  - `enableRotateGestures({required bool})` to `setRotateGesturesEnabled(bool)`
  - `enableScrollGestures({required bool})` to `setScrollGesturesEnabled(bool)`
  - `enableScrollGesturesDuringRotateOrZoom({required bool})` to `setScrollGesturesDuringRotateOrZoomEnabled(bool)`
  - `enableTiltGestures({required bool})` to `setTiltGesturesEnabled(bool)`
  - `enableTraffic({required bool})` to `setTrafficEnabled(bool)`
  - `enableMapToolbar({required bool})` to `setMapToolbarEnabled(bool)`
  - `enableIncidentCards({required bool})` to `setTrafficIncidentCardsEnabled(bool)`
  - `isIncidentCardsEnabled()` to `isTrafficIncidentCardsEnabled`

- **GoogleMapsNavigationView:**
  - `initialNavigationUiEnabled` boolean has been renamed to `initialNavigationUIEnabledPreference` enumeration
  - Initial camera position defaults to zoom level 3.0 instead of 0.0

## 0.1.0-beta

This is the beta release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

**Key Features:**
- Integration of Google Maps Navigation with Flutter.
- Support for basic map and navigation functionalities.

**Known Issues:**
- On Android, a slight delay in rendering markers, polygons, circles, and polylines.

**Notes:**
- This version demonstrates the core capabilities of the package and serves as a basis for community feedback and further development.
- Users are encouraged to report bugs and suggest improvements to enhance the package's stability and functionality.
