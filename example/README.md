# google_maps_navigation_example

Demonstrates how to use the google_maps_navigation plugin.

## Setting up API Keys

To run the example project, you need to provide your Google Maps API key for both Android and iOS platforms.

### Android

1. The project uses the [Google Maps Secrets Gradle Plugin](https://developers.google.com/maps/documentation/android-sdk/secrets-gradle-plugin) for Android to securely manage the API key. 

2. Place your Google Maps API key in the `example/android/local.properties` file in the following format:

    ```
    MAPS_API_KEY=YOUR_API_KEY_HERE
    ```

   This key will be automatically used by the plugin during the build process.
   
   **Note**: To create the local.properties file, open example/android on Android Studio and it will generate that file for you.

3. Check if flutter.sdk path is configured on your local.properties file:

    ```
    flutter.sdk=PATH_TO_FLUTTER_SDK
    ```

### iOS

On iOS, example application implementation initially attempts to read the `MAPS_API_KEY` from Dart defines. If it is not provided in Dart defines, the implementation will then try to fetch the API key from Xcode environment variables. If it’s still not set, it will default to a placeholder. Here are the options to set the API key for example application:

**Option 1:** Running from the command line:

```bash
flutter run --dart-define=MAPS_API_KEY=YOUR_API_KEY
```

**Option 2:** Add the API key to the runner environment parameters in Xcode by editing the scheme and adding an environment variable named `MAPS_API_KEY`.

**Option 3:** Add the API key directly to the `example/ios/Runner/AppDelegate.swift` file by replacing "YOUR_API_KEY" string with your actual Google Maps API key:
```swift
...
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    var mapsApiKey = findMapApiKeyFromDartDefines("MAPS_API_KEY") ?? ProcessInfo.processInfo.environment["MAPS_API_KEY"] ?? ""
    if (mapsApiKey.isEmpty) {
        mapsApiKey = "YOUR_API_KEY" // REPLACE THIS TEXT WITH YOUR API KEY
    }
    GMSServices.provideAPIKey(mapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
...
```

**NOTE**: Please be aware that adding the API key directly to your project files or environment variables can risk exposing the key if you accidentally commit it to a public repository. Always ensure that sensitive information like API keys are not included in your commits.

If you have pod related issues to run the example code you can run the following commands from example/ios folder:
 - pod repo update
 - pod install

This should install all required pod files to run the example in iOS.