// Copyright 2026 Google LLC
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

import '../../google_navigation_flutter.dart';

/// Extension on [Future] to handle platform exceptions.
///
/// This extension provides a convenient way to wrap platform API calls
/// and convert [PlatformException] to typed exceptions using
/// [convertPlatformException].
extension PlatformExceptionHandler<T> on Future<T> {
  /// Wraps the future and converts any [PlatformException] to a typed
  /// exception using [convertPlatformException].
  ///
  /// Example:
  /// ```dart
  /// Future<bool> isMyLocationEnabled({required int viewId}) async {
  ///   return _viewApi.isMyLocationEnabled(viewId).wrapPlatformException();
  /// }
  /// ```
  Future<T> wrapPlatformException() async {
    try {
      return await this;
    } catch (e, stackTrace) {
      throw convertPlatformException(e, stackTrace);
    }
  }
}
