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

import android.app.Activity
import android.location.Location
import android.util.DisplayMetrics
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.Observer
import com.google.android.gms.maps.model.LatLng
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.android.libraries.navigation.CustomRoutesOptions
import com.google.android.libraries.navigation.DisplayOptions
import com.google.android.libraries.navigation.NavigationApi
import com.google.android.libraries.navigation.NavigationApi.NavigatorListener
import com.google.android.libraries.navigation.NavigationUpdatesOptions
import com.google.android.libraries.navigation.NavigationUpdatesOptions.GeneratedStepImagesType
import com.google.android.libraries.navigation.Navigator
import com.google.android.libraries.navigation.Navigator.TaskRemovedBehavior
import com.google.android.libraries.navigation.RoadSnappedLocationProvider
import com.google.android.libraries.navigation.RouteSegment
import com.google.android.libraries.navigation.RoutingOptions
import com.google.android.libraries.navigation.SimulationOptions
import com.google.android.libraries.navigation.SpeedAlertOptions
import com.google.android.libraries.navigation.SpeedAlertSeverity
import com.google.android.libraries.navigation.SpeedingListener
import com.google.android.libraries.navigation.TermsAndConditionsCheckOption
import com.google.android.libraries.navigation.TermsAndConditionsUIParams
import com.google.android.libraries.navigation.TimeAndDistance
import com.google.android.libraries.navigation.Waypoint
import com.google.maps.flutter.navigation.Convert.convertTravelModeFromDto
import io.flutter.plugin.common.BinaryMessenger
import java.lang.ref.WeakReference

interface NavigationReadyListener {
  fun onNavigationReady(ready: Boolean)
}

