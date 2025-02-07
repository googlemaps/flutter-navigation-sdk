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
import '../widgets/widgets.dart';

class PolylinesPage extends ExamplePage {
  const PolylinesPage({super.key})
      : super(leading: const Icon(Icons.polyline), title: 'Polylines');

  @override
  ExamplePageState<PolylinesPage> createState() => _PolylinesPageState();
}

class _PolylinesPageState extends ExamplePageState<PolylinesPage> {
  late final GoogleNavigationViewController _navigationViewController;
  List<Polyline> _polylines = <Polyline>[];
  Polyline? _selectedPolyline;

  final List<Color> _colors = <Color>[
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue
  ];
  final List<double> _strokeWidths = <double>[2, 6, 10];
  final List<double> _zIndexes = <double>[-1, 0, 1];
  final List<List<PatternItem>> _strokePatterns = <List<PatternItem>>[
    <PatternItem>[const DashPattern(length: 1.0)],
    <PatternItem>[const DotPattern()],
    <PatternItem>[const DotPattern(), const GapPattern(length: 50)],
    <PatternItem>[const DotPattern(), const GapPattern(length: 100)],
    <PatternItem>[
      const DashPattern(length: 20),
      const DotPattern(),
      const GapPattern(length: 50)
    ]
  ];
  int _selectedStrokePatternIndex = 0;

  // ignore: use_setters_to_change_properties
  void _onViewCreated(GoogleNavigationViewController controller) {
    _navigationViewController = controller;
  }

  Future<void> _addPolyline() async {
    // Add triangle made out of polylines on the current camera position.
    final LatLngBounds cameraBounds =
        await _navigationViewController.getVisibleRegion();

    // Use the latitudeSpan and longitudeSpan properties of LatLngBounds
    final List<LatLng> points = _createInsetTriangle(cameraBounds, 0.2);

    final PolylineOptions options = PolylineOptions(
      points: points,
      clickable: true,
      strokePattern: _strokePatterns[0],
    );
    final List<Polyline?> polylines = await _navigationViewController
        .addPolylines(<PolylineOptions>[options]);
    final Polyline? polyline = polylines.firstOrNull;
    if (polyline != null) {
      setState(() {
        _polylines = _polylines + <Polyline>[polyline];
        _selectedPolyline = polyline;
      });
    }
  }

  /// Creates list of 4 coordinates, 3 for each corner of the triangle and starting point again.
  /// Each point is offset away from the center point.
  List<LatLng> _createInsetTriangle(LatLngBounds bounds, double insetFraction) {
// Calculate inset amounts based on the fraction of the latitude and longitude spans
    final double latInsetAmount = bounds.latitudeSpan * insetFraction;
    final double lonInsetAmount = bounds.longitudeSpan * insetFraction;

    // Offset each corner of the bounds inward
    final LatLng corner1 = bounds.northwest
        .offset(LatLng(latitude: -latInsetAmount, longitude: lonInsetAmount));
    final LatLng corner2 = bounds.northeast
        .offset(LatLng(latitude: -latInsetAmount, longitude: -lonInsetAmount));
    final LatLng corner3 = bounds.southeast
        .offset(LatLng(latitude: latInsetAmount, longitude: -lonInsetAmount));

    // Return the points forming the triangle, ending at the starting point
    return <LatLng>[corner1, corner2, corner3, corner1];
  }

  Future<void> _updateSelectedPolylineWithOptions(
      PolylineOptions options) async {
    final Polyline newPolyline = _selectedPolyline!.copyWith(options: options);

    final List<Polyline?> polylines = await _navigationViewController
        .updatePolylines(<Polyline>[newPolyline]);
    final Polyline? polyline = polylines.firstOrNull;
    if (polyline != null) {
      setState(() {
        _polylines = _polylines
            .where((Polyline element) => element != _selectedPolyline)
            .toList();
        _selectedPolyline = polyline;
        _polylines = _polylines + <Polyline>[polyline];
      });
    }
  }

  Future<void> _removePolyline() async {
    await _navigationViewController
        .removePolylines(<Polyline>[_selectedPolyline!]);

    setState(() {
      _polylines = _polylines
          .where((Polyline element) => element != _selectedPolyline)
          .toList();
      _selectedPolyline = null;
    });
  }

  void _onPolylineClicked(String polylineId) {
    final Polyline polyline = _polylines
        .firstWhere((Polyline element) => element.polylineId == polylineId);
    setState(() {
      _selectedPolyline = polyline;
    });
  }

