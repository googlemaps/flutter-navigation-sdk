# Changelog

## [0.8.2](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.8.1...0.8.2) (2026-01-20)


### Features

* add support for maneuver and lanes images ([#546](https://github.com/googlemaps/flutter-navigation-sdk/issues/546)) ([767cda4](https://github.com/googlemaps/flutter-navigation-sdk/commit/767cda47ad5592a8710a98efce02f16dd3b0dc0b))
* support for speed alert options ([#585](https://github.com/googlemaps/flutter-navigation-sdk/issues/585)) ([3c98d7a](https://github.com/googlemaps/flutter-navigation-sdk/commit/3c98d7abf45b26c46290c8de39400d51c283869d))
* support for terms and conditions UI customization ([#569](https://github.com/googlemaps/flutter-navigation-sdk/issues/569)) ([f8e9867](https://github.com/googlemaps/flutter-navigation-sdk/commit/f8e9867aa9e695347e3485ff2e532f54212f1b6c))


### Bug Fixes

* filter out null from navigation steps on android ([#592](https://github.com/googlemaps/flutter-navigation-sdk/issues/592)) ([82e28b7](https://github.com/googlemaps/flutter-navigation-sdk/commit/82e28b7d2cf1c8468829a5a81860c1ee9df16dc5))
* store images in a map instead of an array in ImageRegistry ([#588](https://github.com/googlemaps/flutter-navigation-sdk/issues/588)) ([b083beb](https://github.com/googlemaps/flutter-navigation-sdk/commit/b083beb93b1660ae0f26c8455717accae27792e6))

## [0.8.1](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.8.0...0.8.1) (2026-01-08)


### Features

* support POI click events ([#564](https://github.com/googlemaps/flutter-navigation-sdk/issues/564)) ([3c48de5](https://github.com/googlemaps/flutter-navigation-sdk/commit/3c48de58b0494d9046ca86698abca0361fd5bbac))
* upgrade Navigation SDK for Android to 7.3.0 ([#577](https://github.com/googlemaps/flutter-navigation-sdk/issues/577)) ([21911d8](https://github.com/googlemaps/flutter-navigation-sdk/commit/21911d832abaa6ba419455ca3212eb9684bc700d))
* upgrade Navigation SDK for iOS to 10.7.0 ([#578](https://github.com/googlemaps/flutter-navigation-sdk/issues/578)) ([1f1dcb0](https://github.com/googlemaps/flutter-navigation-sdk/commit/1f1dcb0fc5b27791124cc9a7a1cf6e6f8dcb7569))


### Bug Fixes

* marker drag event handling ([#567](https://github.com/googlemaps/flutter-navigation-sdk/issues/567)) ([c165694](https://github.com/googlemaps/flutter-navigation-sdk/commit/c165694c7f03c280c42e5f1e9b59ae4d46c3fe92))

## [0.8.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.7.0...0.8.0) (2025-12-15)


### ⚠ BREAKING CHANGES

* Most fields in StepInfo are now nullable. Null checks for these properties must be handled.

### Features

* add controls for light and dark modes ([#548](https://github.com/googlemaps/flutter-navigation-sdk/issues/548)) ([7ed6692](https://github.com/googlemaps/flutter-navigation-sdk/commit/7ed66920b21b5f2fd2d5524ad6575e4dc7e3ae09))
* add traffic delay severity ([#543](https://github.com/googlemaps/flutter-navigation-sdk/issues/543)) ([db19ffc](https://github.com/googlemaps/flutter-navigation-sdk/commit/db19ffca035fd34fedcd0a4199af92f09b249702))
* upgrade to latest native SDK's ([#526](https://github.com/googlemaps/flutter-navigation-sdk/issues/526)) ([0c358cb](https://github.com/googlemaps/flutter-navigation-sdk/commit/0c358cb98bc25c91d9af23b7333f633c98ebd376))
  - Upgrades Android SDK to version 7.2.0
  - Upgrades iOS SDK to version 10.6.0
  - Adds support for Map ID (cloud-based styling)
  - Adds support for controlling building visibility
  - Adds support for controlling incident panel visibility and detecting visibility changes
  - Updates Android minSdkVersion to 24
  - Updates minimum supported SDK version to Flutter 3.32/Dart 3.8
  - Deprecates NavigationDisplayOptions.showStopSigns and NavigationDisplayOptions.showTrafficLights
  - Deprecates Navigator.setOnGpsAvailabilityListener in favor of Navigator.setOnGpsAvailabilityChangeListener

### Bug Fixes

* ios view registration race condition ([#555](https://github.com/googlemaps/flutter-navigation-sdk/issues/555)) ([577d10f](https://github.com/googlemaps/flutter-navigation-sdk/commit/577d10fac474916bdf7b1434ccec3193c758c2f6))

## [0.7.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.5...0.7.0) (2025-11-20)


### ⚠ BREAKING CHANGES

* native state issues on Android when multiple engines are used ([#525](https://github.com/googlemaps/flutter-navigation-sdk/issues/525))

### Features

* add interface for listening new navigation sessions ([#530](https://github.com/googlemaps/flutter-navigation-sdk/issues/530)) ([6128cc6](https://github.com/googlemaps/flutter-navigation-sdk/commit/6128cc69e40b8d218e4a79927294452e4bbbbd6c))


### Bug Fixes

* native state issues on Android when multiple engines are used ([#525](https://github.com/googlemaps/flutter-navigation-sdk/issues/525)) ([cb7d61e](https://github.com/googlemaps/flutter-navigation-sdk/commit/cb7d61e29da29e2cc873a4b514dcad2a1e0e1045))

## [0.6.5](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.4...0.6.5) (2025-10-14)


### Features

* deprecate continueToNextDestination method ([#490](https://github.com/googlemaps/flutter-navigation-sdk/issues/490)) ([083fcc5](https://github.com/googlemaps/flutter-navigation-sdk/commit/083fcc588e9f17bc5b2dbadb27f5cb9486d7e9d8))
* improve string presentation for internal classes ([#491](https://github.com/googlemaps/flutter-navigation-sdk/issues/491)) ([a6aef40](https://github.com/googlemaps/flutter-navigation-sdk/commit/a6aef403ce13209d779fa12f79b75298d6da6e56))


### Bug Fixes

* flutter plugin lifecycle logic ([#487](https://github.com/googlemaps/flutter-navigation-sdk/issues/487)) ([48dd3e4](https://github.com/googlemaps/flutter-navigation-sdk/commit/48dd3e4490d0d4a5bacfa7dde27af02c82737c4b))
* view dispose crash on android if view is on background ([#453](https://github.com/googlemaps/flutter-navigation-sdk/issues/453)) ([9774479](https://github.com/googlemaps/flutter-navigation-sdk/commit/977447918151a0d1a46616c0c13d89c622459ee7))

## [0.6.4](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.3...0.6.4) (2025-08-08)


### Bug Fixes

* waypoint conversion issue while using placeId ([#439](https://github.com/googlemaps/flutter-navigation-sdk/issues/439)) ([9280761](https://github.com/googlemaps/flutter-navigation-sdk/commit/9280761ee7fd927677e65ee9b6d446e89929dca2))

## [0.6.3](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.2...0.6.3) (2025-08-05)


### Bug Fixes

* fix background location updates on iOS ([#404](https://github.com/googlemaps/flutter-navigation-sdk/issues/404)) ([7389afe](https://github.com/googlemaps/flutter-navigation-sdk/commit/7389afe0e4ac9a1a84ce79b4bea287f1b08e78b1))

## [0.6.2](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.1...0.6.2) (2025-06-24)


### Features

* upgrade dependencies and environment requirements ([#375](https://github.com/googlemaps/flutter-navigation-sdk/issues/375)) ([5a83661](https://github.com/googlemaps/flutter-navigation-sdk/commit/5a83661676728c265747f51cd61a392561ee4875))


### Bug Fixes

* add assert to NavigationWaypoint constructor ([#387](https://github.com/googlemaps/flutter-navigation-sdk/issues/387)) ([aff35af](https://github.com/googlemaps/flutter-navigation-sdk/commit/aff35af4268b250909e7a6768a98c457584b0fdf))

## [0.6.1](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.6.0...0.6.1) (2025-05-14)


### Bug Fixes

* error handling for awaitMapReady calls ([#353](https://github.com/googlemaps/flutter-navigation-sdk/issues/353)) ([867f500](https://github.com/googlemaps/flutter-navigation-sdk/commit/867f500c338702d8309e64e36793a5066ed5c2cb))
* hide report incident button from the carplay view ([#364](https://github.com/googlemaps/flutter-navigation-sdk/issues/364)) ([794a890](https://github.com/googlemaps/flutter-navigation-sdk/commit/794a89041d1cbea712d527a772b6f9ea5f5bd44b))

## [0.6.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.5.2...0.6.0) (2025-04-11)


### ⚠ BREAKING CHANGES

* switch to TLHC mode to fix rendering issues on Android ([#340](https://github.com/googlemaps/flutter-navigation-sdk/issues/340))

### Features

* support for real-time disruption settings ([#338](https://github.com/googlemaps/flutter-navigation-sdk/issues/338)) ([97c803f](https://github.com/googlemaps/flutter-navigation-sdk/commit/97c803f86182b80577ecc7f3f230963cd8724168))
* switch to TLHC mode to fix rendering issues on Android ([#340](https://github.com/googlemaps/flutter-navigation-sdk/issues/340)) ([76685a7](https://github.com/googlemaps/flutter-navigation-sdk/commit/76685a7a9f9ce5f745457bdfe48e47c4f02b81c4))
* update navigation SDKs ([#332](https://github.com/googlemaps/flutter-navigation-sdk/issues/332)) ([ed31ce0](https://github.com/googlemaps/flutter-navigation-sdk/commit/ed31ce041d49fee489b984f24a27831f203b8935))


### Bug Fixes

* initialize view listeners on platform view creation ([#342](https://github.com/googlemaps/flutter-navigation-sdk/issues/342)) ([e113fdd](https://github.com/googlemaps/flutter-navigation-sdk/commit/e113fdd7846a1ccc24038b648cbcb5d36828bc66))

## [0.5.2](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.5.1...0.5.2) (2025-03-31)


### Bug Fixes

* polyline, polygon and circle click events ([#326](https://github.com/googlemaps/flutter-navigation-sdk/issues/326)) ([71ad280](https://github.com/googlemaps/flutter-navigation-sdk/commit/71ad2806e9a023d60b7452c8ce737cdc529ac5e9))
* update minimum supported SDK version to Flutter 3.27/Dart 3.6. ([#301](https://github.com/googlemaps/flutter-navigation-sdk/issues/301)) ([32e5b9f](https://github.com/googlemaps/flutter-navigation-sdk/commit/32e5b9f9fa7df408480d38413801cd5a2a0cf6c4))

## [0.5.1](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.5.0...0.5.1) (2025-02-27)


### Features

* support navigation disposal on app exit on android ([#289](https://github.com/googlemaps/flutter-navigation-sdk/issues/289)) ([8bc03c1](https://github.com/googlemaps/flutter-navigation-sdk/commit/8bc03c1604a4074101758c48d99c4fa4b3763335))


### Bug Fixes

* android unregisterListeners crash on app disposal ([#283](https://github.com/googlemaps/flutter-navigation-sdk/issues/283)) ([fa71176](https://github.com/googlemaps/flutter-navigation-sdk/commit/fa7117606551f30ca79c07fa98be40914ccfddc0))
* camera events on mapview ([#292](https://github.com/googlemaps/flutter-navigation-sdk/issues/292)) ([d6aaa0d](https://github.com/googlemaps/flutter-navigation-sdk/commit/d6aaa0d13efbe3b365b95b49b6b5ffd715f343cd))


### Miscellaneous Chores

* improve platform interface by removing unnecessary abstraction ([#233](https://github.com/googlemaps/flutter-navigation-sdk/issues/233)) ([da716a7](https://github.com/googlemaps/flutter-navigation-sdk/commit/da716a73215b32ed645ecaaf2e35a685f954c99e))
* updates navigation SDK for android to 6.1.0 ([#282](https://github.com/googlemaps/flutter-navigation-sdk/issues/282)) ([af21548](https://github.com/googlemaps/flutter-navigation-sdk/commit/af215480049edfaee56d40978e814d0b8efdc08c))

## [0.5.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/v0.4.0...0.5.0) (2025-02-10)


### Features

* add carplay and android auto support ([#209](https://github.com/googlemaps/flutter-navigation-sdk/issues/209)) ([1b6c72e](https://github.com/googlemaps/flutter-navigation-sdk/commit/1b6c72e9660f9ed9300212dbd48d2318be07598b))
* add map padding ([#232](https://github.com/googlemaps/flutter-navigation-sdk/issues/232)) ([bf991ee](https://github.com/googlemaps/flutter-navigation-sdk/commit/bf991ee8138ffb0e11b4738d45f43866810f2444))
* update navigation SDKs ([#261](https://github.com/googlemaps/flutter-navigation-sdk/issues/261)) ([acfa42e](https://github.com/googlemaps/flutter-navigation-sdk/commit/acfa42e2ae8efb6e5c4c8c1e0615dfd701303894))
  * Updates navigation SDK for android to 6.0.2
  * Updates navigation SDK for iOS to 9.3.0

## [0.4.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.3.0...v0.4.0) (2024-10-30)


### Features

* standalone classic mapview ([#181](https://github.com/googlemaps/flutter-navigation-sdk/issues/181)) ([e85f590](https://github.com/googlemaps/flutter-navigation-sdk/commit/e85f59070639a9ad97e970b8e9df25d54b938293))
* update navigation sdk versions (iOS -&gt; 9.1.2, Android -> 6.0.0) and min iOS version to 15 ([#177](https://github.com/googlemaps/flutter-navigation-sdk/issues/177)) ([fa9eb88](https://github.com/googlemaps/flutter-navigation-sdk/commit/fa9eb880247496a2a583011853e5b9a6cbc953be))


### Bug Fixes

* make ios map view array thread safe ([#180](https://github.com/googlemaps/flutter-navigation-sdk/issues/180)) ([8f0283f](https://github.com/googlemaps/flutter-navigation-sdk/commit/8f0283ffc8885fa085b8c47edeeb2b6c44693e14))
* showStopLights and showDestinationMarkers functionality on iOS ([#178](https://github.com/googlemaps/flutter-navigation-sdk/issues/178)) ([d882837](https://github.com/googlemaps/flutter-navigation-sdk/commit/d882837589b380b29fbdb6c4d823ef2844394f11))

## [0.3.0](https://github.com/googlemaps/flutter-navigation-sdk/compare/0.2.3-beta...v0.3.0) (2024-06-05)

### Features

* update pubspec to prepare for 0.3.0 release ([#97](https://github.com/googlemaps/flutter-navigation-sdk/issues/97)) ([0114353](https://github.com/googlemaps/flutter-navigation-sdk/commit/011435382b8573b78fa21d25b27a8ccd524c9b88))
* update README.md to prepare for publishing package to pub.dev


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
