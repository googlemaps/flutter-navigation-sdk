# Migration Guide

This document covers breaking changes and migration steps between versions of
`google_navigation_flutter`.

## Table of Contents

- [Migrating from 0.12.1 to 0.13.x](#migrating-from-0121-to-013x)
- [Migrating from 0.12.0 to 0.12.1](#migrating-from-0120-to-0121)
- [Migrating from 0.11.x to 0.12.x](#migrating-from-011x-to-012x)

---

## Migrating from 0.12.1 to 0.13.x

### Update token-routing arguments

`GoogleMapsNavigator.setDestinationsWithToken` now takes one
`DestinationsWithToken` object. This is a breaking change from the positional
route-token string and named `displayOptions` introduced in 0.12.1. Move those
values into the object:

```dart
final NavigationRouteStatus status =
    await GoogleMapsNavigator.setDestinationsWithToken(
  DestinationsWithToken(
    routeToken: routeToken,
    travelMode: NavigationTravelMode.driving,
    displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
  ),
);
```

The token is required; `travelMode` and `displayOptions` are optional.
Destination markers are visible by default. Do not pass waypoints or routing
options: the token defines the destinations and actual routing parameters.

### Handle unsupported client travel modes

Only `NavigationTravelMode.driving` and `NavigationTravelMode.twoWheeler` are
accepted explicitly. Other explicit modes return
`NavigationRouteStatus.travelModeUnsupported` before changing route or display
state, even with an invalid token.

On iOS, the wrapper no longer resets the session to driving automatically.
Omitting `travelMode` preserves the current session mode; after walking,
cycling, or taxi, pass a supported mode explicitly to avoid
`NavigationRouteStatus.travelModeUnsupported`. On Android, an omitted mode
follows native token routing. A supported client mode does not override the
travel mode encoded in the token.

Unsupported modes are reported through the returned status, not an exception.
Session and terms-of-service errors retain precedence over mode validation;
missing route statuses and other native-call errors can still throw.

The deprecated `Destinations.routeTokenOptions` path is unchanged. Rebuild the
native app after upgrading because the Pigeon contract changed; hot reload
alone is not sufficient.

## Migrating from 0.12.0 to 0.12.1

Version 0.12.1 upgrades the Android Navigation SDK from 8.0.0 to 8.1.0.
The iOS Navigation SDK remains at 11.3.0. Existing destination APIs remain
supported; the new token-only API is available on both platforms.

For the upstream Android changes, see the
[Navigation SDK 8.1.0 release notes](https://developers.google.com/maps/documentation/navigation/android-sdk/release-notes#November_04_2026).

### Migrate route-token requests

Use `GoogleMapsNavigator.setDestinationsWithToken` instead of
`Destinations.routeTokenOptions`, which is deprecated:

```dart
final NavigationRouteStatus status =
    await GoogleMapsNavigator.setDestinationsWithToken(
  routeToken,
  displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
);
```

From 0.13.0, these arguments are wrapped in a `DestinationsWithToken` object;
see [Update token-routing arguments](#update-token-routing-arguments).

The token defines the destinations and routing parameters on both Android and
iOS. Do not pass waypoints, a travel mode, or routing options to the new method.
`displayOptions` is optional. A previous walking or cycling route does not
prevent using a supported route token.

Existing `setDestinations` calls with `routeTokenOptions` remain supported,
including their previous platform-specific behavior: Android passes the
waypoints with the token, while iOS does not. New callers should use the
dedicated method.
The deprecated `routeTokenOptions` parameter may be removed in a future major
release.

On both platforms, routing options encoded in the route token, including the
travel mode, take precedence over client-side settings. A successful route
status means a route was found, not necessarily that the planned route was
followed exactly.

## Migrating from 0.11.x to 0.12.x

Version 0.12.0 upgrades the Android Navigation SDK from 7.9.0 to 8.0.0 and the
iOS Navigation SDK from 11.1.0 to 11.3.0. The shared Dart API changes below
apply to apps targeting either platform.

### Update the Android build configuration

Use Flutter **3.44 or later**, AGP **9.0.1 or later**, Gradle **9.1.0 or later**,
Kotlin **2.3.0 or later**, JDK **17 or later**, and
`compileSdk` **36 or later**. The minimum supported Android version remains
**API 24**.

Flutter 3.44 to 3.46 support AGP 9 only with built-in Kotlin disabled, so keep
these settings in `android/gradle.properties`:

```properties
android.builtInKotlin=false
android.newDsl=false
```

Flutter 3.47 or later can enable built-in Kotlin once your app and its plugins
support it. See Flutter's
[built-in Kotlin migration guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers).

Remove any `android.nonFinalResIds=false` override. AGP 9's optimized resource
shrinker requires non-final resource IDs, which are enabled by default.

Enable core library desugaring and use
`com.android.tools:desugar_jdk_libs_nio:2.1.5`. See the
[Android installation instructions](README.md#android) for the configuration.

The native SDK's target API level 37 does not itself change your app's `targetSdk`.

### Remove the deprecated display options

Remove `showStopSigns` and `showTrafficLights` from
`NavigationDisplayOptions`. Traffic lights and stop signs are always enabled
during navigation when data is available on both Android and iOS.

There is no replacement option to hide them; `showDestinationMarkers` is unchanged.

### Migrate GPS availability listeners

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

### Handle routing timeouts

Update route-result switches to handle
`NavigationRouteStatus.routingTimeout`. Android emits this result when route
calculation times out on the routing backend. It is distinct from
`NavigationRouteStatus.networkError`.

This result can be returned by destination requests and simulations that
calculate a new route. No equivalent status is emitted by this plugin on iOS.

### Raise the iOS deployment target

iOS Navigation SDK 11.3.0 requires **iOS 17.0 or later** and Xcode 26. Set the
`Runner` target's iOS deployment target to 17.0. See the
[iOS installation instructions](README.md#ios).

### Handle a missing route status

`GoogleMapsNavigator.setDestinations` throws `RouteStatusUnavailableException`
when the native SDK completes a route request without a route status. On
Android, the `Simulator.simulateLocationsAlongNewRoute` methods throw it as well.
Routes that are not found still complete with a failure
`NavigationRouteStatus`, as before.

### Review route token behavior

On iOS, `setDestinations` with `RouteTokenOptions` sends only the route token to
the Navigation SDK; the token defines the destinations, and
`Destinations.waypoints` is not sent. Android still sends the waypoints with
the token.

On both platforms, routing options encoded in the route token, including the
travel mode, take precedence over client-side settings. This upstream change
applies to all Navigation SDK versions.

### Review terrain map behavior

On Android, terrain maps selected before navigation fall back to normal maps
while navigation is active. Terrain remains available for non-navigation maps;
do not remove `MapType.terrain` from map-only functionality.

### Check native dependencies and Google Play declarations

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

### Release notes

For the full upstream changes, review the
[Android Navigation SDK 8.0.0 release notes](https://developers.google.com/maps/documentation/navigation/android-sdk/release-notes#October_01_2026)
and the
[iOS Navigation SDK 11.3.0 release notes](https://developers.google.com/maps/documentation/navigation/ios-sdk/release-notes#November_02_2026).
