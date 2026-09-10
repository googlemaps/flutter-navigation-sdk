<!--
Copyright 2026 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->

# Agent Guide for Google Navigation for Flutter

This file provides instructions for AI coding agents working in this repository.
Read `README.md` and `CONTRIBUTING.md` before making substantial changes, and
follow existing code and test patterns when they are more specific than this
guide.

## Core rules

- Keep changes focused on the requested issue. Do not perform unrelated cleanup
  or broad refactoring without a clear need.
- Preserve existing public API behavior unless the task explicitly calls for a
  breaking change.
- Maintain Android and iOS parity for cross-platform features. Do not silently
  implement a public API on only one platform.
- Never hand-edit generated files. Change their source definitions and run the
  appropriate generator.
- Add or update tests for behavior changes and bug fixes.
- Update public documentation and the example app when user-facing behavior or
  API usage changes.
- Never commit API keys, credentials, signing material, or other secrets.
- Do not claim that checks passed unless they were actually run successfully.

## Repository layout

The repository contains one Flutter plugin and its example application:

- `lib/`: Public Dart API and plugin implementation.
  - `lib/google_navigation_flutter.dart`: Main public library export file.
  - `lib/src/`: Controllers, widgets, types, platform interfaces, method-channel
    code, and platform-specific Dart implementations.
- `pigeons/messages.dart`: Source of truth for the Pigeon platform-channel API.
- `android/`: Android plugin implementation and Kotlin unit tests.
- `ios/`: iOS plugin implementation and Swift package sources.
- `test/`: Dart unit tests, generated Pigeon tests, and generated mocks.
- `example/`: Example Flutter application, native iOS tests, and Patrol
  integration tests.
- `doc/`: Additional documentation and assets.
- `tool/`: Repository scripts, including the iOS native test runner.
- `.github/workflows/`: CI configuration and the current CI tool versions.

## Development setup

Use Flutter and Dart versions that satisfy `pubspec.yaml`. When reproducing a CI
failure, use the versions pinned in `.github/workflows/` rather than copying
version numbers into this file.

From the repository root, install the Melos version used by CI and bootstrap the
workspace. Replace `VERSION_FROM_CI` with the `melos-version` value in
`.github/workflows/test-and-build.yaml`:

```sh
dart pub global activate melos VERSION_FROM_CI
melos bootstrap
```

Additional tools depend on the files being changed:

- Android work requires the Java version configured by CI and a working Android
  SDK.
- iOS work requires macOS, the Xcode version used by CI, and `swift-format`.
- iOS uses Swift Package Manager; CocoaPods is not supported. Follow the SwiftPM
  setup in `README.md`.
- New source files may require the `addlicense` command described in
  `CONTRIBUTING.md`.
- Patrol is required only for integration tests. Use the Patrol CLI version
  configured by the integration-test workflow.

## Common commands

Run commands from the repository root unless noted otherwise.

```sh
# Static analysis. Warnings and infos are treated as failures.
melos run flutter-analyze

# Format Dart, Kotlin, and Swift sources.
melos run format

# Unit tests.
melos run test:dart
melos run test:android
melos run test:ios

# Release builds of the example app.
melos run flutter-build-android
melos run flutter-build-ios

# License checks.
melos run check-license-header
```

Before running native iOS tests on a fresh checkout, generate the Flutter iOS
configuration from `example/` (as CI does):

```sh
(cd example && flutter build ios --config-only)
```

The iOS test script accepts `TEST_DEVICE` and `TEST_OS` environment variables
when its defaults do not match the installed simulator runtime:

```sh
TEST_DEVICE='iPhone 17 Pro' TEST_OS='26.5' melos run test:ios
```

Treat the values above as examples. Use an installed simulator and the runtime
expected by the current CI workflow.

For a focused Dart test during development:

```sh
flutter test test/path/to/test_file.dart
```

CI's formatting validation script expects a clean checkout and fails when any
tracked file changes after formatting. In a normal working tree, run
`melos run format` and inspect `git diff` instead of treating that validation
script as a general-purpose local command.

## Generated code

### Pigeon messages

`pigeons/messages.dart` is the source of truth for platform-channel messages.
After changing it, run:

```sh
melos run generate:pigeon
```

This regenerates files including:

- `lib/src/method_channel/messages.g.dart`
- `android/src/main/kotlin/com/google/maps/flutter/navigation/messages.g.kt`
- `ios/google_navigation_flutter/Sources/google_navigation_flutter/messages.g.swift`
- `test/messages_test.g.dart`

Do not edit any of these generated files directly. Include all generator output
that belongs to the source change, and review it before committing.

### Mockito mocks

Tests use generated Mockito mocks. When a mocked interface or a
`@GenerateMocks` declaration changes, run:

```sh
melos run generate:mocks
```

Do not edit `*.mocks.dart` files directly. The generation command also formats
files and applies license headers, so review the complete resulting diff.

## Implementing API and platform changes

A cross-platform API change commonly touches several layers. Check each layer
rather than stopping after the Dart code compiles:

1. Add or update the public Dart type, method, property, callback, or export.
2. Update the relevant platform interface or method-channel abstraction.
3. Change `pigeons/messages.dart` when the native bridge contract changes, then
   regenerate all Pigeon outputs.
4. Update Dart-to-platform and platform-to-Dart conversion code.
5. Implement equivalent behavior in Kotlin and Swift.
6. Add Dart tests and native tests for the affected behavior.
7. Update API documentation, `README.md`, `doc/`, and the example when users need
   new instructions or a migration step.

For platform-specific limitations, document the limitation in the public Dart
API and use the repository's established unsupported-operation behavior. Do not
silently no-op or return fabricated success.

Be especially careful with lifecycle-sensitive code:

- Release listeners, delegates, views, and native resources during disposal.
- Avoid retaining Flutter views or platform views beyond their lifecycle.
- Keep asynchronous callbacks and event streams from firing after disposal.
- Preserve nullability, numeric units, enum mappings, and error semantics across
  Dart, Kotlin, and Swift.

## Testing expectations

Run the narrowest relevant tests while iterating, then run the complete checks
for every affected layer before finishing.

- Dart-only implementation or type changes: run analysis and Dart tests.
- Kotlin changes: also run Android unit tests and the Android example build.
- Swift changes: also run iOS native tests and the iOS example build.
- Pigeon or public cross-platform API changes: regenerate code and test Dart,
  Android, and iOS.
- Example application or end-to-end behavior changes: run the relevant Patrol
  test on each affected platform when the required SDK, simulator/emulator, and
  credentials are available.

When fixing a bug, prefer a regression test that fails before the fix and passes
after it. Keep tests deterministic; do not add arbitrary sleeps when an
observable condition can be awaited.

### Patrol integration tests

Run integration tests from `example/` with a Maps API key supplied at runtime:

```sh
cd example
patrol test --dart-define=MAPS_API_KEY="$MAPS_API_KEY"
```

Never place a real API key in source files, committed configuration, test output,
or documentation examples.

New Patrol tests must handle the initial location permission and terms-of-service
flow using the shared helper established by the existing tests:

```dart
await checkLocationDialogAndTosAcceptance($);
```

Follow the current numbered files in `example/patrol_test/` for naming,
initialization, teardown, and interaction patterns.

## Code style and documentation

- Run `melos run format`; do not manually imitate formatter output.
- Keep `flutter analyze` clean, including informational diagnostics.
- Follow effective Dart conventions and the repository's existing naming and
  null-safety patterns.
- Follow the neighboring Kotlin and Swift implementation style. Keep platform
  behavior structurally similar where practical, while still using idiomatic
  platform APIs.
- Add Dart documentation to public APIs. Explain units, valid ranges, lifecycle
  requirements, asynchronous behavior, errors, and platform differences when
  relevant.
- Prefer comments that explain why code exists or why an unusual approach is
  necessary. Do not narrate obvious code.
- Use the public package import in examples and user-facing documentation unless
  a test intentionally targets an internal implementation.
- Keep dependencies minimal. Do not add or upgrade a dependency unless it is
  required for the task, and explain the reason in the pull request.

## License headers

New source files must contain the repository's Apache 2.0 license header. Run:

```sh
melos run add-license-header
melos run check-license-header
```

Review the diff after applying headers because the command operates across the
workspace.

## Releases, versions, and changelog

This repository uses Release Please. For ordinary feature and bug-fix pull
requests, do not manually update release-managed metadata solely to record the
change. In particular, avoid manual edits to:

- `CHANGELOG.md`
- `.release-please-manifest.json`
- The `version` field in the root `pubspec.yaml`
- `android/src/main/kotlin/com/google/maps/flutter/navigation/SdkVersion.kt`
- `ios/google_navigation_flutter/Sources/google_navigation_flutter/SdkVersion.swift`

Change release-managed files only when the task specifically concerns release
configuration or a maintainer explicitly requests it. Normal dependency or SDK
constraint changes may still require editing other parts of `pubspec.yaml` or
native build configuration.

## Pull requests and commits

- Use a Conventional Commit pull-request title, such as `feat:`, `fix:`,
  `docs:`, `test:`, `refactor:`, `build:`, or `chore:`.
- Mark intentional breaking changes clearly, including migration instructions.
- Explain what changed and why, link the relevant issue when applicable, and
  list the checks that were actually run.
- Keep generated changes, implementation changes, tests, and documentation in
  the same pull request when they are part of one logical change.
- Do not mix unrelated formatting or cleanup into a functional change.

## Before finishing

Confirm that:

- The implementation is complete on every affected platform.
- Generated files are current and were not edited by hand.
- Formatting and static analysis pass.
- Relevant Dart, Android, iOS, build, and integration checks pass, or any checks
  that could not be run are stated accurately.
- Tests cover the behavior change or regression.
- Public exports, documentation, and examples are updated where needed.
- New files have valid license headers.
- No secrets, local paths, build artifacts, or unrelated changes are included.
