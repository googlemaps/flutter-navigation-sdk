# Navigation for Apple CarPlay

This guide explains how to enable and integrate Apple CarPlay with the Flutter SDK.

## Requirements

- iOS device or iOS simulator
- CarPlay Simulator
- CarPlay entitlement for your application (provided by Apple)

## Setup

Refer to the [Apple CarPlay Developer Guide](https://developer.apple.com/carplay/) to understand how CarPlay works and to complete the initial setup. Key steps include:

- Adding the CarPlay entitlement to your Xcode project.
- Creating a separate scene for the CarPlay map and enabling support for multiple scenes.

### SceneDelegate for CarPlay

Once your project is configured to support multiple scenes, and you are setting up a dedicated scene for CarPlay, you can leverage the `BaseCarSceneDelegate` provided by the SDK. This base class simplifies the setup by handling initialization, teardown, and rendering the map on the CarPlay display.

Please refer to the `CarSceneDelegate.swift` file in the iOS example app for guidance.

To customize the CarPlay experience, override the `getTemplate` method in your custom `CarSceneDelegate` class, providing your own `CPMapTemplate`:

```swift
override func getTemplate() -> CPMapTemplate {
    let template = CPMapTemplate()
    template.showPanningInterface(animated: true)

    let button = CPBarButton(title: "Custom Event") { [weak self] _ in
      let data = ["sampleDataKey": "sampleDataContent"]
      self?.sendCustomNavigationAutoEvent(event: "CustomCarPlayEvent", data: data)
    }
    template.leadingNavigationBarButtons = [button]
    return template
  }
```

For advanced customization, you can bypass the base class and implement your own delegate inheriting `CPTemplateApplicationSceneDelegate`. You can use the provided `BaseCarSceneDelegate` base class as a reference on how to do that.

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

For a fully functional CarPlay implementation, check out the [Runner](./example/ios/) Xcode project, which includes the `RunnerCarPlay` build target. The sample already contains test entitlement so you don't need to request one from Apple to run it.
