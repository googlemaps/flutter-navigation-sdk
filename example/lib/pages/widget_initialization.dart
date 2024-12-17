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

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class WidgetInitializationPage extends ExamplePage {
  const WidgetInitializationPage({super.key})
      : super(
            leading: const Icon(Icons.settings),
            title: 'Widget initialization');

  @override
  ExamplePageState<WidgetInitializationPage> createState() =>
      _ViewInitializationPageState();
}

class _ViewInitializationPageState
    extends ExamplePageState<WidgetInitializationPage> {
  CameraPosition _initialCameraPosition =
      const CameraPosition(target: LatLng(latitude: 65, longitude: 25.5));
  MapType _initialMapType = MapType.normal;
  bool _initialCompassEnabled = true;
  bool _initialRotateGesturesEnabled = true;
  bool _initialScrollGesturesEnabled = true;
  bool _initialTiltGesturesEnabled = true;
  bool _initialZoomGesturesEnabled = true;
  bool _initialScrollGesturesEnabledDuringRotateOrZoom = true;
  bool _initialMapToolbarEnabled = true;
  double? _initialMinZoomPreference;
  double? _initialMaxZoomPreference;
  bool _initialZoomControlsEnabled = true;
  LatLngBounds? _initialCameraTargetBounds;
  EdgeInsets? _initialPadding;
  NavigationUIEnabledPreference _initialNavigationUIEnabledPreference =
      NavigationUIEnabledPreference.automatic;
  TextDirection? _layoutDirection;
  bool _isMinZoomPreferenceEnabled = false;
  bool _isMaxZoomPreferenceEnabled = false;

  /// Navigation state
  bool _navigationInitialized = false;

  @override
  void initState() {
    super.initState();
    _updateNavigationInitializationState();
  }

  @override
  void dispose() {
    if (_navigationInitialized) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }

  Future<void> _updateNavigationInitializationState() async {
    _navigationInitialized = await GoogleMapsNavigator.isInitialized();
    setState(() {});
  }

  void _toggleCameraTargetBounds(bool enabled) {
    setState(() {
      _initialCameraTargetBounds = enabled
          ? LatLngBounds(
              northeast: const LatLng(latitude: 90, longitude: 180),
              southwest: const LatLng(latitude: -90, longitude: -179.9),
            )
          : null;
    });
  }

  void _changePage() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _InitializedViewPage(
          initialCameraPosition: _initialCameraPosition,
          initialMapType: _initialMapType,
          initialCompassEnabled: _initialCompassEnabled,
          initialRotateGesturesEnabled: _initialRotateGesturesEnabled,
          initialScrollGesturesEnabled: _initialScrollGesturesEnabled,
          initialTiltGesturesEnabled: _initialTiltGesturesEnabled,
          initialZoomGesturesEnabled: _initialZoomGesturesEnabled,
          initialScrollGesturesEnabledDuringRotateOrZoom:
              _initialScrollGesturesEnabledDuringRotateOrZoom,
          initialMapToolbarEnabled: _initialMapToolbarEnabled,
          initialMinZoomPreference: _initialMinZoomPreference,
          initialMaxZoomPreference: _initialMaxZoomPreference,
          initialZoomControlsEnabled: _initialZoomControlsEnabled,
          initialCameraTargetBounds: _initialCameraTargetBounds,
          initialPadding: _initialPadding,
          initialNavigationUIEnabledPreference:
              _initialNavigationUIEnabledPreference,
          layoutDirection: _layoutDirection,
        ),
      ),
    );
  }

  double _limitMinZoomReference(double value) {
    return min(_initialMaxZoomPreference ?? googleMapsMaxZoomLevel, value);
  }

  double _limitMaxZoomReference(double value) {
    return max(_initialMinZoomPreference ?? googleMapsMinZoomLevel, value);
  }

  Future<void> _startNavigation() async {
    if (!await GoogleMapsNavigator.areTermsAccepted()) {
      await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'test_title',
        'test_company_name',
      );
    }
    await GoogleMapsNavigator.initializeNavigationSession();
    await _updateNavigationInitializationState();
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => Column(children: <Widget>[
            Expanded(
                child: Scrollbar(
                    thumbVisibility: true,
                    radius: const Radius.circular(30),
                    child: SingleChildScrollView(
                        child: Column(
                      children: <Widget>[
                        ExpansionTile(
                          title: const Text(
                            'Map controls',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: <Widget>[
                            ExampleDropdownButton<MapType>(
                              title: 'Map Type',
                              value: _initialMapType,
                              items: MapType.values,
                              onChanged: (MapType? newValue) {
                                setState(() {
                                  _initialMapType = newValue!;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Compass Enabled'),
                              value: _initialCompassEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialCompassEnabled = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Map Toolbar Enabled'),
                              value: _initialMapToolbarEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialMapToolbarEnabled = value;
                                });
                              },
                            ),
                            ExampleDropdownButton<TextDirection?>(
                              title: 'Layout direction',
                              value: _layoutDirection,
                              items: const <TextDirection?>[
                                null,
                                ...TextDirection.values
                              ],
                              onChanged: (TextDirection? newValue) {
                                setState(() {
                                  _layoutDirection = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Text(
                            'Camera controls',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: <Widget>[
                            ExampleCameraPositionEditor(
                              initialCameraPosition: _initialCameraPosition,
                              onChanged: (CameraPosition newCameraPosition) {
                                setState(() {
                                  _initialCameraPosition = newCameraPosition;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Rotate Gestures Enabled'),
                              value: _initialRotateGesturesEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialRotateGesturesEnabled = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Scroll Gestures Enabled'),
                              value: _initialScrollGesturesEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialScrollGesturesEnabled = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Tilt Gestures Enabled'),
                              value: _initialTiltGesturesEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialTiltGesturesEnabled = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Zoom Gestures Enabled'),
                              value: _initialZoomGesturesEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialZoomGesturesEnabled = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text(
                                  'Scroll gestures enabled during rotate or zoom'),
                              value:
                                  _initialScrollGesturesEnabledDuringRotateOrZoom,
                              onChanged: (bool value) {
                                setState(() {
                                  _initialScrollGesturesEnabledDuringRotateOrZoom =
                                      value;
                                });
                              },
                            ),
                            if (Platform.isAndroid)
                              SwitchListTile(
                                title: const Text('Zoom Controls Enabled'),
                                value: _initialZoomControlsEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    _initialZoomControlsEnabled = value;
                                  });
                                },
                              ),
                            SwitchListTile(
                              title: const Text('Min Zoom Preference Enabled'),
                              value: _isMinZoomPreferenceEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _isMinZoomPreferenceEnabled = value;
                                  _initialMinZoomPreference = value
                                      ? _limitMinZoomReference(
                                          googleMapsMinZoomLevel)
                                      : null;
                                });
                              },
                            ),
                            if (_isMinZoomPreferenceEnabled)
                              ExampleSlider(
                                value: _initialMinZoomPreference!,
                                onChanged: (double newValue) {
                                  setState(() {
                                    _initialMinZoomPreference =
                                        _limitMinZoomReference(newValue);
                                  });
                                },
                                title: 'Min Zoom Preference',
                                min: googleMapsMinZoomLevel,
                                max: googleMapsMaxZoomLevel,
                              ),
                            SwitchListTile(
                              title: const Text('Max Zoom Preference Enabled'),
                              value: _isMaxZoomPreferenceEnabled,
                              onChanged: (bool value) {
                                setState(() {
                                  _isMaxZoomPreferenceEnabled = value;
                                  _initialMaxZoomPreference = value
                                      ? _limitMaxZoomReference(
                                          googleMapsMaxZoomLevel)
                                      : null;
                                });
                              },
                            ),
                            if (_isMaxZoomPreferenceEnabled)
                              ExampleSlider(
                                value: _initialMaxZoomPreference!,
                                onChanged: (double newValue) {
                                  setState(() {
                                    _initialMaxZoomPreference =
                                        _limitMaxZoomReference(newValue);
                                  });
                                },
                                title: 'Max Zoom Preference',
                                min: googleMapsMinZoomLevel,
                                max: googleMapsMaxZoomLevel,
                              ),
                            SwitchListTile(
                              title: const Text('Camera Target Bounds Enabled'),
                              value: _initialCameraTargetBounds != null,
                              onChanged: _toggleCameraTargetBounds,
                            ),
                            if (_initialCameraTargetBounds != null)
                              ExampleLatLngBoundsEditor(
                                title: 'Camera bounds',
                                initiallyExpanded: true,
                                initialBounds: _initialCameraTargetBounds!,
                                onChanged: (LatLngBounds newBounds) {
                                  setState(() {
                                    _initialCameraTargetBounds = newBounds;
                                  });
                                  hideSnackBarMessage(context);
                                },
                                onAssert: (AssertionError error) =>
                                    showSnackBarMessage(
                                        context, error.message.toString()),
                              ),
                          ],
                        ),
                        ExpansionTile(
                            title: const Text(
                              'Navigation controls',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children: <Widget>[
                              ExampleDropdownButton<
                                  NavigationUIEnabledPreference>(
                                title: 'Navigation UI Enabled preference',
                                value: _initialNavigationUIEnabledPreference,
                                items: const <NavigationUIEnabledPreference>[
                                  NavigationUIEnabledPreference.automatic,
                                  NavigationUIEnabledPreference.disabled
                                ],
                                onChanged:
                                    (NavigationUIEnabledPreference? newValue) {
                                  setState(() {
                                    _initialNavigationUIEnabledPreference =
                                        newValue ??
                                            NavigationUIEnabledPreference
                                                .automatic;
                                  });
                                },
                              ),
                            ]),
                      ],
                    )))),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed:
                          !_navigationInitialized ? _startNavigation : null,
                      child: Text(_navigationInitialized
                          ? 'Initialized'
                          : 'Init navigation'),
                    ),
                    ElevatedButton(
                      onPressed: () => _changePage(),
                      child: const Text('Open map'),
                    ),
                  ]),
            ),
          ]));
}

