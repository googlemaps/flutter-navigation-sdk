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

import 'package:flutter/foundation.dart';

import '../../google_navigation_flutter.dart';

/// Marker that has beed added to the map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class Marker {
  /// Construct [Marker]
  const Marker({required this.markerId, required this.options});

  /// Identifies the marker.
  final String markerId;

  /// Options for the marker.
  final MarkerOptions options;

  /// Create copy of [Marker] with the specified options.
  Marker copyWith({required MarkerOptions options}) {
    return Marker(markerId: markerId, options: options);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Marker &&
        markerId == other.markerId &&
        options == other.options;
  }

  @override
  int get hashCode => Object.hash(markerId.hashCode, options.hashCode);
}

/// Defines MarkerOptions for a marker.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class MarkerOptions {
  /// Initialize MarkerOptions object.
  const MarkerOptions(
      {this.alpha = 1.0,
      this.anchor = const MarkerAnchor(u: 0.5, v: 1.0),
      this.draggable = false,
      this.flat = false,
      this.icon = ImageDescriptor.defaultImage,
      this.consumeTapEvents = false,
      this.position = const LatLng(latitude: 0.0, longitude: 0.0),
      this.rotation = 0.0,
      this.infoWindow = InfoWindow.noInfo,
      this.visible = true,
      this.zIndex = 0.0});

  /// Sets the alpha (opacity) of the marker.
  ///
  /// By default, the marker is fully opaque; [alpha] is 1.0.
  final double alpha;

  /// Specifies the anchor to be at a particular point in the marker image.
  ///
  /// By default, the marker image is placed on bottom center; [anchor] is `MarkerAnchor(0.5, 1.0)`.
  final MarkerAnchor anchor;

  /// Allow dragging the marker.
  ///
  /// By default, the marker is stationary; [draggable] is false.
  final bool draggable;

  /// Sets whether this marker should be flat against the map or a billboard facing the camera.
  ///
  /// By default, the marker is drawn facing the camera; [flat] is false.
  final bool flat;

  /// Specifies the image ID of the bitmap drawn as the marker on the map.
  /// The bitmap must be registered with [registerBitmapImage] before creating marker.
  ///
  /// By default, the icon ID is [ImageDescriptor.defaultImage], this draws the default marker icon.
  final ImageDescriptor icon;

  /// Sets whether map view does the default behavior when clicking marker.
  /// If set to true default behaviour does not occur.
  /// If set to false the camera moves to marker and info window appears.
  ///
  /// By default, the default behaviour is enabled; [consumeTapEvents] is false.
  final bool consumeTapEvents;

  /// Sets the location for the marker.
  ///
  /// By default, the marker is positioned at 0, 0; [position] is `LatLng(latitude: 0.0, longitude: 0.0)`.
  final LatLng position;

  /// Sets the rotation of the marker in degrees clockwise about the marker's anchor point.
  ///
  /// By default, the marker has axis-aligned icon; [rotation] is 0.0.
  final double rotation;

  /// Sets [InfoWindow]. The window is displayed when the marker is tapped.
  ///
  /// By default, the info window title and snippet are null, therefore info window is not shown; [infoWindow] is `InfoWindow.noInfo`.
  final InfoWindow infoWindow;

  /// Sets the visibility for the marker.
  ///
  /// By default, the marker is visible; [visible] is true.
  final bool visible;

  /// Sets the zIndex for the marker.
  ///
  /// By default, the marker is placed at the base of the drawing order; [zIndex] is 0.0
  final double zIndex;

  /// Create copy of [MarkerOptions] with specified parameters
  MarkerOptions copyWith(
      {double? alpha,
      MarkerAnchor? anchor,
      bool? draggable,
      bool? flat,
      ImageDescriptor? icon,
      bool? consumeTapEvents,
      MarkerAnchor? infoWindowAnchor,
      LatLng? position,
      double? rotation,
      String? snippet,
      String? title,
      InfoWindow? infoWindow,
      bool? visible,
      double? zIndex}) {
    return MarkerOptions(
        alpha: alpha ?? this.alpha,
        anchor: anchor ?? this.anchor,
        draggable: draggable ?? this.draggable,
        flat: flat ?? this.flat,
        icon: icon ?? this.icon,
        consumeTapEvents: consumeTapEvents ?? this.consumeTapEvents,
        position: position ?? this.position,
        rotation: rotation ?? this.rotation,
        infoWindow: infoWindow ?? this.infoWindow,
        visible: visible ?? this.visible,
        zIndex: zIndex ?? this.zIndex);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkerOptions &&
        alpha == other.alpha &&
        anchor == other.anchor &&
        draggable == other.draggable &&
        flat == other.flat &&
        icon == other.icon &&
        consumeTapEvents == other.consumeTapEvents &&
        position == other.position &&
        rotation == other.rotation &&
        infoWindow == other.infoWindow &&
        visible == other.visible &&
        zIndex == other.zIndex;
  }

  @override
  int get hashCode => Object.hash(
      alpha.hashCode,
      anchor.hashCode,
      draggable.hashCode,
      flat.hashCode,
      icon.hashCode,
      consumeTapEvents.hashCode,
      position.hashCode,
      rotation.hashCode,
      infoWindow.hashCode,
      visible.hashCode,
      zIndex.hashCode);
}

