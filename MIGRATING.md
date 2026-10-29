# Migrating to Android Navigation SDK 8.0.0

This upgrade replaces Android Navigation SDK 7.9.0 with 8.0.0. The native iOS SDK
is unchanged, but the shared Dart API removals below apply to apps targeting
either platform.

## Update the Android build configuration

Use Flutter **3.44 or later**, AGP **9.0.1 or later**, Gradle **9.1.0 or later**,
Kotlin **2.3.0 or later**, JDK **17 or later**, and
`compileSdk` **36 or later**. The minimum supported Android version remains
**API 24**.

For Flutter 3.44, retain the AGP 9 compatibility settings in
`android/gradle.properties`:

```properties
android.builtInKotlin=false
android.newDsl=false
```

Remove any `android.nonFinalResIds=false` override. AGP 9's optimized resource
shrinker requires non-final resource IDs, which are enabled by default.

Enable core library desugaring and use
`com.android.tools:desugar_jdk_libs_nio:2.1.5`. See the
[Android installation instructions](README.md#android) for the configuration.

The native SDK's target API level 37 does not itself change your app's `targetSdk`.

## Remove the deprecated display options

Remove `showStopSigns` and `showTrafficLights` from
`NavigationDisplayOptions`. Traffic lights and stop signs are always enabled
during navigation when data is available on both Android and iOS.

There is no replacement option to hide them; `showDestinationMarkers` is unchanged.

## Migrate GPS availability listeners

Replace `GoogleMapsNavigator.setOnGpsAvailabilityListener` with
`GoogleMapsNavigator.setOnGpsAvailabilityChangeListener`. Replace callback and
event types as follows:

| Removed API | Replacement |
| ----------- | ----------- |
| `OnGpsAvailabilityEventCallback` | `OnGpsAvailabilityChangeEventCallback` |
| `GpsAvailabilityUpdatedEvent` | `GpsAvailabilityChangeEvent` |

The replacement event has two distinct fields:

- `isGpsLost` signals loss of a sufficiently reliable location after a short timeout.
- `isGpsValidForNavigation` indicates location quality suitable for navigation;
  it can remain false briefly after navigation starts.

Neither field is an interchangeable replacement for the old `available` boolean.
Choose the field appropriate to your app's behavior. This API remains **Android-only**.

## Handle routing timeouts

Update route-result switches to handle
`NavigationRouteStatus.routingTimeout`. Android emits this result when route
calculation times out on the routing backend. It is distinct from
`NavigationRouteStatus.networkError`.

This result can be returned by destination requests and simulations that
calculate a new route. No equivalent status is emitted by this plugin on iOS.

## Review terrain map behavior

On Android, terrain maps selected before navigation fall back to normal maps
while navigation is active. Terrain remains available for non-navigation maps;
do not remove `MapType.terrain` from map-only functionality.

## Check native dependencies and Google Play declarations

Android Auto integrations must use `androidx.car.app:app` and
`androidx.car.app:app-projected` **1.3.0 or later** so their consumer ProGuard
rules are included. Navigation SDK 8.0.0 no longer bundles those keep rules.
See the [Android Auto guide](doc/android-auto.md#requirements).

If your native app code relied on implicit dependencies on
`com.github.bumptech.glide:glide`, `com.github.bumptech.glide:okhttp3-integration`,
or `org.jetbrains.kotlin:kotlin-reflect`, declare them explicitly in your app's
Gradle dependencies: SDK 8.0.0 no longer supplies them.

When publishing to Google Play, complete the
[Location Purpose Declaration](https://support.google.com/googleplay/android-developer/answer/17033915#play_console_declaration),
selecting **Navigation** and any additional precise-location use cases.

## Release notes

For the full upstream changes, review the
[Android Navigation SDK 8.0.0 release notes](https://developers.google.com/maps/documentation/navigation/android-sdk/release-notes#October_01_2026).
