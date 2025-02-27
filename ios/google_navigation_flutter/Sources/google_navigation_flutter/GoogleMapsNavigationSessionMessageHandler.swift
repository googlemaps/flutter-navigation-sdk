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

class GoogleMapsNavigationSessionMessageHandler: NavigationSessionApi {
  init(navigationSessionEventApi: NavigationSessionEventApi,
       viewRegistry: GoogleMapsNavigationViewRegistry) {
    GoogleMapsNavigationSessionManager.shared.setSessionEventApi(
      navigationSessionEventApi: navigationSessionEventApi
    )
    GoogleMapsNavigationSessionManager.shared.setViewRegistry(
      viewRegistry: viewRegistry
    )
  }

  /// General SDK functionality
  func showTermsAndConditionsDialog(title: String, companyName: String,
                                    shouldOnlyShowDriverAwarenessDisclaimer: Bool,
                                    completion: @escaping (Result<Bool, Error>) -> Void) {
    if shouldOnlyShowDriverAwarenessDisclaimer {
      // TODO: Disable driver awareness disclaimer on iOS due to the bug in the native side SDK
      completion(Result.failure(GoogleMapsNavigationSessionManagerError.notSupported))
      return
    }

    GoogleMapsNavigationSessionManager.shared.showTermsAndConditionsDialog(
      title: title,
      companyName: companyName,
      shouldOnlyShowDriverAwarenessDisclaimer: shouldOnlyShowDriverAwarenessDisclaimer
    ) { termsAccepted in
      completion(Result.success(termsAccepted))
    }
  }

  func areTermsAccepted() throws -> Bool {
    GoogleMapsNavigationSessionManager.shared.areTermsAccepted()
  }

  func resetTermsAccepted() throws {
    try GoogleMapsNavigationSessionManager.shared.resetTermsAccepted()
  }

  func getNavSDKVersion() -> String {
    GoogleMapsNavigationSessionManager.shared.getNavSDKVersion()
  }

  func createNavigationSession(abnormalTerminationReportingEnabled: Bool,
                               // taskRemovedBehaviourValue is Android only value and not used on
                               // iOS.
                               behavior: TaskRemovedBehaviorDto,
                               completion: @escaping (Result<Void, Error>) -> Void) {
    do {
      try GoogleMapsNavigationSessionManager.shared
        .createNavigationSession(abnormalTerminationReportingEnabled)
      completion(.success(()))
    } catch {
      completion(.failure(error))
    }
  }

  func isInitialized() -> Bool {
    GoogleMapsNavigationSessionManager.shared.isInitialized()
  }

  func cleanup() throws {
    try GoogleMapsNavigationSessionManager.shared.cleanup()
  }

  /// Navigation actions
  func isGuidanceRunning() throws -> Bool {
    try GoogleMapsNavigationSessionManager.shared.isGuidanceRunning()
  }

  func startGuidance() throws {
    try GoogleMapsNavigationSessionManager.shared.startGuidance()
  }

  func stopGuidance() throws {
    try GoogleMapsNavigationSessionManager.shared.stopGuidance()
  }

  func setDestinations(destinations: DestinationsDto,
                       completion: @escaping (Result<RouteStatusDto, Error>) -> Void) {
    GoogleMapsNavigationSessionManager.shared.setDestinations(
      destinations: destinations,
      completion: completion
    )
  }

  func clearDestinations() throws {
    try GoogleMapsNavigationSessionManager.shared.clearDestinations()
  }

  func continueToNextDestination() throws -> NavigationWaypointDto? {
    try GoogleMapsNavigationSessionManager.shared.continueToNextDestination()
  }

  func getCurrentTimeAndDistance() throws -> NavigationTimeAndDistanceDto {
    try GoogleMapsNavigationSessionManager.shared.getCurrentTimeAndDistance()
  }

  func setAudioGuidance(settings: NavigationAudioGuidanceSettingsDto) throws {
    try GoogleMapsNavigationSessionManager.shared.setAudioGuidance(settings: settings)
  }

  /// Simulation
  func simulateLocationsAlongExistingRoute() throws {
    try GoogleMapsNavigationSessionManager.shared.simulateLocationsAlongExistingRoute()
  }

  func setUserLocation(location: LatLngDto) throws {
    try GoogleMapsNavigationSessionManager.shared.setUserLocation(location: location)
  }