/// Text labels for [Marker] info window.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class InfoWindow {
  /// Construct [InfoWindow] object.
  const InfoWindow(
      {this.title,
      this.snippet,
      this.anchor = const MarkerAnchor(u: 0.5, v: 0.0)});

  /// Display no info window on the marker.
  static const InfoWindow noInfo = InfoWindow();

  /// Text displayed in an info window when the user taps the marker. A null value means no title.
  ///
  /// By default, the info window title is null.
  final String? title;

  /// Additional text displayed below the [title]. A null value means no additional text.
  ///
  /// By default, the additional text is null.
  final String? snippet;

  /// Specifies the anchor point of the info window on the marker image.
  ///
  /// By default, the info window is placed on top center; [anchor] is `MarkerAnchor(u: 0.5, v: 0.0)`.
  final MarkerAnchor anchor;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is InfoWindow &&
        title == other.title &&
        snippet == other.snippet &&
        anchor == other.anchor;
  }

  @override
  int get hashCode =>
      Object.hash(title.hashCode, snippet.hashCode, anchor.hashCode);
}

/// Specifies the anchor to be at a particular point in the marker image.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class MarkerAnchor {
  /// Initialize MarkerAnchor object.
  const MarkerAnchor({
    required this.u,
    required this.v,
  });

  /// u-coordinate of the anchor, as a ratio of the image width (in the range 0, 1).
  final double u;

  /// v-coordinate of the anchor, as a ratio of the image height (in the range 0, 1).
  final double v;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MarkerAnchor && u == other.u && v == other.v;
  }

  @override
  int get hashCode => Object.hash(u.hashCode, v.hashCode);
}

/// Marker event types
/// {@category Navigation View}
/// {@category Map View}
enum MarkerEventType {
  /// The marker has been tapped.
  clicked,

  /// The marker info window has been tapped.
  infoWindowClicked,

  /// The marker info window has been closed.
  infoWindowClosed,

  /// The marker info window has been long clicked.
  infoWindowLongClicked,
}

/// Marker drag event types
/// {@category Navigation View}
/// {@category Map View}
enum MarkerDragEventType {
  /// The marker is being dragged.
  drag,

  /// The marker drag has been started.
  dragStart,

  /// The marker drag has been ended.
  dragEnd,
}

/// Marker event sent from platform side.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class MarkerEvent {
  /// Initialize [MarkerEvent] object.
  const MarkerEvent({
    required this.markerId,
    required this.eventType,
  });

  /// Id of the marker that has been tapped.
  final String markerId;

  /// Type of the event.
  final MarkerEventType eventType;
}

/// Marker drag event sent from platform side.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class MarkerDragEvent {
  /// Initialize [MarkerDragEvent] object.
  const MarkerDragEvent(
      {required this.markerId,
      required this.eventType,
      required this.position});

  /// Id of the marker that has been tapped.
  final String markerId;

  /// Position of the marker that has been dragged.
  final LatLng position;

  /// Type of the event.
  final MarkerDragEventType eventType;
}
