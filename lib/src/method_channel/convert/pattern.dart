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

import '../../../google_navigation_flutter.dart';
import '../method_channel.dart';

/// [PatternItemDto] convert extension.
/// @nodoc
extension ConvertPatternItemDto on PatternItemDto {
  /// Convert [PatternItemDto] to [PatternItem].
  PatternItem toPatternItem() {
    switch (type) {
      case PatternTypeDto.dash:
        return DashPattern(length: length!);
      case PatternTypeDto.dot:
        return const DotPattern();
      case PatternTypeDto.gap:
        return GapPattern(length: length!);
    }
  }
}

/// [PatternItem] convert extension.
/// @nodoc
extension ConvertPatternItem on PatternItem {
  /// Convert [PatternItem] to [PatternItemDto].
  PatternItemDto toDto() {
    switch (type) {
      case PatternType.dash:
        return PatternItemDto(
          type: PatternTypeDto.dash,
          length: (this as DashPattern).length,
        );
      case PatternType.dot:
        return PatternItemDto(
          type: PatternTypeDto.dot,
        );
      case PatternType.gap:
        return PatternItemDto(
          type: PatternTypeDto.gap,
          length: (this as GapPattern).length,
        );
    }
  }
}
