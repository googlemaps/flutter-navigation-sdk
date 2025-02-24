# Contributing to Google Maps Navigation Flutter Plugins

_See also: [Flutter's code of conduct](https://flutter.io/design-principles/#code-of-conduct)_

## 1. Essential Setup for Contributors

- **Operating System:** Linux, macOS, or Windows.
- **Version Control:** [git](https://git-scm.com).
- **Development Environment:** An IDE such as [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/).
- **Code Formatting:** [`swiftformat`](https://github.com/nicklockwood/SwiftFormat) (available via brew on macOS, on Windows install Swift toolchain and build SwiftFormat from git sources). 

### 1.1. Installing swiftformat
The CI is locked to swiftformat 0.54.6 version which you can install with the command below:
```bash
curl -O https://raw.githubusercontent.com/Homebrew/homebrew-core/4564fbc21a326c4eb349327ce327cbe983bf302a/Formula/s/swiftformat.rb
brew install swiftformat.rb
```

## 2. Setting Up Your Local Repository

- **Preparation:** Before starting, make sure you have all dependencies installed as mentioned in the prior section.
- **Fork the Repository:** Navigate to `https://github.com/googlemaps/flutter-navigation-sdk` and create a fork in your GitHub account.
- **SSH Key Configuration:** If your machine doesn't have an SSH key registered with GitHub, generate one following the instructions at [Generating SSH Keys on GitHub.](https://help.github.com/articles/generating-ssh-keys/).
- **Clone Your Fork:** Use the command `git clone git@github.com:<your_name_here>/google_maps_flutter_navigation.git` to clone the repository to your local machine.
- **Add remote upstream:** Establish a link to the main repository for updates using command `git remote add upstream git@github.com:googlemaps/flutter-navigation-sdk.git` This ensures you pull changes from the original source, not just your clone, when using git fetch and similar commands.

## 3. Install Melos

This project leverages [Melos](https://github.com/invertase/melos) to manage the project and its dependencies.

Run the following command to install Melos:

```bash
dart pub global activate melos
```

## 4. Automatically generated MethodChannel with Pigeon

### Using pigeon

Google Maps Navigation Flutter Plugins utilizes [pigeon](https://github.com/flutter/packages/tree/main/packages/pigeon) to generate the `MethodChannel` API layer between Dart and the native platforms.
To modify the messages sent with Pigeon (i.e., the API code between Dart and native platforms), you can edit the `pigeons/messages.dart` file in the corresponding folder and regenerate the code by running the following melos command:

```
melos run generate:pigeon
```

Remember to format the generated files using the formatter.

> [!NOTE]
> The melos script automatically runs the formatter after pigeon generation.

### Testing pigeon generated code

To test the created interface, you can mock the interface directly with:

```dart
late MockTestNAMEHostApi mockApi;
TestNAMEHostApi.setup(mockApi);
```

Add a unit test to a new method:

1. Mock the return value (if the function has one).

```dart
when(mockApi.newMethod(any)).thenReturn(returnValueIn);
```

3. Call the public API.

```dart
returnValueOut = await GoogleMapsNavigationPlatform.instance.newMethod(parameterIn)
```

4. Check that the parameters and return values passed between the public API and platform match.

```dart
final VerificationResult result = verify(mockApi.newMethod(captureAny));
final MyType parameterOut = result.captured[0] as MyType;
expect(parameterIn.param, parameterOut.param)
expect(returnValueIn.param, returnValueOut.param)
```

See examples in `test/` folders.

## 5. Running the Navigation Example

The Google Maps Flutter Navigation plugin provides an example app that showcases its main use-cases.

To run the Navigation example, navigate to the `example` directory of the plugin and run the app:

```bash
cd example
flutter run --dart-define MAPS_API_KEY=YOUR_API_KEY
```

## 6. Running tests

Google Maps Flutter Navigation package has integration and unit tests. 

### Unit tests

To run unit tests for the Google Maps Flutter Navigation plugin, navigate to the plugin's root directory and execute the `flutter test` command. Use the following command:

```bash
melos run test:dart
```

To run unit tests on Android call

```bash
melos run test:android
```

To run unit tests on iOS, follow these steps:
1. Open Xcode.
2. Navigate to the Test Navigator.
3. Find and select the "RunnerTests" target.
4. Click on the play icon button to run the tests.

Or to run the iOS unit tests from command line, call

```bash
TEST_DEVICE='iPhone 16 Pro' TEST_OS="18.1" melos run test:ios
```

Specify the device you want to run the tests on with the DEVICE env variable. 

### Integration tests

Integration tests are responsible for ensuring that the plugin works against the native Navigation SDK for both Android and iOS platforms. Patrol is used for the integration tests to simplify interactions with native elements. To use patrol, you first need to activate the patrol_cli.  

```bash
flutter pub global activate patrol_cli 3.5.0
```

To ensure that all necessary dependencies for patrol are properly set up, run the following command:

```bash
patrol doctor
```

Google Maps Flutter Navigation integration tests can be run with the following command:

```bash
cd ./example
patrol test --dart-define MAPS_API_KEY=YOUR_API_KEY
```

To only run a specific test file, use patrol command with -t flag. For example to run a navigation_test.dart run it with the following command:

```bash
cd ./example
patrol test --dart-define MAPS_API_KEY=YOUR_API_KEY -t integration_test/navigation_test.dart
```

Test report should appear in the build folder:

```
Android - example/build/app/reports/androidTests/connected/debug/index.html
iOS - example/build/ios_results_*.xcresult
```

When adding new tests, add the location dialog and ToS check to the beginning of each test.

```dart
    await checkLocationDialogAndTosAcceptance($);
```

For debugging the tests, you can add `debugPrint()` functions in your test and use patrol develop mode with the `--verbose` flag to see the printed messages. To run `navigation_test.dart` in develop mode, use the following command:

```bash
cd ./example
patrol develop --dart-define MAPS_API_KEY=YOUR_API_KEY --verbose -t integration_test/navigation_test.dart
```

Please note that the "hot restart" feature in patrol's develop mode may not work correctly with all test files.

#### Android emulator setup

If the patrol tests fail to run on the Android emulator due to insufficient RAM, increase the emulator's default RAM allocation to ensure proper test execution.

## 7. Contributing code

We welcome contributions through GitHub pull requests.

Before working on any significant changes, please review the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and [design principles](https://flutter.io/design-principles/). These guidelines help maintain code consistency and avoid common pitfalls.

To begin working on a patch, follow these steps:

1. Fetch the latest changes from the upstream repository:
   ```bash
   git fetch upstream
   ```

2. Create a new branch based on the latest upstream master branch:
   ```bash
   git checkout upstream/master -b <name_of_your_branch>
   ```

3. Start coding!

Before committing your changes, it's important to ensure that your code passes the internal analyzer and formatting checks. You can run the following commands locally to identify any issues:

- Run the analyze check:
  ```bash
  melos run flutter-analyze
  ```

- Format your code:
  ```bash
  melos run format
  ```

If you have made changes to pigeon messages, don't forget to generate the necessary code by running:

```bash
melos run generate:pigeon
```

If you have changed files that have mocked tests, make sure to run the following command:

```bash
melos run generate:mocks
```
And run affecting tests locally to make sure they still pass.


Assuming all is successful, commit and push your code using the following commands:

1. Stage your changes:
  ```bash
  git add .
  ```

2. Commit your changes with an informative commit message:
  ```bash
  git commit -m "<your informative commit message>"
  ```

3. Push your changes to the remote repository:
  ```bash
  git push origin <name_of_your_branch>
  ```

To send us a pull request:

- `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/googlemaps/flutter-navigation-sdk` and click the
  "Compare & pull request" button

Please ensure that all your commits have detailed commit messages explaining the changes made.

When naming the title of your pull request, please follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.4/)
guide. For example, for a fix to the plugin:

`fix: Fixed a bug!`

Automated tests will be run on your contributions using GitHub Actions. Depending on
your code changes, various tests will be performed automatically.

Once you have received an LGTM (Looks Good To Me) from a project maintainer and once your pull request has passed all automated tests, please wait for one of the package maintainers to merge your changes.

Before contributing, please ensure that you have completed the
[Contributor License Agreement](https://cla.developers.google.com/clas).
This can be done online and only takes a few moments.

This project uses Google's `addlicense` [here](https://github.com/google/addlicense) tool to add the license header to all necessary files. Running `addlicense` is a required step before committing any new files.

To install `addlicense`, run:
```bash
go install github.com/google/addlicense@latest
```

Make sure to include `$HOME/go/bin` in your `PATH` environment variable. 
If you are using Bash on Linux or macOS, add `export PATH="$HOME/go/bin:$PATH"` to your `.bash_profile`.

To add the license header to all files, run the following command from the root of the repository:
```bash
melos run add-license-header
```
This command uses `addlicense` with all necessary flags.

To check the license header of all files, run from the root of the repository:
```bash
melos run check-license-header
```

## 8. Contributing documentation

We welcome contributions to the plugin documentation. The documentation for this project is generated using Dart Docs. All documentation for the app-facing API is described in Dart files.

Please refer to the "Contributing code" section above for instructions on how to prepare and submit a pull request to the repository.
