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

import 'dart:async';

import '../../google_maps_navigation.dart';
import '../google_maps_navigation_platform_interface.dart';
// ignore_for_file: avoid_classes_with_only_static_members

import 'google_maps_navigation_simulator.dart';

/// GoogleMapsNavigator handles general actions of the navigation SDK
/// and allows creating navigation session controller.
/// {@category Navigation}
class GoogleMapsNavigator {
  static final Simulator _simulator = Simulator();

  /// Simulator manager handling simulator actions.
  static Simulator get simulator {
    return _simulator;
  }

  /// Initializes the navigation session.
  ///
  /// Successful initialization requires that a valid Maps API key has been defined,
  /// and the user has accepted the navigation terms and conditions and granted
  /// location permissions for the app. Otherwise the method throws
  /// [SessionInitializationException].
  ///
  /// Before the initialization different navigation actions provided by [GoogleMapsNavigator]
  /// ([GoogleMapsNavigator.setDestinations], [GoogleMapsNavigator.startGuidance], etc.)
  /// throw [SessionNotInitializedException].
  ///
  static Future<void> initializeNavigationSession() async {
    await GoogleMapsNavigationPlatform.instance.createNavigationSession();
  }

  /// Check whether navigator has been initialized.
  ///
  /// Note: This does not detect if there is ongoing navigation session in the Android
  /// foreground service. To resume navigation after Android activity has been destroyed,
  /// navigation session must be re-initialized with [initializeNavigationSession].
  /// After initialization guidance state can be checked with [isGuidanceRunning].
  static Future<bool> isInitialized() async {
    return GoogleMapsNavigationPlatform.instance.isInitialized();
  }

