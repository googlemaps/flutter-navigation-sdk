# Navigation for Android Auto

This guide explains how to enable and integrate Android Auto with the Flutter Navigation SDK.

## Requirements

- Android device
- Android Auto test device or Android Automotive OS emulator

## Setup

Refer to the [Android for Cars developer documentation](https://developer.android.com/training/cars) to understand how the Android Auto works and to complete the initial setup. Key steps include:

- Installing Android for Cars App Library.
- Configuring your app's manifest file to include Android Auto.
- Declaring a minimum car-app level in your manifest.
- Creating 'CarAppService' and session

For all the steps above, you can refer to the Android example application for guidance.

### Screen for Android Auto

Once your project is configured accordingly, and you are ready to build the screen for Android Auto, you can leverage the `AndroidAutoBaseScreen` provided by the SDK. This base class simplifies the setup by handling initialization, teardown, and rendering the map on the Android Auto display.

Please refer to the `SampleAndroidAutoScreen.kt` file in the Android example app for guidance.

To customize the Android Auto experience, override the `onGetTemplate` method in your custom AndroidAutoScreen class, providing your own `Template`:

```kotlin
override fun onGetTemplate(): Template {
    /** ... */
    @SuppressLint("MissingPermission")
    val navigationTemplateBuilder =
        NavigationTemplate.Builder()
            .setActionStrip(
                ActionStrip.Builder()
                    .addAction(
                        Action.Builder()
                            .setTitle("Re-center")
                            .setOnClickListener {
                                if (mGoogleMap == null) return@setOnClickListener
                                mGoogleMap!!.followMyLocation(GoogleMap.CameraPerspective.TILTED)
                            }
                            .build())
                    .addAction(
                        Action.Builder()
                            .setTitle("Custom event")
                            .setOnClickListener {
                                sendCustomNavigationAutoEvent("CustomAndroidAutoEvent", mapOf("sampleDataKey" to "sampleDataContent"))
                            }
                            .build())
                    .build())
            .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())
    /** ... */
}
```

For advanced customization, you can bypass the base class and implement your own screen by inheriting `Screen`. You can use the provided `AndroidAutoBaseScreen` base class as a reference on how to do that.

### Flutter Setup

On the Flutter side, you can use the `GoogleMapsAutoViewController` to interface with the CarPlay instance. The `GoogleMapsAutoViewController` allows you to call map functions on the CarPlay map view, and you can manage listeners using the provided functions.

```dart
final GoogleMapsAutoViewController _autoViewController =
      GoogleMapsAutoViewController();

_autoViewController.listenForCustomNavigationAutoEvents((event) {
    showMessage("Received event: ${event.event}");
});

Future<void> _setMapTypeForAutoToSatellite() async {
    await _autoViewController.setMapType(mapType: MapType.satellite);
}
```

For a more detailed example, refer to the `lib/pages/navigation.dart` file in the Flutter example application.

## Example Project

For a fully functional Android Auto implementation, check out the [Android Studio example app](./example/android/).
