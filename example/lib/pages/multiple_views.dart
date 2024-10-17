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

// ignore_for_file: public_member_api_docs, unused_field, use_setters_to_change_properties

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../widgets/widgets.dart';
import '../utils/utils.dart';
import 'navigation.dart';

class MultipleMapViewsPage extends ExamplePage {
  const MultipleMapViewsPage({super.key})
      : super(leading: const Icon(Icons.view_stream), title: 'Multiple maps');

  @override
  ExamplePageState<MultipleMapViewsPage> createState() => _MultiplexState();
}

class _MultiplexState extends ExamplePageState<MultipleMapViewsPage> {
  final CameraPosition cameraPositionOxford = const CameraPosition(
    target: LatLng(latitude: 51.7550635, longitude: -1.2552031),
    zoom: 17,
  );
  final CameraPosition cameraPositionMIT = const CameraPosition(
    target: LatLng(latitude: 42.3601, longitude: -71.094013),
    zoom: 17,
  );

  // Counter to keep track of the number of camera moves to alternate between the two cameras.
  int _cameraMoveCounter = 0;

  bool _termsAndConditionsAccepted = false;
  bool _locationPermissionsAccepted = false;
  bool _navigatorInitialized = false;
  bool _guidanceRunning = false;
  bool _validRoute = false;

  final List<NavigationWaypoint> _waypoints = <NavigationWaypoint>[];
  int _nextWaypointIndex = 0;

  SimulationState _simulationState = SimulationState.notRunning;

  /// Camera location used to initialize the map view on simulator if location
  /// is not available by the given timeout [_userLocationTimeoutMS].
  static const LatLng cameraLocationMIT =
      LatLng(latitude: 42.3601, longitude: -71.094013);
  static const int _userLocationTimeoutMS = 1500;

  /// Latest user location received from the navigator.
  LatLng? _userLocation;

  /// Used to track if navigator has been initialized at least once.
  /// In this example app navigator can be cleaned up and re-initialized.
  /// This variable is used to make sure that navigator is initialized before
  /// showing the navigation view.
  bool _navigatorInitializedAtLeastOnce = false;

  GoogleMapViewController? _mapController;
  GoogleNavigationViewController? _navigationController;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  @override
  void dispose() {
    GoogleMapsNavigator.cleanup();
    clearRegisteredImages();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Check if terms and conditions have been accepted and show dialog if not.
    await _showTermsAndConditionsDialogIfNeeded();

    // Check if location permissions have been accepted and show dialog if not.
    await _askLocationPermissionsIfNeeded();

    // Initilize navigator if terms and conditions and location permissions
    // have been accepted.
    if (_termsAndConditionsAccepted && _locationPermissionsAccepted) {
      await _initializeNavigator();
    }
  }

  Future<void> _initializeNavigator() async {
    assert(_termsAndConditionsAccepted, 'Terms must be accepted');
    assert(
        _locationPermissionsAccepted, 'Location permissions must be granted');

    if (!_navigatorInitialized) {
      debugPrint('Initializing new navigation session...');
      await GoogleMapsNavigator.initializeNavigationSession();
      //await _setupListeners();
      await _updateNavigatorInitializationState();
      await _restorePossibleNavigatorState();
      unawaited(_setDefaultUserLocationAfterDelay());
      debugPrint('Navigator has been initialized: $_navigatorInitialized');
    }
    setState(() {});
  }

  /// iOS emulator does not update location and does not fire roadsnapping
  /// events. Initialize user location to [cameraLocationMIT] if user
  /// location is not available after timeout.
  Future<void> _setDefaultUserLocationAfterDelay() async {
    Future<void>.delayed(const Duration(milliseconds: _userLocationTimeoutMS),
        () async {
      if (mounted && _userLocation == null) {
        _userLocation =
            await _navigationController?.getMyLocation() ?? cameraLocationMIT;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  // Navigator state is not persisted between app restarts, so we need to check
  // if there is a valid route and guidance running, and restore the state.
  Future<void> _restorePossibleNavigatorState() async {
    if (_navigatorInitialized) {
      final List<NavigationWaypoint> waypoints = await _getWaypoints();

      // Restore local waypoint index
      if (waypoints.isNotEmpty) {
        final List<String> parts = waypoints.last.title.split(' ');
        if (parts.length == 2) {
          _nextWaypointIndex = int.tryParse(parts.last) ?? 0;
        }

        _validRoute = true;
        _waypoints.clear();
        _waypoints.addAll(waypoints);
      }

      _guidanceRunning = await GoogleMapsNavigator.isGuidanceRunning();
      if (_guidanceRunning) {
        // Guidance is running, but there is currently no way to check if
        // simulation is running as well, so we set it's state as unknown.
        _simulationState = SimulationState.unknown;
      }

      setState(() {});
    }
  }

  // Helper function to update local waypoint data from the navigation session.
  Future<List<NavigationWaypoint>> _getWaypoints() async {
    assert(_navigatorInitialized);
    final List<RouteSegment> routeSegments =
        await GoogleMapsNavigator.getRouteSegments();
    return routeSegments
        .where((RouteSegment e) => e.destinationWaypoint != null)
        .map((RouteSegment e) => e.destinationWaypoint!)
        .toList();
  }

  Future<void> _updateNavigatorInitializationState() async {
    _navigatorInitialized = await GoogleMapsNavigator.isInitialized();
    if (_navigatorInitialized) {
      _navigatorInitializedAtLeastOnce = true;
    }
    setState(() {});
  }

  Future<void> _showTermsAndConditionsDialogIfNeeded() async {
    _termsAndConditionsAccepted = await requestTermsAndConditionsAcceptance();
    setState(() {});
  }

  Future<void> _askLocationPermissionsIfNeeded() async {
    _locationPermissionsAccepted = await requestLocationDialogAcceptance();
    setState(() {});
  }

  void _onViewCreated(GoogleMapViewController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _onViewCreated2(
      GoogleNavigationViewController controller) async {
    setState(() {
      _navigationController = controller;
    });
    await controller.setMyLocationEnabled(true);
  }

  Future<void> _moveCameras() async {
    await _mapController!.moveCamera(CameraUpdate.newCameraPosition(
        _cameraMoveCounter.isEven ? cameraPositionOxford : cameraPositionMIT));
    await _navigationController!.moveCamera(CameraUpdate.newCameraPosition(
        _cameraMoveCounter.isOdd ? cameraPositionOxford : cameraPositionMIT));
    setState(() {
      _cameraMoveCounter += 1;
    });
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: GoogleMapsMapView(
                      onViewCreated: _onViewCreated,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _navigatorInitializedAtLeastOnce &&
                            _userLocation != null
                        ? GoogleMapsNavigationView(
                            onViewCreated: _onViewCreated2,
                            initialCameraPosition: CameraPosition(
                              // Initialize map to user location.
                              target: _userLocation!,
                              zoom: 15,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Waiting navigator and user location'),
                                SizedBox(height: 10),
                                SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator())
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (_mapController != null && _navigationController != null)
                    ElevatedButton(
                      onPressed: _moveCameras,
                      child: const Text('Move cameras'),
                    ),
                ]),
          ));
}
