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

const _viewPadding = 8.0;
const _smallControlsHeight = 80.0;
const _navigationControlsHeight = 130.0;

class TurnByTurnPage extends ExamplePage {
  const TurnByTurnPage({super.key})
    : super(
        leading: const Icon(Icons.roundabout_right),
        title: 'Turn-by-turn NavInfo',
      );

  @override
  ExamplePageState<TurnByTurnPage> createState() => _TurnByTurnPageState();
}

class _TurnByTurnPageState extends ExamplePageState<TurnByTurnPage> {
  bool _navigationRunning = false;
  bool _isFullscreen = false;
  bool _showCustomUI = true; // Default to custom UI
  bool _isPromptVisible = false;
  GoogleNavigationViewController? _navigationViewController;
  StreamSubscription<NavInfoEvent>? _navInfoSubscription;

  NavInfo? _navInfo;

  final GoogleMapsAutoViewController _autoViewController =
      GoogleMapsAutoViewController();

   @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  

  Future<void> _initialize() async {
    _autoViewController.listenForCustomNavigationAutoEvents((event) {
    //_showMessage("Received event: ${event.event}");

    if (event.event == "AutoEventStart") {
        _startNavigation();
      } else if (event.event == "AutoEventStop") {
        _stopNavigation();
      }
    });
  }

