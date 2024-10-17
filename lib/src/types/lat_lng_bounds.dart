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

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../google_navigation_flutter.dart';

/// LatLngBounds bounds object.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class LatLngBounds {
  /// Initialize LatLngBounds with the given southwest and northeast points.
  LatLngBounds({
    required this.southwest,
    required this.northeast,
  })  : assert(northeast.latitude >= southwest.latitude,
            'The latitude of northeast must be greater than or equal to the latitude of southwest.'),
        assert(
            southwest.longitude <= northeast.longitude ||
                (southwest.longitude > northeast.longitude &&
                    (southwest.longitude <= 180.0 &&
                        northeast.longitude >= -180.0)),
            'Longitudes must form a valid range.');

  /// Southwest corner of the bound.
  final LatLng southwest;

  /// Northeast corner of the bound.
  final LatLng northeast;

  /// Northwest corner of the bound
  LatLng get northwest =>
      LatLng(latitude: northeast.latitude, longitude: southwest.longitude);

  /// Southeast corner of the bound
  LatLng get southeast =>
      LatLng(latitude: southwest.latitude, longitude: northeast.longitude);

  /// Returns the center of this LatLngBounds.
  LatLng get center {
    final double latCenter = (northeast.latitude + southwest.latitude) / 2;

    double lonCenter;
    if (southwest.longitude <= northeast.longitude) {
      lonCenter = (northeast.longitude + southwest.longitude) / 2;
    } else {
      // Adjusts for the International Date Line by treating the longitude
      // as a continuous scale.
      // Modulo 360 ensures that longitude is within (0, 360) range.
      lonCenter = ((northeast.longitude + 360 + southwest.longitude) / 2) % 360;
      if (lonCenter > 180) {
        // Re-normalize the longitude to the standard -180 to 180 range.
        lonCenter -= 360;
      }
    }

    return LatLng(latitude: latCenter, longitude: lonCenter);
  }

  /// Returns the latitude span of this [LatLngBounds].
  double get latitudeSpan => northeast.latitude - southwest.latitude;

  /// Returns the longitude span of this [LatLngBounds].
  double get longitudeSpan {
    if (southwest.longitude <= northeast.longitude) {
      return northeast.longitude - southwest.longitude;
    } else {
      // Adjusts for the International Date Line by treating the longitude
      // as a continuous scale.
      return (northeast.longitude + 360) - southwest.longitude;
    }
  }

  /// Returns a new [LatLngBounds] instance offset by the given [LatLng].
  LatLngBounds offset(LatLng latLngOffset) => LatLngBounds(
        southwest: southwest.offset(latLngOffset),
        northeast: northeast.offset(latLngOffset),
      );

  /// Returns a new [LatLngBounds] instance that is the smallest bounding box
  /// that contains list of given [LatLng] points.
  static LatLngBounds createBoundsFromPoints(List<LatLng> points) {
    assert(points.isNotEmpty, 'No points given.');
    final double minLatitude = points.map((LatLng e) => e.latitude).min;
    final double maxLatitude = points.map((LatLng e) => e.latitude).max;
    final double minLongitude = points.map((LatLng e) => e.longitude).min;
    final double maxLongitude = points.map((LatLng e) => e.longitude).max;

    return LatLngBounds(
      southwest: LatLng(latitude: minLatitude, longitude: minLongitude),
      northeast: LatLng(latitude: maxLatitude, longitude: maxLongitude),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LatLngBounds &&
        southwest == other.southwest &&
        northeast == other.northeast;
  }

  @override
  int get hashCode => Object.hash(southwest.hashCode, northeast.hashCode);
}