  /// Sets the event channel listener for navigation session event.
  static StreamSubscription<NavigationSessionEvent>
      setNavigationSessionEventListener(
          OnNavigationSessionEventCallback onNavigationSessionEvent) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationSessionEventStream()
        .listen(onNavigationSessionEvent);
  }

  /// Sets the event channel listener for the speeding updated event.
  static StreamSubscription<SpeedingUpdatedEvent> setSpeedingUpdatedListener(
    OnSpeedingUpdatedEventCallback onSpeedingUpdatedEvent,
  ) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationSpeedingEventStream()
        .listen(onSpeedingUpdatedEvent);
  }

  /// Sets the event channel listener for the on arrival event.
  static StreamSubscription<OnArrivalEvent> setOnArrivalListener(
      OnArrivalEventCallback onArrivalEvent) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationOnArrivalEventStream()
        .listen(onArrivalEvent);
  }

  /// Sets the event channel listener for the rerouting event. (Android only)
  static StreamSubscription<void> setOnReroutingListener(
      OnReroutingEventCallback onReroutingEvent) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationOnReroutingEventStream()
        .listen((void event) {
      onReroutingEvent.call();
    });
  }

  /// Sets the event channel listener for the traffic updated event. (Android only)
  static StreamSubscription<void> setTrafficUpdatedListener(
      OnTrafficUpdatedEventCallback onTrafficUpdatedEvent) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationTrafficUpdatedEventStream()
        .listen((void event) {
      onTrafficUpdatedEvent.call();
    });
  }

  /// Sets the event channel listener for the on route changed event.
  static StreamSubscription<void> setOnRouteChangedListener(
      OnRouteChangedEventCallback onRouteChangedEvent) {
    return GoogleMapsNavigationPlatform.instance
        .getNavigationOnRouteChangedEventStream()
        .listen((void event) {
      onRouteChangedEvent.call();
    });
  }

  /// Sets the event channel listener for the on remaining time or distance changed event.
  static StreamSubscription<RemainingTimeOrDistanceChangedEvent>
      setOnRemainingTimeOrDistanceChangedListener(
          OnRemainingTimeOrDistanceChangedEventCallback
              onRemainingTimeOrDistanceChangedEvent,
          // iOS default value.
          {int remainingTimeThresholdSeconds = 1,
          // iOS default value.
          int remainingDistanceThresholdMeters = 1}) {
    assert(remainingTimeThresholdSeconds >= 0);
    assert(remainingDistanceThresholdMeters >= 0);
    GoogleMapsNavigationPlatform.instance
        .registerRemainingTimeOrDistanceChangedListener(
            remainingTimeThresholdSeconds, remainingDistanceThresholdMeters);
    return GoogleMapsNavigationPlatform.instance
        .getNavigationRemainingTimeOrDistanceChangedEventStream()
        .listen(onRemainingTimeOrDistanceChangedEvent);
  }

  static StreamController<RoadSnappedLocationUpdatedEvent>?
      _roadSnappedLocationUpdatedController;

  /// Enable road snapped location updates and set the event channel listener
  /// for the road snapped location updated event.
  static Future<StreamSubscription<RoadSnappedLocationUpdatedEvent>>
      setRoadSnappedLocationUpdatedListener(
    OnRoadSnappedLocationUpdatedEventCallback onRoadSnappedLocationUpdatedEvent,
  ) async {
    if (_roadSnappedLocationUpdatedController == null) {
      _roadSnappedLocationUpdatedController =
          StreamController<RoadSnappedLocationUpdatedEvent>.broadcast(
        onCancel: () {
          if (!_roadSnappedLocationUpdatedController!.hasListener) {
            GoogleMapsNavigationPlatform.instance
                .disableRoadSnappedLocationUpdates();
          }
        },
        onListen: () {
          GoogleMapsNavigationPlatform.instance
              .enableRoadSnappedLocationUpdates();
        },
      );
      unawaited(_roadSnappedLocationUpdatedController!.addStream(
          GoogleMapsNavigationPlatform.instance
              .getNavigationRoadSnappedLocationEventStream()));
    }

    return _roadSnappedLocationUpdatedController!.stream
        .listen(onRoadSnappedLocationUpdatedEvent);
  }

  /// Cleans up the navigation session.
  ///
  /// Cleans up the navigator's internal state, clearing
  /// any existing route waypoints and stopping ongoing
  /// navigation guidance and simulation.
  ///
  /// On iOS the session is fully deleted and needs to be recreated
  /// by calling [GoogleMapsNavigator.initializeNavigationSession].
  ///
  /// On Android the session is cleaned up, but never destroyed after the
  /// first initialization.
  ///
  static Future<void> cleanup() async {
    await GoogleMapsNavigationPlatform.instance.cleanup();
  }

  /// Shows terms and conditions dialog.
  ///
  ///  Shows the terms and conditions dialog with the given [title]
  ///  and [companyName]. By default, normal terms and conditions are displayed.
  ///  Optional parameter [shouldOnlyShowDriverAwarenessDisclaimer] indicates
  ///  if only driver awareness disclaimer should be shown (Android only).
  ///  On iOS enabling [shouldOnlyShowDriverAwarenessDisclaimer] throws UnsupportedError.
  ///
  ///  Returns true if the user accepts the terms, and false if not. If the terms
  ///  have already been accepted returns true without showing the dialog again.
  //
  static Future<bool> showTermsAndConditionsDialog(
      String title, String companyName,
      {bool shouldOnlyShowDriverAwarenessDisclaimer = false}) async {
    return GoogleMapsNavigationPlatform.instance.showTermsAndConditionsDialog(
        title, companyName, shouldOnlyShowDriverAwarenessDisclaimer);
  }

  /// Checks if terms and conditions have already been accepted by the user.
  static Future<bool> areTermsAccepted() async {
    return GoogleMapsNavigationPlatform.instance.areTermsAccepted();
  }

  /// Resets the terms of service acceptance state.
  ///
  /// If the navigation session has already been initialized
  /// throws [ResetTermsAndConditionsException].
  static Future<void> resetTermsAccepted() async {
    return GoogleMapsNavigationPlatform.instance.resetTermsAccepted();
  }

  /// Gets the native navigation SDK version as string.
  static Future<String> getNavSDKVersion() async {
    return GoogleMapsNavigationPlatform.instance.getNavSDKVersion();
  }

  /// Starts the navigation guidance.
  static Future<void> startGuidance() {
    return GoogleMapsNavigationPlatform.instance.startGuidance();
  }

  /// Stops the navigation guidance.
  static Future<void> stopGuidance() {
    return GoogleMapsNavigationPlatform.instance.stopGuidance();
  }

  /// Check if guidance is running.
  static Future<bool> isGuidanceRunning() {
    return GoogleMapsNavigationPlatform.instance.isGuidanceRunning();
  }

  /// Sets destination waypoints and other settings.
  static Future<NavigationRouteStatus> setDestinations(Destinations msg) {
    return GoogleMapsNavigationPlatform.instance.setDestinations(msg);
  }

  /// Clears existing destinations.
  static Future<void> clearDestinations() {
    return GoogleMapsNavigationPlatform.instance.clearDestinations();
  }

  /// Continues to the next waypoint.
  ///
  /// Removes the current waypoint.
  /// Following this call, guidance will be toward the next destination,
  /// and information about the old destination is not available.
  static Future<NavigationWaypoint?> continueToNextDestination() {
    return GoogleMapsNavigationPlatform.instance.continueToNextDestination();
  }

  /// Returns how much current time and distance are left.
  static Future<NavigationTimeAndDistance> getCurrentTimeAndDistance() {
    return GoogleMapsNavigationPlatform.instance.getCurrentTimeAndDistance();
  }

  /// Sets the audio guidance settings.
  static Future<void> setAudioGuidance(
      NavigationAudioGuidanceSettings settings) {
    return GoogleMapsNavigationPlatform.instance.setAudioGuidance(settings);
  }

  /// Sets state of allow background location updates. (iOS only)
  ///
  /// Throws [UnsupportedError] on Android.
  static Future<void> allowBackgroundLocationUpdates(bool allow) {
    return GoogleMapsNavigationPlatform.instance.allowBackgroundLocationUpdates(
      allow,
    );
  }

  /// Get route segments.
  static Future<List<RouteSegment>> getRouteSegments() {
    return GoogleMapsNavigationPlatform.instance.getRouteSegments();
  }

  /// Get traveled route.
  static Future<List<LatLng>> getTraveledRoute() {
    return GoogleMapsNavigationPlatform.instance.getTraveledRoute();
  }

  /// Get current route segment.
  static Future<RouteSegment?> getCurrentRouteSegment() {
    return GoogleMapsNavigationPlatform.instance.getCurrentRouteSegment();
  }
}

/// Possible errors that [GoogleMapsNavigator.initializeNavigationSession] can throw.
enum SessionInitializationError {
  /// The session initialization failed, because the required Maps API key is empty or invalid.
  notAuthorized,

  /// The session initialization failed, because the required location permission has not been granted.
  locationPermissionMissing,

  /// The session initialization failed, because the user has not yet accepted the navigation terms and conditions.
  termsNotAccepted
}

/// Exception thrown by [GoogleMapsNavigator.initializeNavigationSession].
class SessionInitializationException implements Exception {
  /// Default constructor for [SessionInitializationException].
  const SessionInitializationException(this.code);

  /// The error code for the exception.
  final SessionInitializationError code;
}

/// Exception thrown by [GoogleMapsNavigator.resetTermsAccepted],
/// when attempting to reset the terms and conditions after the session has
/// already been initialized.
class ResetTermsAndConditionsException implements Exception {
  /// Default constructor for [ResetTermsAndConditionsException].
  const ResetTermsAndConditionsException();
}

/// [GoogleMapsNavigator] navigation method call has failed, because the navigation
/// session hasn't yet been successfully initialized.
class SessionNotInitializedException implements Exception {
  /// Default constructor for [SessionNotInitializedException].
  const SessionNotInitializedException();
}