  // ignore: use_setters_to_change_properties
  void _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    // Sync official UI state with current custom UI toggle
    await _updateUIState();
    setState(() {});
  }

  /// Updates the SDK's navigation header/footer visibility based on
  /// whether custom UI is enabled.
  Future<void> _updateUIState() async {
    if (_navigationViewController == null) return;
    // Hide SDK's header/footer when custom UI is shown
    _navigationViewController!.setNavigationHeaderEnabled(!_showCustomUI);
    _navigationViewController!.setNavigationFooterEnabled(!_showCustomUI);
    _navigationViewController!.setPadding(_getMapPadding());
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
      const LatLng(latitude: 37.528560, longitude: -122.361996),
    );

    final Destinations msg = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'Grace Cathedral',
          target: const LatLng(latitude: 37.791957, longitude: -122.412529),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(msg);

    if (status == NavigationRouteStatus.statusOk) {
      await GoogleMapsNavigator.startGuidance();
      await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
      await _navigationViewController?.followMyLocation(
        CameraPerspective.tilted,
      );

      _hideMessage();
      setState(() {
        _navigationRunning = true;
      });
    } else {
      _showMessage('Starting navigation failed.');
      setState(() {});
    }
    _updateUIState();
  }

  Future<void> _setupListeners() async {
    // Clear old listeners to make sure we subscribe to each event only once.
    _clearListeners();

    // Initialize the Turn-by-turn nav info listener with max number of steps
    // to preview.
    _navInfoSubscription = GoogleMapsNavigator.setNavInfoListener(
      _onNavInfoEvent,
      numNextStepsToPreview: 100,
      stepImageGenerationOptions: const StepImageGenerationOptions(
        generateManeuverImages: true,
        generateLaneImages: true,
      ),
    );
  }

  void _clearListeners() {
    _navInfoSubscription?.cancel();
    _navInfoSubscription = null;
  }

  void _onNavInfoEvent(NavInfoEvent event) {
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
      // Clear registered maneuver and lane images before cleanup
      await clearRegisteredImages(filter: RegisteredImageType.maneuver);
      await clearRegisteredImages(filter: RegisteredImageType.lanes);
      await GoogleMapsNavigator.simulator.removeUserLocation();
      await GoogleMapsNavigator.cleanup();

      setState(() {
        _navigationRunning = false;
      });
    }
    _updateUIState();
  }

  @override
  void dispose() {
    _clearListeners();
    if (_navigationRunning) {
      // Clear registered maneuver and lane images before cleanup
      clearRegisteredImages(filter: RegisteredImageType.maneuver);
      clearRegisteredImages(filter: RegisteredImageType.lanes);
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }

  /// Handles step change when user swipes to a different step.
  /// When swiping back to current step (index 0), re-enable follow mode.
  void _onStepChanged(StepInfo step, int stepIndex) async {
    debugPrint('Step changed to index $stepIndex: ${step.fullRoadName}');
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void _toggleCustomUI() {
    final enabled = !_showCustomUI;

    setState(() {
      _showCustomUI = enabled;
      _isFullscreen = enabled && _isFullscreen;
    });
    _updateUIState();
  }

  double _getControlsHeight() {
    if (!_isFullscreen) {
      return 0;
    }
    if (!_navigationRunning) {
      return _smallControlsHeight;
    }
    if (_showCustomUI) {
      return _navigationControlsHeight;
    }
    return 0;
  }

  EdgeInsets _getViewPadding() {
    if (_isFullscreen) {
      final safePadding = MediaQuery.of(context).padding;

      return EdgeInsets.only(
        top: safePadding.top,
        bottom: safePadding.bottom + _getControlsHeight(),
        left: _viewPadding,
        right: _viewPadding,
      );
    }
    return EdgeInsets.all(_viewPadding);
  }

  EdgeInsets _getMapPadding() {
    EdgeInsets padding;
    if (_navigationRunning) {
      double top = _showCustomUI ? 50 : 0;
      double bottom = _showCustomUI ? 100 : 0;
      padding = EdgeInsets.only(
        top: top,
        bottom: bottom + _getControlsHeight(),
      );
    } else {
      padding = _getViewPadding();
    }

    // On Android, scale padding by device pixel ratio
    if (Platform.isAndroid) {
      return padding * MediaQuery.of(context).devicePixelRatio;
    }
    return padding;
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen mode: render without buildPage (edge-to-edge)
    if (_isFullscreen) {
      return Scaffold(body: _buildFullscreenContent(context));
    }

    // Normal mode: use buildPage with app bar, buttons below map
    return buildPage(
      context,
      (BuildContext context) => _buildNormalContent(context),
    );
  }

  /// Builds the normal (non-fullscreen) layout with map and buttons in a Column.
  /// Buttons are below the map, not overlaid. This demonstrates how custom UI
  /// can have margin at the bottom to sit above the control buttons.
  Widget _buildNormalContent(BuildContext context) {
    return Column(
      children: [
        // Map area (expands to fill available space)
        Expanded(child: _buildMapWithOverlays(context, isFullscreen: false)),
        // Control buttons below the map
        Container(
          padding: const EdgeInsets.all(16),
          child: _buildControlButtons(context),
        ),
      ],
    );
  }

  /// Builds the fullscreen layout with everything overlaid on the map.
  Widget _buildFullscreenContent(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Stack(
      children: [
        // Map fills entire screen
        Positioned.fill(
          child: _buildMapWithOverlays(context, isFullscreen: true),
        ),
        // Control buttons overlaid at bottom
        Positioned(
          bottom: safePadding.bottom + 16,
          left: 16,
          right: 16,
          child: _buildControlButtons(context),
        ),
      ],
    );
  }

  /// Builds the map view with custom navigation overlays.
  Widget _buildMapWithOverlays(
    BuildContext context, {
    required bool isFullscreen,
  }) {
    final viewPadding = _getViewPadding();

    return Stack(
      children: [
        // Map view - fills the entire area
        Positioned.fill(
          child: GoogleMapsNavigationView(
            onViewCreated: _onViewCreated,
            initialPadding: _getMapPadding(),
            initialNavigationUIEnabledPreference:
                NavigationUIEnabledPreference.automatic,
            onPromptVisibilityChanged: (bool promptVisible) {
              if (mounted) {
                setState(() => _isPromptVisible = promptVisible);
              }
            },
          ),
        ),

        // Custom Navigation Header overlay
        if (_showCustomUI &&
            _navInfo != null &&
            _navInfo!.currentStep != null &&
            _navInfo!.navState != NavState.stopped) ...[
          Positioned(
            top: viewPadding.top,
            left: 0,
            right: 0,
            child: CustomNavigationHeaderExample(
              navInfo: _navInfo!,
              onStepChanged: _onStepChanged,
            ),
          ),
          if (!_isPromptVisible)
            Positioned(
              bottom: viewPadding.bottom,
              left: 0,
              right: 0,
              child: CustomNavigationFooterExample(navInfo: _navInfo!),
            ),
        ],
      ],
    );
  }

  /// Builds the control buttons (used in both normal and fullscreen modes).
  Widget _buildControlButtons(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        ElevatedButton(
          onPressed:
              _navigationRunning
                  ? () => _stopNavigation()
                  : () => _startNavigation(),
          child: Text(
            _navigationRunning ? 'Stop navigation' : 'Start navigation',
          ),
        ),
        if (_navigationRunning)
          ElevatedButton(
            onPressed: _toggleCustomUI,
            child: Text(
              _showCustomUI ? 'Disable Custom UI' : 'Enable Custom UI',
            ),
          ),
        ElevatedButton(
          onPressed: _showCustomUI ? _toggleFullscreen : null,
          child: Text(_isFullscreen ? 'Exit fullscreen' : 'Fullscreen'),
        ),
        if (_navInfo != null)
          ElevatedButton(
            onPressed: () => _showSteps(context, _navInfo!),
            child: const Text('Show remaining steps'),
          ),
      ],
    );
  }

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

  void _showSteps(BuildContext context, NavInfo navInfo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
                    child: const Text('Close'),
                  ),
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
                          StepCardExample(step: step),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
