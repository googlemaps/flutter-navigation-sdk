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

import '../../google_navigation_flutter.dart';
import '../google_navigation_flutter_platform_interface.dart';

import 'google_navigation_flutter_simulator.dart';

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
  /// Checks if there are active listeners for either road-snapped location
  /// updates or raw location updates. If there are, this method re-enables the
  /// emission of road-snapped location updates. This is necessary because the
  /// native (Android/iOS) implementation clears the listeners during cleanup.
  ///
  /// Optional parameter [abnormalTerminationReportingEnabled] can be used enables/disables
  /// reporting abnormal SDK terminations such as the app crashes while the SDK is still running.
  ///
  static Future<void> initializeNavigationSession(
      {bool abnormalTerminationReportingEnabled = true,
      TaskRemovedBehavior taskRemovedBehavior =
          TaskRemovedBehavior.continueService}) async {
    await GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .createNavigationSession(
            abnormalTerminationReportingEnabled, taskRemovedBehavior);

    // Enable road-snapped location updates if there are subscriptions to them.
    if ((_roadSnappedLocationUpdatedController?.hasListener ?? false) ||
        (_roadSnappedRawLocationUpdatedController?.hasListener ?? false) ||
        (_gpsAvailabilityUpdatedController?.hasListener ?? false)) {
      await GoogleMapsNavigationPlatform.instance.navigationSessionAPI
          .enableRoadSnappedLocationUpdates();
    }
  }

  /// Check whether navigator has been initialized.
  ///
  /// Note: This does not detect if there is ongoing navigation session in the Android
  /// foreground service. To resume navigation after Android activity has been destroyed,
  /// navigation session must be re-initialized with [initializeNavigationSession].
  /// After initialization guidance state can be checked with [isGuidanceRunning].
  static Future<bool> isInitialized() async {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .isInitialized();
  }

  /// Sets the event channel listener for the [SpeedingUpdatedEvent]s.
  ///
  /// Returns a [StreamSubscription] for [SpeedingUpdatedEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setSpeedingUpdatedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<SpeedingUpdatedEvent> setSpeedingUpdatedListener(
    OnSpeedingUpdatedEventCallback listener,
  ) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationSpeedingEventStream()
        .listen(listener);
  }

  /// Sets the event channel listener for the [OnArrivalEvent]s.
  ///
  /// Returns a [StreamSubscription] for [OnArrivalEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setOnArrivalListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<OnArrivalEvent> setOnArrivalListener(
      OnArrivalEventCallback listener) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationOnArrivalEventStream()
        .listen(listener);
  }

  /// Sets the event channel listener for the rerouting events. (Android only)
  ///
  /// Returns a [StreamSubscription] for rerouting events.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setOnReroutingListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<void> setOnReroutingListener(
      OnReroutingEventCallback listener) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationOnReroutingEventStream()
        .listen((void event) {
      listener.call();
    });
  }

  /// Sets the event channel listener for the GPS availability events.
  /// (Android only).
  ///
  /// Setting this listener will also register road snapped location listener
  /// on native side.
  ///
  /// DISCLAIMER: This is an EXPERIMENTAL API and its behaviors may be subject
  /// to removal or breaking changes in future releases.
  ///
  /// Returns a [StreamSubscription] for GPS availability events.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setOnGpsAvailabilityListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static Future<StreamSubscription<GpsAvailabilityUpdatedEvent>>
      setOnGpsAvailabilityListener(
          OnGpsAvailabilityEventCallback listener) async {
    if (_gpsAvailabilityUpdatedController == null) {
      _gpsAvailabilityUpdatedController =
          StreamController<GpsAvailabilityUpdatedEvent>.broadcast(onCancel: () {
        _disableRoadSnappedLocationUpdatesIfNoActiveListeners();
      }, onListen: () {
        GoogleMapsNavigationPlatform.instance.navigationSessionAPI
            .enableRoadSnappedLocationUpdates();
      });
      unawaited(_gpsAvailabilityUpdatedController!.addStream(
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .getNavigationOnGpsAvailabilityUpdateEventStream()));
    }

    return _gpsAvailabilityUpdatedController!.stream.listen(listener);
  }

  static StreamController<GpsAvailabilityUpdatedEvent>?
      _gpsAvailabilityUpdatedController;

  /// Sets the event channel listener for the traffic updated events. (Android only)
  ///
  /// Returns a [StreamSubscription] for traffic updated events.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setTrafficUpdatedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<void> setTrafficUpdatedListener(
      OnTrafficUpdatedEventCallback listener) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationTrafficUpdatedEventStream()
        .listen((void event) {
      listener.call();
    });
  }

  /// Sets the event channel listener for the on route changed events.
  ///
  /// Returns a [StreamSubscription] for route changed events.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setOnRouteChangedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<void> setOnRouteChangedListener(
      OnRouteChangedEventCallback listener) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationOnRouteChangedEventStream()
        .listen((void event) {
      listener.call();
    });
  }

  /// Sets the event channel listener for [RemainingTimeOrDistanceChangedEvent]s.
  ///
  /// Returns a [StreamSubscription] for handling [RemainingTimeOrDistanceChangedEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setOnRemainingTimeOrDistanceChangedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<RemainingTimeOrDistanceChangedEvent>
      setOnRemainingTimeOrDistanceChangedListener(
    OnRemainingTimeOrDistanceChangedEventCallback listener, {
    int remainingTimeThresholdSeconds = 1,
    int remainingDistanceThresholdMeters = 1,
  }) {
    assert(remainingTimeThresholdSeconds >= 0);
    assert(remainingDistanceThresholdMeters >= 0);
    GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .registerRemainingTimeOrDistanceChangedListener(
            remainingTimeThresholdSeconds, remainingDistanceThresholdMeters);
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavigationRemainingTimeOrDistanceChangedEventStream()
        .listen(listener);
  }

  static StreamController<NavInfoEvent>? _navInfoEventStreamController;

  /// Sets the event channel listener for [NavInfoEvent]s.
  ///
  /// Returns a [StreamSubscription] for handling [NavInfoEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Optional parameter [numNextStepsToPreview] can be used to set the maximum
  /// number of next steps to preview. If set to null, all available steps will
  /// be returned in the [NavInfo.remainingSteps].
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setNavInfoListener(
  ///   yourEventHandler,
  ///   numNextStepsToPreview: 5,
  /// );
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static StreamSubscription<NavInfoEvent> setNavInfoListener(
      OnNavInfoEventCallback listener,
      {int? numNextStepsToPreview}) {
    assert(numNextStepsToPreview == null || numNextStepsToPreview >= 0,
        'numNextStepsToPreview must be a non-negative integer or null.');
    if (_navInfoEventStreamController == null) {
      _navInfoEventStreamController = StreamController<NavInfoEvent>.broadcast(
        onCancel: () {
          if (_navInfoEventStreamController?.hasListener ?? false) {
            GoogleMapsNavigationPlatform.instance.navigationSessionAPI
                .disableTurnByTurnNavigationEvents();
          }
        },
      );
      unawaited(_navInfoEventStreamController!.addStream(
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .getNavInfoStream()));
    }

    GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .enableTurnByTurnNavigationEvents(numNextStepsToPreview);

    return _navInfoEventStreamController!.stream.listen(listener);
  }

  static StreamController<RoadSnappedLocationUpdatedEvent>?
      _roadSnappedLocationUpdatedController;

  /// Sets the event channel listener for [RoadSnappedLocationUpdatedEvent]s.
  ///
  /// Returns a Future for [StreamSubscription] for handling
  /// [RoadSnappedLocationUpdatedEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setRoadSnappedLocationUpdatedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static Future<StreamSubscription<RoadSnappedLocationUpdatedEvent>>
      setRoadSnappedLocationUpdatedListener(
    OnRoadSnappedLocationUpdatedEventCallback listener,
  ) async {
    if (_roadSnappedLocationUpdatedController == null) {
      _roadSnappedLocationUpdatedController =
          StreamController<RoadSnappedLocationUpdatedEvent>.broadcast(
        onCancel: () {
          _disableRoadSnappedLocationUpdatesIfNoActiveListeners();
        },
        onListen: () {
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .enableRoadSnappedLocationUpdates();
        },
      );
      unawaited(_roadSnappedLocationUpdatedController!.addStream(
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .getNavigationRoadSnappedLocationEventStream()));
    }

    return _roadSnappedLocationUpdatedController!.stream.listen(listener);
  }

  static StreamController<RoadSnappedRawLocationUpdatedEvent>?
      _roadSnappedRawLocationUpdatedController;

  /// Sets the event channel listener for [RoadSnappedRawLocationUpdatedEvent]s
  /// (Android only).
  ///
  /// Returns a Future for [StreamSubscription] for handling
  /// [RoadSnappedRawLocationUpdatedEvent]s.
  /// This subscription must be canceled using `cancel()` when it is no longer
  /// needed to stop receiving events and allow the stream to perform necessary
  /// cleanup, such as releasing resources or shutting down event sources. The
  /// cleanup is asynchronous, and the `cancel()` method returns a Future that
  /// completes once the cleanup is done.
  ///
  /// Example usage:
  /// ```dart
  /// final subscription = setRoadSnappedRawLocationUpdatedListener(yourEventHandler);
  /// // When done with the subscription
  /// await subscription.cancel();
  /// ```
  static Future<StreamSubscription<RoadSnappedRawLocationUpdatedEvent>>
      setRoadSnappedRawLocationUpdatedListener(
    OnRoadSnappedRawLocationUpdatedEventCallback listener,
  ) async {
    if (_roadSnappedRawLocationUpdatedController == null) {
      _roadSnappedRawLocationUpdatedController =
          StreamController<RoadSnappedRawLocationUpdatedEvent>.broadcast(
        onCancel: () {
          _disableRoadSnappedLocationUpdatesIfNoActiveListeners();
        },
        onListen: () {
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .enableRoadSnappedLocationUpdates();
        },
      );
      unawaited(_roadSnappedRawLocationUpdatedController!.addStream(
          GoogleMapsNavigationPlatform.instance.navigationSessionAPI
              .getNavigationRoadSnappedRawLocationEventStream()));
    }

    return _roadSnappedRawLocationUpdatedController!.stream.listen(listener);
  }

  /// Disables road snapped location updates if there are no listeners.
  static void _disableRoadSnappedLocationUpdatesIfNoActiveListeners() {
    if (!(_roadSnappedLocationUpdatedController?.hasListener ?? false) &&
        !(_roadSnappedRawLocationUpdatedController?.hasListener ?? false) &&
        !(_gpsAvailabilityUpdatedController?.hasListener ?? false)) {
      GoogleMapsNavigationPlatform.instance.navigationSessionAPI
          .disableRoadSnappedLocationUpdates();
    }
  }

  /// Cleans up the navigation session.
  ///
  /// Cleans up the navigator's internal state, clearing
  /// listeners, any existing route waypoints and stopping ongoing
  /// navigation guidance and simulation.
  ///
  /// On iOS the session is fully deleted and needs to be recreated
  /// by calling [GoogleMapsNavigator.initializeNavigationSession].
  ///
  /// On Android the session is cleaned up, but never destroyed after the
  /// first initialization.
  static Future<void> cleanup() async {
    await GoogleMapsNavigationPlatform.instance.navigationSessionAPI.cleanup();
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
  static Future<bool> showTermsAndConditionsDialog(
      String title, String companyName,
      {bool shouldOnlyShowDriverAwarenessDisclaimer = false}) async {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .showTermsAndConditionsDialog(
            title, companyName, shouldOnlyShowDriverAwarenessDisclaimer);
  }

  /// Checks if terms and conditions have already been accepted by the user.
  static Future<bool> areTermsAccepted() async {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .areTermsAccepted();
  }

  /// Resets the terms of service acceptance state.
  ///
  /// If the navigation session has already been initialized
  /// throws [ResetTermsAndConditionsException].
  static Future<void> resetTermsAccepted() async {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .resetTermsAccepted();
  }

  /// Gets the native navigation SDK version as string.
  static Future<String> getNavSDKVersion() async {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getNavSDKVersion();
  }

  /// Starts the navigation guidance.
  static Future<void> startGuidance() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .startGuidance();
  }

  /// Stops the navigation guidance.
  static Future<void> stopGuidance() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .stopGuidance();
  }

  /// Check if guidance is running.
  static Future<bool> isGuidanceRunning() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .isGuidanceRunning();
  }

  /// Sets one or multiple destinations for navigation.
  ///
  /// Destinations are passed as [NavigationWaypoint] waypoints and options with
  /// [destinations] parameter. Routing can be controlled by defining
  /// [RoutingOptions], or using route tokens passed with [RouteTokenOptions].
  /// [NavigationDisplayOptions] will be used to display the route.
  ///
  /// If the options are omitted, the default routing and display options will
  /// be used.
  static Future<NavigationRouteStatus> setDestinations(
      Destinations destinations) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .setDestinations(destinations);
  }

  /// Clears existing destinations.
  static Future<void> clearDestinations() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .clearDestinations();
  }

  /// Continues to the next waypoint.
  ///
  /// Removes the current waypoint.
  /// Following this call, guidance will be toward the next destination,
  /// and information about the old destination is not available.
  static Future<NavigationWaypoint?> continueToNextDestination() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .continueToNextDestination();
  }

  /// Returns how much current time and distance are left.
  static Future<NavigationTimeAndDistance> getCurrentTimeAndDistance() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getCurrentTimeAndDistance();
  }

  /// Sets the audio guidance settings.
  static Future<void> setAudioGuidance(
      NavigationAudioGuidanceSettings settings) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .setAudioGuidance(settings);
  }

  /// Sets state of allow background location updates. (iOS only)
  ///
  /// Throws [UnsupportedError] on Android.
  static Future<void> allowBackgroundLocationUpdates(bool allow) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .allowBackgroundLocationUpdates(
      allow,
    );
  }

  /// Get route segments.
  static Future<List<RouteSegment>> getRouteSegments() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getRouteSegments();
  }

  /// Get traveled route.
  static Future<List<LatLng>> getTraveledRoute() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getTraveledRoute();
  }

  /// Get current route segment.
  static Future<RouteSegment?> getCurrentRouteSegment() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .getCurrentRouteSegment();
  }

  static Future<void> enableTurnByTurnNavigationEvents(
      int? numNextStepsToPreview) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .enableTurnByTurnNavigationEvents(numNextStepsToPreview);
  }

  static Future<void> disableTurnByTurnNavigationEvents() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .disableTurnByTurnNavigationEvents();
  }
}

