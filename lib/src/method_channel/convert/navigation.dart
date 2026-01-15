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

/// [SpeedAlertSeverityDto] convert extension.
/// @nodoc
extension ConvertSpeedAlertSeverityDto on SpeedAlertSeverityDto {
  /// Converts [SpeedAlertSeverityDto] to [SpeedAlertSeverity]
  SpeedAlertSeverity toSpeedAlertSeverity() {
    switch (this) {
      case SpeedAlertSeverityDto.unknown:
        return SpeedAlertSeverity.unknown;
      case SpeedAlertSeverityDto.notSpeeding:
        return SpeedAlertSeverity.notSpeeding;
      case SpeedAlertSeverityDto.minor:
        return SpeedAlertSeverity.minor;
      case SpeedAlertSeverityDto.major:
        return SpeedAlertSeverity.major;
    }
  }
}

/// [SpeedingUpdatedEventDto] convert extension.
/// @nodoc
extension ConvertSpeedingUpdatedEventDto on SpeedingUpdatedEventDto {
  /// Converts [SpeedingUpdatedEventDto] to [SpeedingUpdatedEvent]
  SpeedingUpdatedEvent toSpeedingUpdatedEvent() => SpeedingUpdatedEvent(
    percentageAboveLimit: percentageAboveLimit,
    severity: severity.toSpeedAlertSeverity(),
  );
}

/// [RouteStatusDto] convert extension.
/// @nodoc
extension ConvertRouteStatusDto on RouteStatusDto {
  /// Converts [RouteStatusDto] to [NavigationRouteStatus]
  NavigationRouteStatus toNavigationRouteStatus() {
    switch (this) {
      case RouteStatusDto.internalError:
        return NavigationRouteStatus.internalError;
      case RouteStatusDto.statusOk:
        return NavigationRouteStatus.statusOk;
      case RouteStatusDto.routeNotFound:
        return NavigationRouteStatus.routeNotFound;
      case RouteStatusDto.networkError:
        return NavigationRouteStatus.networkError;
      case RouteStatusDto.quotaExceeded:
        return NavigationRouteStatus.quotaExceeded;
      case RouteStatusDto.apiKeyNotAuthorized:
        return NavigationRouteStatus.apiKeyNotAuthorized;
      case RouteStatusDto.statusCanceled:
        return NavigationRouteStatus.statusCanceled;
      case RouteStatusDto.duplicateWaypointsError:
        return NavigationRouteStatus.duplicateWaypointsError;
      case RouteStatusDto.noWaypointsError:
        return NavigationRouteStatus.noWaypointsError;
      case RouteStatusDto.locationUnavailable:
        return NavigationRouteStatus.locationUnavailable;
      case RouteStatusDto.waypointError:
        return NavigationRouteStatus.waypointError;
      case RouteStatusDto.travelModeUnsupported:
        return NavigationRouteStatus.travelModeUnsupported;
      case RouteStatusDto.unknown:
        return NavigationRouteStatus.unknown;
      case RouteStatusDto.locationUnknown:
        return NavigationRouteStatus.locationUnknown;
      case RouteStatusDto.quotaCheckFailed:
        return NavigationRouteStatus.quotaCheckFailed;
    }
  }
}

/// [TrafficDelaySeverityDto] convert extension.
/// @nodoc
extension ConvertTrafficDelaySeverityDto on TrafficDelaySeverityDto {
  /// Converts [TrafficDelaySeverityDto] to [TrafficDelaySeverity]
  TrafficDelaySeverity toTrafficDelaySeverity() {
    switch (this) {
      case TrafficDelaySeverityDto.light:
        return TrafficDelaySeverity.light;
      case TrafficDelaySeverityDto.medium:
        return TrafficDelaySeverity.medium;
      case TrafficDelaySeverityDto.heavy:
        return TrafficDelaySeverity.heavy;
      case TrafficDelaySeverityDto.noData:
        return TrafficDelaySeverity.noData;
    }
  }
}

/// [NavigationTimeAndDistanceDto] convert extension.
/// @nodoc
extension ConvertNavigationTimeAndDistanceDto on NavigationTimeAndDistanceDto {
  /// Converts [NavigationTimeAndDistanceDto] to [NavigationTimeAndDistance]
  NavigationTimeAndDistance toNavigationTimeAndDistance() =>
      NavigationTimeAndDistance(
        time: time,
        distance: distance,
        delaySeverity: delaySeverity.toTrafficDelaySeverity(),
      );
}

/// [NavigationAudioGuidanceSettings] convert extension.
/// @nodoc
extension ConvertNavigationAudioGuidanceSettings
    on NavigationAudioGuidanceSettings {
  /// Converts [NavigationAudioGuidanceSettings] to [NavigationAudioGuidanceSettingsDto]
  NavigationAudioGuidanceSettingsDto toDto() {
    late AudioGuidanceTypeDto? targetGuidanceType;
    switch (guidanceType) {
      case NavigationAudioGuidanceType.silent:
        targetGuidanceType = AudioGuidanceTypeDto.silent;
      case NavigationAudioGuidanceType.alertsAndGuidance:
        targetGuidanceType = AudioGuidanceTypeDto.alertsAndGuidance;
      case NavigationAudioGuidanceType.alertsOnly:
        targetGuidanceType = AudioGuidanceTypeDto.alertsOnly;
      case null:
        targetGuidanceType = null;
    }

    return NavigationAudioGuidanceSettingsDto(
      isBluetoothAudioEnabled: isBluetoothAudioEnabled,
      isVibrationEnabled: isVibrationEnabled,
      guidanceType: targetGuidanceType,
    );
  }
}

