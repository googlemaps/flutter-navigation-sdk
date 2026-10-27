# Migration Guide

This document covers the breaking changes and migration steps for the
`google_navigation_flutter` upgrade to Navigation SDK for Android **8.0.0**.

## Migrating to Android Navigation SDK 8.0.0

This upgrade replaces Android Navigation SDK 7.9.0 with 8.0.0. The native iOS SDK
is unchanged, but the shared Dart API removals below apply to apps targeting
either platform.

### Summary of Breaking Changes

| Category | Change |
| -------- | ------ |
| Android toolchain | AGP 9.0.1+, Gradle 9.1.0+, and compile SDK 36+ are required |
| Display options | `showStopSigns` and `showTrafficLights` are removed |
| GPS events | The deprecated GPS availability API is removed in favor of `GpsAvailabilityChangeEvent` |
| Route results | `NavigationRouteStatus.routingTimeout` is a new Android result |
| Terrain maps | Android falls back to normal maps during navigation |
| Android Auto | Car App libraries must supply their own consumer ProGuard rules |
| Google Play | Apps must complete the Location Purpose Declaration |

### Step 1: Update the Android build configuration

Update your app's AGP declaration to **9.0.1 or later** and its Gradle wrapper to
**9.1.0 or later**. Use Kotlin **2.3.0 or later**, JDK **17 or later**, and
`compileSdk` **36 or later**. The minimum supported Android version remains
**API 24**.

For Flutter 3.44, retain the AGP 9 compatibility settings in
`android/gradle.properties`:

```properties
android.builtInKotlin=false
android.newDsl=false
```

Enabling built-in Kotlin instead requires Flutter 3.47 or later and migration of
your app and its plugins. See [Flutter's Kotlin migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin).

Remove any `android.nonFinalResIds=false` override. AGP 9's optimized resource
shrinker requires non-final resource IDs, which are enabled by default.

Enable core library desugaring and use
`com.android.tools:desugar_jdk_libs_nio:2.1.5`. See the
[Android installation instructions](README.md#android) for the configuration.

The native SDK's target API level 37 does not by itself change your app's
`targetSdk` setting. Raising `compileSdk` does not require raising `minSdk`.

> [!NOTE]
> JDK 21 is required to run this repository's Robolectric tests on API 36, not
> to build consuming apps. The plugin's Java and Kotlin JVM targets remain 17.
> See [Contributing](CONTRIBUTING.md#unit-tests) for test setup.

### Step 2: Remove the deprecated display options

Remove `showStopSigns` and `showTrafficLights` from
`NavigationDisplayOptions`. Traffic lights and stop signs are always enabled
during navigation when data is available on both Android and iOS.

```diff
 NavigationDisplayOptions(
   showDestinationMarkers: false,
-  showStopSigns: false,
-  showTrafficLights: false,
 )
```

There is no replacement option to hide stop signs or traffic lights.
`showDestinationMarkers` remains supported.

### Step 3: Migrate GPS availability listeners

Replace `GoogleMapsNavigator.setOnGpsAvailabilityListener` with
`GoogleMapsNavigator.setOnGpsAvailabilityChangeListener`. Replace callback and
event types as follows:

| Removed API | Replacement |
| ----------- | ----------- |
| `OnGpsAvailabilityEventCallback` | `OnGpsAvailabilityChangeEventCallback` |
| `GpsAvailabilityUpdatedEvent` | `GpsAvailabilityChangeEvent` |

The replacement event has two distinct fields:

- `isGpsLost` signals loss of a sufficiently reliable location.
- `isGpsValidForNavigation` indicates location quality suitable for navigation.

Choose the field appropriate to your app's behavior rather than treating either
as an interchangeable replacement for the old `available` boolean. Cancel the
returned stream subscription when it is no longer needed. This API remains
**Android-only**.

### Step 4: Handle routing timeouts

Update route-result switches to handle
`NavigationRouteStatus.routingTimeout`. Android emits this result when route
calculation times out on the routing backend. It is distinct from
`NavigationRouteStatus.networkError`.

This result can be returned by destination requests and simulations that
calculate a new route. No equivalent status is emitted by this plugin on iOS.

### Step 5: Review map behavior and native deprecations

On Android, terrain maps selected before navigation fall back to normal maps
while navigation is active. Terrain remains available for non-navigation maps;
do not remove `MapType.terrain` from map-only functionality.

Android header text-size customization and custom zoom in `followMyLocation`
remain functional, but their underlying native APIs are deprecated in 8.0.0.
Plan for their removal in a future native SDK release.

The plugin now uses native callback overloads for destination and simulation
requests. Dart callers continue to await the existing `Future` results; no
callback migration is required for those Dart methods.

### Step 6: Check Android Auto dependencies and Google Play declarations

Android Auto integrations must use `androidx.car.app:app` and
`androidx.car.app:app-projected` **1.3.0 or later** so their consumer ProGuard
rules are included. Navigation SDK 8.0.0 no longer bundles those keep rules. The
plugin and example already use 1.7.0.

When publishing to Google Play, complete the
[Location Purpose Declaration](https://support.google.com/googleplay/android-developer/answer/17033915#play_console_declaration),
selecting **Navigation** and any additional precise-location use cases.

### Rebuild and verify

Rebuild your app after updating the build configuration and Dart callsites:

```sh
flutter pub get
flutter analyze
flutter build apk
```

Exercise routing, navigation UI, GPS listeners, and any Android Auto integration
used by your app. Verify a release build as well, since R8 and resource shrinking
do not run in the same way in debug builds.

### Release notes

For the full upstream changes, review the
[Android Navigation SDK 8.0.0 release notes](https://developers.google.com/maps/documentation/navigation/android-sdk/release-notes#October_01_2026).
