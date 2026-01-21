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

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../widgets/widgets.dart';

/// A page to demonstrate projection methods (coordinate conversion).
///
/// Allows users to tap on the map to see both geographic coordinates (LatLng)
/// and screen coordinates (ScreenCoordinate), demonstrating the projection API.
class ProjectionPage extends ExamplePage {
  /// Constructs a [ProjectionPage].
  const ProjectionPage({super.key})
    : super(
        leading: const Icon(Icons.adjust),
        title: 'Projection (Coordinate Conversion)',
      );

  @override
  ExamplePageState<ProjectionPage> createState() => _ProjectionPageState();
}

enum ProjectionMode { latLngToScreen, screenToLatLng }

class _ProjectionPageState extends ExamplePageState<ProjectionPage> {
  late final GoogleMapViewController _mapViewController;
  List<Marker> _markers = <Marker>[];
  String _coordinateInfo = 'Select a mode and tap to test projection';
  bool _showOverlay = true;
  ScreenCoordinate? _lastScreenCoordinate;
  ProjectionMode _mode = ProjectionMode.latLngToScreen;

  Future<void> _onViewCreated(GoogleMapViewController controller) async {
    _mapViewController = controller;
    setState(() {});
  }

  Future<void> _onMapClicked(LatLng latLng) async {
    if (_mode != ProjectionMode.latLngToScreen) {
      return;
    }

    // Clear previous markers
    if (_markers.isNotEmpty) {
      await _mapViewController.clearMarkers();
    }

    // Test getScreenCoordinate: LatLng -> ScreenCoordinate
    final ScreenCoordinate screenCoord = await _mapViewController
        .getScreenCoordinate(latLng);

    // Add a marker at the tapped position
    final MarkerOptions options = MarkerOptions(
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Tapped Location',
        snippet:
            'Lat: ${latLng.latitude.toStringAsFixed(6)}, Lng: ${latLng.longitude.toStringAsFixed(6)}',
      ),
    );

    final List<Marker?> addedMarkers = await _mapViewController.addMarkers(
      <MarkerOptions>[options],
    );

    setState(() {
      if (addedMarkers.isNotEmpty && addedMarkers.first != null) {
        _markers = <Marker>[addedMarkers.first!];
      }

      _lastScreenCoordinate = screenCoord;

      _coordinateInfo = '''
Mode: LatLng → Screen
Converts geographic coordinates to screen pixels

Geographic Coordinates (input):
  Lat: ${latLng.latitude.toStringAsFixed(6)}
  Lng: ${latLng.longitude.toStringAsFixed(6)}

Screen Coordinates (output):
  X: ${screenCoord.x.toStringAsFixed(2)} px
  Y: ${screenCoord.y.toStringAsFixed(2)} px
''';
    });
  }

  Future<void> _onScreenTap(Offset position) async {
    if (_mode != ProjectionMode.screenToLatLng) {
      return;
    }

    // Clear previous markers
    if (_markers.isNotEmpty) {
      await _mapViewController.clearMarkers();
    }

    // Test getLatLng: ScreenCoordinate -> LatLng
    final ScreenCoordinate screenCoord = ScreenCoordinate(
      x: position.dx,
      y: position.dy,
    );
    final LatLng latLng = await _mapViewController.getLatLng(screenCoord);

    // Add a marker at the converted position
    final MarkerOptions options = MarkerOptions(
      position: latLng,
      infoWindow: InfoWindow(
        title: 'Screen Tap Location',
        snippet:
            'Lat: ${latLng.latitude.toStringAsFixed(6)}, Lng: ${latLng.longitude.toStringAsFixed(6)}',
      ),
    );

    final List<Marker?> addedMarkers = await _mapViewController.addMarkers(
      <MarkerOptions>[options],
    );

    setState(() {
      if (addedMarkers.isNotEmpty && addedMarkers.first != null) {
        _markers = <Marker>[addedMarkers.first!];
      }

      _lastScreenCoordinate = screenCoord;

      _coordinateInfo = '''
Mode: Screen → LatLng
Converts screen pixels to geographic coordinates

Screen Coordinates (input):
  X: ${screenCoord.x.toStringAsFixed(2)} px
  Y: ${screenCoord.y.toStringAsFixed(2)} px

Geographic Coordinates (output):
  Lat: ${latLng.latitude.toStringAsFixed(6)}
  Lng: ${latLng.longitude.toStringAsFixed(6)}
''';
    });
  }

  Future<void> _testCenterCoordinate() async {
    // Get screen center first before async call
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Offset? screenCenter =
        box != null ? Offset(box.size.width / 2, box.size.height / 2) : null;

    // Get the center of the map
    final CameraPosition position =
        await _mapViewController.getCameraPosition();

    if (_mode == ProjectionMode.latLngToScreen) {
      await _onMapClicked(position.target);
    } else {
      if (screenCenter != null) {
        await _onScreenTap(screenCenter);
      }
    }
  }

  void _clearMarkers() {
    _mapViewController.clearMarkers();
    setState(() {
      _markers.clear();
      _lastScreenCoordinate = null;
      _coordinateInfo = 'Select a mode and tap to test projection';
    });
  }

  void _switchMode(ProjectionMode mode) {
    setState(() {
      _mode = mode;
      _clearMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildPage(
      context,
      (BuildContext context) => Stack(
        children: <Widget>[
          GoogleMapsMapView(
            onViewCreated: _onViewCreated,
            onMapClicked: _onMapClicked,
          ),
          // GestureDetector for screen tap mode
          if (_mode == ProjectionMode.screenToLatLng)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (TapDownDetails details) {
                  _onScreenTap(details.localPosition);
                },
              ),
            ),
          // Crosshair overlay showing screen coordinate position
          if (_lastScreenCoordinate != null)
            Positioned(
              left: _lastScreenCoordinate!.x - 20,
              top: _lastScreenCoordinate!.y - 20,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ),
          // Info overlay
          if (_showOverlay)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Projection Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _showOverlay = false;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _coordinateInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Button to show overlay if hidden
          if (!_showOverlay)
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _showOverlay = true;
                  });
                },
                child: const Icon(Icons.info_outline),
              ),
            ),
          // Mode selector
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _mode == ProjectionMode.latLngToScreen
                              ? null
                              : () =>
                                  _switchMode(ProjectionMode.latLngToScreen),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _mode == ProjectionMode.latLngToScreen
                                ? Theme.of(context).colorScheme.primary
                                : null,
                        foregroundColor:
                            _mode == ProjectionMode.latLngToScreen
                                ? Colors.white
                                : null,
                      ),
                      child: const Text('LatLng → Screen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _mode == ProjectionMode.screenToLatLng
                              ? null
                              : () =>
                                  _switchMode(ProjectionMode.screenToLatLng),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _mode == ProjectionMode.screenToLatLng
                                ? Theme.of(context).colorScheme.primary
                                : null,
                        foregroundColor:
                            _mode == ProjectionMode.screenToLatLng
                                ? Colors.white
                                : null,
                      ),
                      child: const Text('Screen → LatLng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Control buttons
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: _testCenterCoordinate,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Test Center'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _markers.isEmpty ? null : _clearMarkers,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