  Future<void> _setStrokeColor() async {
    final Color oldColor = _selectedPolyline!.options.strokeColor!;
    final Color newColor = _colors.elementAtOrNull(
            _colors.indexWhere((Color e) => e == oldColor) + 1) ??
        _colors[0];

    await _updateSelectedPolylineWithOptions(
        _selectedPolyline!.options.copyWith(strokeColor: newColor));
  }

  // Android only.
  Future<void> _setStrokePattern() async {
    _selectedStrokePatternIndex =
        (_selectedStrokePatternIndex + 1) % _strokePatterns.length;
    await _updateSelectedPolylineWithOptions(_selectedPolyline!.options
        .copyWith(strokePattern: _strokePatterns[_selectedStrokePatternIndex]));
  }

  String _colorName(Color? color) {
    if (color == Colors.black) {
      return 'Black';
    } else if (color == Colors.red) {
      return 'Red';
    } else if (color == Colors.green) {
      return 'Green';
    } else if (color == Colors.blue) {
      return 'Blue';
    } else {
      return 'null';
    }
  }

  Future<void> _toggleGeodesic() async {
    await _updateSelectedPolylineWithOptions(_selectedPolyline!.options
        .copyWith(geodesic: !_selectedPolyline!.options.geodesic!));
  }

  Future<void> _setStrokeWidth() async {
    final double oldStrokeWidth = _selectedPolyline!.options.strokeWidth!;
    final double newStrokeWidth = _strokeWidths.elementAtOrNull(
            _strokeWidths.indexWhere((double e) => e == oldStrokeWidth) + 1) ??
        _strokeWidths[0];

    await _updateSelectedPolylineWithOptions(
        _selectedPolyline!.options.copyWith(strokeWidth: newStrokeWidth));
  }

  Future<void> _toggleVisibility() async {
    final bool oldVisibility = _selectedPolyline!.options.visible!;

    await _updateSelectedPolylineWithOptions(
        _selectedPolyline!.options.copyWith(visible: !oldVisibility));
  }

  Future<void> _setZIndex() async {
    final double oldZIndex = _selectedPolyline!.options.zIndex!;
    final double newZIndex = _zIndexes.elementAtOrNull(
            _zIndexes.indexWhere((double e) => e == oldZIndex) + 1) ??
        _zIndexes[0];

    await _updateSelectedPolylineWithOptions(
        _selectedPolyline!.options.copyWith(zIndex: newZIndex));
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => Padding(
            padding: EdgeInsets.zero,
            child: Column(children: <Widget>[
              Expanded(
                  child: GoogleMapsNavigationView(
                initialCameraPosition: const CameraPosition(
                    target: LatLng(latitude: 37.422, longitude: -122.084),
                    zoom: 12),
                initialNavigationUIEnabledPreference:
                    NavigationUIEnabledPreference.disabled,
                onViewCreated: _onViewCreated,
                onPolylineClicked: _onPolylineClicked,
              )),
              const SizedBox(height: 10),
              Text(
                _polylines.isEmpty
                    ? 'No polylines added. Move camera to place polyline.'
                    : _selectedPolyline == null
                        ? 'Click to select polyline'
                        : 'Selected polyline ${_selectedPolyline!.polylineId}',
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              bottomControls
            ]),
          ));

  Widget get bottomControls {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _addPolyline(),
                child: const Text('Add polyline'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolyline == null ? null : () => _removePolyline(),
                child: const Text('Remove polyline'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolyline == null ? null : () => _toggleGeodesic(),
                child: Text('Geodesic: ${_selectedPolyline?.options.geodesic}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolyline == null ? null : () => _setStrokeColor(),
                child: Text(
                    'Stroke color: ${_colorName(_selectedPolyline?.options.strokeColor)}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolyline == null ? null : () => _setStrokeWidth(),
                child: Text(
                    'Stroke width: ${_selectedPolyline?.options.strokeWidth}'),
              ),
              if (Platform.isAndroid)
                ElevatedButton(
                  onPressed: _selectedPolyline == null
                      ? null
                      : () => _setStrokePattern(),
                  child: const Text('Change stroke pattern'),
                ),
              ElevatedButton(
                onPressed: _selectedPolyline == null
                    ? null
                    : () => _toggleVisibility(),
                child:
                    Text('Visibility: ${_selectedPolyline?.options.visible}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolyline == null ? null : () => _setZIndex(),
                child: Text('Z-index: ${_selectedPolyline?.options.zIndex}'),
              ),
              ElevatedButton(
                onPressed: _polylines.isNotEmpty
                    ? () {
                        setState(() {
                          _navigationViewController.clearPolylines();
                          _polylines.clear();
                          _selectedPolyline = null;
                        });
                      }
                    : null,
                child: const Text('Clear all'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