  func removeUserLocation() throws {
    try GoogleMapsNavigationSessionManager.shared.removeUserLocation()
  }

  func simulateLocationsAlongExistingRouteWithOptions(options: SimulationOptionsDto) throws {
    try GoogleMapsNavigationSessionManager.shared
      .simulateLocationsAlongExistingRouteWithOptions(options: options)
  }

  func simulateLocationsAlongNewRoute(waypoints: [NavigationWaypointDto],
                                      completion: @escaping (Result<
                                        RouteStatusDto,
                                        Error
                                      >)
                                        -> Void) {
    do {
      try GoogleMapsNavigationSessionManager.shared.simulateLocationsAlongNewRoute(
        waypoints: waypoints,
        completion: completion
      )
    } catch {
      completion(.failure(error))
    }
  }

  func simulateLocationsAlongNewRouteWithRoutingOptions(waypoints: [NavigationWaypointDto],
                                                        routingOptions: RoutingOptionsDto,
                                                        completion: @escaping (Result<
                                                          RouteStatusDto,
                                                          Error
                                                        >) -> Void) {
    do {
      try GoogleMapsNavigationSessionManager.shared
        .simulateLocationsAlongNewRouteWithRoutingOptions(
          waypoints: waypoints,
          routingOptions: routingOptions,
          completion: completion
        )
    } catch {
      completion(.failure(error))
    }
  }

  func simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(waypoints: [
    NavigationWaypointDto
  ],
  routingOptions: RoutingOptionsDto,
  simulationOptions: SimulationOptionsDto,
  completion: @escaping (Result<
    RouteStatusDto,
    Error
  >) -> Void) {
    do {
      try GoogleMapsNavigationSessionManager.shared
        .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
          waypoints: waypoints,
          routingOptions: routingOptions,
          simulationOptions: simulationOptions,
          completion: completion
        )
    } catch {
      completion(.failure(error))
    }
  }

  func pauseSimulation() throws {
    try GoogleMapsNavigationSessionManager.shared.pauseSimulation()
  }

  func resumeSimulation() throws {
    try GoogleMapsNavigationSessionManager.shared.resumeSimulation()
  }

  func allowBackgroundLocationUpdates(allow: Bool) throws {
    GoogleMapsNavigationSessionManager.shared.allowBackgroundLocationUpdates(allow: allow)
  }

  func setSpeedAlertOptions(options: SpeedAlertOptionsDto) throws {
    try GoogleMapsNavigationSessionManager.shared.setSpeedAlertOptions(options: options)
  }

  func getRouteSegments() throws -> [RouteSegmentDto] {
    try GoogleMapsNavigationSessionManager.shared.getRouteSegments()
  }

  func getTraveledRoute() throws -> [LatLngDto] {
    try GoogleMapsNavigationSessionManager.shared.getTraveledRoute()
  }

  func getCurrentRouteSegment() throws -> RouteSegmentDto? {
    try GoogleMapsNavigationSessionManager.shared.getCurrentRouteSegment()
  }

  /// Listeners
  func enableRoadSnappedLocationUpdates() throws {
    GoogleMapsNavigationSessionManager.shared.enableRoadSnappedLocationUpdates()
  }

  func disableRoadSnappedLocationUpdates() throws {
    GoogleMapsNavigationSessionManager.shared.disableRoadSnappedLocationUpdates()
  }

  func enableTurnByTurnNavigationEvents(numNextStepsToPreview: Int64?) throws {
    GoogleMapsNavigationSessionManager.shared
      .enableTurnByTurnNavigationEvents(numNextStepsToPreview: numNextStepsToPreview)
  }

  func disableTurnByTurnNavigationEvents() throws {
    GoogleMapsNavigationSessionManager.shared.disableTurnByTurnNavigationEvents()
  }

  func registerRemainingTimeOrDistanceChangedListener(remainingTimeThresholdSeconds: Int64,
                                                      remainingDistanceThresholdMeters: Int64) throws {
    GoogleMapsNavigationSessionManager.shared.registerRemainingTimeOrDistanceChangedListener(
      remainingTimeThresholdSeconds: remainingTimeThresholdSeconds,
      remainingDistanceThresholdMeters: remainingDistanceThresholdMeters
    )
  }
}
