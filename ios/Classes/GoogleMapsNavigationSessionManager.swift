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

import CoreLocation
import Flutter
import Foundation
import GoogleNavigation

// Keep in sync with GoogleMapsNavigationSessionManager.kt
enum GoogleMapsNavigationSessionManagerError: Error {
  case initializeFailure
  case termsNotAccepted
  case termsResetNotAllowed
  case locationPermissionMissing
  case notAuthorized
  case sessionNotInitialized
  case noViewRegistry
  case viewNotFound
  case notSupported
}

// Expose the navigator to the google_maps_driver side.
// DriverApi initialization requires navigator.
public class ExposedGoogleMapsNavigator: NSObject {
  public static func getNavigator() throws -> GMSNavigator {
    try GoogleMapsNavigationSessionManager.shared.getNavigator()
  }
}

class GoogleMapsNavigationSessionManager: NSObject {
  enum RoutingOptionsTarget {
    case navigator
    case simulator
  }

  static let shared = GoogleMapsNavigationSessionManager()

  private var _navigationSessionEventApi: NavigationSessionEventApi?

  private var _viewRegistry: GoogleMapsNavigationViewRegistry?

  private var _session: GMSNavigationSession?

  func getNavigator() throws -> GMSNavigator {
    guard let _session else { throw GoogleMapsNavigationSessionManagerError.sessionNotInitialized }
    guard let navigator = _session.navigator
    else { throw GoogleMapsNavigationSessionManagerError.termsNotAccepted }
    return navigator
  }

  private func getSimulator() throws -> GMSLocationSimulator {
    guard let _session else { throw GoogleMapsNavigationSessionManagerError.sessionNotInitialized }
    guard let simulator = _session.locationSimulator
    else { throw GoogleMapsNavigationSessionManagerError.termsNotAccepted }
    return simulator
  }

  func setViewRegistry(viewRegistry: GoogleMapsNavigationViewRegistry) {
    _viewRegistry = viewRegistry
  }

  func setSessionEventApi(navigationSessionEventApi: NavigationSessionEventApi) {
    _navigationSessionEventApi = navigationSessionEventApi
  }

  // Create a navigation session and initializes listeners.
  // If navigator is already created, only re-initialize listeners.
  func createNavigationSession() throws {
    // Align API behavior with Android:
    // Check the terms and conditions before the location permission check below.
    if !areTermsAccepted() {
      throw GoogleMapsNavigationSessionManagerError.termsNotAccepted
    }

    // Align API behavior with Android:
    // Fail the session creation if the location permission hasn't been accepted.
    let locationManager = CLLocationManager()
    let status = locationManager.authorizationStatus
    if status != .authorizedAlways, status != .authorizedWhenInUse {
      throw GoogleMapsNavigationSessionManagerError.locationPermissionMissing
    }

    // Try to create a session.
    if _session == nil {
      guard let session = GMSNavigationServices.createNavigationSession() else {
        // According API documentation the only reason a nil session is ever returned
        // is due to terms and conditions not having been accepted yet.
        //
        // At this point should not happen due to the earlier check.
        throw GoogleMapsNavigationSessionManagerError.termsNotAccepted
      }
      _session = session
    }

    _session?.isStarted = true
    _session?.navigator?.add(self)
    _session?.navigator?.stopGuidanceAtArrival = false

    // Disable time udpate callbacks.
    _session?.navigator?.timeUpdateThreshold = TimeInterval.infinity

    // Disable distance update callbacks.
    _session?.navigator?.distanceUpdateThreshold = CLLocationDistanceMax

    _session?.roadSnappedLocationProvider?.add(self)

    // Attach navigation session to all existing maps views.
    try _viewRegistry?.getAllRegisteredViewIds().forEach { id in
      try attachNavigationSessionToMapView(mapId: id)
    }
  }

  func isInitialized() -> Bool {
    _session?.navigator != nil
  }

  func cleanup() {
    _session?.locationSimulator?.stopSimulation()
    _session?.navigator?.clearDestinations()
    _session?.roadSnappedLocationProvider?.remove(self)
    _session?.navigator?.isGuidanceActive = false
    _session?.isStarted = false
    _session = nil
  }

  func attachNavigationSessionToMapView(mapId: Int64) throws {
    guard let registry = _viewRegistry else {
      throw GoogleMapsNavigationSessionManagerError.noViewRegistry
    }
    guard let session = _session else {
      throw GoogleMapsNavigationSessionManagerError.sessionNotInitialized
    }
    guard let view = registry.getView(viewId: mapId) else {
      throw GoogleMapsNavigationSessionManagerError.viewNotFound
    }
    guard view.setSession(session) else {
      throw GoogleMapsNavigationSessionManagerError.initializeFailure
    }
    view.setNavigationUIEnabled(true)
  }

