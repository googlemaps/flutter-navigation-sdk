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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_navigation/google_maps_navigation.dart';

void main() {
  late NavigationWaypointDto waypointDto;
  late NavigationWaypoint waypoint;
  late Destinations destinations;
  late NavigationSessionEventDto sessionEventDto;
  late NavigationDisplayOptions displayOptions;
  late RoutingOptions routingOptions;

  setUp(() {
    waypointDto = NavigationWaypointDto(
      title: 'testTitle',
      target: LatLngDto(
        latitude: 5.0,
        longitude: 6.0,
      ),
      placeID: 'testID',
      preferSameSideOfRoad: true,
      preferredSegmentHeading: 50,
    );
    waypoint = NavigationWaypoint.withLatLngTarget(
      title: 'title',
      target: const LatLng(
        latitude: 5.0,
        longitude: 6.0,
      ),
    );
    destinations = Destinations(
      waypoints: <NavigationWaypoint>[waypoint],
      displayOptions: NavigationDisplayOptions(
        showDestinationMarkers: false,
      ),
    );
    sessionEventDto = NavigationSessionEventDto(
      type: NavigationSessionEventTypeDto.arrivalEvent,
      message: 'testMessage',
    );
    displayOptions = NavigationDisplayOptions(
        showDestinationMarkers: false,
        showStopSigns: true,
        showTrafficLights: true);
    routingOptions = RoutingOptions(
      alternateRoutesStrategy: NavigationAlternateRoutesStrategy.all,
      routingStrategy: NavigationRoutingStrategy.defaultBest,
      targetDistanceMeters: <int?>[1, 1, 1],
      avoidFerries: true,
      avoidHighways: true,
      avoidTolls: true,
      locationTimeoutMs: 5000,
    );
  });

  group('NavigationWaypoint tests', () {
    test('tests Navigation Waypoint conversion from DTO', () {
      final NavigationWaypoint gmsWaypoint =
          navigationWaypointFromDto(waypointDto);
      expect(gmsWaypoint.title, waypointDto.title);
      expect(gmsWaypoint.target?.latitude, waypointDto.target?.latitude);
      expect(gmsWaypoint.target?.longitude, waypointDto.target?.longitude);
      expect(gmsWaypoint.placeID, waypointDto.placeID);
      expect(
          gmsWaypoint.preferSameSideOfRoad, waypointDto.preferSameSideOfRoad);
      expect(gmsWaypoint.preferredSegmentHeading,
          waypointDto.preferredSegmentHeading);
    });

    test('tests Navigation Waypoint conversion to DTO', () {
      final NavigationWaypointDto waypointDto2 =
          navigationWaypointToDto(waypoint);
      expect(waypoint.title, waypointDto2.title);
      expect(waypoint.target?.latitude, waypointDto2.target?.latitude);
      expect(waypoint.target?.longitude, waypointDto2.target?.longitude);
      expect(waypoint.placeID, waypointDto2.placeID);
      expect(waypoint.preferSameSideOfRoad, waypointDto2.preferSameSideOfRoad);
      expect(waypoint.preferredSegmentHeading,
          waypointDto2.preferredSegmentHeading);
    });
  });

  group('NavigationDestinationEventMessage tests', () {
    test('tests Navigation Destination Message conversion to DTO', () {
      final DestinationsDto pidgeonDestinationMessage =
          navigationDestinationToDto(destinations);

      expect(destinations.displayOptions.showDestinationMarkers,
          pidgeonDestinationMessage.displayOptions.showDestinationMarkers);
      expect(destinations.displayOptions.showStopSigns,
          pidgeonDestinationMessage.displayOptions.showStopSigns);
      expect(destinations.displayOptions.showTrafficLights,
          pidgeonDestinationMessage.displayOptions.showTrafficLights);

      expect(destinations.waypoints.length,
          pidgeonDestinationMessage.waypoints.length);
      expect(destinations.waypoints[0].target?.latitude,
          pidgeonDestinationMessage.waypoints[0]!.target?.latitude);
      expect(destinations.waypoints[0].target?.longitude,
          pidgeonDestinationMessage.waypoints[0]!.target?.longitude);
      expect(destinations.waypoints[0].placeID,
          pidgeonDestinationMessage.waypoints[0]!.placeID);
      expect(destinations.waypoints[0].preferSameSideOfRoad,
          pidgeonDestinationMessage.waypoints[0]!.preferSameSideOfRoad);
      expect(destinations.waypoints[0].preferredSegmentHeading,
          pidgeonDestinationMessage.waypoints[0]!.preferredSegmentHeading);
    });
  });

  group('Navigation Event Message tests', () {
    test('tests Navigation Session Event Message conversion from Pigeon DTO',
        () {
      final NavigationSessionEvent gmsNavigationSessionEventDto =
          navigationSessionEventFromDto(sessionEventDto);

      expect(
        gmsNavigationSessionEventDto.message,
        sessionEventDto.message,
      );

      expect(
        gmsNavigationSessionEventDto.type.toString().split('.').last,
        sessionEventDto.type.toString().split('.').last,
      );
    });
  });

  group('Navigation Options tests', () {
    test('tests Navigation Display options conversion to Pigeon DTO', () {
      final NavigationDisplayOptionsDto pigeonDtoDisplayOptions =
          navigationDisplayOptionsToDto(displayOptions);

      expect(
        pigeonDtoDisplayOptions.showDestinationMarkers,
        displayOptions.showDestinationMarkers,
      );
      expect(
        pigeonDtoDisplayOptions.showStopSigns,
        displayOptions.showStopSigns,
      );
      expect(
        pigeonDtoDisplayOptions.showTrafficLights,
        displayOptions.showTrafficLights,
      );
    });

    test('tests Navigation Routing options conversion to Pigeon DTO', () {
      final RoutingOptionsDto pigeonDtoRoutingOptions =
          routingOptionsToDto(routingOptions);

      expect(
        pigeonDtoRoutingOptions.targetDistanceMeters,
        routingOptions.targetDistanceMeters,
      );
      expect(
        pigeonDtoRoutingOptions.alternateRoutesStrategy
            .toString()
            .split('.')
            .last,
        routingOptions.alternateRoutesStrategy.toString().split('.').last,
      );
      expect(
        pigeonDtoRoutingOptions.routingStrategy.toString().split('.').last,
        routingOptions.routingStrategy.toString().split('.').last,
      );
      expect(
        pigeonDtoRoutingOptions.travelMode.toString().split('.').last,
        routingOptions.travelMode.toString().split('.').last,
      );
      expect(
        pigeonDtoRoutingOptions.avoidFerries,
        routingOptions.avoidFerries,
      );
      expect(
        pigeonDtoRoutingOptions.avoidHighways,
        routingOptions.avoidHighways,
      );
      expect(
        pigeonDtoRoutingOptions.avoidTolls,
        routingOptions.avoidTolls,
      );
      expect(
        pigeonDtoRoutingOptions.locationTimeoutMs,
        routingOptions.locationTimeoutMs,
      );
    });

    test('tests Navigation Routing strategy conversion to Pigeon DTO', () {
      final RoutingStrategyDto? pigeonDtoStrategy =
          navigationRoutingStrategyToPigeonFormat(
        NavigationRoutingStrategy.defaultBest,
      );

      expect(
        pigeonDtoStrategy.toString().split('.').last,
        NavigationRoutingStrategy.defaultBest.toString().split('.').last,
      );
    });

    test('tests Navigation AlternativeRoutes strategy conversion to Pigeon DTO',
        () {
      final AlternateRoutesStrategyDto? pigeonDtoStrategy =
          navigationAlternateRoutesStrategyToDto(
        NavigationAlternateRoutesStrategy.all,
      );

      expect(
        pigeonDtoStrategy.toString().split('.').last,
        NavigationAlternateRoutesStrategy.all.toString().split('.').last,
      );
    });
  });

  group('Navigation tests', () {
    test('Navigation RouteStatus conversion from Pigeon DTO', () {
      final NavigationRouteStatus status =
          navigationRouteStatusFromDto(RouteStatusDto.apiKeyNotAuthorized);

      expect(
        status.toString().split('.').last,
        RouteStatusDto.apiKeyNotAuthorized.toString().split('.').last,
      );
    });

    test('Navigation time and distance conversion from Pigeon DTO', () {
      final NavigationTimeAndDistance td =
          navigationTimeAndDistanceFromDto(NavigationTimeAndDistanceDto(
        time: 5.0,
        distance: 6.0,
      ));

      expect(
        td.time,
        5.0,
      );
      expect(
        td.distance,
        6.0,
      );
    });

    test('Navigation audio guidance conversion to Pigeon DTO', () {
      final NavigationAudioGuidanceSettingsDto settings =
          navigationAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettings(
            isBluetoothAudioEnabled: true,
            isVibrationEnabled: true,
            guidanceType: NavigationAudioGuidanceType.alertsAndGuidance),
      );

      expect(
        settings.isBluetoothAudioEnabled,
        true,
      );
      expect(
        settings.isVibrationEnabled,
        true,
      );
      expect(
        settings.guidanceType.toString().split('.').last,
        NavigationAudioGuidanceType.alertsAndGuidance
            .toString()
            .split('.')
            .last,
      );
    });

    test('Navigation speed alert severity conversion from Pigeon DTO', () {
      expect(
        SpeedAlertSeverity.major,
        navigationSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.major),
      );
      expect(
        SpeedAlertSeverity.minor,
        navigationSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.minor),
      );
      expect(
        SpeedAlertSeverity.notSpeeding,
        navigationSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.notSpeeding),
      );
      expect(
        SpeedAlertSeverity.unknown,
        navigationSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.unknown),
      );
    });

    test('Navigation simulation options conversion to Pigeon DTO', () {
      expect(
        SimulationOptionsDto(speedMultiplier: 5.5).speedMultiplier,
        simulationOptionsToDto(SimulationOptions(speedMultiplier: 5.5))
            .speedMultiplier,
      );
    });

    test('Navigation lat lng point conversion to Pigeon DTO', () {
      expect(
        LatLngDto(latitude: 5.0, longitude: 6.0).latitude,
        latLngToDto(const LatLng(latitude: 5.0, longitude: 6.0)).latitude,
      );
      expect(
        LatLngDto(latitude: 5.0, longitude: 6.0).longitude,
        latLngToDto(const LatLng(latitude: 5.0, longitude: 6.0)).longitude,
      );
    });

    test('Speeding updated event message conversion from Pigeon DTO', () {
      expect(
        SpeedingUpdatedEvent(
                percentageAboveLimit: 5.0, severity: SpeedAlertSeverity.major)
            .severity,
        speedingUpdatedEventFromDto(SpeedingUpdatedEventDto(
          percentageAboveLimit: 5.0,
          severity: SpeedAlertSeverityDto.major,
        )).severity,
      );
      expect(
        SpeedingUpdatedEvent(
                percentageAboveLimit: 5.0, severity: SpeedAlertSeverity.major)
            .percentageAboveLimit,
        speedingUpdatedEventFromDto(SpeedingUpdatedEventDto(
          percentageAboveLimit: 5.0,
          severity: SpeedAlertSeverityDto.major,
        )).percentageAboveLimit,
      );
    });

    test(
        'Road snapped location updated event message conversion from Pigeon DTO',
        () {
      expect(
        RoadSnappedLocationUpdatedEvent(
          location: const LatLng(
            latitude: 5.0,
            longitude: 9.0,
          ),
        ).location.latitude,
        roadSnappedLocationUpdatedEventFromDto(
            RoadSnappedLocationUpdatedEventDto(
          location: LatLngDto(
            latitude: 5.0,
            longitude: 9.0,
          ),
        )).location.latitude,
      );
      expect(
        RoadSnappedLocationUpdatedEvent(
          location: const LatLng(
            latitude: 5.0,
            longitude: 9.0,
          ),
        ).location.longitude,
        roadSnappedLocationUpdatedEventFromDto(
            RoadSnappedLocationUpdatedEventDto(
          location: LatLngDto(
            latitude: 5.0,
            longitude: 9.0,
          ),
        )).location.longitude,
      );
    });

    test(
        'Navigation remaining time or distance changed event message conversion from Pigeon DTO',
        () {
      final RemainingTimeOrDistanceChangedEventDto event =
          RemainingTimeOrDistanceChangedEventDto(
              remainingDistance: 5000, remainingTime: 100);

      expect(
        remainingTimeOrDistanceChangedEventFromDto(event).remainingDistance,
        event.remainingDistance,
      );
    });

    test('Road stretch rendering data from Pigeon DTO', () {
      final RouteSegmentTrafficDataRoadStretchRenderingDataDto data =
          RouteSegmentTrafficDataRoadStretchRenderingDataDto(
        style: RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
            .slowerTraffic,
        lengthMeters: 500,
        offsetMeters: 600,
      );

      final RouteSegmentTrafficDataRoadStretchRenderingData gmsData =
          roadStretchRenderingDataFromDto(data);

      expect(data.lengthMeters, gmsData.lengthMeters);
      expect(data.offsetMeters, gmsData.offsetMeters);
      expect(data.style.toString().split('.').last,
          gmsData.style.toString().split('.').last);
    });

    test('Road segment traffic data from Pigeon DTO', () {
      final RouteSegmentTrafficDataRoadStretchRenderingDataDto renderingData =
          RouteSegmentTrafficDataRoadStretchRenderingDataDto(
        style: RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
            .slowerTraffic,
        lengthMeters: 500,
        offsetMeters: 600,
      );
      final RouteSegmentTrafficDataDto data = RouteSegmentTrafficDataDto(
          status: RouteSegmentTrafficDataStatusDto.ok,
          roadStretchRenderingDataList: <RouteSegmentTrafficDataRoadStretchRenderingDataDto?>[
            renderingData
          ]);

      final RouteSegmentTrafficData gmsData =
          routeSegmentTrafficDataFromDto(data);

      expect(data.status.toString().split('.').last,
          gmsData.status.toString().split('.').last);
      expect(data.roadStretchRenderingDataList[0]!.lengthMeters,
          gmsData.roadStretchRenderingDataList[0]!.lengthMeters);
      expect(data.roadStretchRenderingDataList[0]!.offsetMeters,
          gmsData.roadStretchRenderingDataList[0]!.offsetMeters);
      expect(
          data.roadStretchRenderingDataList[0]!.style
              .toString()
              .split('.')
              .last,
          gmsData.roadStretchRenderingDataList[0]!.style
              .toString()
              .split('.')
              .last);
    });

    test('Navigation route segment from Pigeon DTO', () {
      final RouteSegmentTrafficDataRoadStretchRenderingDataDto renderingData =
          RouteSegmentTrafficDataRoadStretchRenderingDataDto(
        style: RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto
            .slowerTraffic,
        lengthMeters: 500,
        offsetMeters: 600,
      );
      final RouteSegmentTrafficDataDto trafficData = RouteSegmentTrafficDataDto(
          status: RouteSegmentTrafficDataStatusDto.ok,
          roadStretchRenderingDataList: <RouteSegmentTrafficDataRoadStretchRenderingDataDto?>[
            renderingData
          ]);
      final RouteSegmentDto segment = RouteSegmentDto(
          trafficData: trafficData,
          destinationLatLng: LatLngDto(latitude: 44.0, longitude: 55.0),
          destinationWaypoint: NavigationWaypointDto(
              title: 'test',
              target: LatLngDto(latitude: 77.0, longitude: 88.0)),
          latLngs: <LatLngDto?>[LatLngDto(latitude: 11.0, longitude: 22.0)]);

      final RouteSegment gmsSegment = routeSegmentFromDto(segment);

      expect(segment.destinationLatLng.latitude,
          gmsSegment.destinationLatLng.latitude);
      expect(segment.destinationLatLng.longitude,
          gmsSegment.destinationLatLng.longitude);
      expect(segment.destinationWaypoint!.target?.latitude,
          gmsSegment.destinationWaypoint!.target?.latitude);
      expect(segment.destinationWaypoint!.target?.longitude,
          gmsSegment.destinationWaypoint!.target?.longitude);
      expect(segment.latLngs!.first!.latitude,
          gmsSegment.latLngs!.first!.latitude);
      expect(segment.latLngs!.first!.longitude,
          gmsSegment.latLngs!.first!.longitude);
      expect(segment.trafficData!.status.toString().split('.').last,
          gmsSegment.trafficData!.status.toString().split('.').last);
      expect(
          segment.trafficData!.roadStretchRenderingDataList.first!.style
              .toString()
              .split('.')
              .last,
          gmsSegment.trafficData!.roadStretchRenderingDataList.first!.style
              .toString()
              .split('.')
              .last);
      expect(
          segment.trafficData!.roadStretchRenderingDataList.first!.lengthMeters,
          gmsSegment
              .trafficData!.roadStretchRenderingDataList.first!.lengthMeters);
      expect(
          segment.trafficData!.roadStretchRenderingDataList.first!.offsetMeters,
          gmsSegment
              .trafficData!.roadStretchRenderingDataList.first!.offsetMeters);
    });
  });

  group('LatLng offset tests', () {
    test('Normal offset within valid range', () {
      const LatLng original = LatLng(latitude: 30.0, longitude: 60.0);
      const LatLng latLngOffset = LatLng(latitude: 15.0, longitude: 10.0);
      final LatLng result = original.offset(latLngOffset);

      expect(result.latitude, 45.0);
      expect(result.longitude, 70.0);
    });

    test('Offset crossing the 180th meridian', () {
      const LatLng original = LatLng(latitude: 30.0, longitude: 170.0);
      const LatLng latLngOffset = LatLng(latitude: 0.0, longitude: 20.0);
      final LatLng result = original.offset(latLngOffset);

      expect(result.longitude, -170.0);
    });

    test('Attempt to offset crossing the North Pole (assertion failure)', () {
      const LatLng original = LatLng(latitude: 80.0, longitude: 0.0);
      const LatLng latLngOffset = LatLng(latitude: 20.0, longitude: 0.0);

      expect(() => original.offset(latLngOffset), throwsAssertionError);
    });

    test('Attempt to offset crossing the South Pole (assertion failure)', () {
      const LatLng original = LatLng(latitude: -80.0, longitude: 0.0);
      const LatLng latLngOffset = LatLng(latitude: -20.0, longitude: 0.0);

      expect(() => original.offset(latLngOffset), throwsAssertionError);
    });
  });

  group('LatLngBounds tests', () {
    late LatLngBounds bounds;

    setUp(() {
      bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: -60.0),
        northeast: const LatLng(latitude: 30.0, longitude: 60.0),
      );
    });

    test('Offset within valid range', () {
      const LatLng latLngOffset = LatLng(latitude: 10.0, longitude: 15.0);
      final LatLngBounds result = bounds.offset(latLngOffset);

      expect(result.southwest.latitude, -20.0);
      expect(result.southwest.longitude, -45.0);
      expect(result.northeast.latitude, 40.0);
      expect(result.northeast.longitude, 75.0);
    });

    test('Northwest corner calculation', () {
      final LatLngBounds bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: 60.0),
        northeast: const LatLng(latitude: 40.0, longitude: 100.0),
      );

      final LatLng northwest = bounds.northwest;
      expect(northwest.latitude, 40.0);
      expect(northwest.longitude, 60.0);
    });

    test('Southeast corner calculation', () {
      final LatLngBounds bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: 60.0),
        northeast: const LatLng(latitude: 40.0, longitude: 100.0),
      );

      final LatLng southeast = bounds.southeast;
      expect(southeast.latitude, -30.0);
      expect(southeast.longitude, 100.0);
    });

    test('Center calculation', () {
      final LatLngBounds bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: 60.0),
        northeast: const LatLng(latitude: 40.0, longitude: 100.0),
      );

      final LatLng center = bounds.center;
      expect(center.latitude, 5.0);
      expect(center.longitude, 80.0);
    });

    test('Latitude span calculation', () {
      final LatLngBounds bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: 60.0),
        northeast: const LatLng(latitude: 40.0, longitude: 100.0),
      );

      final double latSpan = bounds.latitudeSpan;
      expect(latSpan, 70.0);
    });

    test('Longitude span calculation', () {
      final LatLngBounds bounds = LatLngBounds(
        southwest: const LatLng(latitude: -30.0, longitude: 170.0),
        northeast: const LatLng(latitude: 40.0, longitude: -170.0),
      );

      final double lonSpan = bounds.longitudeSpan;
      expect(lonSpan, 20.0);
    });
  });
}
