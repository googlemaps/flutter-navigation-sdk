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

import 'package:flutter/services.dart';

/// Abstract base class for specific platform exceptions derived from this
/// plugin.
///
/// This exception serves as a common superclass for more specific exceptions
/// thrown by the plugin's platform channel wrapper. Catching this
/// exception allows handling a broader category of plugin-specific platform
/// errors. It extends [PlatformException] to retain original error details.
///
/// {@category Navigation View}
/// {@category Map View}
abstract class GoogleMapsNavigationPlatformException extends PlatformException {
  /// Default constructor for [GoogleMapsNavigationPlatformException].
  GoogleMapsNavigationPlatformException({
    required super.code,
    super.message,
    super.details,
    super.stacktrace,
  });

  @override
  String toString() => '$runtimeType($code, $message, $details, $stacktrace)';
}

/// Exception thrown when a platform view is not found.
///
/// This exception is typically thrown when an asynchronous operation is
/// attempted on a view that has already been disposed. For example, some
/// controller calls could throw this error if the view is no longer available
/// when the method is handled on the native layer.
///
/// {@category Navigation View}
/// {@category Map View}
class ViewNotFoundException extends GoogleMapsNavigationPlatformException {
  /// Creates a [ViewNotFoundException] from an original [PlatformException].
  ViewNotFoundException({
    required PlatformException exception,
    required StackTrace stacktrace,
  }) : assert(exception.code == platformCode),
       super(
         code: exception.code,
         message: exception.message ?? 'Platform view not found.',
         details: exception.details,
         stacktrace: stacktrace.toString(),
       );

  static const platformCode = 'viewNotFound';
}

/// [GoogleNavigationViewController.updateMarkers] or
/// [GoogleNavigationViewController.removeMarkers] failed
/// to find the marker given to the method.
/// {@category Navigation View}
/// {@category Map View}
class MarkerNotFoundException extends GoogleMapsNavigationPlatformException {
  /// Creates a [MarkerNotFoundException] from an original [PlatformException].
  MarkerNotFoundException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Marker not found.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'markerNotFound';
}

/// [GoogleNavigationViewController.updatePolygons] or
/// [GoogleNavigationViewController.removePolygons] failed
/// to find the polygon given to the method.
/// {@category Navigation View}
/// {@category Map View}
class PolygonNotFoundException extends GoogleMapsNavigationPlatformException {
  /// Creates a [PolygonNotFoundException] from an original [PlatformException].
  PolygonNotFoundException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Polygon not found.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'polygonNotFound';
}

/// [GoogleNavigationViewController.updatePolylines] or
/// [GoogleNavigationViewController.removePolylines] failed
/// to find the polyline given to the method.
/// {@category Navigation View}
/// {@category Map View}
class PolylineNotFoundException extends GoogleMapsNavigationPlatformException {
  /// Creates a [PolylineNotFoundException] from an original [PlatformException].
  PolylineNotFoundException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Polyline not found.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'polylineNotFound';
}

/// [GoogleNavigationViewController.updateCircles] or
/// [GoogleNavigationViewController.removeCircles] failed
/// to find the circle given to the method.
/// {@category Navigation View}
/// {@category Map View}
class CircleNotFoundException extends GoogleMapsNavigationPlatformException {
  /// Creates a [CircleNotFoundException] from an original [PlatformException].
  CircleNotFoundException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Circle not found.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'circleNotFound';
}

/// [GoogleNavigationViewController.setMapStyle] failed to set the map style.
/// {@category Navigation View}
/// {@category Map View}
class MapStyleException extends GoogleMapsNavigationPlatformException {
  /// Creates a [MapStyleException] from an original [PlatformException].
  MapStyleException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Failed to set map style.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'mapStyleError';
}

/// [GoogleNavigationViewController.setMaxZoomPreference] failed to set zoom level.
/// {@category Navigation View}
/// {@category Map View}
class MaxZoomRangeException extends GoogleMapsNavigationPlatformException {
  /// Creates a [MaxZoomRangeException] from an original [PlatformException].
  MaxZoomRangeException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: 'Cannot set max zoom to less than min zoom.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  // Override toString for potentially more specific default message if needed
  @override
  String toString() {
    return 'MaxZoomRangeException: Cannot set max zoom to less than min zoom';
  }

  static const platformCode = 'maxZoomLessThanMinZoom';
}

/// [GoogleNavigationViewController.setMinZoomPreference] failed to set zoom level.
/// {@category Navigation View}
/// {@category Map View}
class MinZoomRangeException extends GoogleMapsNavigationPlatformException {
  /// Creates a [MinZoomRangeException] from an original [PlatformException].
  MinZoomRangeException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: 'Cannot set min zoom to greater than max zoom.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  @override
  String toString() {
    return 'MinZoomRangeException: Cannot set min zoom to greater than max zoom';
  }

  static const platformCode = 'minZoomGreaterThanMaxZoom';
}

/// [registerBitmapImage] failed to decode bitmap from byte array.
/// {@category Image Registry}
class ImageDecodingFailedException
    extends GoogleMapsNavigationPlatformException {
  /// Creates a [ImageDecodingFailedException] from an original [PlatformException].
  ImageDecodingFailedException({required PlatformException exception})
    : assert(exception.code == platformCode),
      super(
        code: exception.code,
        message: exception.message ?? 'Failed to decode bitmap image.',
        details: exception.details,
        stacktrace: exception.stacktrace,
      );

  static const platformCode = 'imageDecodingFailed';
}

/// Platform code for unsupported features.
///
/// Used internally by [convertPlatformException] to convert
/// platform exceptions to [UnsupportedError].
const String unsupportedPlatformCode = 'notSupported';

/// Converts [exception] to [GoogleMapsNavigationPlatformException]
/// if [exception] is a [PlatformException].
///
/// If the [exception] is not a [PlatformException], the original [exception]
/// is returned unchanged.
Object convertPlatformException(Object exception, StackTrace stacktrace) {
  if (exception is PlatformException) {
    switch (exception.code) {
      case MarkerNotFoundException.platformCode:
        return MarkerNotFoundException(exception: exception);
      case PolygonNotFoundException.platformCode:
        return PolygonNotFoundException(exception: exception);
      case PolylineNotFoundException.platformCode:
        return PolylineNotFoundException(exception: exception);
      case CircleNotFoundException.platformCode:
        return CircleNotFoundException(exception: exception);
      case MapStyleException.platformCode:
        return MapStyleException(exception: exception);
      case MaxZoomRangeException.platformCode:
        return MaxZoomRangeException(exception: exception);
      case MinZoomRangeException.platformCode:
        return MinZoomRangeException(exception: exception);
      case ImageDecodingFailedException.platformCode:
        return ImageDecodingFailedException(exception: exception);
      case ViewNotFoundException.platformCode:
        return ViewNotFoundException(
          exception: exception,
          stacktrace: stacktrace,
        );
      case unsupportedPlatformCode:
        return UnsupportedError(
          exception.message ??
              'This feature is not supported on this platform.',
        );
    }
  }

  return exception;
}
