// Copyright 2024 Google LLC
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

import '../google_navigation_flutter.dart';
import 'google_navigation_flutter_platform_interface.dart';

class GoogleMapsAutoViewController {
  /// Changes the type of the map being displayed on the Google Maps view.
  ///
  /// The [mapType] parameter specifies the new map type to be set.
  /// It should be one of the values defined in the [MapType] enum,
  /// such as [MapType.normal], [MapType.satellite], [MapType.terrain],
  /// or [MapType.hybrid].
  ///
  /// Example usage:
  /// ```dart
  /// _mapViewController.changeMapType(MapType.satellite);
  /// ```
  Future<void> setMapType({required MapType mapType}) async {
    return GoogleMapsNavigationPlatform.instance
        .setMapTypeForAuto(mapType: mapType);
  }
}
