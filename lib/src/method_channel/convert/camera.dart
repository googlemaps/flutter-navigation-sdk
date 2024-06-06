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

/// [CameraPositionDto] convert extension.
/// @nodoc
extension ConvertCameraPositionDto on CameraPositionDto {
  /// Convert [CameraPositionDto] to [CameraPosition].
  CameraPosition toCameraPosition() => CameraPosition(
      bearing: bearing, target: target.toLatLng(), tilt: tilt, zoom: zoom);
}

/// [CameraPosition] convert extension.
/// @nodoc
extension ConvertCameraPosition on CameraPosition {
  /// Convert [CameraPosition] to [CameraPositionDto].
  CameraPositionDto toCameraPosition() => CameraPositionDto(
      bearing: bearing, target: target.toDto(), tilt: tilt, zoom: zoom);
}

/// [CameraPerspective] convert extension.
/// @nodoc
extension ConvertCameraPerspective on CameraPerspective {
  /// Convert [CameraPerspective] to [CameraPerspectiveDto].
  CameraPerspectiveDto toDto() {
    switch (this) {
      case CameraPerspective.tilted:
        return CameraPerspectiveDto.tilted;
      case CameraPerspective.topDownHeadingUp:
        return CameraPerspectiveDto.topDownHeadingUp;
      case CameraPerspective.topDownNorthUp:
        return CameraPerspectiveDto.topDownNorthUp;
    }
  }
}

/// [CameraEventTypeDto] convert extension.
/// @nodoc
extension ConvertCameraEventTypeDto on CameraEventTypeDto {
  /// Convert [CameraEventTypeDto] to [CameraEventType].
  CameraEventType toCameraEventType() {
    switch (this) {
      case CameraEventTypeDto.moveStartedByApi:
        return CameraEventType.moveStartedByApi;
      case CameraEventTypeDto.moveStartedByGesture:
        return CameraEventType.moveStartedByGesture;
      case CameraEventTypeDto.onCameraMove:
        return CameraEventType.onCameraMove;
      case CameraEventTypeDto.onCameraIdle:
        return CameraEventType.onCameraIdle;
      case CameraEventTypeDto.onCameraStartedFollowingLocation:
        return CameraEventType.onCameraStartedFollowingLocation;
      case CameraEventTypeDto.onCameraStoppedFollowingLocation:
        return CameraEventType.onCameraStoppedFollowingLocation;
    }
  }
}