  func attachNavigationSessionToMapView(mapView: GoogleMapsNavigationView) {
    guard let _session else { return }
    mapView.setSession(_session)
  }

  func showTermsAndConditionsDialog(title: String, companyName: String,
                                    shouldOnlyShowDriverAwarenessDisclaimer: Bool,
                                    completion: @escaping (Bool) -> Void) {
    GMSNavigationServices
      .shouldOnlyShowDriverAwarenesssDisclaimer = shouldOnlyShowDriverAwarenessDisclaimer
    GMSNavigationServices.showTermsAndConditionsDialogIfNeeded(
      withTitle: title, companyName: companyName
    ) { termsAccepted in
      completion(termsAccepted)
    }
  }

  func areTermsAccepted() -> Bool {
    GMSNavigationServices.areTermsAndConditionsAccepted()
  }

  func resetTermsAccepted() throws {
    if _session != nil {
      throw GoogleMapsNavigationSessionManagerError.termsResetNotAllowed
    }

    GMSNavigationServices.resetTermsAndConditionsAccepted()
  }

  func getNavSDKVersion() -> String {
    GMSNavigationServices.navSDKVersion()
  }

  /// Navigation.
  func startGuidance() throws {
    try getNavigator().isGuidanceActive = true
  }

  func stopGuidance() throws {
    try getNavigator().isGuidanceActive = false
  }

  func isGuidanceRunning() throws -> Bool {
    try getNavigator().isGuidanceActive
  }

  /// If the session has view attached, enable given display options.
  private func handleDisplayOptionsIfNeeded(options: NavigationDisplayOptionsDto) {
    _viewRegistry?.getAllRegisteredViews().forEach { view in
      if let showDestinationMarkers = options.showDestinationMarkers {
        view.showDestinationMarkers(show: showDestinationMarkers)
      }
      if let showStopSigns = options.showStopSigns {
        view.showStopSigns(show: showStopSigns)
      }
      if let showTrafficLights = options.showTrafficLights {
        view.showTrafficLights(show: showTrafficLights)
      }
    }
  }

  func setDestinations(msg: DestinationsDto,
                       completion: @escaping (Result<RouteStatusDto, Error>) -> Void) {
    do {
      /// Set the routing options globally for navigator or restore the defaults
      try setRoutingOptionsGlobals(msg.routingOptions, for: .navigator)
      guard msg.routingOptions != nil else {
        /// Set destinations for navigator.
        try getNavigator()
          .setDestinations(
            Convert.convertWaypoints(msg.waypoints)
          ) { routeStatus in
            completion(.success(Convert.convertRouteStatus(routeStatus)))
          }
        return
      }

      /// If the session has view attached, enable given display options.
      handleDisplayOptionsIfNeeded(options: msg.displayOptions)
      /// Set destinations for navigator with routing options.
      try getNavigator()
        .setDestinations(
          Convert.convertWaypoints(msg.waypoints),
          routingOptions: Convert.convertRoutingOptions(msg.routingOptions),
          callback: { routeStatus in
            completion(.success(Convert.convertRouteStatus(routeStatus)))
          }
        )
    } catch {
      completion(.failure(error))
    }
  }

  func clearDestinations() throws {
    try getNavigator().clearDestinations()
  }

  func continueToNextDestination() throws -> NavigationWaypointDto? {
    guard let nextWaypoint = try getNavigator().continueToNextDestination() else { return nil }
    return Convert.convertNavigationWayPoint(nextWaypoint)
  }

  func getCurrentTimeAndDistance() throws -> NavigationTimeAndDistanceDto {
    let time = try getNavigator().timeToNextDestination
    let distance = try getNavigator().distanceToNextDestination
    return .init(
      time: time,
      distance: distance
    )
  }

  func setAudioGuidance(settings: NavigationAudioGuidanceSettingsDto) throws {
    if let isVibrationEnabled = settings.isVibrationEnabled {
      try getNavigator().isVibrationEnabled = isVibrationEnabled
    }

    if let isBluetoothAudioEnabled = settings.isBluetoothAudioEnabled {
      try getNavigator().audioDeviceType = isBluetoothAudioEnabled ? .bluetooth : .builtInOnly
    }

    if let guidanceType = settings.guidanceType {
      try getNavigator().voiceGuidance = Convert.convertNavigationAudioGuidanceType(guidanceType)
    }
  }

