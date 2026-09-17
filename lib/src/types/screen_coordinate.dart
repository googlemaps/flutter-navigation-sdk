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

import 'package:flutter/foundation.dart';

/// A point on the device's screen, specified in logical pixels.
///
/// Coordinates are in Flutter's logical pixel coordinate system, which
/// automatically accounts for device pixel density. This means you can use
/// these coordinates directly with Flutter's layout system without manual
/// conversion.
///
/// {@category Navigation}
/// {@category Navigation View}
/// {@category Map View}
@immutable
class ScreenCoordinate {
  /// Initializes a [ScreenCoordinate] with the provided x and y values.
  ///
  /// The coordinates should be in logical pixels (Flutter's coordinate system).
  const ScreenCoordinate({required this.x, required this.y});

  /// The x coordinate of the point in logical pixels.
  final double x;

  /// The y coordinate of the point in logical pixels.
  final double y;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ScreenCoordinate && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x.hashCode, y.hashCode);

  @override
  String toString() => 'ScreenCoordinate(x: $x, y: $y)';
}
