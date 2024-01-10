// Copyright 2024 Google LLC
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

// Mocks generated by Mockito 5.4.4 from annotations
// in google_maps_navigation/test/google_maps_navigation_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i6;

import 'package:google_maps_navigation/src/method_channel/messages.g.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

import 'messages_test.g.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeNavigationTimeAndDistanceDto_0 extends _i1.SmartFake
    implements _i2.NavigationTimeAndDistanceDto {
  _FakeNavigationTimeAndDistanceDto_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCameraPositionDto_1 extends _i1.SmartFake
    implements _i2.CameraPositionDto {
  _FakeCameraPositionDto_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLatLngBoundsDto_2 extends _i1.SmartFake
    implements _i2.LatLngBoundsDto {
  _FakeLatLngBoundsDto_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeImageDescriptorDto_3 extends _i1.SmartFake
    implements _i2.ImageDescriptorDto {
  _FakeImageDescriptorDto_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [TestNavigationSessionApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestNavigationSessionApi extends _i1.Mock
    implements _i3.TestNavigationSessionApi {
  MockTestNavigationSessionApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> createNavigationSession(
          bool? abnormalTerminationReportingEnabled) =>
      (super.noSuchMethod(
        Invocation.method(
          #createNavigationSession,
          [abnormalTerminationReportingEnabled],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  bool isInitialized() => (super.noSuchMethod(
        Invocation.method(
          #isInitialized,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  void cleanup() => super.noSuchMethod(
        Invocation.method(
          #cleanup,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<bool> showTermsAndConditionsDialog(
    String? title,
    String? companyName,
    bool? shouldOnlyShowDriverAwarenessDisclaimer,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #showTermsAndConditionsDialog,
          [
            title,
            companyName,
            shouldOnlyShowDriverAwarenessDisclaimer,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  bool areTermsAccepted() => (super.noSuchMethod(
        Invocation.method(
          #areTermsAccepted,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  void resetTermsAccepted() => super.noSuchMethod(
        Invocation.method(
          #resetTermsAccepted,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  String getNavSDKVersion() => (super.noSuchMethod(
        Invocation.method(
          #getNavSDKVersion,
          [],
        ),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.method(
            #getNavSDKVersion,
            [],
          ),
        ),
      ) as String);

  @override
  bool isGuidanceRunning() => (super.noSuchMethod(
        Invocation.method(
          #isGuidanceRunning,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  void startGuidance() => super.noSuchMethod(
        Invocation.method(
          #startGuidance,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void stopGuidance() => super.noSuchMethod(
        Invocation.method(
          #stopGuidance,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<_i2.RouteStatusDto> setDestinations(_i2.DestinationsDto? msg) =>
      (super.noSuchMethod(
        Invocation.method(
          #setDestinations,
          [msg],
        ),
        returnValue: _i4.Future<_i2.RouteStatusDto>.value(
            _i2.RouteStatusDto.internalError),
      ) as _i4.Future<_i2.RouteStatusDto>);

  @override
  void clearDestinations() => super.noSuchMethod(
        Invocation.method(
          #clearDestinations,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.NavigationTimeAndDistanceDto getCurrentTimeAndDistance() =>
      (super.noSuchMethod(
        Invocation.method(
          #getCurrentTimeAndDistance,
          [],
        ),
        returnValue: _FakeNavigationTimeAndDistanceDto_0(
          this,
          Invocation.method(
            #getCurrentTimeAndDistance,
            [],
          ),
        ),
      ) as _i2.NavigationTimeAndDistanceDto);

  @override
  void setAudioGuidance(_i2.NavigationAudioGuidanceSettingsDto? settings) =>
      super.noSuchMethod(
        Invocation.method(
          #setAudioGuidance,
          [settings],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setSpeedAlertOptions(_i2.SpeedAlertOptionsDto? options) =>
      super.noSuchMethod(
        Invocation.method(
          #setSpeedAlertOptions,
          [options],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.RouteSegmentDto?> getRouteSegments() => (super.noSuchMethod(
        Invocation.method(
          #getRouteSegments,
          [],
        ),
        returnValue: <_i2.RouteSegmentDto?>[],
      ) as List<_i2.RouteSegmentDto?>);

  @override
  List<_i2.LatLngDto?> getTraveledRoute() => (super.noSuchMethod(
        Invocation.method(
          #getTraveledRoute,
          [],
        ),
        returnValue: <_i2.LatLngDto?>[],
      ) as List<_i2.LatLngDto?>);

  @override
  void setUserLocation(_i2.LatLngDto? location) => super.noSuchMethod(
        Invocation.method(
          #setUserLocation,
          [location],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeUserLocation() => super.noSuchMethod(
        Invocation.method(
          #removeUserLocation,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void simulateLocationsAlongExistingRoute() => super.noSuchMethod(
        Invocation.method(
          #simulateLocationsAlongExistingRoute,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void simulateLocationsAlongExistingRouteWithOptions(
          _i2.SimulationOptionsDto? options) =>
      super.noSuchMethod(
        Invocation.method(
          #simulateLocationsAlongExistingRouteWithOptions,
          [options],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<_i2.RouteStatusDto> simulateLocationsAlongNewRoute(
          List<_i2.NavigationWaypointDto?>? waypoints) =>
      (super.noSuchMethod(
        Invocation.method(
          #simulateLocationsAlongNewRoute,
          [waypoints],
        ),
        returnValue: _i4.Future<_i2.RouteStatusDto>.value(
            _i2.RouteStatusDto.internalError),
      ) as _i4.Future<_i2.RouteStatusDto>);

  @override
  _i4.Future<_i2.RouteStatusDto>
      simulateLocationsAlongNewRouteWithRoutingOptions(
    List<_i2.NavigationWaypointDto?>? waypoints,
    _i2.RoutingOptionsDto? routingOptions,
  ) =>
          (super.noSuchMethod(
            Invocation.method(
              #simulateLocationsAlongNewRouteWithRoutingOptions,
              [
                waypoints,
                routingOptions,
              ],
            ),
            returnValue: _i4.Future<_i2.RouteStatusDto>.value(
                _i2.RouteStatusDto.internalError),
          ) as _i4.Future<_i2.RouteStatusDto>);

  @override
  _i4.Future<_i2.RouteStatusDto>
      simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
    List<_i2.NavigationWaypointDto?>? waypoints,
    _i2.RoutingOptionsDto? routingOptions,
    _i2.SimulationOptionsDto? simulationOptions,
  ) =>
          (super.noSuchMethod(
            Invocation.method(
              #simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions,
              [
                waypoints,
                routingOptions,
                simulationOptions,
              ],
            ),
            returnValue: _i4.Future<_i2.RouteStatusDto>.value(
                _i2.RouteStatusDto.internalError),
          ) as _i4.Future<_i2.RouteStatusDto>);

  @override
  void pauseSimulation() => super.noSuchMethod(
        Invocation.method(
          #pauseSimulation,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void resumeSimulation() => super.noSuchMethod(
        Invocation.method(
          #resumeSimulation,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void allowBackgroundLocationUpdates(bool? allow) => super.noSuchMethod(
        Invocation.method(
          #allowBackgroundLocationUpdates,
          [allow],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void enableRoadSnappedLocationUpdates() => super.noSuchMethod(
        Invocation.method(
          #enableRoadSnappedLocationUpdates,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void disableRoadSnappedLocationUpdates() => super.noSuchMethod(
        Invocation.method(
          #disableRoadSnappedLocationUpdates,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void registerRemainingTimeOrDistanceChangedListener(
    int? remainingTimeThresholdSeconds,
    int? remainingDistanceThresholdMeters,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #registerRemainingTimeOrDistanceChangedListener,
          [
            remainingTimeThresholdSeconds,
            remainingDistanceThresholdMeters,
          ],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestNavigationViewApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestNavigationViewApi extends _i1.Mock
    implements _i3.TestNavigationViewApi {
  MockTestNavigationViewApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<void> awaitMapReady(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #awaitMapReady,
          [viewId],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  bool isMyLocationEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isMyLocationEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setMyLocationEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMyLocationEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.LatLngDto? getMyLocation(int? viewId) =>
      (super.noSuchMethod(Invocation.method(
        #getMyLocation,
        [viewId],
      )) as _i2.LatLngDto?);

  @override
  _i2.MapTypeDto getMapType(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getMapType,
          [viewId],
        ),
        returnValue: _i2.MapTypeDto.none,
      ) as _i2.MapTypeDto);

  @override
  void setMapType(
    int? viewId,
    _i2.MapTypeDto? mapType,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMapType,
          [
            viewId,
            mapType,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setMapStyle(
    int? viewId,
    String? styleJson,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMapStyle,
          [
            viewId,
            styleJson,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isNavigationTripProgressBarEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isNavigationTripProgressBarEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setNavigationTripProgressBarEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setNavigationTripProgressBarEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isNavigationHeaderEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isNavigationHeaderEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setNavigationHeaderEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setNavigationHeaderEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isNavigationFooterEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isNavigationFooterEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setNavigationFooterEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setNavigationFooterEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isRecenterButtonEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isRecenterButtonEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setRecenterButtonEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setRecenterButtonEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isSpeedLimitIconEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isSpeedLimitIconEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setSpeedLimitIconEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setSpeedLimitIconEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isSpeedometerEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isSpeedometerEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setSpeedometerEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setSpeedometerEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isIncidentCardsEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isIncidentCardsEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setIncidentCardsEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setIncidentCardsEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isNavigationUIEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isNavigationUIEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  void setNavigationUIEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setNavigationUIEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.CameraPositionDto getCameraPosition(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getCameraPosition,
          [viewId],
        ),
        returnValue: _FakeCameraPositionDto_1(
          this,
          Invocation.method(
            #getCameraPosition,
            [viewId],
          ),
        ),
      ) as _i2.CameraPositionDto);

  @override
  _i2.LatLngBoundsDto getVisibleRegion(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getVisibleRegion,
          [viewId],
        ),
        returnValue: _FakeLatLngBoundsDto_2(
          this,
          Invocation.method(
            #getVisibleRegion,
            [viewId],
          ),
        ),
      ) as _i2.LatLngBoundsDto);

  @override
  void followMyLocation(
    int? viewId,
    _i2.CameraPerspectiveDto? perspective,
    double? zoomLevel,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #followMyLocation,
          [
            viewId,
            perspective,
            zoomLevel,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<bool> animateCameraToCameraPosition(
    int? viewId,
    _i2.CameraPositionDto? cameraPosition,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraToCameraPosition,
          [
            viewId,
            cameraPosition,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraToLatLng(
    int? viewId,
    _i2.LatLngDto? point,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraToLatLng,
          [
            viewId,
            point,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraToLatLngBounds(
    int? viewId,
    _i2.LatLngBoundsDto? bounds,
    double? padding,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraToLatLngBounds,
          [
            viewId,
            bounds,
            padding,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraToLatLngZoom(
    int? viewId,
    _i2.LatLngDto? point,
    double? zoom,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraToLatLngZoom,
          [
            viewId,
            point,
            zoom,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraByScroll(
    int? viewId,
    double? scrollByDx,
    double? scrollByDy,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraByScroll,
          [
            viewId,
            scrollByDx,
            scrollByDy,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraByZoom(
    int? viewId,
    double? zoomBy,
    double? focusDx,
    double? focusDy,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraByZoom,
          [
            viewId,
            zoomBy,
            focusDx,
            focusDy,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> animateCameraToZoom(
    int? viewId,
    double? zoom,
    int? duration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #animateCameraToZoom,
          [
            viewId,
            zoom,
            duration,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  void moveCameraToCameraPosition(
    int? viewId,
    _i2.CameraPositionDto? cameraPosition,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraToCameraPosition,
          [
            viewId,
            cameraPosition,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraToLatLng(
    int? viewId,
    _i2.LatLngDto? point,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraToLatLng,
          [
            viewId,
            point,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraToLatLngBounds(
    int? viewId,
    _i2.LatLngBoundsDto? bounds,
    double? padding,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraToLatLngBounds,
          [
            viewId,
            bounds,
            padding,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraToLatLngZoom(
    int? viewId,
    _i2.LatLngDto? point,
    double? zoom,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraToLatLngZoom,
          [
            viewId,
            point,
            zoom,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraByScroll(
    int? viewId,
    double? scrollByDx,
    double? scrollByDy,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraByScroll,
          [
            viewId,
            scrollByDx,
            scrollByDy,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraByZoom(
    int? viewId,
    double? zoomBy,
    double? focusDx,
    double? focusDy,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraByZoom,
          [
            viewId,
            zoomBy,
            focusDx,
            focusDy,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void moveCameraToZoom(
    int? viewId,
    double? zoom,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #moveCameraToZoom,
          [
            viewId,
            zoom,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void showRouteOverview(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #showRouteOverview,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  double getMinZoomLevel(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getMinZoomLevel,
          [viewId],
        ),
        returnValue: 0.0,
      ) as double);

  @override
  double getMaxZoomLevel(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getMaxZoomLevel,
          [viewId],
        ),
        returnValue: 0.0,
      ) as double);

  @override
  void resetMinMaxZoomPreference(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #resetMinMaxZoomPreference,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setMinZoomPreference(
    int? viewId,
    double? minZoomPreference,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMinZoomPreference,
          [
            viewId,
            minZoomPreference,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setMaxZoomPreference(
    int? viewId,
    double? maxZoomPreference,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMaxZoomPreference,
          [
            viewId,
            maxZoomPreference,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setMyLocationButtonEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMyLocationButtonEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setConsumeMyLocationButtonClickEventsEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setConsumeMyLocationButtonClickEventsEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setZoomGesturesEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setZoomGesturesEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setZoomControlsEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setZoomControlsEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setCompassEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setCompassEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setRotateGesturesEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setRotateGesturesEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setScrollGesturesEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setScrollGesturesEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setScrollGesturesDuringRotateOrZoomEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setScrollGesturesDuringRotateOrZoomEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setTiltGesturesEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setTiltGesturesEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setMapToolbarEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setMapToolbarEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setTrafficEnabled(
    int? viewId,
    bool? enabled,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #setTrafficEnabled,
          [
            viewId,
            enabled,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isMyLocationButtonEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isMyLocationButtonEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isConsumeMyLocationButtonClickEventsEnabled(int? viewId) =>
      (super.noSuchMethod(
        Invocation.method(
          #isConsumeMyLocationButtonClickEventsEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isZoomGesturesEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isZoomGesturesEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isZoomControlsEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isZoomControlsEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isCompassEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isCompassEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isRotateGesturesEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isRotateGesturesEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isScrollGesturesEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isScrollGesturesEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isScrollGesturesEnabledDuringRotateOrZoom(int? viewId) =>
      (super.noSuchMethod(
        Invocation.method(
          #isScrollGesturesEnabledDuringRotateOrZoom,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isTiltGesturesEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isTiltGesturesEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isMapToolbarEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isMapToolbarEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  bool isTrafficEnabled(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #isTrafficEnabled,
          [viewId],
        ),
        returnValue: false,
      ) as bool);

  @override
  List<_i2.MarkerDto?> getMarkers(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getMarkers,
          [viewId],
        ),
        returnValue: <_i2.MarkerDto?>[],
      ) as List<_i2.MarkerDto?>);

  @override
  List<_i2.MarkerDto?> addMarkers(
    int? viewId,
    List<_i2.MarkerDto?>? markers,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addMarkers,
          [
            viewId,
            markers,
          ],
        ),
        returnValue: <_i2.MarkerDto?>[],
      ) as List<_i2.MarkerDto?>);

  @override
  List<_i2.MarkerDto?> updateMarkers(
    int? viewId,
    List<_i2.MarkerDto?>? markers,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateMarkers,
          [
            viewId,
            markers,
          ],
        ),
        returnValue: <_i2.MarkerDto?>[],
      ) as List<_i2.MarkerDto?>);

  @override
  void removeMarkers(
    int? viewId,
    List<_i2.MarkerDto?>? markers,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #removeMarkers,
          [
            viewId,
            markers,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clearMarkers(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #clearMarkers,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clear(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #clear,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.PolygonDto?> getPolygons(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getPolygons,
          [viewId],
        ),
        returnValue: <_i2.PolygonDto?>[],
      ) as List<_i2.PolygonDto?>);

  @override
  List<_i2.PolygonDto?> addPolygons(
    int? viewId,
    List<_i2.PolygonDto?>? polygons,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addPolygons,
          [
            viewId,
            polygons,
          ],
        ),
        returnValue: <_i2.PolygonDto?>[],
      ) as List<_i2.PolygonDto?>);

  @override
  List<_i2.PolygonDto?> updatePolygons(
    int? viewId,
    List<_i2.PolygonDto?>? polygons,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePolygons,
          [
            viewId,
            polygons,
          ],
        ),
        returnValue: <_i2.PolygonDto?>[],
      ) as List<_i2.PolygonDto?>);

  @override
  void removePolygons(
    int? viewId,
    List<_i2.PolygonDto?>? polygons,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #removePolygons,
          [
            viewId,
            polygons,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clearPolygons(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #clearPolygons,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.PolylineDto?> getPolylines(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getPolylines,
          [viewId],
        ),
        returnValue: <_i2.PolylineDto?>[],
      ) as List<_i2.PolylineDto?>);

  @override
  List<_i2.PolylineDto?> addPolylines(
    int? viewId,
    List<_i2.PolylineDto?>? polylines,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addPolylines,
          [
            viewId,
            polylines,
          ],
        ),
        returnValue: <_i2.PolylineDto?>[],
      ) as List<_i2.PolylineDto?>);

  @override
  List<_i2.PolylineDto?> updatePolylines(
    int? viewId,
    List<_i2.PolylineDto?>? polylines,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePolylines,
          [
            viewId,
            polylines,
          ],
        ),
        returnValue: <_i2.PolylineDto?>[],
      ) as List<_i2.PolylineDto?>);

  @override
  void removePolylines(
    int? viewId,
    List<_i2.PolylineDto?>? polylines,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #removePolylines,
          [
            viewId,
            polylines,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clearPolylines(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #clearPolylines,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.CircleDto?> getCircles(int? viewId) => (super.noSuchMethod(
        Invocation.method(
          #getCircles,
          [viewId],
        ),
        returnValue: <_i2.CircleDto?>[],
      ) as List<_i2.CircleDto?>);

  @override
  List<_i2.CircleDto?> addCircles(
    int? viewId,
    List<_i2.CircleDto?>? circles,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #addCircles,
          [
            viewId,
            circles,
          ],
        ),
        returnValue: <_i2.CircleDto?>[],
      ) as List<_i2.CircleDto?>);

  @override
  List<_i2.CircleDto?> updateCircles(
    int? viewId,
    List<_i2.CircleDto?>? circles,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateCircles,
          [
            viewId,
            circles,
          ],
        ),
        returnValue: <_i2.CircleDto?>[],
      ) as List<_i2.CircleDto?>);

  @override
  void removeCircles(
    int? viewId,
    List<_i2.CircleDto?>? circles,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #removeCircles,
          [
            viewId,
            circles,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clearCircles(int? viewId) => super.noSuchMethod(
        Invocation.method(
          #clearCircles,
          [viewId],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [TestImageRegistryApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestImageRegistryApi extends _i1.Mock
    implements _i3.TestImageRegistryApi {
  MockTestImageRegistryApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.ImageDescriptorDto registerBitmapImage(
    String? imageId,
    _i6.Uint8List? bytes,
    double? imagePixelRatio,
    double? width,
    double? height,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #registerBitmapImage,
          [
            imageId,
            bytes,
            imagePixelRatio,
            width,
            height,
          ],
        ),
        returnValue: _FakeImageDescriptorDto_3(
          this,
          Invocation.method(
            #registerBitmapImage,
            [
              imageId,
              bytes,
              imagePixelRatio,
              width,
              height,
            ],
          ),
        ),
      ) as _i2.ImageDescriptorDto);

  @override
  void unregisterImage(_i2.ImageDescriptorDto? imageDescriptor) =>
      super.noSuchMethod(
        Invocation.method(
          #unregisterImage,
          [imageDescriptor],
        ),
        returnValueForMissingStub: null,
      );

  @override
  List<_i2.ImageDescriptorDto?> getRegisteredImages() => (super.noSuchMethod(
        Invocation.method(
          #getRegisteredImages,
          [],
        ),
        returnValue: <_i2.ImageDescriptorDto?>[],
      ) as List<_i2.ImageDescriptorDto?>);

  @override
  void clearRegisteredImages() => super.noSuchMethod(
        Invocation.method(
          #clearRegisteredImages,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
