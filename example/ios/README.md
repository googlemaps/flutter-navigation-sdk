# iOS Example Apps

This directory contains two iOS example apps to demonstrate different use cases of the Google Maps Navigation SDK:

## 1. Runner (Standard iOS App)
**Bundle ID:** `com.google.maps.flutter.navigationExample`

A standard iOS app without CarPlay support.

### Running from Command Line:
```bash
# From example/ directory
flutter run -d <device-id> -t lib/main.dart --flavor Runner
```

### Running from Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select the **Runner** scheme
3. Build and run

---

## 2. RunnerCarPlay (CarPlay-Enabled App)
**Bundle ID:** `com.google.maps.flutter.navigationExample.carplay`

An iOS app with full CarPlay support, including:
- Multi-scene setup (phone + car scenes)
- CarPlay entitlements
- CarPlay-specific delegate (`AppDelegateCarPlay`)
- Conditional compilation with `#if CARPLAY`

### Running from Command Line:
```bash
# From example/ directory
flutter run -d <device-id> -t lib/main.dart --flavor RunnerCarPlay
```

### Running from Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select the **RunnerCarPlay** scheme
3. Build and run

---

## Technical Details

### Key Differences

| Feature       | Runner               | RunnerCarPlay                |
| ------------- | -------------------- | ---------------------------- |
| Bundle ID     | `.navigationExample` | `.navigationExample.carplay` |
| Info.plist    | `Info.plist`         | `Info-CarPlay.plist`         |
| Entitlements  | None                 | `RunnerCarPlay.entitlements` |
| App Delegate  | `AppDelegate`        | `AppDelegateCarPlay`         |
| Scene Support | Single scene         | Multi-scene (phone + car)    |
| Swift Flags   | Default              | `-D CARPLAY`                 |

### How main.swift Selects the Delegate

The `main.swift` uses conditional compilation:

```swift
#if CARPLAY
  UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegateCarPlay.self)
  )
#else
  UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
  )
#endif
```

The `CARPLAY` flag is set via `OTHER_SWIFT_FLAGS` in the RunnerCarPlay target's build settings.

### Swift Package Manager (SPM) Support

Both targets support SPM. The shared scheme files are located in:
```
ios/Runner.xcodeproj/xcshareddata/xcschemes/
├── Runner.xcscheme
└── RunnerCarPlay.xcscheme
```

These schemes are version-controlled and shared across all developers.

### CocoaPods Configuration

The `Podfile` configures both targets:
- `Runner` target - standard iOS app
- `RunnerCarPlay` target - with CarPlay support

All pods have their deployment target set to iOS 16.0 minimum in the `post_install` hook.

---

## Troubleshooting

### Error: "requires minimum platform version 16.0"
Run `pod install` from the `ios/` directory. The Podfile's `post_install` hook sets all pods to iOS 16.0.

### Error: "You must specify a --flavor option"
Don't use `--flavor`. Use `--scheme` instead:
```bash
flutter run --scheme RunnerCarPlay
```

### Error: "Unable to get scheme file for RunnerCarPlay"
Remove any duplicate user-specific schemes:
```bash
rm -rf ios/Runner.xcodeproj/xcuserdata/*/xcschemes/RunnerCarPlay.xcscheme
```

### Both Apps Can't Be Installed at the Same Time
This is expected! They have different bundle IDs, so both apps can be installed simultaneously on the same device for testing purposes.
