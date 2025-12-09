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

import '../../types/types.dart';
import '../method_channel.dart';

/// [NavigationForceNightMode] convert extension.
/// @nodoc
extension ConvertNavigationForceNightMode on NavigationForceNightMode {
  /// Converts [NavigationForceNightMode] to [NavigationForceNightModeDto]
  NavigationForceNightModeDto toDto() {
    switch (this) {
      case NavigationForceNightMode.auto:
        return NavigationForceNightModeDto.auto;
      case NavigationForceNightMode.forceDay:
        return NavigationForceNightModeDto.forceDay;
      case NavigationForceNightMode.forceNight:
        return NavigationForceNightModeDto.forceNight;
    }
  }
}

/// [NavigationForceNightModeDto] convert extension.
/// @nodoc
extension ConvertNavigationForceNightModeDto on NavigationForceNightModeDto {
  /// Converts [NavigationForceNightModeDto] to [NavigationForceNightMode]
  NavigationForceNightMode toNavigationForceNightMode() {
    switch (this) {
      case NavigationForceNightModeDto.auto:
        return NavigationForceNightMode.auto;
      case NavigationForceNightModeDto.forceDay:
        return NavigationForceNightMode.forceDay;
      case NavigationForceNightModeDto.forceNight:
        return NavigationForceNightMode.forceNight;
    }
  }
}
