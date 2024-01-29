# Google Maps Navigation (Preview)

## Description

This repository contains a Flutter plugin that provides a [Google Maps Navigation](https://developers.google.com/maps/documentation/navigation) widget.


## Requirements

|             | Android | iOS       |
| ----------- | ------- | --------- |
| **Support** | SDK 23+ | iOS 14.0+ |

* A Flutter project
* A Google Cloud project with the [Navigation SDK enabled](https://developers.google.com/maps/documentation/navigation/android-sdk/set-up-project) and the [Maps SDK for iOS enabled](https://developers.google.com/maps/documentation/navigation/ios-sdk/config)
* An API key from the project above
* If targeting Android, [Google Play Services](https://developers.google.com/android/guides/overview) installed and enabled
* [Attributions and licensing text](https://developers.google.com/maps/documentation/navigation/android-sdk/set-up-project#include_the_required_attributions_in_your_app) added to your app

## Installation

1. This repository is currently private. You will need to add the package dependency using [Git with SSH](https://docs.flutter.dev/packages-and-plugins/using-packages#dependencies-on-unpublished-packages) in the app's `pubspec.yaml` file. See [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) for instructions on how to provide SSH keys.

```
  dependencies:
    google_maps_navigation:
      git:
        url: git@github.com:googlemaps/flutter-navigation-sdk.git
```

2. Follow the instructions below to add your API key to the approrpiate files in your Flutter project.

* Enable Google Maps SDK and Google Maps Navigation SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Select the project where you want to enable Google Maps Navigation.
  * Navigate to the "Google Maps Platform" through the main menu.
  * Under the Google Maps Platform menu, go to "[APIs & Services](https://console.cloud.google.com/google/maps-apis/api-list)".
  * For Android, enable "Maps SDK for Android" by selecting "ENABLE".
  * For iOS, enable "Maps SDK for iOS" by selecting "ENABLE".

* Generate an API key at <https://console.cloud.google.com/google/maps-apis/credentials>.

> [!IMPORTANT]
> [Apply API restrictions](https://developers.google.com/maps/api-security-best-practices#api-restriction) to the API key to limit usage to "Navigation SDK, "Maps SDK for Android", and "Maps SDK for iOS" for enhanced security and cost management. This helps guard against unauthorized use of your API key.

* Add your API key to the Flutter project using [these instructions for the corresponding Android and iOS files](https://developers.google.com/maps/flutter-package/config#step_4_add_your_api_key_to_the_project).

For more details, see [Google Navigation SDK Documentation](https://developers.google.com/maps/documentation/navigation).


### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 23
    }
}
```

To securely store your API key, it is recommended to use the [Google Maps Secrets Gradle Plugin](https://developers.google.com/maps/documentation/android-sdk/secrets-gradle-plugin). This plugin helps manage API keys without exposing them in your app's source code.

See example configuration for secrets plugin at example applications [build.gradle](./example/android/app/build.gradle) file.

### iOS

To set up, specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```swift
import UIKit
import Flutter
import GoogleMaps
import GoogleNavigation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR API KEY HERE")
    GMSServices.setMetalRendererEnabled(true)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Usage

You can now add a `GoogleMapsNavigationView` widget to your widget tree.

The view can be controlled with the `GoogleNavigationViewController` that is passed to via `onViewCreated` callback.

The `GoogleMapsNavigationView` widget should be used within a widget with a bounded size. Using it
in an unbounded widget will cause the application to throw a Flutter exception.

### Add a navigation view

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_navigation/google_maps_navigation.dart';

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
      await GoogleMapsNavigationManager.showTermsAndConditionsDialog(
        'Example title',
        'Example company',
      );
    }
    // Note: make sure user has also granted location permissions before starting navigation session.
    await GoogleMapsNavigator.initializeNavigationSession();
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
## Contributing

See the [Contributing guide](https://github.com/googlemaps/flutter-navigation-sdk/blob/main/CONTRIBUTING.md).

## Terms of Service

This package uses Google Maps Platform services, and any use of Google Maps Platform is subject to the [Terms of Service](https://cloud.google.com/maps-platform/terms).

For clarity, this package, and each underlying component, is not a Google Maps Platform Core Service.

## Support

This package is offered via an open source license. It is not governed by the Google Maps Platform Support [Technical Support Services Guidelines](https://cloud.google.com/maps-platform/terms/tssg), the [SLA](https://cloud.google.com/maps-platform/terms/sla), or the [Deprecation Policy](https://cloud.google.com/maps-platform/terms) (however, any Google Maps Platform services used by the library remain subject to the Google Maps Platform Terms of Service).

This package adheres to [semantic versioning](https://semver.org/) to indicate when backwards-incompatible changes are introduced. Accordingly, while the library is in version 0.x, backwards-incompatible changes may be introduced at any time. 

If you find a bug, or have a feature request, please [file an issue](https://github.com/googlemaps/flutter-navigation-sdk/issues) on GitHub. If you would like to get answers to technical questions from other Google Maps Platform developers, ask through one of our [developer community channels](https://developers.google.com/maps/developer-community). If you'd like to contribute, please check the [Contributing guide](https://github.com/googlemaps/flutter-navigation-sdk/blob/main/CONTRIBUTING.md).
