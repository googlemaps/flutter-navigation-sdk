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
import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class CameraPage extends ExamplePage {
  const CameraPage({super.key})
      : super(leading: const Icon(Icons.video_camera_back), title: 'Camera');

  @override
  ExamplePageState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ExamplePageState<CameraPage> {
  bool _animationsEnabled = true;
  bool _displayAnimationFinished = false;
  int? _animationDuration;
  double _focusX = 0;
  double _focusY = 0;
  bool _navigationRunning = false;
  late final GoogleNavigationViewController _navigationViewController;
  late double _minZoomLevel;
  late double _maxZoomLevel;
  bool _showCameraUpdates = false;
  String _latestCameraUpdate = '';
  bool _isFollowingLocation = false;

  // ignore: use_setters_to_change_properties
  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    calculateFocusCenter();
    _minZoomLevel = await _navigationViewController.getMinZoomPreference();
    _maxZoomLevel = await _navigationViewController.getMaxZoomPreference();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startNavigation() async {
    showMessage('Starting navigation.');
    if (!await GoogleMapsNavigator.areTermsAccepted()) {
      await GoogleMapsNavigator.showTermsAndConditionsDialog(
        'test_title',
        'test_company_name',
      );
    }
    await GoogleMapsNavigator.initializeNavigationSession();

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

    if (!mounted) {
      return;
    }

    setState(() {});
    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(msg);

    if (status == NavigationRouteStatus.statusOk) {
      await GoogleMapsNavigator.startGuidance();
      await GoogleMapsNavigator.simulator.simulateLocationsAlongExistingRoute();
      await _navigationViewController
          .followMyLocation(CameraPerspective.tilted);

      if (mounted) {
        setState(() {
          _navigationRunning = true;
        });
      }
    } else {
      showMessage('Starting navigation failed.');
    }
  }

  Future<void> _stopNavigation() async {
    if (_navigationRunning) {
      await GoogleMapsNavigator.cleanup();

      if (mounted) {
        setState(() {
          _navigationRunning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_navigationRunning) {
      GoogleMapsNavigator.cleanup();
    }
    super.dispose();
  }

  void calculateFocusCenter() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    _focusX = screenWidth / 2;
    _focusY = (screenHeight - appBarHeight) / 2;
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => Stack(children: <Widget>[
            GoogleMapsNavigationView(
                initialNavigationUIEnabledPreference:
                    NavigationUIEnabledPreference.disabled,
                onViewCreated: _onViewCreated,
                onCameraMoveStarted: _onCameraMoveStarted,
                onCameraMove: _onCameraMove,
                onCameraIdle: _onCameraIdle,
                onCameraStartedFollowingLocation:
                    _onCameraStartedFollowingLocation,
                onCameraStoppedFollowingLocation:
                    _onCameraStoppedFollowingLocation),
            getOverlayOptionsButton(context, onPressed: () => toggleOverlay()),
            if (_showCameraUpdates)
              Container(
                width: 180,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white),
                child: Text(
                  _latestCameraUpdate,
                ),
              )
          ]));

  void _onCameraMoveStarted(CameraPosition position, bool gesture) {
    if (!mounted) {
      return;
    }
    if (_showCameraUpdates) {
      showMessage(gesture
          ? 'Camera move started by gesture'
          : 'Camera move started by action');
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (!mounted) {
      return;
    }
    final String cameraState =
        _isFollowingLocation ? 'Camera following' : 'Camera moving';
    final String positionStr =
        'Position: ${position.target.latitude.toStringAsFixed(2)}, ${position.target.longitude.toStringAsFixed(2)}';
    setState(() {
      _latestCameraUpdate = '$cameraState\n$positionStr';
    });
  }

  void _onCameraIdle(CameraPosition position) {
    if (!mounted) {
      return;
    }
    setState(() {
      _latestCameraUpdate =
          'Camera idle\nPosition: ${position.target.latitude.toStringAsFixed(2)}, ${position.target.longitude.toStringAsFixed(2)}';
    });
  }

  // Android only.
  void _onCameraStartedFollowingLocation(CameraPosition position) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isFollowingLocation = true;
    });
  }

  // Android only.
  void _onCameraStoppedFollowingLocation(CameraPosition position) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isFollowingLocation = false;
    });
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }
    hideMessage();
    if (isOverlayVisible) {
      showOverlaySnackBar(message);
    } else {
      final SnackBar snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void hideMessage() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  void _showAnimationFinishedMessage(bool success) {
    if (!mounted) {
      return;
    }
    if (_displayAnimationFinished) {
      showMessage(success ? 'Animation finished' : 'Animation canceled');
    }
  }

  Future<void> _setMinZoomLevel(double newMinZoomLevel) async {
    try {
      await _navigationViewController.setMinZoomPreference(newMinZoomLevel);
      setState(() {
        _minZoomLevel = newMinZoomLevel;
      });
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<void> _setMaxZoomLevel(double newMaxZoomLevel) async {
    try {
      await _navigationViewController.setMaxZoomPreference(newMaxZoomLevel);
      setState(() {
        _maxZoomLevel = newMaxZoomLevel;
      });
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future<void> _resetZoomLevels() async {
    await _navigationViewController.resetMinMaxZoomPreference();
    _minZoomLevel = await _navigationViewController.getMinZoomPreference();
    _maxZoomLevel = await _navigationViewController.getMaxZoomPreference();

    setState(() {});
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    final ButtonStyle threeButtonRowStyle = Theme.of(context)
        .elevatedButtonTheme
        .style!
        .copyWith(
            minimumSize: WidgetStateProperty.all<Size>(const Size(107, 36)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SwitchListTile(
          title: const Text('Animations enabled'),
          value: _animationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _animationsEnabled = value;
            });
          },
        ),
        if (Platform.isAndroid && _animationsEnabled) ...<Widget>[
          SwitchListTile(
            title: const Text('Default animation duration'),
            value: _animationDuration == null,
            onChanged: (bool value) {
              setState(() {
                _animationDuration = _animationDuration == null ? 1000 : null;
              });
            },
          ),
          if (_animationDuration != null)
            ExampleSlider(
              value: _animationDuration?.toDouble() ?? 0.0,
              onChanged: (double newValue) {
                setState(() {
                  _animationDuration = newValue.toInt();
                });
              },
              title: 'Animation duration',
              unit: 'ms',
              fractionDigits: 0,
              min: 0,
              max: 3000,
            ),
        ],
        if (Platform.isAndroid && _animationsEnabled && _animationDuration != 0)
          SwitchListTile(
            title: const Text('Display animation finished'),
            value: _displayAnimationFinished,
            onChanged: (bool value) {
              setState(() {
                _displayAnimationFinished = value;
              });
            },
          ),
        SwitchListTile(
          title: const Text('Show camera updates'),
          value: _showCameraUpdates,
          onChanged: (bool value) {
            setState(() {
              _showCameraUpdates = value;
            });
          },
        ),
        const SizedBox(height: 24.0),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate =
                    CameraUpdate.newCameraPosition(const CameraPosition(
                  bearing: 270.0,
                  target: LatLng(latitude: 51.5160895, longitude: -0.1294527),
                  tilt: 30.0,
                  zoom: 17.0,
                ));
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('newCameraPosition'),
            ),
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate =
                    CameraUpdate.scrollBy(150.0, -225.0);
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('scrollBy'),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
                  const LatLng(latitude: 56.1725505, longitude: 10.1850512),
                );
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('newLatLng'),
            ),
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: const LatLng(
                        latitude: -38.483935, longitude: 113.248673),
                    northeast: const LatLng(
                        latitude: -8.982446, longitude: 153.823821),
                  ),
                  padding: 10.0,
                );
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('newLatLngBounds'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
                const LatLng(latitude: 37.4231613, longitude: -122.087159),
                11.0);
            if (_animationsEnabled) {
              _navigationViewController.animateCamera(cameraUpdate,
                  duration: _animationDuration != null
                      ? Duration(milliseconds: _animationDuration!)
                      : null,
                  onFinished: (bool success) =>
                      _showAnimationFinishedMessage(success));
            } else {
              _navigationViewController.moveCamera(cameraUpdate);
            }
          },
          child: const Text('newLatLngZoom'),
        ),
        const SizedBox(height: 24.0),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.zoomBy(-0.5);
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('zoomBy'),
            ),
            ElevatedButton(
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.zoomBy(
                  1.0,
                  focus: Offset(_focusX, _focusY),
                );
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('zoomBy with focus'),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            ElevatedButton(
              style: threeButtonRowStyle,
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.zoomIn();
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('zoomIn'),
            ),
            ElevatedButton(
              style: threeButtonRowStyle,
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.zoomOut();
                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('zoomOut'),
            ),
            ElevatedButton(
              style: threeButtonRowStyle,
              onPressed: () {
                final CameraUpdate cameraUpdate = CameraUpdate.zoomTo(16.0);

                if (_animationsEnabled) {
                  _navigationViewController.animateCamera(cameraUpdate,
                      duration: _animationDuration != null
                          ? Duration(milliseconds: _animationDuration!)
                          : null,
                      onFinished: (bool success) =>
                          _showAnimationFinishedMessage(success));
                } else {
                  _navigationViewController.moveCamera(cameraUpdate);
                }
              },
              child: const Text('zoomTo'),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        Wrap(alignment: WrapAlignment.center, spacing: 10, children: <Widget>[
          ElevatedButton(
              onPressed: _navigationRunning
                  ? () => _stopNavigation()
                  : () => _startNavigation(),
              child: Text(
                  _navigationRunning ? 'Stop navigation' : 'Start navigation')),
          ElevatedButton(
              onPressed: _navigationRunning
                  ? () => _navigationViewController.showRouteOverview()
                  : null,
              child: const Text('Route overview')),
        ]),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          children: <Widget>[
            ElevatedButton(
                style: threeButtonRowStyle,
                onPressed: _navigationRunning
                    ? () {
                        _navigationViewController
                            .followMyLocation(CameraPerspective.tilted);

                        hideMessage();
                      }
                    : null,
                child: const Text('Tilted')),
            ElevatedButton(
                style: threeButtonRowStyle,
                onPressed: _navigationRunning
                    ? () {
                        _navigationViewController.followMyLocation(
                            CameraPerspective.topDownHeadingUp);
                        hideMessage();
                      }
                    : null,
                child: const Text('Heading up')),
            ElevatedButton(
                style: threeButtonRowStyle,
                onPressed: _navigationRunning
                    ? () {
                        _navigationViewController
                            .followMyLocation(CameraPerspective.topDownNorthUp);
                        hideMessage();
                      }
                    : null,
                child: const Text('North up')),
            ElevatedButton(
                style: threeButtonRowStyle,
                onPressed: _navigationRunning
                    ? () {
                        _navigationViewController.followMyLocation(
                            CameraPerspective.tilted,
                            zoomLevel: 10.0);
                        hideMessage();
                      }
                    : null,
                child: const Text('Tilted with custom zoom')),
          ],
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () async {
            final CameraPosition position =
                await _navigationViewController.getCameraPosition();

            // Hide overlay to show the message.
            hideOverlay();
            showMessage(
                'Camera position\n\nTilt: ${position.tilt}°\nZoom: ${position.zoom}\nBearing: ${position.bearing}°\nTarget: ${position.target.latitude.toStringAsFixed(4)}, ${position.target.longitude.toStringAsFixed(4)}');
          },
          child: const Text('Get camera position'),
        ),
        const SizedBox(height: 24.0),
        Text('Min zoom level: ${_minZoomLevel.round()}'),
        Slider(
            value: _minZoomLevel,
            min: googleMapsMinZoomLevel,
            max: googleMapsMaxZoomLevel,
            divisions:
                (googleMapsMaxZoomLevel - googleMapsMinZoomLevel).toInt(),
            label: _minZoomLevel.round().toString(),
            onChanged: (double value) {
              _setMinZoomLevel(value);
            }),
        Text('Max zoom level: ${_maxZoomLevel.round()}'),
        Slider(
            value: _maxZoomLevel,
            min: googleMapsMinZoomLevel,
            max: googleMapsMaxZoomLevel,
            divisions:
                (googleMapsMaxZoomLevel - googleMapsMinZoomLevel).toInt(),
            label: _maxZoomLevel.round().toString(),
            onChanged: (double value) {
              _setMaxZoomLevel(value);
            }),
        ElevatedButton(
          onPressed: () => _resetZoomLevels(),
          child: const Text('Reset zoom levels'),
        ),
      ],
    );
  }
}
