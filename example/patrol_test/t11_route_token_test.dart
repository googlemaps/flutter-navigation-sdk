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

import 'package:google_navigation_flutter_example/routes_api/routes_api.dart';

import 'shared.dart';

void main() {
  /// Destination near the shared start location in Finland (Näkkäläntie).
  const double endLat = 68.59451829688189, endLng = 23.512277951523007;
  const double tolerance = 0.001;

  // The token is fetched from the Routes API with the same MAPS_API_KEY the
  // app uses, so the key must have the Routes API enabled. A failed fetch
  // fails the test instead of skipping it, so a broken token path cannot pass.
  patrol('Test navigating to a destination with a route token', (
    PatrolIntegrationTester $,
  ) async {
    final Completer<void> hasArrived = Completer<void>();

    final GoogleNavigationViewController viewController =
        await startNavigationWithoutDestination($);

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

    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(
          Destinations(
            waypoints: <NavigationWaypoint>[destination],
            displayOptions: NavigationDisplayOptions(
              showDestinationMarkers: false,
            ),
            routeTokenOptions: RouteTokenOptions(
              routeToken: routeTokens.first,
              travelMode: NavigationTravelMode.driving,
            ),
          ),
        );
    expect(status, NavigationRouteStatus.statusOk);

    final List<RouteSegment> segments =
        await GoogleMapsNavigator.getRouteSegments();
    expect(segments, isNotEmpty);
    expect(
      segments.last.destinationLatLng.latitude,
      closeTo(endLat, tolerance),
    );
    expect(
      segments.last.destinationLatLng.longitude,
      closeTo(endLng, tolerance),
    );

    final StreamSubscription<OnArrivalEvent> onArrivalSubscription =
        GoogleMapsNavigator.setOnArrivalListener((OnArrivalEvent event) {
          if (!hasArrived.isCompleted) {
            hasArrived.complete();
          }
        });

    await GoogleMapsNavigator.startGuidance();
    await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();

    await hasArrived.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw TimeoutException(
        'Did not arrive at the route token destination',
      ),
    );

    await onArrivalSubscription.cancel();
    await GoogleMapsNavigator.cleanup();
  });
}
