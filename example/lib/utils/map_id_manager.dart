// Copyright 2025 Google LLC
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

// ignore_for_file: public_member_api_docs

/// Manager class for handling map ID configuration.
class MapIdManager {
  MapIdManager._();

  static final MapIdManager _instance = MapIdManager._();
  static MapIdManager get instance => _instance;

  String? _mapId;

  /// Initialize map ID from dart-define or use default value.
  /// This should be called once at app startup.
  void initialize() {
    // Read from dart-define (compile-time constant)
    const String dartDefineMapId = String.fromEnvironment('MAP_ID');
    _mapId = dartDefineMapId.isNotEmpty ? dartDefineMapId : null;
  }

  /// Get the current map ID.
  String? get mapId => _mapId;

  /// Get display string for map ID (for UI display).
  String get mapIdDisplay => _mapId ?? '<not set>';

  /// Set map ID manually (used by the UI button).
  void setMapId(String? mapId) {
    _mapId = mapId?.trim().isEmpty ?? true ? null : mapId;
  }
}
