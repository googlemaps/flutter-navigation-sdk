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

import '../../types/types.dart';
import '../method_channel.dart';

/// [IndoorLevelDto] convert extension.
/// @nodoc
extension ConvertIndoorLevelDto on IndoorLevelDto {
  /// Converts [IndoorLevelDto] to [IndoorLevel].
  IndoorLevel toIndoorLevel({required int levelIndex}) {
    return IndoorLevel(
      levelIndex: levelIndex,
      name: name,
      shortName: shortName,
    );
  }
}

/// [IndoorBuildingDto] convert extension.
/// @nodoc
extension ConvertIndoorBuildingDto on IndoorBuildingDto {
  /// Converts [IndoorBuildingDto] to [IndoorBuilding].
  IndoorBuilding toIndoorBuilding() {
    return IndoorBuilding(
      levels: levels
          .asMap()
          .entries
          .where((e) => e.value != null)
          .map((e) => e.value!.toIndoorLevel(levelIndex: e.key))
          .toList(),
      activeLevelIndex: activeLevelIndex,
      defaultLevelIndex: defaultLevelIndex,
      isUnderground: isUnderground,
    );
  }
}
