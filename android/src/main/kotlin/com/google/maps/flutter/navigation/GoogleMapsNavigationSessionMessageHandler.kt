/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.maps.flutter.navigation

import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.navigation.RoutingOptions
import com.google.android.libraries.navigation.SimulationOptions

class GoogleMapsNavigationSessionMessageHandler(
  private val sessionManager: GoogleMapsNavigationSessionManager
) : NavigationSessionApi {

  override fun createNavigationSession(
    abnormalTerminationReportingEnabled: Boolean,
    behavior: TaskRemovedBehaviorDto,
    callback: (Result<Unit>) -> Unit,
  ) {
    sessionManager.createNavigationSession(abnormalTerminationReportingEnabled, behavior, callback)
  }

  override fun isInitialized(): Boolean {
    return GoogleMapsNavigatorHolder.getInitializationState() ==
      GoogleNavigatorInitializationState.INITIALIZED
  }

  override fun cleanup(resetSession: Boolean) {
    sessionManager.cleanup(resetSession)
  }

  override fun showTermsAndConditionsDialog(
    title: String,
    companyName: String,
    shouldOnlyShowDriverAwarenessDisclaimer: Boolean,
    callback: (Result<Boolean>) -> Unit,
  ) {
    sessionManager.showTermsAndConditionsDialog(
      title,
      companyName,
      shouldOnlyShowDriverAwarenessDisclaimer,
      callback,
    )
  }

  override fun areTermsAccepted(): Boolean {
    return sessionManager.areTermsAccepted()
  }

  override fun resetTermsAccepted() {
    sessionManager.resetTermsAccepted()
  }

  override fun getNavSDKVersion(): String {
    return sessionManager.getNavSDKVersion()
  }

  override fun isGuidanceRunning(): Boolean {
    return sessionManager.isGuidanceRunning()
  }

  override fun startGuidance() {
    sessionManager.startGuidance()
  }

  override fun stopGuidance() {
    sessionManager.stopGuidance()
  }

  override fun setDestinations(
    destinations: DestinationsDto,
    callback: (Result<RouteStatusDto>) -> Unit,
  ) {
    val waypoints =
      destinations.waypoints.filterNotNull().map { Convert.convertWaypointFromDto(it) }
    val displayOptions = Convert.convertDisplayOptionsFromDto(destinations.displayOptions)
    val routingOptions =
      if (destinations.routingOptions != null) {
        Convert.convertRoutingOptionsFromDto(destinations.routingOptions)
      } else {
        RoutingOptions()
      }
    sessionManager.setDestinations(
      waypoints,
      routingOptions,
      displayOptions,
      destinations.routeTokenOptions,
    ) {
      if (it.isSuccess) {
        callback(Result.success(Convert.convertRouteStatusToDto(it.getOrThrow())))
      } else {
        val throwable = it.exceptionOrNull()
        if (throwable != null) {
          callback(Result.failure(throwable))
        }
      }
    }
  }

  override fun clearDestinations() {
    sessionManager.clearDestinations()
  }

  override fun continueToNextDestination(): NavigationWaypointDto? {
    val waypoint = sessionManager.continueToNextDestination()
    return if (waypoint != null) {
      Convert.convertWaypointToDto(waypoint)
    } else {
      null
    }
  }

  override fun getCurrentTimeAndDistance(): NavigationTimeAndDistanceDto {
    val timeAndDistance = sessionManager.getCurrentTimeAndDistance()
    return Convert.convertTimeAndDistanceToDto(timeAndDistance)
  }

  override fun setAudioGuidance(settings: NavigationAudioGuidanceSettingsDto) {
    val audioGuidanceSettings = Convert.convertAudioGuidanceSettingsToDto(settings)
    sessionManager.setAudioGuidance(audioGuidanceSettings)
  }

  override fun setSpeedAlertOptions(options: SpeedAlertOptionsDto) {
    val newOptions = Convert.convertSpeedAlertOptionsFromDto(options)
    sessionManager.setSpeedAlertOptions(newOptions)
  }

  override fun getRouteSegments(): List<RouteSegmentDto> {
    val routeSegments = sessionManager.getRouteSegments()
    return routeSegments.map { Convert.convertRouteSegmentToDto(it) }
  }

  override fun getTraveledRoute(): List<LatLngDto> {
    val traveledRoute = sessionManager.getTraveledRoute()
    return traveledRoute.map { LatLngDto(it.latitude, it.longitude) }
  }

  override fun getCurrentRouteSegment(): RouteSegmentDto? {
    val currentRouteSegment = sessionManager.getCurrentRouteSegment()
    if (currentRouteSegment != null) {
      return Convert.convertRouteSegmentToDto(currentRouteSegment)
    }
    return null
  }

  override fun setUserLocation(location: LatLngDto) {
    sessionManager.setUserLocation(LatLng(location.latitude, location.longitude))
  }

  override fun removeUserLocation() {
    sessionManager.removeUserLocation()
  }

  override fun simulateLocationsAlongExistingRoute() {
    sessionManager.simulateLocationsAlongExistingRoute()
  }

  override fun simulateLocationsAlongExistingRouteWithOptions(options: SimulationOptionsDto) {
    sessionManager.simulateLocationsAlongExistingRouteWithOptions(
      SimulationOptions().speedMultiplier(options.speedMultiplier.toFloat())
    )
  }

  override fun simulateLocationsAlongNewRoute(
    waypoints: List<NavigationWaypointDto>,
    callback: (Result<RouteStatusDto>) -> Unit,
  ) {
    val convertedWaypoints = waypoints.map { Convert.convertWaypointFromDto(it) }
    sessionManager.simulateLocationsAlongNewRoute(convertedWaypoints) {
      if (it.isSuccess) {
        callback(Result.success(Convert.convertRouteStatusToDto(it.getOrThrow())))
      } else {
        val throwable = it.exceptionOrNull()
        if (throwable != null) {
          callback(Result.failure(throwable))
        }
      }
    }
  }

  override fun simulateLocationsAlongNewRouteWithRoutingOptions(
    waypoints: List<NavigationWaypointDto>,
    routingOptions: RoutingOptionsDto,
    callback: (Result<RouteStatusDto>) -> Unit,
  ) {
    val convertedWaypoints = waypoints.map { Convert.convertWaypointFromDto(it) }
    sessionManager.simulateLocationsAlongNewRouteWithRoutingOptions(
      convertedWaypoints,
      Convert.convertRoutingOptionsFromDto(routingOptions),
    ) {
      if (it.isSuccess) {
        callback(Result.success(Convert.convertRouteStatusToDto(it.getOrThrow())))
      } else {
        val throwable = it.exceptionOrNull()
        if (throwable != null) {
          callback(Result.failure(throwable))
        }
      }
    }
  }

  override fun simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
    waypoints: List<NavigationWaypointDto>,
    routingOptions: RoutingOptionsDto,
    simulationOptions: SimulationOptionsDto,
    callback: (Result<RouteStatusDto>) -> Unit,
  ) {
    val convertedWaypoints = waypoints.map { Convert.convertWaypointFromDto(it) }
    sessionManager.simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
      convertedWaypoints,
      Convert.convertRoutingOptionsFromDto(routingOptions),
      SimulationOptions().speedMultiplier(simulationOptions.speedMultiplier.toFloat()),
    ) {
      if (it.isSuccess) {
        callback(Result.success(Convert.convertRouteStatusToDto(it.getOrThrow())))
      } else {
        val throwable = it.exceptionOrNull()
        if (throwable != null) {
          callback(Result.failure(throwable))
        }
      }
    }
  }

  override fun pauseSimulation() {
    sessionManager.pauseSimulation()
  }

  override fun resumeSimulation() {
    sessionManager.resumeSimulation()
  }

  override fun allowBackgroundLocationUpdates(allow: Boolean) {
    throw RuntimeException("Should only be called by iOS application")
  }

  override fun enableRoadSnappedLocationUpdates() {
    sessionManager.enableRoadSnappedLocationUpdates()
  }

  override fun disableRoadSnappedLocationUpdates() {
    sessionManager.disableRoadSnappedLocationUpdates()
  }

  override fun enableTurnByTurnNavigationEvents(numNextStepsToPreview: Long?) {
    sessionManager.enableTurnByTurnNavigationEvents(numNextStepsToPreview?.toInt() ?: Int.MAX_VALUE)
  }

  override fun disableTurnByTurnNavigationEvents() {
    sessionManager.disableTurnByTurnNavigationEvents()
  }

  override fun registerRemainingTimeOrDistanceChangedListener(
    remainingTimeThresholdSeconds: Long,
    remainingDistanceThresholdMeters: Long,
  ) {
    sessionManager.registerRemainingTimeOrDistanceChangedListener(
      remainingTimeThresholdSeconds,
      remainingDistanceThresholdMeters,
    )
  }
}
