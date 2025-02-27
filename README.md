# Google Navigation for Flutter (Beta)

## Description

This repository contains a Flutter plugin that provides a [Google Navigation](https://developers.google.com/maps/documentation/navigation) widget to Flutter apps targeting Android and iOS.

> [!NOTE]
> This package is in Beta until it reaches version 1.0. According to [semantic versioning](https://semver.org/#spec-item-4), breaking changes may be introduced before 1.0.

## Requirements

|                                 | Android       | iOS       |
| ------------------------------- | ------------- | --------- |
| **Minimum mobile OS supported** | API level 23+ | iOS 15.0+ |

* A Flutter project
* A Google Cloud project
  *  If you are a Mobility Services developer, you must contact Sales as described in [Mobility services documentation](https://developers.google.com/maps/documentation/transportation-logistics/mobility).
  *  If you are not a Mobility Services developer, refer to [Setup Google Cloud Project](https://developers.google.com/maps/documentation/navigation/android-sdk/cloud-setup) for instructions.
* An [API key](https://console.cloud.google.com/google/maps-apis/credentials) from the project above
  * The API key must be configured for both Android and iOS. Refer to [Android Using Api Keys](https://developers.google.com/maps/documentation/navigation/android-sdk/get-api-key) and [iOS Using Api Keys](https://developers.google.com/maps/documentation/navigation/ios-sdk/get-api-key) respectively for instructions.
* If targeting Android, [Google Play Services](https://developers.google.com/android/guides/overview) installed and enabled and minimum Kotlin version 2.0
* [Attributions and licensing text](https://developers.google.com/maps/documentation/navigation/android-sdk/set-up-project#include_the_required_attributions_in_your_app) added to your app

> [!IMPORTANT]
> [Apply API restrictions](https://developers.google.com/maps/api-security-best-practices#api-restriction) to the API key to limit usage to "Navigation SDK, "Maps SDK for Android", and "Maps SDK for iOS" for enhanced security and cost management. This helps guard against unauthorized use of your API key.

## Installation

To add the Google Navigation for Flutter package to your project, use the command:
```
flutter pub add google_navigation_flutter
```

### Android

Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

If `minSdkVersion` is set to less than 34 (API 34), you need to configure desugaring for your Android app.
To enable desugaring, add the following configurations to `android/app/build.gradle` file:
```groovy
android {
    ...
    compileOptions {
        coreLibraryDesugaringEnabled true
        ...
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs_nio:2.0.4'
}
```

### iOS

1. Open the ios/Podfile config file in your preferred IDE.
2. Add the following lines to the beginning of this Podfile:

```
  # Set platform to 15.0 to enable latest Google Maps SDK
  platform :ios, '15.0'
```
3. In Xcode open Info.plist file and add `App registers for location updates` to the list of `Required background modes`

### Set Google Maps API Key

Add your API key to the Flutter project using [these instructions for the corresponding Android (build.gradle) and iOS (AppDelegate.swift) files](https://developers.google.com/maps/flutter-package/config#step_4_add_your_api_key_to_the_project). The instructions for this step in the google_maps_flutter package documentation apply to the google_navigation_flutter package as well.

  See the example configuration for Secrets Gradle Plugin in the example app's [build.gradle](./example/android/app/build.gradle) file.
  To securely load your API key, use the [Secrets Gradle Plugin](https://developers.google.com/maps/documentation/android-sdk/secrets-gradle-plugin). This plugin helps manage API keys without exposing them in your app's source code.

For more details, see [Google Navigation SDK Documentation](https://developers.google.com/maps/documentation/navigation).

## Usage

You can now add a `GoogleMapsNavigationView` widget to your widget tree.

The view can be controlled with the `GoogleNavigationViewController` that is passed to via `onViewCreated` callback.

The `GoogleMapsNavigationView` widget should be used within a widget with a bounded size. Using it
in an unbounded widget will cause the application to throw a Flutter exception.

You can also add a bare GoogleMapsMapView that works as a normal map view without navigation functionality.

### Add a navigation view

```dart
import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

class NavigationSample extends StatefulWidget {
  const NavigationSample({super.key});

  @override
  State<NavigationSample> createState() => _NavigationSampleState();
}

class _NavigationSampleState extends State<NavigationSample> {
  GoogleNavigationViewController? _navigationViewController;
  bool _navigationSessionInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNavigationSession();
  }

  Future<void> _initializeNavigationSession() async {
    if (!await GoogleMapsNavigator.areTermsAccepted()) {
      await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'Example title',
        'Example company',
      );
    }
    // Note: make sure user has also granted location permissions before starting navigation session.
    await GoogleMapsNavigator.initializeNavigationSession(taskRemovedBehavior: TaskRemovedBehavior.continueService);
    setState(() {
      _navigationSessionInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Navigation Sample')),
      body: _navigationSessionInitialized
          ? GoogleMapsNavigationView(
              onViewCreated: _onViewCreated,
              initialNavigationUIEnabledPreference: NavigationUIEnabledPreference.disabled,
              // Other view initialization settings
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _onViewCreated(GoogleNavigationViewController controller) {
    _navigationViewController = controller;
    controller.setMyLocationEnabled(true);
    // Additional setup can be added here.
  }

  @override
  void dispose() {
    if (_navigationSessionInitialized) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }
}
```

#### Task Removed Behavior

The `taskRemovedBehavior` parameter of navigation session initialization defines how the navigation should behave when a task is removed from the recent apps list on Android. It can either:

 - `TaskRemovedBehavior.continueService`: Continue running in the background. (default)
 - `TaskRemovedBehavior.quitService`: Shut down immediately.

This parameter has only an effect on Android.

### Add a map view

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Navigation Sample')),
      body: _navigationSessionInitialized
          ? GoogleMapsMapView(
              onViewCreated: _onViewCreated,
              initialCameraPosition: CameraPosition(
                // Initialize map to user location.
                target: _userLocation!,
                zoom: 15,
              ),
              // Other view initialization settings
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

```

See the [example](./example) directory for a complete navigation sample app.

### Requesting and handling permissions

The Google Navigation SDK Flutter plugin offers functionalities that necessitate specific permissions from the mobile operating system. These include, but are not limited to, location services, background execution, and receiving background location updates.

> [!NOTE]
> The management of these permissions falls outside the scope of the Navigation SDKs for Android and iOS. As a developer integrating these SDKs into your applications, you are responsible for requesting and obtaining the necessary permissions from the users of your app.

You can see example of handling permissions in the [main.dart](./example/lib/main.dart) file of the example application:

```dart
PermissionStatus _locationPermissionStatus = PermissionStatus.denied;

// ...

/// Request permission for accessing the device's location.
///
/// Android: Fine and Coarse Location
/// iOS: CoreLocation (Always and WhenInUse)
Future<void> _requestLocationPermission() async {
  final PermissionStatus status = await Permission.location.request();

  setState(() {
    _locationPermissionStatus = status;
  });
}

// ...

@override
Widget build(BuildContext context) {
  _requestLocationPermission();
  ...
}
```

## Support for Android Auto and Apple CarPlay
This plugin is compatible with both Android Auto and Apple CarPlay infotainment systems. For more details, please refer to the respective platform documentation:

- [Android Auto documentation](./ANDROIDAUTO.md)
- [CarPlay documentation](./CARPLAY.md)

## Known issues

### Compatibility with other libraries

This package uses the Google Maps [Navigation SDK](https://mapsplatform.google.com/maps-products/navigation-sdk/) for Android and iOS, which includes a dependency on the `Google Maps SDK`. If your project includes other flutter libraries with `Google Maps SDK` dependencies, you may encounter build errors due to version conflicts. To avoid this, it's recommended to avoid using multiple packages with Google Maps dependencies.

> [!NOTE]
> This package provides a `GoogleMapsMapView` widget, which can be used as a classic Google Maps view without navigation. See [Add a map view](#add-a-map-view) for details.

## Contributing

See the [Contributing guide](https://github.com/googlemaps/flutter-navigation-sdk/blob/main/CONTRIBUTING.md).

## Terms of Service

This library uses Google Maps Platform services. Use of Google Maps Platform services through this library is subject to the [Google Maps Platform Terms of Service](https://cloud.google.com/maps-platform/terms).

This library is not a Google Maps Platform Core Service. Therefore, the Google Maps Platform Terms of Service (e.g. Technical Support Services, Service Level Agreements, and Deprecation Policy) do not apply to the code in this library.

## Support

This package is offered via an open source license. It is not governed by the Google Maps Platform Support [Technical Support Services Guidelines](https://cloud.google.com/maps-platform/terms/tssg), the [SLA](https://cloud.google.com/maps-platform/terms/sla), or the [Deprecation Policy](https://cloud.google.com/maps-platform/terms) (however, any Google Maps Platform services used by the library remain subject to the Google Maps Platform Terms of Service).

This package adheres to [semantic versioning](https://semver.org/) to indicate when backwards-incompatible changes are introduced. Accordingly, while the library is in version 0.x, backwards-incompatible changes may be introduced at any time.

If you find a bug, or have a feature request, please [file an issue](https://github.com/googlemaps/flutter-navigation-sdk/issues) on GitHub. If you would like to get answers to technical questions from other Google Maps Platform developers, ask through one of our [developer community channels](https://developers.google.com/maps/developer-community). If you'd like to contribute, please check the [Contributing guide](https://github.com/googlemaps/flutter-navigation-sdk/blob/main/CONTRIBUTING.md).
