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

import 'package:flutter/foundation.dart';

/// LatLng coordinate object.
/// {@category Navigation}
/// {@category Navigation View}
/// {@category Map View}
@immutable
class LatLng {
  /// Initializes a [LatLng] with the provided latitude and longitude values.
  const LatLng({
    required this.latitude,
    required this.longitude,
  })  : assert(latitude >= -90.0 && latitude <= 90.0,
            'Latitude must be between -90 and 90 degrees.'),
        assert(longitude >= -180.0 && longitude <= 180.0,
            'Longitude must be between -180 and 180 degrees.');

  /// The latitude of this point in degrees, where negative values indicate south of the equator.
  final double latitude;

  /// The longitude of this point in degrees, where negative values indicate west of the prime meridian.
  final double longitude;

  /// Returns a new [LatLng] instance offset by the given [LatLng].
  /// Asserts that the operation does not cross the poles.
  LatLng offset(LatLng offset) {
    final double newLatitude = latitude + offset.latitude;
    assert(newLatitude >= -90.0 && newLatitude <= 90.0,
        'Latitude after applying offset must be between -90 and 90 degrees.');

    // Handle longitude wrap-around (across the 180th meridian)
    double newLongitude = longitude + offset.longitude;
    newLongitude = (newLongitude + 180) % 360 - 180;

    return LatLng(latitude: newLatitude, longitude: newLongitude);
  }

  /// Returns a new [LatLng] instance with the latitude and longitude negated.
  LatLng operator -() => LatLng(latitude: -latitude, longitude: -longitude);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LatLng &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hash(latitude.hashCode, longitude.hashCode);
}
