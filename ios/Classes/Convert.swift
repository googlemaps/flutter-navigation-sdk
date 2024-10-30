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

import Foundation
import GoogleMaps
import GoogleNavigation

enum Convert {
  static func convertMapType(mapType: MapTypeDto) -> GMSMapViewType {
    switch mapType {
    case .none:
      return .none
    case .normal:
      return .normal
    case .satellite:
      return .satellite
    case .terrain:
      return .terrain
    case .hybrid:
      return .hybrid
    }
  }

  static func convertMapType(gmsMapType: GMSMapViewType) -> MapTypeDto {
    switch gmsMapType {
    case .none:
      return .none
    case .normal:
      return .normal
    case .satellite:
      return .satellite
    case .terrain:
      return .terrain
    case .hybrid:
      return .hybrid
    @unknown default:
      return .normal
    }
  }

  static func convertCameraPosition(position: GMSCameraPosition) -> CameraPositionDto {
    let target = LatLngDto(
      latitude: position.target.latitude,
      longitude: position.target.longitude
    )
    return CameraPositionDto(
      bearing: position.bearing,
      target: target,
      tilt: position.viewingAngle,
      zoom: Double(position.zoom)
    )
  }

  static func convertCameraPosition(position: CameraPositionDto) -> GMSCameraPosition {
    GMSCameraPosition(
      latitude: position.target.latitude,
      longitude: position.target.longitude,
      zoom: Float(position.zoom),
      bearing: position.bearing,
      viewingAngle: position.tilt
    )
  }

