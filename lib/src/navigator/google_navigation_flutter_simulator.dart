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

import '../../google_navigation_flutter.dart';
import '../google_navigation_flutter_platform_interface.dart';

/// Simulator handles actions of the navigation simulation
/// {@category Navigation}
class Simulator {
  /// Sets user location.
  Future<void> setUserLocation(LatLng location) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .setUserLocation(
      location,
    );
  }

  /// Stops simulation by unsetting user location simulation.
  Future<void> removeUserLocation() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .removeUserLocation();
  }

  /// Simulates locations along existing route.
  Future<void> simulateLocationsAlongExistingRoute() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .simulateLocationsAlongExistingRoute();
  }

  /// Simulates locations along existing route with simulation options.
  Future<void> simulateLocationsAlongExistingRouteWithOptions(
    SimulationOptions options,
  ) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .simulateLocationsAlongExistingRouteWithOptions(
      options,
    );
  }

  /// Simulates locations along new route.
  Future<NavigationRouteStatus> simulateLocationsAlongNewRoute(
    List<NavigationWaypoint> waypoints,
  ) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .simulateLocationsAlongNewRoute(
      waypoints,
    );
  }

  /// Simulates locations along new route with routing options.
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingOptions(
    List<NavigationWaypoint> waypoints,
    RoutingOptions routingOptions,
  ) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .simulateLocationsAlongNewRouteWithRoutingOptions(
      waypoints,
      routingOptions,
    );
  }

  /// Simulates locations along new route with routing and simulation options.
  Future<NavigationRouteStatus>
      simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
    List<NavigationWaypoint> waypoints,
    RoutingOptions routingOptions,
    SimulationOptions simulationOptions,
  ) {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
      waypoints,
      routingOptions,
      simulationOptions,
    );
  }

  /// Pauses simulation.
  Future<void> pauseSimulation() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .pauseSimulation();
  }

  /// Resumes simulation.
  Future<void> resumeSimulation() {
    return GoogleMapsNavigationPlatform.instance.navigationSessionAPI
        .resumeSimulation();
  }
}
