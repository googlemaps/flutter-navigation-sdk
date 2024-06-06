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

/// [Marker] convert extension.
/// @nodoc
extension ConvertMarker on Marker {
  /// Converts [Marker] to [MarkerDto]
  MarkerDto toDto() {
    return MarkerDto(markerId: markerId, options: options.toDto());
  }
}

/// [MarkerDto] convert extension.
/// @nodoc
extension ConvertMarkerDto on MarkerDto {
  /// Converts [MarkerDto] to [Marker]
  Marker toMarker() {
    return Marker(markerId: markerId, options: options.toMarkerOptions());
  }
}

/// [MarkerOptions] convert extension.
/// @nodoc
extension ConvertMarkerOptions on MarkerOptions {
  /// Converts [MarkerOptions] to [MarkerOptionsDto]
  MarkerOptionsDto toDto() {
    return MarkerOptionsDto(
        alpha: alpha,
        anchor: anchor.toDto(),
        draggable: draggable,
        flat: flat,
        icon: icon.toDto(),
        consumeTapEvents: consumeTapEvents,
        position: position.toDto(),
        rotation: rotation,
        infoWindow: infoWindow.toDto(),
        visible: visible,
        zIndex: zIndex);
  }
}

/// [MarkerOptionsDto] convert extension.
/// @nodoc
extension ConvertMarkerOptionsDto on MarkerOptionsDto {
  /// Converts [MarkerOptionsDto] to [MarkerOptions]
  MarkerOptions toMarkerOptions() {
    return MarkerOptions(
        alpha: alpha,
        anchor: anchor.toMarkerAnchor(),
        draggable: draggable,
        flat: flat,
        icon: icon.toImageDescriptor(),
        consumeTapEvents: consumeTapEvents,
        position: position.toLatLng(),
        rotation: rotation,
        infoWindow: infoWindow.toInfoWindow(),
        visible: visible,
        zIndex: zIndex);
  }
}

/// [MarkerAnchor] convert extension.
/// @nodoc
extension ConvertMarkerAnchor on MarkerAnchor {
  /// Converts [MarkerAnchor] to [MarkerAnchorDto]
  MarkerAnchorDto toDto() {
    return MarkerAnchorDto(u: u, v: v);
  }
}

/// [MarkerAnchorDto] convert extension.
/// @nodoc
extension ConvertMarkerAnchorDto on MarkerAnchorDto {
  /// Converts [MarkerAnchorDto] to [MarkerAnchor]
  MarkerAnchor toMarkerAnchor() {
    return MarkerAnchor(u: u, v: v);
  }
}

/// [InfoWindow] convert extension.
/// @nodoc
extension ConvertInfoWindow on InfoWindow {
  /// Converts [InfoWindow] to [InfoWindowDto].
  InfoWindowDto toDto() {
    return InfoWindowDto(
        title: title, snippet: snippet, anchor: anchor.toDto());
  }
}

/// [InfoWindowDto] convert extension.
/// @nodoc
extension ConvertInfoWindowDto on InfoWindowDto {
  /// Converts [InfoWindowDto] to [InfoWindow].
  InfoWindow toInfoWindow() {
    return InfoWindow(
        title: title, snippet: snippet, anchor: anchor.toMarkerAnchor());
  }
}

/// [MarkerEventTypeDto] convert extension.
/// @nodoc
extension ConvertMarkerEventType on MarkerEventTypeDto {
  /// Converts [MarkerEventTypeDto] to [MarkerEventType]
  MarkerEventType toMarkerEventType() {
    switch (this) {
      case MarkerEventTypeDto.clicked:
        return MarkerEventType.clicked;
      case MarkerEventTypeDto.infoWindowClicked:
        return MarkerEventType.infoWindowClicked;
      case MarkerEventTypeDto.infoWindowClosed:
        return MarkerEventType.infoWindowClosed;
      case MarkerEventTypeDto.infoWindowLongClicked:
        return MarkerEventType.infoWindowLongClicked;
    }
  }
}

/// [ImageDescriptor] convert extension.
/// @nodoc
extension ConvertImageDescriptor on ImageDescriptor {
  /// Converts [ImageDescriptor] to [ImageDescriptorDto].
  ImageDescriptorDto toDto() {
    return ImageDescriptorDto(
        registeredImageId: registeredImageId,
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height);
  }
}

/// [ImageDescriptorDto] convert extension.
/// @nodoc
extension ConvertImageDescriptorDto on ImageDescriptorDto {
  /// Converts [ImageDescriptorDto] to [ImageDescriptor].
  ImageDescriptor toImageDescriptor() {
    return ImageDescriptor(
        registeredImageId: registeredImageId,
        imagePixelRatio: imagePixelRatio,
        width: width,
        height: height);
  }
}