  /// Simulation
  func setUserLocation(location: LatLngDto) throws {
    try getSimulator().simulateLocation(at:
      .init(
        latitude: location.latitude, longitude: location.longitude
      ))
  }

  func removeUserLocation() throws {
    try getSimulator().stopSimulation()
  }

  func simulateLocationsAlongExistingRoute() throws {
    /// Speedmultiplier is set to default value here because the functions using
    /// SimulationOptionsDto will set it globally to a custom value. This
    /// is because we want to use unified API across Android and iOS in the
    /// whole navigation library.
    try getSimulator().speedMultiplier = 1.0
    try getSimulator().simulateLocationsAlongExistingRoute()
  }

  func simulateLocationsAlongExistingRouteWithOptions(options: SimulationOptionsDto) throws {
    try getSimulator().speedMultiplier = Float(options.speedMultiplier)
    try getSimulator().simulateLocationsAlongExistingRoute()
  }

  func simulateLocationsAlongNewRoute(waypoints: [NavigationWaypointDto],
                                      completion: @escaping (Result<
                                        RouteStatusDto,
                                        Error
                                      >)
                                        -> Void) throws {
    /// Speedmultiplier is set to default value here because the functions using
    /// SimulationOptionsDto will set it globally to a custom value. This
    /// is because we want to use unified API across Android and iOS in the
    /// whole navigation library.
    try getSimulator().speedMultiplier = 1.0
    try getSimulator()
      .simulateAlongNewRoute(
        toDestinations: Convert.convertWaypoints(waypoints),
        callback: { routeStatus in
          completion(.success(Convert.convertRouteStatus(routeStatus)))
        }
      )
  }

  /// Set routing options globally for simulator or navigator depending on the use case
  /// or fallback to system default values.
  private func setRoutingOptionsGlobals(_ routingOptions: RoutingOptionsDto?,
                                        for routingOptionsTarget: RoutingOptionsTarget) throws {
    switch routingOptionsTarget {
    case .navigator:
      try getNavigator().avoidsFerries = routingOptions?.avoidFerries ?? true
      try getNavigator().avoidsTolls = routingOptions?.avoidTolls ?? false
      try getNavigator().avoidsHighways = routingOptions?.avoidHighways ?? false
    case .simulator:
      try getSimulator().avoidsFerries = routingOptions?.avoidFerries ?? true
      try getSimulator().avoidsTolls = routingOptions?.avoidTolls ?? false
      try getSimulator().avoidsHighways = routingOptions?.avoidHighways ?? false
    }

    _session?.travelMode = Convert.convertTravelMode(routingOptions?.travelMode)
  }

  func simulateLocationsAlongNewRouteWithRoutingOptions(waypoints: [NavigationWaypointDto],
                                                        routingOptions: RoutingOptionsDto,
                                                        completion: @escaping (Result<
                                                          RouteStatusDto,
                                                          Error
                                                        >) -> Void) throws {
    /// Speedmultiplier is set to default value here because the functions using
    /// SimulationOptionsDto will set it globally to a custom value. This
    /// is because we want to use unified API across Android and iOS in the
    /// whole navigation library.
    try getSimulator().speedMultiplier = 1.0
    try setRoutingOptionsGlobals(routingOptions, for: .simulator)
    try getSimulator()
      .simulateAlongNewRoute(
        toDestinations: Convert.convertWaypoints(waypoints),
        routingOptions: Convert.convertRoutingOptions(routingOptions),
        callback: { routeStatus in
          completion(.success(Convert.convertRouteStatus(routeStatus)))
        }
      )
  }

  func simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(waypoints: [
    NavigationWaypointDto
  ],
  routingOptions: RoutingOptionsDto,
  simulationOptions: SimulationOptionsDto,
  completion: @escaping (Result<
    RouteStatusDto,
    Error
  >) -> Void) throws {
    try getSimulator().speedMultiplier = Float(simulationOptions.speedMultiplier)
    try setRoutingOptionsGlobals(routingOptions, for: .simulator)
    try getSimulator()
      .simulateAlongNewRoute(
        toDestinations: Convert.convertWaypoints(waypoints),
        routingOptions: Convert.convertRoutingOptions(routingOptions),
        callback: { routeStatus in
          completion(.success(Convert.convertRouteStatus(routeStatus)))
        }
      )
  }

  func pauseSimulation() throws {
    try getSimulator().isPaused = true
  }

