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
import GoogleNavigation

extension Convert {
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