/** This class handles creation of navigation session and other navigation related tasks. */
class GoogleMapsNavigationSessionManager
private constructor(private val navigationSessionEventApi: NavigationSessionEventApi) :
  DefaultLifecycleObserver {
  companion object {
    private var instance: GoogleMapsNavigationSessionManager? = null
    var navigationReadyListener: NavigationReadyListener? = null

    /**
     * Create new GoogleMapsNavigationSessionManager instance. Does nothing if instance is already
     * created.
     *
     * @param binaryMessenger BinaryMessenger to use for API setup.
     */
    @Synchronized
    fun createInstance(binaryMessenger: BinaryMessenger) {
      if (instance != null) {
        return
      }

      val sessionMessageHandler = GoogleMapsNavigationSessionMessageHandler()
      NavigationSessionApi.setUp(binaryMessenger, sessionMessageHandler)
      val navigationSessionEventApi = NavigationSessionEventApi(binaryMessenger)
      instance = GoogleMapsNavigationSessionManager(navigationSessionEventApi)
    }

    /**
     * Stop all navigation related tasks and destroy [GoogleMapsNavigationSessionManager] instance.
     */
    @Synchronized
    fun destroyInstance() {
      // Stop all navigation related tasks.
      instance = null
    }

    /**
     * Get instance that was previously created
     *
     * @return [GoogleMapsNavigationSessionManager] instance.
     */
    @Synchronized
    fun getInstance(): GoogleMapsNavigationSessionManager {
      if (instance == null) {
        throw RuntimeException("Instance not created, create with createInstance()")
      }
      return instance!!
    }
  }

  private var navigator: Navigator? = null
  private var isNavigationSessionInitialized = false
  private var arrivalListener: Navigator.ArrivalListener? = null
  private var routeChangedListener: Navigator.RouteChangedListener? = null
  private var reroutingListener: Navigator.ReroutingListener? = null
  private var trafficUpdatedListener: Navigator.TrafficUpdatedListener? = null
  private var remainingTimeOrDistanceChangedListener:
    Navigator.RemainingTimeOrDistanceChangedListener? =
    null
  private var roadSnappedLocationProvider: RoadSnappedLocationProvider? = null
  private var roadSnappedLocationListener:
    RoadSnappedLocationProvider.GpsAvailabilityEnhancedLocationListener? =
    null
  private var speedingListener: SpeedingListener? = null
  private var weakActivity: WeakReference<Activity>? = null
  private var turnByTurnEventsEnabled: Boolean = false
  private var weakLifecycleOwner: WeakReference<LifecycleOwner>? = null
  private var taskRemovedBehavior: @TaskRemovedBehavior Int = 0

  override fun onCreate(owner: LifecycleOwner) {
    weakLifecycleOwner = WeakReference(owner)
  }

  override fun onStart(owner: LifecycleOwner) {
    weakLifecycleOwner = WeakReference(owner)
  }

  override fun onResume(owner: LifecycleOwner) {
    weakLifecycleOwner = WeakReference(owner)
  }

  /** Set activity instance to use. Some functions require [Activity] instance to show user UI. */
  fun onActivityCreated(activity: Activity) {
    weakActivity = WeakReference(activity)
  }

  /** Convenience function for returning the activity. */
  private fun getActivity(): Activity {
    return weakActivity?.get() ?: throw FlutterError("activityNotFound", "Activity not created.")
  }

  /** Clean up activity reference to prevent memory leaks. */
  fun onActivityDestroyed() {
    unregisterListeners()
    weakActivity?.clear()
    weakActivity = null
    weakLifecycleOwner?.clear()
    weakLifecycleOwner = null
  }

  @Throws(FlutterError::class)
  fun getNavigator(): Navigator {
    if (navigator != null) {
      return navigator!!
    } else {
      throw FlutterError(
        "sessionNotInitialized",
        "Cannot access navigation functionality before the navigation session has been initialized.",
      )
    }
  }

  // Expose the navigator to the google_maps_driver side.
  // DriverApi initialization requires navigator.
  fun getNavigatorWithoutError(): Navigator? {
    return navigator
  }

  /** Creates Navigator instance. */
  fun createNavigationSession(
    abnormalTerminationReportingEnabled: Boolean,
    behavior: TaskRemovedBehaviorDto,
    callback: (Result<Unit>) -> Unit,
  ) {
    if (navigator != null) {
      // Navigator is already initialized, just re-register listeners.
      registerNavigationListeners()
      isNavigationSessionInitialized = true
      navigationReadyListener?.onNavigationReady(true)
      callback(Result.success(Unit))
      return
    }
    taskRemovedBehavior = Convert.taskRemovedBehaviorDtoToTaskRemovedBehavior(behavior)

    // Align API behavior with iOS:
    // If the terms haven't yet been accepted throw an error.
    if (!areTermsAccepted()) {
      callback(
        Result.failure(
          FlutterError(
            "termsNotAccepted",
            "The session initialization failed, because the user has not yet accepted the navigation terms and conditions.",
          )
        )
      )
      return
    }

    // Enable or disable abnormal termination reporting.
    NavigationApi.setAbnormalTerminationReportingEnabled(abnormalTerminationReportingEnabled)

    val listener =
      object : NavigatorListener {
        override fun onNavigatorReady(newNavigator: Navigator) {
          navigator = newNavigator
          navigator?.setTaskRemovedBehavior(taskRemovedBehavior)
          registerNavigationListeners()
          isNavigationSessionInitialized = true
          navigationReadyListener?.onNavigationReady(true)
          callback(Result.success(Unit))
        }

        override fun onError(@NavigationApi.ErrorCode errorCode: Int) {
          // Keep in sync with GoogleMapsNavigationSessionManager.swift
          when (errorCode) {
            NavigationApi.ErrorCode.NOT_AUTHORIZED -> {
              callback(
                Result.failure(
                  FlutterError(
                    "notAuthorized",
                    "The session initialization failed, because the required Maps API key is empty or invalid.",
                  )
                )
              )
            }
            NavigationApi.ErrorCode.TERMS_NOT_ACCEPTED -> {
              callback(
                Result.failure(
                  FlutterError(
                    "termsNotAccepted",
                    "The session initialization failed, because the user has not yet accepted the navigation terms and conditions.",
                  )
                )
              )
            }
            NavigationApi.ErrorCode.NETWORK_ERROR -> {
              callback(
                Result.failure(
                  FlutterError(
                    "networkError",
                    "The session initialization failed, because there is no working network connection.",
                  )
                )
              )
            }
            NavigationApi.ErrorCode.LOCATION_PERMISSION_MISSING -> {
              callback(
                Result.failure(
                  FlutterError(
                    "locationPermissionMissing",
                    "The session initialization failed, because the required location permission has not been granted.",
                  )
                )
              )
            }
          }
        }
      }

    NavigationApi.getNavigator(getActivity(), listener)
  }

  @Throws(FlutterError::class)
  private fun getRoadSnappedLocationProvider(): RoadSnappedLocationProvider? {
    return if (roadSnappedLocationProvider != null) {
      roadSnappedLocationProvider
    } else {
      val application = getActivity().application
      if (application != null) {
        roadSnappedLocationProvider = NavigationApi.getRoadSnappedLocationProvider(application)
        roadSnappedLocationProvider
      } else {
        throw FlutterError(
          "roadSnappedLocationProviderUnavailable",
          "Could not get the road snapped location provider, activity not set.",
        )
      }
    }
  }

  /** Stops navigation and cleans up internal state of the navigator when it's no longer needed. */
  fun cleanup() {
    val navigator = getNavigator()
    navigator.stopGuidance()
    navigator.clearDestinations()
    navigator.simulator.unsetUserLocation()
    unregisterListeners()

    // As unregisterListeners() is removing all listeners, we need to re-register them when
    // navigator is re-initialized. This is done in createNavigationSession() method.
    isNavigationSessionInitialized = false
    navigationReadyListener?.onNavigationReady(false)
  }

  private fun unregisterListeners() {
    if (isInitialized()) {
      val navigator = getNavigator()
      if (remainingTimeOrDistanceChangedListener != null) {
        navigator.removeRemainingTimeOrDistanceChangedListener(
          remainingTimeOrDistanceChangedListener
        )
        remainingTimeOrDistanceChangedListener = null
      }
      if (arrivalListener != null) {
        navigator.removeArrivalListener(arrivalListener)
        arrivalListener = null
      }
      if (routeChangedListener != null) {
        navigator.removeRouteChangedListener(routeChangedListener)
        routeChangedListener = null
      }
      if (reroutingListener != null) {
        navigator.removeReroutingListener(reroutingListener)
        reroutingListener = null
      }
      if (trafficUpdatedListener != null) {
        navigator.removeTrafficUpdatedListener(trafficUpdatedListener)
        trafficUpdatedListener = null
      }
      if (speedingListener != null) {
        navigator.setSpeedingListener(null)
        speedingListener = null
      }
    }
    if (roadSnappedLocationListener != null) {
      disableRoadSnappedLocationUpdates()
    }
    if (turnByTurnEventsEnabled) {
      disableTurnByTurnNavigationEvents()
    }
  }

  fun registerRemainingTimeOrDistanceChangedListener(
    remainingTimeThresholdSeconds: Long,
    remainingDistanceThresholdMeters: Long,
  ) {
    if (remainingTimeOrDistanceChangedListener != null) {
      // Remove previously created listener to prevent
      // duplicate events.
      getNavigator()
        .removeRemainingTimeOrDistanceChangedListener(remainingTimeOrDistanceChangedListener)
    } else {
      remainingTimeOrDistanceChangedListener =
        Navigator.RemainingTimeOrDistanceChangedListener {
          val timeAndDistance = getNavigator().currentTimeAndDistance
          navigationSessionEventApi.onRemainingTimeOrDistanceChanged(
            timeAndDistance.seconds.toDouble(),
            timeAndDistance.meters.toDouble(),
          ) {}
        }
    }

    getNavigator()
      .addRemainingTimeOrDistanceChangedListener(
        remainingTimeThresholdSeconds.toInt(),
        remainingDistanceThresholdMeters.toInt(),
        remainingTimeOrDistanceChangedListener,
      )
  }

  private fun registerNavigationListeners() {
    val navigator = getNavigator()
    if (arrivalListener == null) {
      arrivalListener =
        Navigator.ArrivalListener {
          navigationSessionEventApi.onArrival(Convert.convertWaypointToDto(it.waypoint)) {}
        }
      navigator.addArrivalListener(arrivalListener)
    }

    if (routeChangedListener == null) {
      routeChangedListener =
        Navigator.RouteChangedListener { navigationSessionEventApi.onRouteChanged() {} }
      navigator.addRouteChangedListener(routeChangedListener)
    }

    if (reroutingListener == null) {
      reroutingListener = Navigator.ReroutingListener { navigationSessionEventApi.onRerouting() {} }
      navigator.addReroutingListener(reroutingListener)
    }

    if (trafficUpdatedListener == null) {
      trafficUpdatedListener =
        Navigator.TrafficUpdatedListener { navigationSessionEventApi.onTrafficUpdated() {} }
      navigator.addTrafficUpdatedListener(trafficUpdatedListener)
    }

    if (speedingListener == null) {
      speedingListener =
        SpeedingListener { percentageAboveLimit: Float, speedAlertSeverity: SpeedAlertSeverity ->
          navigationSessionEventApi.onSpeedingUpdated(
            SpeedingUpdatedEventDto(
              percentageAboveLimit.toDouble(),
              Convert.convertSpeedAlertSeverityFromDto(speedAlertSeverity),
            )
          ) {}
        }
      navigator.setSpeedingListener(speedingListener)
    }
  }

  /**
   * Wraps [Navigator.startGuidance]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#startGuidance()).
   */
  fun startGuidance() {
    getNavigator().startGuidance()
  }

  /**
   * Wraps [Navigator.stopGuidance]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#stopGuidance()).
   */
  fun stopGuidance() {
    getNavigator().stopGuidance()
  }

  fun isGuidanceRunning(): Boolean {
    return getNavigator().isGuidanceRunning
  }

  /**
   * Wraps [Navigator.setDestinations] with result listener. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#setDestinations(java.util.List%3Ccom.google.android.libraries.navigation.Waypoint%3E,%20com.google.android.libraries.navigation.CustomRoutesOptions,%20com.google.android.libraries.navigation.DisplayOptions)).
   */
  fun setDestinations(
    waypoints: List<Waypoint>,
    routingOptions: RoutingOptions,
    displayOptions: DisplayOptions,
    routeTokenOptions: RouteTokenOptionsDto?,
    callback: (Result<Navigator.RouteStatus>) -> Unit,
  ) {
    try {
      // If route toke options are present set token and travel mode if given.
      if (routeTokenOptions != null) {
        val customRoutesOptionBuilder =
          CustomRoutesOptions.builder().setRouteToken(routeTokenOptions.routeToken)
        if (routeTokenOptions.travelMode != null) {
          customRoutesOptionBuilder.setTravelMode(
            convertTravelModeFromDto(routeTokenOptions.travelMode)
          )
        }

        val customRoutesOptions: CustomRoutesOptions
        try {
          customRoutesOptions = customRoutesOptionBuilder.build()
        } catch (e: IllegalStateException) {
          throw FlutterError(
            "routeTokenMalformed",
            "The route token passed is malformed",
            e.message,
          )
        }

        getNavigator()
          .setDestinations(waypoints, customRoutesOptions, displayOptions)
          .setOnResultListener { callback(Result.success(it)) }
        return
      }
      getNavigator()
        .setDestinations(waypoints, routingOptions, displayOptions)
        .setOnResultListener { callback(Result.success(it)) }
    } catch (e: Throwable) {
      callback(Result.failure(e))
    }
  }

  /**
   * Wraps [Navigator.clearDestinations]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#clearDestinations())
   */
  fun clearDestinations() {
    getNavigator().clearDestinations()
  }

  /**
   * Wraps [Navigator.continueToNextDestination]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#continueToNextDestination())
   *
   * @return the waypoint guidance is now heading to, or null if there were no more waypoints left.
   */
  fun continueToNextDestination(): Waypoint? {
    return getNavigator().continueToNextDestination()
  }

  /**
   * Wraps [Navigator.getCurrentTimeAndDistance]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#getCurrentTimeAndDistance()).
   *
   * @return [TimeAndDistance] object.
   */
  fun getCurrentTimeAndDistance(): TimeAndDistance {
    return getNavigator().currentTimeAndDistance
  }

  /**
   * Wraps [Navigator.setAudioGuidance]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Navigator#setAudioGuidance(int)).
   */
  fun setAudioGuidance(audioGuidanceSettings: Int) {
    getNavigator().setAudioGuidance(audioGuidanceSettings)
  }

  fun setSpeedAlertOptions(options: SpeedAlertOptions) {
    getNavigator().setSpeedAlertOptions(options)
  }

  fun getRouteSegments(): List<RouteSegment> {
    return getNavigator().routeSegments
  }

  fun getTraveledRoute(): List<LatLng> {
    return getNavigator().traveledRoute
  }

  fun getCurrentRouteSegment(): RouteSegment? {
    return getNavigator().currentRouteSegment
  }

  /**
   * Wraps [NavigationApi.showTermsAndConditionsDialog]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/NavigationApi#showTermsAndConditionsDialog(android.app.Activity,%20java.lang.String,%20java.lang.String,%20com.google.android.libraries.navigation.NavigationApi.OnTermsResponseListener)).
   */
  fun showTermsAndConditionsDialog(
    title: String,
    companyName: String,
    shouldOnlyShowDriverAwarenessDisclaimer: Boolean,
    callback: (Result<Boolean>) -> Unit,
  ) {
    // Align API behavior with iOS:
    // If the terms have already been accepted just return true straight away.
    if (areTermsAccepted()) {
      callback(Result.success(true))
      return
    }

    if (shouldOnlyShowDriverAwarenessDisclaimer) {
      val defaultParams: TermsAndConditionsUIParams = TermsAndConditionsUIParams.builder().build()
      NavigationApi.showTermsAndConditionsDialog(
        getActivity(),
        companyName,
        title,
        defaultParams,
        { accepted -> callback(Result.success(accepted)) },
        TermsAndConditionsCheckOption.SKIPPED,
      )
    } else {
      NavigationApi.showTermsAndConditionsDialog(getActivity(), companyName, title) { accepted ->
        callback(Result.success(accepted))
      }
    }
  }

  /**
   * Check if navigation session is already created.
   *
   * @return true if session is already created.
   */
  fun isInitialized(): Boolean {
    return navigator != null && isNavigationSessionInitialized
  }

  /**
   * Wraps [NavigationApi.areTermsAccepted]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/NavigationApi#areTermsAccepted(android.app.Application)).
   *
   * @return true if the terms have been accepted by the user, and false otherwise.
   */
  fun areTermsAccepted(): Boolean {
    return NavigationApi.areTermsAccepted(getActivity().application)
  }

  /**
   * Wraps [NavigationApi.resetTermsAccepted]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/NavigationApi#resetTermsAccepted(android.app.Application)).
   */
  fun resetTermsAccepted() {
    try {
      NavigationApi.resetTermsAccepted(getActivity().application)
    } catch (error: IllegalStateException) {
      throw FlutterError(
        "termsResetNotAllowed",
        "The terms acceptance cannot be reset while the navigation session is active.",
      )
    }
  }

  fun getNavSDKVersion(): String {
    return NavigationApi.getNavSDKVersion()
  }

  /**
   * Wraps [Simulator.setUserLocation]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#setUserLocation(com.google.android.gms.maps.model.LatLng)).
   */
  fun setUserLocation(location: LatLng) {
    getNavigator().simulator.setUserLocation(location)
  }

  /**
   * Wraps [Simulator.unsetUserLocation]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#unsetUserLocation()).
   */
  fun removeUserLocation() {
    getNavigator().simulator.unsetUserLocation()
  }

  /**
   * Wraps [Simulator.simulateLocationsAlongExistingRoute]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#simulateLocationsAlongExistingRoute()).
   */
  fun simulateLocationsAlongExistingRoute() {
    getNavigator().simulator.simulateLocationsAlongExistingRoute()
  }

  /**
   * Wraps [Simulator.simulateLocationsAlongExistingRoute]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#simulateLocationsAlongExistingRoute()).
   */
  fun simulateLocationsAlongExistingRouteWithOptions(options: SimulationOptions) {
    getNavigator().simulator.simulateLocationsAlongExistingRoute(options)
  }

  /**
   * Wraps [Simulator.simulateLocationsAlongNewRoute] with callback. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#simulateLocationsAlongExistingRoute(com.google.android.libraries.navigation.SimulationOptions)).
   */
  fun simulateLocationsAlongNewRoute(
    waypoints: List<Waypoint>,
    callback: (Result<Navigator.RouteStatus>) -> Unit,
  ) {
    try {
      getNavigator().simulator.simulateLocationsAlongNewRoute(waypoints).setOnResultListener {
        callback(Result.success(it))
      }
    } catch (e: Throwable) {
      callback(Result.failure(e))
    }
  }

  /**
   * Wraps [Simulator.simulateLocationsAlongNewRoute] with callback. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#simulateLocationsAlongExistingRoute(com.google.android.libraries.navigation.SimulationOptions)).
   */
  fun simulateLocationsAlongNewRouteWithRoutingOptions(
    waypoints: List<Waypoint>,
    routingOptions: RoutingOptions,
    callback: (Result<Navigator.RouteStatus>) -> Unit,
  ) {
    try {
      getNavigator()
        .simulator
        .simulateLocationsAlongNewRoute(waypoints, routingOptions)
        .setOnResultListener { callback(Result.success(it)) }
    } catch (e: Throwable) {
      callback(Result.failure(e))
    }
  }

  /**
   * Wraps [Simulator.simulateLocationsAlongNewRoute] with callback. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#simulateLocationsAlongExistingRoute(com.google.android.libraries.navigation.SimulationOptions)).
   */
  fun simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
    waypoints: List<Waypoint>,
    routingOptions: RoutingOptions,
    simulationOptions: SimulationOptions,
    callback: (Result<Navigator.RouteStatus>) -> Unit,
  ) {
    try {
      getNavigator()
        .simulator
        .simulateLocationsAlongNewRoute(waypoints, routingOptions, simulationOptions)
        .setOnResultListener { callback(Result.success(it)) }
    } catch (e: Throwable) {
      callback(Result.failure(e))
    }
  }

  /**
   * Wraps [Simulator.pause]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#pause()).
   */
  fun pauseSimulation() {
    getNavigator().simulator.pause()
  }

  /**
   * Wraps [Simulator.resume]. See
   * [Google Navigation SDK for Android](https://developers.google.com/maps/documentation/navigation/android-sdk/reference/com/google/android/libraries/navigation/Simulator#resume()).
   */
  fun resumeSimulation() {
    getNavigator().simulator.resume()
  }

  @Throws(FlutterError::class)
  fun enableTurnByTurnNavigationEvents(numNextStepsToPreview: Int) {
    var lifeCycleOwner: LifecycleOwner? = weakLifecycleOwner?.get()
    if (!turnByTurnEventsEnabled && lifeCycleOwner != null) {

      /// DisplayMetrics is required to be set for turn-by-turn updates.
      /// But not used as image generation is disabled.
      var displayMetrics = DisplayMetrics()
      displayMetrics.density = 2.0f

      // Configure options for navigation updates.
      val options =
        NavigationUpdatesOptions.builder()
          .setNumNextStepsToPreview(numNextStepsToPreview)
          .setGeneratedStepImagesType(GeneratedStepImagesType.NONE)
          .setDisplayMetrics(displayMetrics)
          .build()

      // Attempt to register the service for navigation updates.
      val success =
        getNavigator()
          .registerServiceForNavUpdates(
            getActivity().packageName,
            GoogleMapsNavigationNavUpdatesService::class.java.name,
            options,
          )

      if (success) {
        val navInfoObserver: Observer<NavInfo> = Observer { navInfo ->
          navigationSessionEventApi.onNavInfo(Convert.convertNavInfo(navInfo)) {}
        }
        GoogleMapsNavigationNavUpdatesService.navInfoLiveData.observe(
          lifeCycleOwner,
          navInfoObserver,
        )
        turnByTurnEventsEnabled = true
      } else {
        throw FlutterError(
          "turnByTurnServiceError",
          "Error while registering turn-by-turn updates service.",
        )
      }
    }
  }

  @Throws(FlutterError::class)
  fun disableTurnByTurnNavigationEvents() {
    var lifeCycleOwner: LifecycleOwner? = weakLifecycleOwner?.get()
    if (turnByTurnEventsEnabled && lifeCycleOwner != null) {
      GoogleMapsNavigationNavUpdatesService.navInfoLiveData.removeObservers(lifeCycleOwner)
      val success = getNavigator().unregisterServiceForNavUpdates()
      if (success) {
        turnByTurnEventsEnabled = false
      } else {
        throw FlutterError(
          "turnByTurnServiceError",
          "Error while unregistering turn-by-turn updates service.",
        )
      }
    }
  }

  @Throws(FlutterError::class)
  fun enableRoadSnappedLocationUpdates() {
    if (roadSnappedLocationListener == null) {
      roadSnappedLocationListener =
        object : RoadSnappedLocationProvider.GpsAvailabilityEnhancedLocationListener {
          override fun onLocationChanged(location: Location) {
            navigationSessionEventApi.onRoadSnappedLocationUpdated(
              LatLngDto(location.latitude, location.longitude)
            ) {}
          }

          override fun onRawLocationUpdate(location: Location) {
            navigationSessionEventApi.onRoadSnappedRawLocationUpdated(
              LatLngDto(location.latitude, location.longitude)
            ) {}
          }

          override fun onGpsAvailabilityUpdate(isGpsAvailable: Boolean) {
            navigationSessionEventApi.onGpsAvailabilityUpdate(isGpsAvailable) {}
          }
        }
      getRoadSnappedLocationProvider()?.addLocationListener(roadSnappedLocationListener)
    }
  }

  @Throws(FlutterError::class)
  fun disableRoadSnappedLocationUpdates() {
    getRoadSnappedLocationProvider()?.removeLocationListener(roadSnappedLocationListener)
    roadSnappedLocationListener = null
  }
}