class _InitializedViewPage extends StatelessWidget {
  const _InitializedViewPage({
    required this.initialCameraPosition,
    required this.initialMapType,
    required this.initialCompassEnabled,
    required this.initialRotateGesturesEnabled,
    required this.initialScrollGesturesEnabled,
    required this.initialTiltGesturesEnabled,
    required this.initialZoomGesturesEnabled,
    required this.initialScrollGesturesEnabledDuringRotateOrZoom,
    required this.initialMapToolbarEnabled,
    required this.initialMinZoomPreference,
    required this.initialMaxZoomPreference,
    required this.initialZoomControlsEnabled,
    required this.initialCameraTargetBounds,
    required this.initialPadding,
    required this.initialNavigationUIEnabledPreference,
    required this.layoutDirection,
  });

  final CameraPosition initialCameraPosition;
  final TextDirection? layoutDirection;
  final MapType initialMapType;
  final bool initialCompassEnabled;
  final bool initialRotateGesturesEnabled;
  final bool initialScrollGesturesEnabled;
  final bool initialTiltGesturesEnabled;
  final bool initialZoomGesturesEnabled;
  final bool initialScrollGesturesEnabledDuringRotateOrZoom;
  final bool initialMapToolbarEnabled;
  final double? initialMinZoomPreference;
  final double? initialMaxZoomPreference;
  final bool initialZoomControlsEnabled;
  final LatLngBounds? initialCameraTargetBounds;
  final EdgeInsets? initialPadding;
  final NavigationUIEnabledPreference initialNavigationUIEnabledPreference;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialized Map Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMapsNavigationView(
        onViewCreated: (GoogleNavigationViewController controller) {},
        initialCameraPosition: initialCameraPosition,
        layoutDirection: layoutDirection,
        initialMapType: initialMapType,
        initialCompassEnabled: initialCompassEnabled,
        initialRotateGesturesEnabled: initialRotateGesturesEnabled,
        initialScrollGesturesEnabled: initialScrollGesturesEnabled,
        initialTiltGesturesEnabled: initialTiltGesturesEnabled,
        initialZoomGesturesEnabled: initialZoomGesturesEnabled,
        initialScrollGesturesEnabledDuringRotateOrZoom:
            initialScrollGesturesEnabledDuringRotateOrZoom,
        initialMapToolbarEnabled: initialMapToolbarEnabled,
        initialMinZoomPreference: initialMinZoomPreference,
        initialMaxZoomPreference: initialMaxZoomPreference,
        initialZoomControlsEnabled: initialZoomControlsEnabled,
        initialCameraTargetBounds: initialCameraTargetBounds,
        initialPadding: initialPadding,
        initialNavigationUIEnabledPreference:
            initialNavigationUIEnabledPreference,
      ),
    );
  }
}