/// Possible errors that [GoogleMapsNavigator.initializeNavigationSession] can throw.
/// {@category Navigation}
enum SessionInitializationError {
  /// The session initialization failed, because the required Maps API key is empty or invalid.
  notAuthorized,

  /// The session initialization failed, because the required location permission has not been granted.
  locationPermissionMissing,

  /// The session initialization failed, because the user has not yet accepted the navigation terms and conditions.
  termsNotAccepted
}

/// Exception thrown by [GoogleMapsNavigator.initializeNavigationSession].
/// {@category Navigation}
class SessionInitializationException implements Exception {
  /// Default constructor for [SessionInitializationException].
  const SessionInitializationException(this.code);

  /// The error code for the exception.
  final SessionInitializationError code;
}

/// Exception thrown by [GoogleMapsNavigator.resetTermsAccepted],
/// when attempting to reset the terms and conditions after the session has
/// already been initialized.
/// {@category Navigation}
class ResetTermsAndConditionsException implements Exception {
  /// Default constructor for [ResetTermsAndConditionsException].
  const ResetTermsAndConditionsException();
}

/// [GoogleMapsNavigator] navigation method call has failed, because the navigation
/// session hasn't yet been successfully initialized.
/// {@category Navigation}
class SessionNotInitializedException implements Exception {
  /// Default constructor for [SessionNotInitializedException].
  const SessionNotInitializedException();
}

/// [GoogleMapsNavigator.setDestinations] method call has failed, because the
/// [RouteTokenOptions.routeToken] is malformed. (Android only)
class RouteTokenMalformedException implements Exception {
  /// Default constructor for [RouteTokenMalformedException].
  const RouteTokenMalformedException();
}
