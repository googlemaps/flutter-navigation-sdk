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

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../widgets/widgets.dart';

class NavigationWithoutMapPage extends ExamplePage {
  const NavigationWithoutMapPage({super.key})
    : super(
        leading: const Icon(Icons.navigation),
        title: 'Navigation without map',
      );

  @override
  ExamplePageState<NavigationWithoutMapPage> createState() =>
      _NavigationWithoutMapPageState();
}

class _NavigationWithoutMapPageState
    extends ExamplePageState<NavigationWithoutMapPage> {
  bool? termsAccepted;
  bool sessionInitialized = false;
  bool routeCalculated = false;
  bool guidanceRunning = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await checkTermsAcceptance();
  }

  Future<void> checkTermsAcceptance() async {
    final bool accepted = await GoogleMapsNavigator.areTermsAccepted();
    setState(() {
      termsAccepted = accepted;
    });
  }

  Future<bool> resetTermsAccepted() async {
    try {
      await GoogleMapsNavigator.resetTermsAccepted();
      return true;
    } on ResetTermsAndConditionsException {
      _showMessage(
        'Cannot reset the terms after the navigation session has already been initialized.',
      );
      return false;
    }
  }

  Future<void> showTermsAndConditionsDialog(
    String title,
    String companyName, {
    bool shouldOnlyShowDriverAwarenessDisclaimer = false,
  }) async {
    final bool accepted =
        await GoogleMapsNavigator.showTermsAndConditionsDialog(
          title,
          companyName,
          shouldOnlyShowDriverAwarenessDisclaimer:
              shouldOnlyShowDriverAwarenessDisclaimer,
          uiParams: const TermsAndConditionsUIParams(
            backgroundColor: Color(0xFFECEFF1),
            titleColor: Color(0xFF01579B),
            mainTextColor: Color(0xFF263238),
            acceptButtonTextColor: Color(0xFF00695C),
            cancelButtonTextColor: Color(0xFFD32F2F),
          ),
        );
    _showMessage(accepted ? 'Terms accepted' : 'Terms not accepted');
    setState(() {
      termsAccepted = accepted;
    });
  }

  Future<void> initializeNavigationSession() async {
    try {
      await GoogleMapsNavigator.initializeNavigationSession();
      setState(() {
        sessionInitialized = true;
      });
    } on SessionInitializationException catch (e) {
      switch (e.code) {
        case SessionInitializationError.locationPermissionMissing:
          _showMessage(
            'No user location is available. Did you allow location permission?',
          );
        case SessionInitializationError.termsNotAccepted:
          _showMessage('Accept the terms and conditions dialog first.');
        case SessionInitializationError.notAuthorized:
          _showMessage(
            'Your API key is empty, invalid or not authorized to use Navigation.',
          );
      }
    }
  }

  Future<void> cleanupNavigationSession() async {
    await GoogleMapsNavigator.cleanup();
    setState(() {
      routeCalculated = false;
      guidanceRunning = false;
      if (Platform.isIOS) {
        sessionInitialized = false;
      }
    });
  }

  Future<void> setDestinations() async {
    setState(() {
      routeCalculated = false;
    });
    final Destinations msg = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(latitude: 37.791957, longitude: -122.412529),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );
    try {
      final NavigationRouteStatus navRouteStatus =
          await GoogleMapsNavigator.setDestinations(msg);
      switch (navRouteStatus) {
        case NavigationRouteStatus.statusOk:
          setState(() {
            routeCalculated = true;
          });
        case NavigationRouteStatus.internalError:
          _showMessage(
            'Unexpected internal error occured. Please restart the app.',
          );
        case NavigationRouteStatus.routeNotFound:
          _showMessage('The route could not be calculated.');
        case NavigationRouteStatus.networkError:
          _showMessage(
            'Working network connection is required to calculate the route.',
          );
        case NavigationRouteStatus.quotaExceeded:
          _showMessage('Insufficient API quota to use the navigation.');
        case NavigationRouteStatus.quotaCheckFailed:
          _showMessage(
            'API quota check failed, cannot authorize the navigation.',
          );
        case NavigationRouteStatus.apiKeyNotAuthorized:
          _showMessage('A valid API key is required to use the navigation.');
        case NavigationRouteStatus.statusCanceled:
          _showMessage(
            'The route calculation was canceled in favor of a newer one.',
          );
        case NavigationRouteStatus.duplicateWaypointsError:
          _showMessage(
            'The route could not be calculated because of duplicate waypoints.',
          );
        case NavigationRouteStatus.noWaypointsError:
          _showMessage(
            'The route could not be calculated because no waypoints were provided.',
          );
        case NavigationRouteStatus.locationUnavailable:
          _showMessage(
            'No user location is available. Did you allow location permission?',
          );
        case NavigationRouteStatus.waypointError:
          _showMessage('Invalid waypoints provided.');
        case NavigationRouteStatus.travelModeUnsupported:
          _showMessage(
            'The route could not calculated for the given travel mode.',
          );
        case NavigationRouteStatus.unknown:
          _showMessage(
            'The route could not be calculated due to an unknown error.',
          );
        case NavigationRouteStatus.locationUnknown:
          _showMessage(
            'The route could not be calculated, because the user location is unknown.',
          );
      }
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot set the destination before the navigation session has been initialized.',
      );
    }
  }

  Future<void> clearDestinations() async {
    try {
      await GoogleMapsNavigator.clearDestinations();
      setState(() {
        routeCalculated = false;
      });
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot clear the destinations before the navigation session has been initialized.',
      );
    }
  }

  Future<void> startGuidance() async {
    try {
      await GoogleMapsNavigator.startGuidance();
      if (await GoogleMapsNavigator.isGuidanceRunning()) {
        setState(() {
          guidanceRunning = true;
        });
      }
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot start the guidance before the navigation session has been initialized.',
      );
    }
  }

  Future<void> stopGuidance() async {
    try {
      await GoogleMapsNavigator.stopGuidance();
      if (!await GoogleMapsNavigator.isGuidanceRunning()) {
        setState(() {
          guidanceRunning = false;
        });
      }
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot stop the guidance before the navigation session has been initialized.',
      );
    }
  }

  Future<void> simulateUserLocation() async {
    try {
      await GoogleMapsNavigator.simulator.setUserLocation(
        const LatLng(latitude: 37.528560, longitude: -122.361996),
      );
      _showMessage('User location simulated.');
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot set the user location before the navigation session has been initialized.',
      );
    }
  }

  Future<void> simulateLocationsAlongExistingRoute() async {
    try {
      await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
      _showMessage('Simulating user location along existing route.');
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot start the simulation before the navigation session has been initialized.',
      );
    }
  }

  Future<void> pauseSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.pauseSimulation();
      _showMessage('Simulation paused.');
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot pause the simulation before the navigation session has been initialized.',
      );
    }
  }

  Future<void> resumeSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.resumeSimulation();
      _showMessage('Simulation resumed.');
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot resume the simulation before the navigation session has been initialized.',
      );
    }
  }

  Future<void> stopSimulation() async {
    try {
      await GoogleMapsNavigator.simulator.removeUserLocation();
      _showMessage('The simulation stopped.');
    } on SessionNotInitializedException {
      _showMessage(
        'Cannot stop the user location simulation before the navigation session has been initialized.',
      );
    }
  }

  void _showMessage(String message) {
    _hideMessage();

    final SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 2000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _hideMessage() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return buildPage(
      context,
      (BuildContext context) => SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                termsAccepted == null
                    ? ' '
                    : termsAccepted! == true
                    ? 'Terms accepted'
                    : 'Terms not accepted',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed:
                  termsAccepted == null || !termsAccepted!
                      ? null
                      : () async {
                        if (await resetTermsAccepted()) {
                          setState(() {
                            termsAccepted = false;
                          });
                        }
                      },
              child: const Text('Reset TOS'),
            ),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed:
                      termsAccepted != null && termsAccepted!
                          ? null
                          : () => showTermsAndConditionsDialog(
                            'Test title',
                            'Test company',
                          ),
                  child: const Text('Show TOS'),
                ),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed:
                        termsAccepted != null && termsAccepted!
                            ? null
                            : () => showTermsAndConditionsDialog(
                              'Test title',
                              'Test company',
                              shouldOnlyShowDriverAwarenessDisclaimer: true,
                            ),
                    child: const Text('Show noTOS'),
                  ),
              ],
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                '${sessionInitialized ? 'Session initialized' : 'No session'} • ${routeCalculated ? 'Route calculated' : 'No route'}',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => initializeNavigationSession(),
                  child: const Text('Initialize session'),
                ),
                ElevatedButton(
                  onPressed: () => cleanupNavigationSession(),
                  child: const Text('Clean up session'),
                ),
                ElevatedButton(
                  onPressed: () => setDestinations(),
                  child: const Text('Set destination'),
                ),
                ElevatedButton(
                  onPressed: () => clearDestinations(),
                  child: const Text('Clear destinations'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                guidanceRunning ? 'Guidance running' : 'Guidance stopped',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => startGuidance(),
                  child: const Text('Start guidance'),
                ),
                ElevatedButton(
                  onPressed: () => stopGuidance(),
                  child: const Text('Stop guidance'),
                ),
                ElevatedButton(
                  onPressed: () => simulateUserLocation(),
                  child: const Text('Simulate location'),
                ),
                ElevatedButton(
                  onPressed: () => simulateLocationsAlongExistingRoute(),
                  child: const Text('Simulate route'),
                ),
                ElevatedButton(
                  onPressed: () => pauseSimulation(),
                  child: const Text('Pause simulation'),
                ),
                ElevatedButton(
                  onPressed: () => resumeSimulation(),
                  child: const Text('Resume simulation'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => stopSimulation(),
              child: const Text('Stop simulation'),
            ),
          ],
        ),
      ),
    );
  }
}
