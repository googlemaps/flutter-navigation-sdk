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

import '../../../google_maps_navigation.dart';

/// [Marker] convert extension
extension ConvertMarker on Marker {
  /// Converts [Marker] to [MarkerDto]
  MarkerDto toDto() {
    return MarkerDto(markerId: markerId, options: options.toDto());
  }
}

/// [NavigationViewMarker] convert extension
extension ConvertMarkerDto on MarkerDto {
  /// Converts [MarkerDto] to [Marker]
  Marker toMarker() {
    return Marker(markerId: markerId, options: options.toMarkerOptions());
  }

  /// Converts [Marker] to [MarkerDto]
  static MarkerDto fromMarker(Marker marker) {
    return MarkerDto(
        markerId: marker.markerId, options: marker.options.toDto());
  }
}

/// [MarkerOptions] convert extension
extension ConvertMarkerOptions on MarkerOptions {
  /// Converts [MarkerOptions] to [MarkerOptionsDto]
  MarkerOptionsDto toDto() {
    return MarkerOptionsDto(
        alpha: alpha,
        anchor: anchor.toDto(),
        draggable: draggable,
        flat: flat,
        consumeTapEvents: consumeTapEvents,
        position: position.toDto(),
        rotation: rotation,
        infoWindow: infoWindow.toDto(),
        visible: visible,
        zIndex: zIndex);
  }
}

/// [MarkerOptionsDto] convert extension
extension ConvertMarkerOptionsDto on MarkerOptionsDto {
  /// Converts [MarkerOptionsDto] to [MarkerOptions]
  MarkerOptions toMarkerOptions() {
    return MarkerOptions(
        alpha: alpha,
        anchor: anchor.toMarkerAnchor(),
        draggable: draggable,
        flat: flat,
        consumeTapEvents: consumeTapEvents,
        position: position.toLatLng(),
        rotation: rotation,
        infoWindow: infoWindow.toInfoWindow(),
        visible: visible,
        zIndex: zIndex);
  }
}

/// [MarkerAnchor] convert extension
extension ConvertMarkerAnchor on MarkerAnchor {
  /// Converts [MarkerAnchor] to [MarkerAnchorDto]
  MarkerAnchorDto toDto() {
    return MarkerAnchorDto(u: u, v: v);
  }
}

/// [MarkerAnchorDto] convert extension
extension ConvertMarkerAnchorDto on MarkerAnchorDto {
  /// Converts [MarkerAnchorDto] to [MarkerAnchor]
  MarkerAnchor toMarkerAnchor() {
    return MarkerAnchor(u: u, v: v);
  }
}

/// [InfoWindow] convert extension.
extension ConvertInfoWindow on InfoWindow {
  /// Converts [InfoWindow] to [InfoWindowDto].
  InfoWindowDto toDto() {
    return InfoWindowDto(
        title: title, snippet: snippet, anchor: anchor.toDto());
  }
}

/// [InfoWindowDto] convert extension.
extension ConvertInfoWindowDto on InfoWindowDto {
  /// Converts [InfoWindowDto] to [InfoWindow].
  InfoWindow toInfoWindow() {
    return InfoWindow(
        title: title, snippet: snippet, anchor: anchor.toMarkerAnchor());
  }
}

/// [LatLng] convert extension
extension ConvertLatLng on LatLng {
  /// Converts [LatLng] to [LatLngDto]
  LatLngDto toDto() {
    return LatLngDto(latitude: latitude, longitude: longitude);
  }
}

/// [LatLngDto] convert extension
extension ConvertLatLngDto on LatLngDto {
  /// Converts [LatLngDto] to [LatLng]
  LatLng toLatLng() {
    return LatLng(latitude: latitude, longitude: longitude);
  }
}
