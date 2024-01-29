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

/// [MapType] convert extension.
/// @nodoc
extension ConvertMapType on MapType {
  /// Converts [MapType] to [MapTypeDto]
  MapTypeDto toDto() {
    switch (this) {
      case MapType.none:
        return MapTypeDto.none;
      case MapType.hybrid:
        return MapTypeDto.hybrid;
      case MapType.normal:
        return MapTypeDto.normal;
      case MapType.satellite:
        return MapTypeDto.satellite;
      case MapType.terrain:
        return MapTypeDto.terrain;
    }
  }
}

/// [MapTypeDto] convert extension.
/// @nodoc
extension ConvertMapTypeDto on MapTypeDto {
  /// Converts [MapTypeDto] to [MapType]
  MapType toMapType() {
    switch (this) {
      case MapTypeDto.none:
        return MapType.none;
      case MapTypeDto.hybrid:
        return MapType.hybrid;
      case MapTypeDto.normal:
        return MapType.normal;
      case MapTypeDto.satellite:
        return MapType.satellite;
      case MapTypeDto.terrain:
        return MapType.terrain;
    }
  }
}
