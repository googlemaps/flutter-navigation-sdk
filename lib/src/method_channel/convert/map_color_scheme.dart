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

/// [MapColorScheme] convert extension.
/// @nodoc
extension ConvertMapColorScheme on MapColorScheme {
  /// Converts [MapColorScheme] to [MapColorSchemeDto]
  MapColorSchemeDto toDto() {
    switch (this) {
      case MapColorScheme.followSystem:
        return MapColorSchemeDto.followSystem;
      case MapColorScheme.light:
        return MapColorSchemeDto.light;
      case MapColorScheme.dark:
        return MapColorSchemeDto.dark;
    }
  }
}

/// [MapColorSchemeDto] convert extension.
/// @nodoc
extension ConvertMapColorSchemeDto on MapColorSchemeDto {
  /// Converts [MapColorSchemeDto] to [MapColorScheme]
  MapColorScheme toMapColorScheme() {
    switch (this) {
      case MapColorSchemeDto.followSystem:
        return MapColorScheme.followSystem;
      case MapColorSchemeDto.light:
        return MapColorScheme.light;
      case MapColorSchemeDto.dark:
        return MapColorScheme.dark;
    }
  }
}
