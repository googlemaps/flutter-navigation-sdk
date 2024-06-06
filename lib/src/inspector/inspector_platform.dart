// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel.dart';

/// The interface that platform-specific implementations of
/// `google_navigation_flutter` can extend to support state inspection in tests.
///
/// Avoid `implements` of this interface. Using `implements` makes adding any
/// new methods here a breaking change for end users of your platform!
///
/// Do `extends GoogleNavigationInspectorPlatform` instead, so new methods
/// added here are inherited in your code with the default implementation (that
/// throws at runtime), rather than breaking your users at compile time.
/// @nodoc
abstract class GoogleNavigationInspectorPlatform extends PlatformInterface {
  /// Constructs a GoogleNavigationInspectorPlatform.
  GoogleNavigationInspectorPlatform() : super(token: _token);

  final NavigationInspector _inspector = NavigationInspector();

  static final Object _token = Object();

  static GoogleNavigationInspectorPlatform? _instance;

  /// The instance of [GoogleNavigationInspectorPlatform], if any.
  ///
  /// This is usually populated by calling
  /// [GoogleNavigationFlutterPlatform.enableDebugInspection].
  static GoogleNavigationInspectorPlatform? get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [GoogleNavigationInspectorPlatform] in their
  /// implementation of [GoogleNavigationFlutterPlatform.enableDebugInspection].
  static set instance(GoogleNavigationInspectorPlatform? instance) {
    if (instance != null) {
      PlatformInterface.verify(instance, _token);
    }
    _instance = instance;
  }

  /// Internal testing function to check guidance status.
  Future<bool> isViewAttachedToSession(int viewId) async {
    return _inspector.isViewAttachedToSession(viewId);
  }
}