/// [SpeedAlertOptions] convert extension.
/// @nodoc
extension ConvertSpeedAlertOptions on SpeedAlertOptions {
  SpeedAlertOptionsDto toDto() {
    return SpeedAlertOptionsDto(
      minorSpeedAlertThresholdPercentage: minorSpeedAlertThresholdPercentage,
      majorSpeedAlertThresholdPercentage: majorSpeedAlertThresholdPercentage,
      severityUpgradeDurationSeconds: severityUpgradeDurationSeconds,
    );
  }
}

/// [RouteSegmentTrafficDataRoadStretchRenderingDataDto] convert extension.
/// @nodoc
extension ConvertRouteSegmentTrafficDataRoadStretchRenderingDataDto
    on RouteSegmentTrafficDataRoadStretchRenderingDataDto {
  /// Converts [RouteSegmentTrafficDataRoadStretchRenderingDataDto] to [RouteSegmentTrafficDataRoadStretchRenderingData]
  RouteSegmentTrafficDataRoadStretchRenderingData
  toRouteSegmentTrafficDataRoadStretchRenderingData() =>
      RouteSegmentTrafficDataRoadStretchRenderingData(
        style: () {
          switch (style) {
            case RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
                .slowerTraffic:
              return RouteSegmentTrafficDataRoadStretchRenderingDataStyle
                  .slowerTraffic;
            case RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
                .trafficJam:
              return RouteSegmentTrafficDataRoadStretchRenderingDataStyle
                  .trafficJam;
            case RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
                .unknown:
              return RouteSegmentTrafficDataRoadStretchRenderingDataStyle
                  .unknown;
          }
        }(),
        lengthMeters: lengthMeters,
        offsetMeters: offsetMeters,
      );
}

/// [RouteSegmentTrafficDataDto] convert extension.
/// @nodoc
extension ConvertRouteSegmentTrafficDataDto on RouteSegmentTrafficDataDto {
  /// Converts [RouteSegmentTrafficDataDto] to [RouteSegmentTrafficData]
  RouteSegmentTrafficData toRouteSegmentTrafficData() =>
      RouteSegmentTrafficData(
        status: () {
          switch (status) {
            case RouteSegmentTrafficDataStatusDto.ok:
              return RouteSegmentTrafficDataStatus.ok;
            case RouteSegmentTrafficDataStatusDto.unavailable:
              return RouteSegmentTrafficDataStatus.unavailable;
          }
        }(),
        roadStretchRenderingDataList: roadStretchRenderingDataList
            .where(
              (RouteSegmentTrafficDataRoadStretchRenderingDataDto? d) =>
                  d != null,
            )
            .cast<RouteSegmentTrafficDataRoadStretchRenderingDataDto>()
            .map(
              (RouteSegmentTrafficDataRoadStretchRenderingDataDto d) =>
                  d.toRouteSegmentTrafficDataRoadStretchRenderingData(),
            )
            .toList(),
      );
}

/// [RouteSegmentDto] convert extension.
/// @nodoc
extension ConvertRouteSegmentDto on RouteSegmentDto {
  /// Converts [RouteSegmentDto] to [RouteSegment]
  RouteSegment toRouteSegment() => RouteSegment(
    destinationLatLng: LatLng(
      latitude: destinationLatLng.latitude,
      longitude: destinationLatLng.longitude,
    ),
    destinationWaypoint: destinationWaypoint?.toNavigationWaypoint(),
    latLngs: latLngs
        ?.where((LatLngDto? p) => p != null)
        .cast<LatLngDto>()
        .map(
          (LatLngDto p) => LatLng(latitude: p.latitude, longitude: p.longitude),
        )
        .toList(),
    trafficData: trafficData?.toRouteSegmentTrafficData(),
  );
}

/// [NavigationViewOptions] convert extension.
/// @nodoc
extension ConvertNavigationViewOptions on NavigationViewOptions {
  /// Converts [NavigationViewOptions] to [NavigationViewOptionsDto]
  NavigationViewOptionsDto toDto() {
    late NavigationUIEnabledPreferenceDto preference;
    switch (navigationUIEnabledPreference) {
      case NavigationUIEnabledPreference.automatic:
        preference = NavigationUIEnabledPreferenceDto.automatic;
      case NavigationUIEnabledPreference.disabled:
        preference = NavigationUIEnabledPreferenceDto.disabled;
    }

    return NavigationViewOptionsDto(
      navigationUIEnabledPreference: preference,
      forceNightMode: forceNightMode.toDto(),
    );
  }
}

extension ConvertTaskRemovedBehavior on TaskRemovedBehavior {
  TaskRemovedBehaviorDto toDto() {
    switch (this) {
      case TaskRemovedBehavior.continueService:
        return TaskRemovedBehaviorDto.continueService;
      case TaskRemovedBehavior.quitService:
        return TaskRemovedBehaviorDto.quitService;
    }
  }
}

/// [StepImageGenerationOptionsDto] convert extension.
/// @nodoc
extension ConvertStepImageGenerationOptions on StepImageGenerationOptions {
  /// Converts [StepImageGenerationOptions] to [StepImageGenerationOptionsDto]
  StepImageGenerationOptionsDto toDto() {
    return StepImageGenerationOptionsDto(
      generateManeuverImages: generateManeuverImages,
      generateLaneImages: generateLaneImages,
    );
  }
}

/// [RegisteredImageType] convert extension.
/// @nodoc
extension ConvertRegisteredImageType on RegisteredImageType {
  /// Converts [RegisteredImageType] to [RegisteredImageTypeDto].
  RegisteredImageTypeDto toDto() {
    switch (this) {
      case RegisteredImageType.regular:
        return RegisteredImageTypeDto.regular;
      case RegisteredImageType.maneuver:
        return RegisteredImageTypeDto.maneuver;
      case RegisteredImageType.lanes:
        return RegisteredImageTypeDto.lanes;
    }
  }
}
