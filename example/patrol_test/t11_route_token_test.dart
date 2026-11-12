// Copyright 2026 Google LLC
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
import 'dart:io';

import 'package:google_navigation_flutter_example/routes_api/routes_api.dart';

import 'shared.dart';

void main() {
  /// Destination near the shared start location in Finland (Näkkäläntie).
  const double endLat = 68.59451829688189, endLng = 23.512277951523007;
  const double tolerance = 0.001;

  patrol('Route-token session errors precede explicit mode validation', (
    PatrolIntegrationTester $,
  ) async {
    await startNavigationWithoutDestination($, initializeNavigation: false);
    expect(await GoogleMapsNavigator.isInitialized(), false);

    // This needs no Routes API request: session errors must win even when
    // both the explicit client mode and token are invalid.
    await expectLater(
      GoogleMapsNavigator.setDestinationsWithToken(
        DestinationsWithToken(
          routeToken: 'invalid-route-token',
          travelMode: NavigationTravelMode.walking,
        ),
      ),
      throwsA(isA<SessionNotInitializedException>()),
    );
    expect(await GoogleMapsNavigator.isInitialized(), false);
  });

  // Tokens are fetched with the app's runtime MAPS_API_KEY, which must have
  // the Routes API enabled. Failed fetches fail the test rather than skip it.
  patrol('Route-token modes preserve rejected routes and support guidance', (
    PatrolIntegrationTester $,
  ) async {
    final Completer<void> hasArrived = Completer<void>();

    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);
    addTearDown(GoogleMapsNavigator.cleanup);

    await setSimulatedUserLocationWithCheck(
      $,
      viewController,
      startLocationLat,
      startLocationLng,
      tolerance,
    );

    final NavigationWaypoint destination = NavigationWaypoint.withLatLngTarget(
      title: 'Näkkäläntie',
      target: const LatLng(latitude: endLat, longitude: endLng),
    );
    final NavigationWaypoint priorDestination =
        NavigationWaypoint.withLatLngTarget(
          title: 'Prior destination',
          target: const LatLng(
            latitude: 68.60338455021943,
            longitude: 23.548804200724454,
          ),
        );

    Future<String> fetchRouteToken() async {
      final List<String> routeTokens = await getRouteToken(<NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Origin',
          target: const LatLng(
            latitude: startLocationLat,
            longitude: startLocationLng,
          ),
        ),
        destination,
      ]);
      expect(routeTokens, isNotEmpty);
      return routeTokens.first;
    }

    Future<List<LatLng>> routeEndpoints() async {
      final List<RouteSegment> segments =
          await GoogleMapsNavigator.getRouteSegments();
      expect(segments, isNotEmpty);
      return segments
          .map((RouteSegment segment) => segment.destinationLatLng)
          .toList();
    }

    Future<void> expectTokenDestination() async {
      final List<LatLng> endpoints = await routeEndpoints();
      expect(endpoints.last.latitude, closeTo(endLat, tolerance));
      expect(endpoints.last.longitude, closeTo(endLng, tolerance));
    }

    Future<List<LatLng>> setPriorRoute(NavigationTravelMode mode) async {
      final NavigationRouteStatus status =
          await GoogleMapsNavigator.setDestinations(
            Destinations(
              waypoints: <NavigationWaypoint>[priorDestination],
              routingOptions: RoutingOptions(travelMode: mode),
              displayOptions: NavigationDisplayOptions(
                showDestinationMarkers: false,
              ),
            ),
          );
      expect(status, NavigationRouteStatus.statusOk);
      return routeEndpoints();
    }

    // Start in a supported mode so ignoring an explicit unsupported mode
    // cannot accidentally pass through iOS's inherited-mode validation.
    final List<LatLng> baselineEndpoints = await setPriorRoute(
      NavigationTravelMode.driving,
    );
    for (final NavigationTravelMode unsupportedMode in <NavigationTravelMode>[
      NavigationTravelMode.walking,
      NavigationTravelMode.cycling,
      NavigationTravelMode.taxi,
    ]) {
      final NavigationRouteStatus status =
          await GoogleMapsNavigator.setDestinationsWithToken(
            DestinationsWithToken(
              routeToken: 'invalid-route-token',
              travelMode: unsupportedMode,
              displayOptions: NavigationDisplayOptions(
                showDestinationMarkers: true,
              ),
            ),
          );
      expect(status, NavigationRouteStatus.travelModeUnsupported);
      expect(await routeEndpoints(), orderedEquals(baselineEndpoints));
    }

    // Keep the previous route distinct from the token's destination so
    // rejected requests cannot silently replace it.
    for (final NavigationTravelMode priorMode in <NavigationTravelMode>[
      NavigationTravelMode.walking,
      NavigationTravelMode.cycling,
    ]) {
      final List<LatLng> priorEndpoints = await setPriorRoute(priorMode);

      final NavigationRouteStatus inheritedModeStatus =
          await GoogleMapsNavigator.setDestinationsWithToken(
            DestinationsWithToken(routeToken: await fetchRouteToken()),
          );
      if (Platform.isIOS) {
        expect(
          inheritedModeStatus,
          NavigationRouteStatus.travelModeUnsupported,
        );
        expect(await routeEndpoints(), orderedEquals(priorEndpoints));
      } else {
        expect(inheritedModeStatus, NavigationRouteStatus.statusOk);
        await expectTokenDestination();
      }

      final NavigationRouteStatus drivingStatus =
          await GoogleMapsNavigator.setDestinationsWithToken(
            DestinationsWithToken(
              routeToken: await fetchRouteToken(),
              travelMode: NavigationTravelMode.driving,
              displayOptions: NavigationDisplayOptions(
                showDestinationMarkers: false,
              ),
            ),
          );
      expect(drivingStatus, NavigationRouteStatus.statusOk);
      await expectTokenDestination();
    }

    // Either supported client mode can use a DRIVE token, even where
    // two-wheeler route generation is unavailable (such as Finland).
    // Omitting displayOptions also exercises the default visible markers.
    final NavigationRouteStatus twoWheelerStatus =
        await GoogleMapsNavigator.setDestinationsWithToken(
          DestinationsWithToken(
            routeToken: await fetchRouteToken(),
            travelMode: NavigationTravelMode.twoWheeler,
          ),
        );
    expect(twoWheelerStatus, NavigationRouteStatus.statusOk);
    await expectTokenDestination();

    final StreamSubscription<OnArrivalEvent> onArrivalSubscription =
        GoogleMapsNavigator.setOnArrivalListener((OnArrivalEvent event) {
          if (!hasArrived.isCompleted) {
            hasArrived.complete();
          }
        });
    addTearDown(onArrivalSubscription.cancel);

    await GoogleMapsNavigator.startGuidance();
    expect(await GoogleMapsNavigator.isGuidanceRunning(), true);
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    await hasArrived.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw TimeoutException(
        'Did not arrive at the route token destination',
      ),
    );
  });
}
