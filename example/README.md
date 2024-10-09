# google_navigation_flutter_example

Demonstrates how to use the google_navigation_flutter plugin.

## Setting up API Keys

To run the example project, you need to provide your Google Maps API key for both Android and iOS platforms.
Both Android and iOS builds are able to use the `MAPS_API_KEY` variable provided through Dart defines.
However, this can be overridden to use separate, platform-specific API keys if needed.

### Using Dart defines

Using Dart defines to provide the Google Maps API key is the preferred method for this example app. It allows the key to be utilized in Dart code for accessing Google Maps services, such as the Routes API. Additionally, Patrol integration tests should also be run with the API key provided via Dart defines.

Run the app with the API key as a Dart define.
```bash
flutter run --dart-define MAPS_API_KEY=YOUR_API_KEY
```

The example app demonstrates multiple ways to provide the Maps API key for platforms.

### Android specific API key

For Android, the example app determines the `MAPS_API_KEY` using the following order (first match applies):
1. `MAPS_API_KEY` variable in `local.properties` file
2. `MAPS_API_KEY` variable in environment variables
3. `MAPS_API_KEY` variable in Dart defines

#### Setting the API Key in local.properties
The project uses the [Google Maps Secrets Gradle Plugin](https://developers.google.com/maps/documentation/android-sdk/secrets-gradle-plugin) for secure API key management. Place your Google Maps API key in `example/android/local.properties` file in the following format:

```text
MAPS_API_KEY=YOUR_API_KEY_HERE
```

This key will be specifically used for the Android build, overriding the Dart define value.

> [!NOTE]
> `local.properties` file should always be listed in your .gitignore file to ensure it is not committed to your repository.

### iOS specific API key

For iOS, the app attempts to read the `MAPS_API_KEY` in this order (first match applies):

1. `MAPS_API_KEY` variable in Xcode environment variables
2. `MAPS_API_KEY` variable in Dart defines
3. Default API key from `AppDelegate.swift`.

#### Set the API key

**1. Option: Xcode Environment Variables**

Add an environment variable named `MAPS_API_KEY` in the Xcode scheme settings.

**2. Option: Directly in AppDelegate.swift**

Set the API key directly in `example/ios/Runner/AppDelegate.swift`:

```swift
...
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool { 
    GMSServices.provideAPIKey("YOUR_API_KEY") // REPLACE THIS TEXT WITH YOUR API KEY
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
...
```

> [!NOTE]
> Be cautious with API keys. Avoid exposing them in public repositories, especially when hardcoded in the project files or the environment variables.

## Running the example app

To run the example app, follow these steps:
1. Start the emulator or connect your device.
2. Run the following command from the root of the example project: 
    ``` bash
    cd example
    flutter run
    ```
If you want to run the example app with a specific API key, see the [Setting up API Keys](#setting-up-api-keys) section.

> [!TIP]
> If you encounter pod-related issues when running the example code on iOS, you can try running the following commands from the `example/ios` folder:
>  - pod repo update
>  - pod install
> 
> These commands will update and install the required pod files specifically for iOS.
