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
import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class TurnByTurnPage extends ExamplePage {
  const TurnByTurnPage({super.key})
      : super(
            leading: const Icon(Icons.roundabout_right), title: 'Turn-by-turn');

  @override
  ExamplePageState<TurnByTurnPage> createState() => _TurnByTurnPageState();
}

class _TurnByTurnPageState extends ExamplePageState<TurnByTurnPage> {
  bool _navigationRunning = false;
  late final GoogleNavigationViewController _navigationViewController;
  StreamSubscription<NavInfoEvent>? _navInfoSubscription;

  NavInfo? _navInfo;

  // ignore: use_setters_to_change_properties
  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    setState(() {});
  }

  Future<void> _startNavigation() async {
    _showMessage('Starting navigation.');
    if (!await GoogleMapsNavigator.areTermsAccepted()) {
      await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'test_title',
        'test_company_name',
      );
    }

    await GoogleMapsNavigator.initializeNavigationSession();
    await _setupListeners();

    /// Simulate location.
    await GoogleMapsNavigator.simulator.setUserLocation(
        const LatLng(latitude: 37.528560, longitude: -122.361996));

    final Destinations msg = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(
            latitude: 37.791957,
            longitude: -122.412529,
          ),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(msg);

    if (status == NavigationRouteStatus.statusOk) {
      await GoogleMapsNavigator.startGuidance();
      await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
      await _navigationViewController
          .followMyLocation(CameraPerspective.tilted);

      _hideMessage();
      setState(() {
        _navigationRunning = true;
      });
    } else {
      _showMessage('Starting navigation failed.');
      setState(() {});
    }
  }

  Future<void> _setupListeners() async {
    // Clear old listeners to make sure we subscribe to each event only once.
    _clearListeners();

    // Initialize the Turn-by-turn nav info listener with max number of steps
    // to preview.
    _navInfoSubscription = GoogleMapsNavigator.setNavInfoListener(
      _onNavInfoEvent,
      numNextStepsToPreview: 100,
    );
  }

  void _clearListeners() {
    _navInfoSubscription?.cancel();
    _navInfoSubscription = null;
  }

  void _onNavInfoEvent(
    NavInfoEvent event,
  ) {
    if (!mounted) {
      return;
    }
    setState(() {
      _navInfo = event.navInfo;
    });
  }

  Future<void> _stopNavigation() async {
    _clearListeners();
    _navInfo = null;
    if (_navigationRunning) {
      await GoogleMapsNavigator.cleanup();

      setState(() {
        _navigationRunning = false;
      });
    }
  }

  @override
  void dispose() {
    _clearListeners();
    if (_navigationRunning) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: GoogleMapsNavigationView(
                    onViewCreated: _onViewCreated,
                    initialNavigationUIEnabledPreference:
                        NavigationUIEnabledPreference.disabled,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: <Widget>[
                      ElevatedButton(
                          onPressed: _navigationRunning
                              ? () => _stopNavigation()
                              : () => _startNavigation(),
                          child: Text(_navigationRunning
                              ? 'Stop navigation'
                              : 'Start navigation')),
                      ElevatedButton(
                          onPressed: _navigationRunning
                              ? () async {
                                  await _navigationViewController
                                      .setNavigationHeaderEnabled(
                                          !(await _navigationViewController
                                              .isNavigationHeaderEnabled()));
                                  await _navigationViewController
                                      .setNavigationFooterEnabled(
                                          !(await _navigationViewController
                                              .isNavigationFooterEnabled()));
                                }
                              : null,
                          child: const Text('Toggle header/footer')),
                    ]),
                if (_navInfo != null) _getNavInfoWidgets(context, _navInfo!),
                if (_navInfo != null)
                  ElevatedButton(
                    onPressed: () => _showSteps(context, _navInfo!),
                    child: const Text('Show all remaining steps'),
                  ),
              ],
            ),
          ));

  void _showMessage(String message) {
    _hideMessage();
    if (isOverlayVisible) {
      showOverlaySnackBar(message);
    } else {
      final SnackBar snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _hideMessage() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  /// Builds a widget that displays information about the current navigation.
  ///
  /// Note: This method does not display all available navigation information.
  /// Look at the [NavInfo] documentation for more information.
  Widget _getNavInfoWidgets(BuildContext context, NavInfo navInfo) {
    const TextStyle navInfoTextStyle =
        TextStyle(fontSize: 12, color: Colors.white);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: <Widget>[
        if (navInfo.navState == NavState.stopped)
          const Text('Navigation stopped.'),
        if (navInfo.currentStep != null) ...<Widget>[
          _getNavInfoWidgetForStep(context, navInfo.currentStep!,
              navInfo.distanceToCurrentStepMeters),
          const SizedBox(height: 5),
          Card(
            color: Colors.green.shade400,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        if (navInfo.timeToFinalDestinationSeconds != null &&
                            navInfo.distanceToFinalDestinationMeters != null)
                          Text(
                            '${formatRemainingDuration(Duration(seconds: navInfo.timeToFinalDestinationSeconds!))} and ${formatRemainingDistance(navInfo.distanceToFinalDestinationMeters!)} to final destination.',
                            style: navInfoTextStyle,
                          ),
                        const SizedBox(height: 5),
                        if (navInfo.timeToCurrentStepSeconds != null)
                          Text(
                            '${formatRemainingDuration(Duration(seconds: navInfo.timeToCurrentStepSeconds!))} to current step.',
                            style: navInfoTextStyle,
                          ),
                      ],
                    )
                  ]),
            ),
          )
        ]
      ]),
    );
  }

  /// Builds a card that displays information  about the given step.
  ///
  /// Note: This method does not display all available step information.
  /// Look at the [NavInfo] documentation for more information.
  Widget _getNavInfoWidgetForStep(
      BuildContext context, StepInfo stepInfo, int? metersToStep) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const TextStyle navInfoTextStyle =
        TextStyle(fontSize: 12, color: Colors.white);
    return Card(
      color: Colors.green.shade400,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(right: 10),
              width: screenWidth / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: navInfoTextStyle,
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Maneuver\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: stepInfo.maneuver.name),
                        if (metersToStep != null)
                          TextSpan(
                            text:
                                '\n\n${formatRemainingDistance(metersToStep)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Step #${stepInfo.stepNumber}',
                      style: navInfoTextStyle,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: navInfoTextStyle,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Road: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: stepInfo.fullRoadName),
                          const TextSpan(
                            text: '\nInstructions: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: stepInfo.fullInstructions),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSteps(BuildContext context, NavInfo navInfo) {
    Scaffold.of(context).showBottomSheet((BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text('Steps', style: TextStyle(fontSize: 20)),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
              ],
            ),
            SizedBox(
              height: 300,
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      if (navInfo.remainingSteps.isEmpty)
                        const Text('No remaining steps'),
                      for (final StepInfo step in navInfo.remainingSteps)
                        _getNavInfoWidgetForStep(context, step, null),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
