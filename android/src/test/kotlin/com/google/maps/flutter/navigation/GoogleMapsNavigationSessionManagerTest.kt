/*
 * Copyright 2026 Google LLC
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

import android.app.Application
import com.google.android.libraries.navigation.CustomRoutesOptions
import com.google.android.libraries.navigation.DisplayOptions
import com.google.android.libraries.navigation.Navigator
import com.google.android.libraries.navigation.RouteDescription
import com.google.android.libraries.navigation.RouteDescriptionLoadCallback
import com.google.android.libraries.navigation.RoutingOptions
import com.google.android.libraries.navigation.SimulationOptions
import com.google.android.libraries.navigation.Simulator
import com.google.android.libraries.navigation.Waypoint
import io.mockk.Runs
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.just
import io.mockk.slot
import io.mockk.verify
import kotlin.test.assertEquals
import kotlin.test.assertSame
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
internal class GoogleMapsNavigationSessionManagerTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK lateinit var navigator: Navigator
  @MockK lateinit var simulator: Simulator
  @MockK lateinit var application: Application
  @MockK lateinit var imageRegistry: ImageRegistry
  @MockK lateinit var eventApi: NavigationSessionEventApi
  @MockK lateinit var waypoint: Waypoint

  private lateinit var sessionManager: GoogleMapsNavigationSessionManager

  @Before
  fun setUp() {
    GoogleMapsNavigatorHolder.setNavigator(navigator)
    sessionManager = GoogleMapsNavigationSessionManager(eventApi, application, imageRegistry)
  }

  @After
  fun tearDown() {
    GoogleMapsNavigatorHolder.setNavigator(null)
  }

  @Test
  fun continueToNextDestination_reportsUninitializedSessionWithoutThrowing() {
    GoogleMapsNavigatorHolder.setNavigator(null)
    val handler = GoogleMapsNavigationSessionMessageHandler(sessionManager)
    val results = mutableListOf<Result<ContinueToNextDestinationResponseDto>>()

    handler.continueToNextDestination(results::add)

    assertEquals(1, results.size)
    assertEquals("sessionNotInitialized", (results.single().exceptionOrNull() as FlutterError).code)
  }

  @Test
  fun setDestinations_waitsForCallbackBeforeCompletingTimeoutResult() {
    val routeCallback = slot<RouteDescriptionLoadCallback>()
    every {
      navigator.setDestinations(
        any<List<Waypoint>>(),
        any<RoutingOptions>(),
        any<DisplayOptions>(),
        capture(routeCallback),
      )
    } just Runs
    every {
      navigator.setDestinations(
        any<List<Waypoint>>(),
        any<CustomRoutesOptions>(),
        any<DisplayOptions>(),
        capture(routeCallback),
      )
    } just Runs
    val handler = GoogleMapsNavigationSessionMessageHandler(sessionManager)

    for (routeTokenOptions in listOf(null, RouteTokenOptionsDto("dG9rZW4="))) {
      val destinations =
        DestinationsDto(
          waypoints = listOf(NavigationWaypointDto("Destination", LatLngDto(60.0, 25.0))),
          displayOptions = NavigationDisplayOptionsDto(),
          routeTokenOptions = routeTokenOptions,
        )
      val results = mutableListOf<Result<RouteStatusDto>>()
      handler.setDestinations(destinations, results::add)
      assertEquals(0, results.size)

      routeCallback.captured.onRouteDescription(
        RouteDescription(Navigator.RouteStatus.ROUTING_TIMEOUT)
      )

      assertEquals(1, results.size)
      assertEquals(RouteStatusDto.ROUTING_TIMEOUT, results.single().getOrThrow())
    }
  }

  @Test
  fun setDestinations_forwardsSynchronousErrors() {
    val error = IllegalStateException("Routing request failed")
    every {
      navigator.setDestinations(
        any<List<Waypoint>>(),
        any<RoutingOptions>(),
        any<DisplayOptions>(),
        any<RouteDescriptionLoadCallback>(),
      )
    } throws error
    every {
      navigator.setDestinations(
        any<List<Waypoint>>(),
        any<CustomRoutesOptions>(),
        any<DisplayOptions>(),
        any<RouteDescriptionLoadCallback>(),
      )
    } throws error

    for (routeTokenOptions in listOf(null, RouteTokenOptionsDto("dG9rZW4="))) {
      val results = mutableListOf<Result<Navigator.RouteStatus>>()
      sessionManager.setDestinations(
        listOf(waypoint),
        RoutingOptions(),
        DisplayOptions(),
        routeTokenOptions,
        results::add,
      )

      assertEquals(1, results.size)
      assertSame(error, results.single().exceptionOrNull())
    }
  }

  @Test
  fun setDestinations_preservesMalformedRouteTokenError() {
    val results = mutableListOf<Result<Navigator.RouteStatus>>()
    sessionManager.setDestinations(
      listOf(waypoint),
      RoutingOptions(),
      DisplayOptions(),
      RouteTokenOptionsDto("!"),
      results::add,
    )

    assertEquals(1, results.size)
    assertEquals("routeTokenMalformed", (results.single().exceptionOrNull() as FlutterError).code)
    verify(exactly = 0) {
      navigator.setDestinations(
        any<List<Waypoint>>(),
        any<CustomRoutesOptions>(),
        any<DisplayOptions>(),
        any<RouteDescriptionLoadCallback>(),
      )
    }
  }

  @Test
  fun simulationWrappers_forwardCallbackTimeout() {
    val waypoints = listOf(waypoint)
    val routingOptions = RoutingOptions()
    val simulationOptions = SimulationOptions()
    val routeCallback = slot<RouteDescriptionLoadCallback>()
    every { navigator.simulator } returns simulator
    every { simulator.simulateLocationsAlongNewRoute(waypoints, capture(routeCallback)) } just Runs
    every {
      simulator.simulateLocationsAlongNewRoute(waypoints, routingOptions, capture(routeCallback))
    } just Runs
    every {
      simulator.simulateLocationsAlongNewRoute(
        waypoints,
        routingOptions,
        simulationOptions,
        capture(routeCallback),
      )
    } just Runs

    val requests =
      listOf<((Result<Navigator.RouteStatus>) -> Unit) -> Unit>(
        { callback -> sessionManager.simulateLocationsAlongNewRoute(waypoints, callback) },
        { callback ->
          sessionManager.simulateLocationsAlongNewRouteWithRoutingOptions(
            waypoints,
            routingOptions,
            callback,
          )
        },
        { callback ->
          sessionManager.simulateLocationsAlongNewRouteWithRoutingAndSimulationOptions(
            waypoints,
            routingOptions,
            simulationOptions,
            callback,
          )
        },
      )
    for (request in requests) {
      val results = mutableListOf<Result<Navigator.RouteStatus>>()
      request(results::add)
      assertEquals(0, results.size)

      routeCallback.captured.onRouteDescription(
        RouteDescription(Navigator.RouteStatus.ROUTING_TIMEOUT)
      )

      assertEquals(1, results.size)
      assertEquals(Navigator.RouteStatus.ROUTING_TIMEOUT, results.single().getOrThrow())
    }
  }
}
