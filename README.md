# Google Maps Navigation

A Flutter plugin that provides a [Google Maps Navigation](https://developers.google.com/maps/documentation/navigation) widget.

|             | Android | iOS       |
| ----------- | ------- | --------- |
| **Support** | SDK 23+ | iOS 14.0+ |

## Usage

To use this plugin, add `google_maps_navigation` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

## Getting Started

* Enable Google Maps SDK and Google Maps Navigation SDK for each platform.
  * Go to [Google Developers Console](https://console.cloud.google.com/).
  * Select the project where you want to enable Google Maps Navigation.
  * Navigate to the "Google Maps Platform" through the main menu.
  * Under the Google Maps Platform menu, go to "[APIs & Services](https://console.cloud.google.com/google/maps-apis/api-list)".
  * For Android, enable "Maps SDK for Android" by selecting "ENABLE".
  * For iOS, enable "Maps SDK for iOS" by selecting "ENABLE".

* Generate an API key at <https://console.cloud.google.com/google/maps-apis/credentials>.
  * **Important**: Restrict your API key usage to the "Navigation SDK, "Maps SDK for Android" and "Maps SDK for iOS" for enhanced security and cost management. This prevents unauthorized use of your API key on other services.

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

### Integration Overview

You can now add a `GoogleMapsNavigationView` widget to your widget tree.

The view can be controlled with the `GoogleNavigationViewController` that is passed to via `onViewCreated` callback.

The `GoogleMapsNavigationView` widget should be used within a widget with a bounded size. Using it
in an unbounded widget will cause the application to throw a Flutter exception.

### Sample Usage

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
              initialNavigationUiEnabled: false,
              // Other view initialization settings
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _onViewCreated(GoogleNavigationViewController controller) {
    _navigationViewController = controller;
    controller.enableMyLocation(enabled: true);
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

## Permissions
The Google Navigation SDK Flutter plugin offers functionalities that necessitate specific permissions from the mobile operating system. These include, but are not limited to, location services, background execution, and receiving background location updates.

It is important to note that the management of these permissions falls outside the scope of the Google Navigation and Driver SDKs. As a developer integrating these SDKs into your applications, you are responsible for requesting and obtaining the necessary permissions from the users of your app.

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