  static func convertLatLngFromDto(point: LatLngDto) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(
      latitude: point.latitude,
      longitude: point.longitude
    )
  }

  static func convertLatLngToDto(point: CLLocationCoordinate2D) -> LatLngDto {
    LatLngDto(latitude: point.latitude, longitude: point.longitude)
  }

  static func convertLatLngBounds(bounds: LatLngBoundsDto) -> GMSCoordinateBounds {
    GMSCoordinateBounds(
      coordinate: CLLocationCoordinate2D(
        latitude: bounds.northeast.latitude,
        longitude: bounds.northeast.longitude
      ),
      coordinate: CLLocationCoordinate2D(
        latitude: bounds.southwest.latitude,
        longitude: bounds.southwest.longitude
      )
    )
  }

  static func convertLatLngBounds(bounds: GMSCoordinateBounds) -> LatLngBoundsDto {
    LatLngBoundsDto(
      southwest: LatLngDto(
        latitude: bounds.southWest.latitude,
        longitude: bounds.southWest.longitude
      ), northeast: LatLngDto(
        latitude: bounds.northEast.latitude,
        longitude: bounds.northEast.longitude
      )
    )
  }

  static func convertCameraPerspective(perspective: CameraPerspectiveDto)
    -> GMSNavigationCameraPerspective {
    switch perspective {
    case .tilted:
      return .tilted
    case .topDownHeadingUp:
      return .topDownHeadingUp
    case .topDownNorthUp:
      return .topDownNorthUp
    }
  }

  static func convertDeltaToPoint(dx: Double?, dy: Double?) -> CGPoint? {
    var point: CGPoint?
    if dx != nil, dy != nil {
      point = CGPoint(x: dx!, y: dy!)
    }
    return point
  }

  static func convertStepInfo(_ stepInfo: GMSNavigationStepInfo) ->
    StepInfoDto {
    .init(
      distanceFromPrevStepMeters: Int64(stepInfo.distanceFromPrevStepMeters),
      timeFromPrevStepSeconds: Int64(stepInfo.timeFromPrevStepSeconds),
      drivingSide: convertDrivingSide(side: stepInfo.drivingSide),
      exitNumber: stepInfo.exitNumber,
      fullInstructions: stepInfo.fullInstructionText,
      fullRoadName: stepInfo.fullRoadName,
      simpleRoadName: stepInfo.simpleRoadName,
      roundaboutTurnNumber: stepInfo
        .roundaboutTurnNumber >= 0 ? Int64(stepInfo.roundaboutTurnNumber) : 0,
      lanes: [],
      maneuver: convertManeuver(maneuver: stepInfo.maneuver),
      stepNumber: Int64(stepInfo.stepNumber)
    )
  }

  static func convertNavInfo(_ gmsNavInfo: GMSNavigationNavInfo, maxAmountOfRemainingSteps: Int64)
    -> NavInfoDto {
    let currentStepDto = gmsNavInfo
      .currentStep != nil ? convertStepInfo(gmsNavInfo.currentStep!) : nil
    let remainingStepsDto = gmsNavInfo.remainingSteps.prefix(Int(maxAmountOfRemainingSteps))
      .map { convertStepInfo($0) }

    return NavInfoDto(
      navState: convertNavState(state: gmsNavInfo.navState),
      currentStep: currentStepDto,
      remainingSteps: remainingStepsDto,
      routeChanged: gmsNavInfo.routeChanged,
      distanceToCurrentStepMeters: Int64(gmsNavInfo.distanceToCurrentStepMeters
        .isFinite ? round(gmsNavInfo.distanceToCurrentStepMeters) : 0),
      distanceToFinalDestinationMeters: Int64(gmsNavInfo.distanceToFinalDestinationMeters
        .isFinite ? round(gmsNavInfo.distanceToFinalDestinationMeters) : 0),
      distanceToNextDestinationMeters: nil,
      timeToCurrentStepSeconds: Int64(gmsNavInfo.timeToCurrentStepSeconds
        .isFinite ? round(gmsNavInfo.timeToCurrentStepSeconds) : 0),
      timeToFinalDestinationSeconds: Int64(gmsNavInfo.timeToFinalDestinationSeconds
        .isFinite ? round(gmsNavInfo.timeToFinalDestinationSeconds) : 0),
      timeToNextDestinationSeconds: nil
    )
  }

  static func convertNavState(state: GMSNavigationNavState)
    -> NavStateDto {
    switch state {
    case .enroute:
      return .enroute
    case .rerouting:
      return .rerouting
    case .stopped:
      return .stopped
    case .unknown:
      return .unknown
    @unknown default:
      return .unknown
    }
  }

  static func convertDrivingSide(side: GMSNavigationDrivingSide)
    -> DrivingSideDto {
    switch side {
    case .none:
      return .none
    case .left:
      return .left
    case .right:
      return .right
    @unknown default:
      return .none
    }
  }

  static func convertManeuver(maneuver: GMSNavigationManeuver) -> ManeuverDto {
    switch maneuver {
    case .depart: return .depart
    case .destination: return .destination
    case .destinationLeft: return .destinationLeft
    case .destinationRight: return .destinationRight
    case .ferryBoat: return .ferryBoat
    case .ferryTrain: return .ferryTrain
    case .forkLeft: return .forkLeft
    case .forkRight: return .forkRight
    case .mergeLeft: return .mergeLeft
    case .mergeRight: return .mergeRight
    case .mergeUnspecified: return .mergeUnspecified
    case .nameChange: return .nameChange
    case .offRampKeepLeft: return .offRampKeepLeft
    case .offRampKeepRight: return .offRampKeepRight
    case .offRampLeft: return .offRampLeft
    case .offRampRight: return .offRampRight
    case .offRampSharpLeft: return .offRampSharpLeft
    case .offRampSharpRight: return .offRampSharpRight
    case .offRampSlightLeft: return .offRampSlightLeft
    case .offRampSlightRight: return .offRampSlightRight
    case .offRampUnspecified: return .offRampUnspecified
    case .offRampUTurnClockwise: return .offRampUTurnClockwise
    case .offRampUTurnCounterClockwise: return .offRampUTurnCounterclockwise
    case .onRampKeepLeft: return .onRampKeepLeft
    case .onRampKeepRight: return .onRampKeepRight
    case .onRampLeft: return .onRampLeft
    case .onRampRight: return .onRampRight
    case .onRampSharpLeft: return .onRampSharpLeft
    case .onRampSharpRight: return .onRampSharpRight
    case .onRampSlightLeft: return .onRampSlightLeft
    case .onRampSlightRight: return .onRampSlightRight
    case .onRampUnspecified: return .onRampUnspecified
    case .onRampUTurnClockwise: return .onRampUTurnClockwise
    case .onRampUTurnCounterClockwise: return .onRampUTurnCounterclockwise
    case .roundaboutClockwise: return .roundaboutClockwise
    case .roundaboutCounterClockwise: return .roundaboutCounterclockwise
    case .roundaboutExitClockwise: return .roundaboutExitClockwise
    case .roundaboutExitCounterClockwise: return .roundaboutExitCounterclockwise
    case .roundaboutLeftClockwise: return .roundaboutLeftClockwise
    case .roundaboutLeftCounterClockwise: return .roundaboutLeftCounterclockwise
    case .roundaboutRightClockwise: return .roundaboutRightClockwise
    case .roundaboutRightCounterClockwise: return .roundaboutRightCounterclockwise
    case .roundaboutSharpLeftClockwise: return .roundaboutSharpLeftClockwise
    case .roundaboutSharpLeftCounterClockwise: return .roundaboutSharpLeftCounterclockwise
    case .roundaboutSharpRightClockwise: return .roundaboutSharpRightClockwise
    case .roundaboutSharpRightCounterClockwise: return .roundaboutSharpRightCounterclockwise
    case .roundaboutSlightLeftClockwise: return .roundaboutSlightLeftClockwise
    case .roundaboutSlightLeftCounterClockwise: return .roundaboutSlightLeftCounterclockwise
    case .roundaboutSlightRightClockwise: return .roundaboutSlightRightClockwise
    case .roundaboutSlightRightCounterClockwise: return .roundaboutSlightRightCounterclockwise
    case .roundaboutStraightClockwise: return .roundaboutStraightClockwise
    case .roundaboutStraightCounterClockwise: return .roundaboutStraightCounterclockwise
    case .roundaboutUTurnClockwise: return .roundaboutUTurnClockwise
    case .roundaboutUTurnCounterClockwise: return .roundaboutUTurnCounterclockwise
    case .straight: return .straight
    case .turnKeepLeft: return .turnKeepLeft
    case .turnKeepRight: return .turnKeepRight
    case .turnLeft: return .turnLeft
    case .turnRight: return .turnRight
    case .turnSharpLeft: return .turnSharpLeft
    case .turnSharpRight: return .turnSharpRight
    case .turnSlightLeft: return .turnSlightLeft
    case .turnSlightRight: return .turnSlightRight
    case .turnUTurnClockwise: return .turnUTurnClockwise
    case .turnUTurnCounterClockwise: return .turnUTurnCounterclockwise
    case .unknown: return .unknown
    @unknown default:
      return .unknown
    }
  }

  static func convertNavigationWayPoint(_ gmsNavigationWaypoint: GMSNavigationWaypoint)
    -> NavigationWaypointDto {
    .init(
      title: gmsNavigationWaypoint.title,
      target: .init(
        latitude: gmsNavigationWaypoint.coordinate.latitude,
        longitude: gmsNavigationWaypoint.coordinate.longitude
      ),
      placeID: gmsNavigationWaypoint.placeID,
      preferSameSideOfRoad: gmsNavigationWaypoint.preferSameSideOfRoad,
      preferredSegmentHeading: Int64(gmsNavigationWaypoint.preferredHeading)
    )
  }

  static func convertWaypoints(_ waypoints: [NavigationWaypointDto?])
    -> [GMSNavigationWaypoint] {
    waypoints
      .map { waypoint -> GMSNavigationWaypoint? in
        guard let waypoint else { return nil }
        if let latitude = waypoint.target?.latitude, let longitude = waypoint.target?.longitude {
          if let preferSameSideOfRoad = waypoint.preferSameSideOfRoad {
            return GMSNavigationWaypoint(
              location: .init(latitude: latitude, longitude: longitude),
              title: waypoint.title,
              preferSameSideOfRoad: preferSameSideOfRoad
            )
          } else if let preferredSegmentHeading = waypoint.preferredSegmentHeading {
            return GMSNavigationWaypoint(
              location: .init(latitude: latitude, longitude: longitude),
              title: waypoint.title,
              preferredSegmentHeading: Int32(preferredSegmentHeading)
            )
          }
          return GMSNavigationWaypoint(
            location: CLLocationCoordinate2D(
              latitude: latitude,
              longitude: longitude
            ),
            title: waypoint.title
          )
        }
        if let placeID = waypoint.placeID {
          return GMSNavigationWaypoint(
            placeID: placeID,
            title: waypoint.title
          )
        }
        return nil
      }
      .compactMap { $0 }
  }

  static func convertRoutingOptions(_ routingOptions: RoutingOptionsDto?)
    -> GMSNavigationRoutingOptions {
    let options = GMSNavigationMutableRoutingOptions()

    if let routingStraregy = routingOptions?.routingStrategy {
      switch routingStraregy {
      case .defaultBest:
        options.routingStrategy = .defaultBest
      case .deltaToTargetDistance:
        options.routingStrategy = .deltaToTargetDistance
      case .shorter:
        options.routingStrategy = .shorter
      }
    }

    if let alternateRoutesStrategy = routingOptions?
      .alternateRoutesStrategy {
      switch alternateRoutesStrategy {
      case .all:
        options.alternateRoutesStrategy = .all
      case .one:
        options.alternateRoutesStrategy = .one
      case .none:
        options.alternateRoutesStrategy = .none
      }
    }

    if let targetDistanceMeters = routingOptions?
      .targetDistanceMeters {
      options.targetDistancesMeters = targetDistanceMeters
        .compactMap { $0 }
        .map { NSNumber(value: $0) }
    }

    return options
  }

  static func convertRouteStatus(_ gmsRouteStatus: GMSRouteStatus)
    -> RouteStatusDto {
    switch gmsRouteStatus {
    case .apiKeyNotAuthorized: return .apiKeyNotAuthorized
    case .OK: return .statusOk
    case .canceled: return .statusCanceled
    case .duplicateWaypointsError: return .duplicateWaypointsError
    case .internalError: return .internalError
    case .locationUnavailable: return .locationUnavailable
    case .networkError: return .networkError
    case .noRouteFound: return .routeNotFound
    case .noWaypointsError: return .noWaypointsError
    case .quotaExceeded: return .quotaExceeded
    case .travelModeUnsupported: return .travelModeUnsupported
    case .waypointError: return .waypointError
    @unknown default:
      return .unknown
    }
  }

  static func convertTravelMode(_ travelMode: TravelModeDto?)
    -> GMSNavigationTravelMode {
    guard let travelMode else {
      return .driving // defaults to driving
    }

    switch travelMode {
    case .driving: return .driving
    case .cycling: return .cycling
    case .walking: return .walking
    case .taxi: return .taxicab
    case .twoWheeler: return .twoWheeler
    }
  }

  static func convertSpeedAlertSeverity(gmsSpeedAlertSeverity: GMSNavigationSpeedAlertSeverity)
    -> SpeedAlertSeverityDto {
    switch gmsSpeedAlertSeverity {
    case .unknown: return .unknown
    case .notSpeeding: return .notSpeeding
    case .minor: return .minor
    case .major: return .major
    @unknown default:
      return .unknown
    }
  }

  static func convertSpeedAlertSeverity(speedAlertSeverity: SpeedAlertSeverityDto)
    -> GMSNavigationSpeedAlertSeverity {
    switch speedAlertSeverity {
    case .unknown: return .unknown
    case .notSpeeding: return .notSpeeding
    case .minor: return .minor
    case .major: return .major
    }
  }

  static func convertNavigationAudioGuidanceType(_ navigationAudioGuidanceType: AudioGuidanceTypeDto)
    -> GMSNavigationVoiceGuidance {
    switch navigationAudioGuidanceType {
    case .alertsAndGuidance: return .alertsAndGuidance
    case .alertsOnly: return .alertsOnly
    case .silent: return .silent
    }
  }

  static func convertPath(_ path: GMSPath) -> [LatLngDto] {
    var coordinates = [LatLngDto]()
    guard path.count() != 0 else { return coordinates }
    for i in 0 ... (path.count() - 1) {
      coordinates.append(
        LatLngDto(
          latitude: path.coordinate(at: i).latitude,
          longitude: path.coordinate(at: i).longitude
        )
      )
    }
    return coordinates
  }

  static func convertRouteSegment(_ routeLeg: GMSRouteLeg) -> RouteSegmentDto {
    RouteSegmentDto(
      destinationLatLng: LatLngDto(
        latitude: routeLeg.destinationCoordinate.latitude,
        longitude: routeLeg.destinationCoordinate.longitude
      ),
      latLngs: {
        guard let path = routeLeg.path else { return nil }
        return Self.convertPath(path)
      }(),
      destinationWaypoint: {
        guard let waypoint = routeLeg.destinationWaypoint else { return nil }
        return Self.convertNavigationWayPoint(waypoint)
      }()
    )
  }
}
