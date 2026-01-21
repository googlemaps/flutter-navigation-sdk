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
import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/method_channel/platform_exception_extension.dart';

void main() {
  group('convertPlatformException', () {
    final StackTrace testStackTrace = StackTrace.current;

    test('converts viewNotFound to ViewNotFoundException', () {
      final PlatformException exception = PlatformException(
        code: ViewNotFoundException.platformCode,
        message: 'View was not found',
        details: 'viewId: 123',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<ViewNotFoundException>());
      final ViewNotFoundException typed = result as ViewNotFoundException;
      expect(typed.code, ViewNotFoundException.platformCode);
      expect(typed.message, 'View was not found');
      expect(typed.details, 'viewId: 123');
    });

    test('converts markerNotFound to MarkerNotFoundException', () {
      final PlatformException exception = PlatformException(
        code: MarkerNotFoundException.platformCode,
        message: 'Marker not found',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<MarkerNotFoundException>());
      final MarkerNotFoundException typed = result as MarkerNotFoundException;
      expect(typed.code, MarkerNotFoundException.platformCode);
      expect(typed.message, 'Marker not found');
    });

    test('converts polygonNotFound to PolygonNotFoundException', () {
      final PlatformException exception = PlatformException(
        code: PolygonNotFoundException.platformCode,
        message: 'Polygon not found',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<PolygonNotFoundException>());
      final PolygonNotFoundException typed = result as PolygonNotFoundException;
      expect(typed.code, PolygonNotFoundException.platformCode);
      expect(typed.message, 'Polygon not found');
    });

    test('converts polylineNotFound to PolylineNotFoundException', () {
      final PlatformException exception = PlatformException(
        code: PolylineNotFoundException.platformCode,
        message: 'Polyline not found',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<PolylineNotFoundException>());
      final PolylineNotFoundException typed =
          result as PolylineNotFoundException;
      expect(typed.code, PolylineNotFoundException.platformCode);
      expect(typed.message, 'Polyline not found');
    });

    test('converts circleNotFound to CircleNotFoundException', () {
      final PlatformException exception = PlatformException(
        code: CircleNotFoundException.platformCode,
        message: 'Circle not found',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<CircleNotFoundException>());
      final CircleNotFoundException typed = result as CircleNotFoundException;
      expect(typed.code, CircleNotFoundException.platformCode);
      expect(typed.message, 'Circle not found');
    });

    test('converts mapStyleError to MapStyleException', () {
      final PlatformException exception = PlatformException(
        code: MapStyleException.platformCode,
        message: 'Invalid map style JSON',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<MapStyleException>());
      final MapStyleException typed = result as MapStyleException;
      expect(typed.code, MapStyleException.platformCode);
      expect(typed.message, 'Invalid map style JSON');
    });

    test('converts maxZoomLessThanMinZoom to MaxZoomRangeException', () {
      final PlatformException exception = PlatformException(
        code: MaxZoomRangeException.platformCode,
        message: 'Max zoom is less than min zoom',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<MaxZoomRangeException>());
      final MaxZoomRangeException typed = result as MaxZoomRangeException;
      expect(typed.code, MaxZoomRangeException.platformCode);
    });

    test('converts minZoomGreaterThanMaxZoom to MinZoomRangeException', () {
      final PlatformException exception = PlatformException(
        code: MinZoomRangeException.platformCode,
        message: 'Min zoom is greater than max zoom',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<MinZoomRangeException>());
      final MinZoomRangeException typed = result as MinZoomRangeException;
      expect(typed.code, MinZoomRangeException.platformCode);
    });

    test('converts imageDecodingFailed to ImageDecodingFailedException', () {
      final PlatformException exception = PlatformException(
        code: ImageDecodingFailedException.platformCode,
        message: 'Failed to decode image',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, isA<ImageDecodingFailedException>());
      final ImageDecodingFailedException typed =
          result as ImageDecodingFailedException;
      expect(typed.code, ImageDecodingFailedException.platformCode);
      expect(typed.message, 'Failed to decode image');
    });

    group('notSupported code', () {
      test('converts to UnsupportedError with message from exception', () {
        final PlatformException exception = PlatformException(
          code: unsupportedPlatformCode,
          message: 'Zoom controls are not supported on iOS.',
        );

        final Object result = convertPlatformException(
          exception,
          testStackTrace,
        );

        expect(result, isA<UnsupportedError>());
        final UnsupportedError typed = result as UnsupportedError;
        expect(typed.message, 'Zoom controls are not supported on iOS.');
      });

      test('uses default message when exception message is null', () {
        final PlatformException exception = PlatformException(
          code: unsupportedPlatformCode,
        );

        final Object result = convertPlatformException(
          exception,
          testStackTrace,
        );

        expect(result, isA<UnsupportedError>());
        final UnsupportedError typed = result as UnsupportedError;
        expect(
          typed.message,
          'This feature is not supported on this platform.',
        );
      });

      test('converts map toolbar not supported error', () {
        final PlatformException exception = PlatformException(
          code: unsupportedPlatformCode,
          message: 'Map toolbar is not supported on iOS.',
        );

        final Object result = convertPlatformException(
          exception,
          testStackTrace,
        );

        expect(result, isA<UnsupportedError>());
        final UnsupportedError typed = result as UnsupportedError;
        expect(typed.message, 'Map toolbar is not supported on iOS.');
      });
    });

    test('returns original exception for unknown PlatformException codes', () {
      final PlatformException exception = PlatformException(
        code: 'unknownError',
        message: 'Some unknown error',
      );

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, same(exception));
    });

    test('returns original exception for non-PlatformException', () {
      final Exception exception = Exception('Regular exception');

      final Object result = convertPlatformException(exception, testStackTrace);

      expect(result, same(exception));
    });

    test('returns original error for non-Exception types', () {
      const String error = 'String error';

      final Object result = convertPlatformException(error, testStackTrace);

      expect(result, same(error));
    });
  });

  group('wrapPlatformException extension', () {
    test('returns value when future completes successfully', () async {
      final Future<int> future = Future<int>.value(42);

      final int result = await future.wrapPlatformException();

      expect(result, 42);
    });

    test('returns value for async computation', () async {
      Future<String> asyncComputation() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 'success';
      }

      final String result = await asyncComputation().wrapPlatformException();

      expect(result, 'success');
    });

    test('converts PlatformException to typed exception', () async {
      Future<void> failingCall() async {
        throw PlatformException(
          code: MarkerNotFoundException.platformCode,
          message: 'Marker not found',
        );
      }

      expect(
        () => failingCall().wrapPlatformException(),
        throwsA(isA<MarkerNotFoundException>()),
      );
    });

    test('converts notSupported to UnsupportedError', () async {
      Future<void> unsupportedCall() async {
        throw PlatformException(
          code: unsupportedPlatformCode,
          message: 'Zoom controls are not supported on iOS.',
        );
      }

      expect(
        () => unsupportedCall().wrapPlatformException(),
        throwsA(
          isA<UnsupportedError>().having(
            (UnsupportedError e) => e.message,
            'message',
            'Zoom controls are not supported on iOS.',
          ),
        ),
      );
    });

    test('passes through unknown PlatformException unchanged', () async {
      Future<void> unknownErrorCall() async {
        throw PlatformException(
          code: 'unknownError',
          message: 'Unknown error occurred',
        );
      }

      expect(
        () => unknownErrorCall().wrapPlatformException(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'unknownError',
          ),
        ),
      );
    });

    test('passes through non-PlatformException unchanged', () async {
      Future<void> regularExceptionCall() async {
        throw StateError('State error');
      }

      expect(
        () => regularExceptionCall().wrapPlatformException(),
        throwsA(isA<StateError>()),
      );
    });

    test('works with nullable return types', () async {
      final Future<String?> future = Future<String?>.value(null);

      final String? result = await future.wrapPlatformException();

      expect(result, isNull);
    });

    test('works with complex return types', () async {
      final Future<List<int>> future = Future<List<int>>.value(<int>[1, 2, 3]);

      final List<int> result = await future.wrapPlatformException();

      expect(result, <int>[1, 2, 3]);
    });

    test('preserves stack trace information', () async {
      Future<void> failingCall() async {
        throw PlatformException(
          code: ViewNotFoundException.platformCode,
          message: 'View not found',
        );
      }

      try {
        await failingCall().wrapPlatformException();
        fail('Expected ViewNotFoundException to be thrown');
      } on ViewNotFoundException catch (e) {
        // ViewNotFoundException captures the stack trace
        expect(e.stacktrace, isNotNull);
        expect(e.stacktrace, isNotEmpty);
      }
    });
  });

  group('Exception type hierarchy', () {
    test(
      'all typed exceptions extend GoogleMapsNavigationPlatformException',
      () {
        final StackTrace stackTrace = StackTrace.current;

        // Create each exception type and verify hierarchy
        final List<GoogleMapsNavigationPlatformException> exceptions =
            <GoogleMapsNavigationPlatformException>[
              ViewNotFoundException(
                exception: PlatformException(
                  code: ViewNotFoundException.platformCode,
                  message: 'test',
                ),
                stacktrace: stackTrace,
              ),
              MarkerNotFoundException(
                exception: PlatformException(
                  code: MarkerNotFoundException.platformCode,
                  message: 'test',
                ),
              ),
              PolygonNotFoundException(
                exception: PlatformException(
                  code: PolygonNotFoundException.platformCode,
                  message: 'test',
                ),
              ),
              PolylineNotFoundException(
                exception: PlatformException(
                  code: PolylineNotFoundException.platformCode,
                  message: 'test',
                ),
              ),
              CircleNotFoundException(
                exception: PlatformException(
                  code: CircleNotFoundException.platformCode,
                  message: 'test',
                ),
              ),
              MapStyleException(
                exception: PlatformException(
                  code: MapStyleException.platformCode,
                  message: 'test',
                ),
              ),
              MaxZoomRangeException(
                exception: PlatformException(
                  code: MaxZoomRangeException.platformCode,
                  message: 'test',
                ),
              ),
              MinZoomRangeException(
                exception: PlatformException(
                  code: MinZoomRangeException.platformCode,
                  message: 'test',
                ),
              ),
              ImageDecodingFailedException(
                exception: PlatformException(
                  code: ImageDecodingFailedException.platformCode,
                  message: 'test',
                ),
              ),
            ];

        for (final GoogleMapsNavigationPlatformException exception
            in exceptions) {
          expect(
            exception,
            isA<GoogleMapsNavigationPlatformException>(),
            reason:
                '${exception.runtimeType} should extend '
                'GoogleMapsNavigationPlatformException',
          );
          expect(
            exception,
            isA<PlatformException>(),
            reason: '${exception.runtimeType} should extend PlatformException',
          );
        }
      },
    );

    test(
      'UnsupportedError is not a PlatformException (backward compatible)',
      () {
        // This test verifies that notSupported returns UnsupportedError
        // which is a core Dart Error, maintaining backward compatibility
        // with existing code that catches UnsupportedError.
        final PlatformException exception = PlatformException(
          code: unsupportedPlatformCode,
          message: 'Feature not supported',
        );

        final Object result = convertPlatformException(
          exception,
          StackTrace.current,
        );

        expect(result, isA<UnsupportedError>());
        expect(result, isNot(isA<PlatformException>()));
        expect(result, isA<Error>());
      },
    );
  });

  group('Platform code constants', () {
    test('unsupportedPlatformCode has correct value', () {
      expect(unsupportedPlatformCode, 'notSupported');
    });

    test('all exception types have unique platform codes', () {
      final Set<String> codes = <String>{
        ViewNotFoundException.platformCode,
        MarkerNotFoundException.platformCode,
        PolygonNotFoundException.platformCode,
        PolylineNotFoundException.platformCode,
        CircleNotFoundException.platformCode,
        MapStyleException.platformCode,
        MaxZoomRangeException.platformCode,
        MinZoomRangeException.platformCode,
        ImageDecodingFailedException.platformCode,
        unsupportedPlatformCode,
      };

      // If all codes are unique, the set size equals the number of codes
      expect(codes.length, 10);
    });
  });
}
