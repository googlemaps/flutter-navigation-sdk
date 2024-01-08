## 0.2.0-pre1

- **BREAKING CHANGES** Following `GoogleNavigationViewController` gesture and UI option setters renamed:
  - `enableNavigationUI({required bool})` to `setNavigationUIEnabled(bool)`
  - `enableNavigationHeader({required bool})` to `setNavigationHeaderEnabled(bool)`
  - `enableNavigationFooter({required bool})` to `setNavigationFooterEnabled(bool)`
  - `enableNavigationTripProgressBar({required bool})` to `setNavigationTripProgressBarEnabled(bool)`
  - `enableSpeedLimitIcon({required bool})` to `setSpeedLimitIconEnabled(bool)`
  - `enableSpeedometer({required bool})` to `setSpeedometerEnabled(bool)`
  - `enableIncidentCards({required bool})` to `setIncidentCardsEnabled(bool)`
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
-- **BREAKING CHANGES** `GoogleMapsNavigationView` property `initialNavigationUiEnabled` renamed to `initialNavigationUIEnabled`

## 0.1.0-pre1

This is the first pre-release of the Google Maps Navigation package for Flutter. It is an early look at the package and is intended for testing and feedback collection. The functionalities and APIs in this version are subject to change.

**Key Features:**
- Integration of Google Maps Navigation with Flutter.
- Support for basic map and navigation functionalities.

**Known Issues:**
- On Android, a slight delay in rendering markers, polygons, circles, and polylines.

**Notes:**
- This version demonstrates the core capabilities of the package and serves as a basis for community feedback and further development.
- Users are encouraged to report bugs and suggest improvements to enhance the package's stability and functionality.