  func resumeSimulation() throws {
    try getSimulator().isPaused = false
  }

  func allowBackgroundLocationUpdates(allow: Bool) {
    LocationManager.shared.allowBackgroundLocationUpdates(allow: allow)
  }

  func setSpeedAlertOptions(options: SpeedAlertOptionsDto) throws {
    let gmsOptions = GMSNavigationMutableSpeedAlertOptions()
    gmsOptions.severityUpgradeDurationSeconds = options.severityUpgradeDurationSeconds
    gmsOptions.setSpeedAlertThresholdPercentage(
      options.minorSpeedAlertThresholdPercentage,
      for: .minor
    )
    gmsOptions.setSpeedAlertThresholdPercentage(
      options.majorSpeedAlertThresholdPercentage,
      for: .major
    )
    try getNavigator().speedAlertOptions = gmsOptions
  }

  func getRouteSegments() throws -> [RouteSegmentDto] {
    try (getNavigator().routeLegs ?? []).map {
      Convert.convertRouteSegment($0)
    }
  }

  func getTraveledRoute() throws -> [LatLngDto] {
    try Convert.convertPath(getNavigator().traveledPath)
  }

  func getCurrentRouteSegment() throws -> RouteSegmentDto? {
    guard let currentRouteLeg = try getNavigator().currentRouteLeg else { return nil }
    return Convert.convertRouteSegment(currentRouteLeg)
  }

  /// Listeners
  func enableRoadSnappedLocationUpdates() throws {
    LocationManager.shared.startUpdatingLocation()
    _session?.roadSnappedLocationProvider?.startUpdatingLocation()
  }

  func disableRoadSnappedLocationUpdates() throws {
    LocationManager.shared.stopUpdatingLocation()
    _session?.roadSnappedLocationProvider?.stopUpdatingLocation()
  }

  func registerRemainingTimeOrDistanceChangedListener(remainingTimeThresholdSeconds: Int64,
                                                      remainingDistanceThresholdMeters: Int64) {
    // Setting these will also enable listener.
    _session?.navigator?.timeUpdateThreshold = TimeInterval(remainingTimeThresholdSeconds)
    _session?.navigator?
      .distanceUpdateThreshold = CLLocationDistance(remainingDistanceThresholdMeters)
  }
}

extension GoogleMapsNavigationSessionManager: GMSRoadSnappedLocationProviderListener {
  /// Send road snapped location update back to flutter code.
  func locationProvider(_ locationProvider: GMSRoadSnappedLocationProvider,
                        didUpdate location: CLLocation) {
    _navigationSessionEventApi?.onRoadSnappedLocationUpdated(msg:
      .init(
        location:
        .init(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude
        )
      ),
      completion: { _ in })
  }
}

extension GoogleMapsNavigationSessionManager: GMSNavigatorListener {
  /// Send speeding information update back to flutter code.
  func navigator(_ navigator: GMSNavigator,
                 didUpdate speedAlertSeverity: GMSNavigationSpeedAlertSeverity,
                 speedingPercentage percentageAboveLimit: CGFloat) {
    _navigationSessionEventApi?.onSpeedingUpdated(
      msg: .init(
        percentageAboveLimit: percentageAboveLimit,
        severity: Convert.convertSpeedAlertSeverity(gmsSpeedAlertSeverity: speedAlertSeverity)
      ),
      completion: { _ in }
    )
  }

  func navigator(_ navigator: GMSNavigator, didArriveAt waypoint: GMSNavigationWaypoint) {
    _navigationSessionEventApi?.onArrival(
      msg: .init(waypoint: Convert.convertNavigationWayPoint(waypoint)),
      completion: { _ in }
    )
  }

  func navigatorDidChangeRoute(_ navigator: GMSNavigator) {
    _navigationSessionEventApi?.onRouteChanged(
      msg: .init(message: .empty),
      completion: { _ in }
    )
  }

  func navigator(_ navigator: GMSNavigator, didUpdateRemainingTime time: TimeInterval) {
    _navigationSessionEventApi?.onRemainingTimeOrDistanceChanged(
      msg: .init(remainingTime: time, remainingDistance: navigator.distanceToNextDestination),
      completion: { _ in }
    )
  }

  func navigator(_ navigator: GMSNavigator,
                 didUpdateRemainingDistance distance: CLLocationDistance) {
    _navigationSessionEventApi?.onRemainingTimeOrDistanceChanged(
      msg: .init(remainingTime: navigator.timeToNextDestination, remainingDistance: distance),
      completion: { _ in }
    )
  }
}
