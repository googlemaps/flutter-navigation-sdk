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

class CirclesPage extends ExamplePage {
  const CirclesPage({super.key})
      : super(leading: const Icon(Icons.circle), title: 'Circles');
  @override
  ExamplePageState<CirclesPage> createState() => _CirclesPageState();
}

class _CirclesPageState extends ExamplePageState<CirclesPage> {
  late final GoogleNavigationViewController _navigationViewController;
  List<Circle> _circles = <Circle>[];
  Circle? _selectedCircle;

  final List<Color> _colors = <Color>[
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue
  ];
  final List<double> _radiusList = <double>[5, 50, 500, 5000, 50000];
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

  Future<void> _addCircle() async {
    // Add circle on the current camera position.
    final LatLngBounds cameraBounds =
        await _navigationViewController.getVisibleRegion();

    final LatLng centerPoint = cameraBounds.center;

    final CircleOptions options = CircleOptions(
        position: centerPoint,
        radius: 50,
        clickable: true,
        fillColor: Colors.red,
        strokePattern: _strokePatterns[0]);
    final List<Circle?> circles =
        await _navigationViewController.addCircles(<CircleOptions>[options]);
    final Circle? circle = circles.firstOrNull;
    if (circle != null) {
      setState(() {
        _circles = _circles + <Circle>[circle];
        _selectedCircle = circle;
      });
    }
  }

  Future<void> _updateSelectedCircleWithOptions(CircleOptions options) async {
    final Circle newCircle = _selectedCircle!.copyWith(options: options);

    final List<Circle?> circles =
        await _navigationViewController.updateCircles(<Circle>[newCircle]);
    final Circle? circle = circles.firstOrNull;
    if (circle != null) {
      setState(() {
        _circles = _circles
            .where((Circle element) => element != _selectedCircle)
            .toList();
        _selectedCircle = circle;
        _circles = _circles + <Circle>[circle];
      });
    }
  }

  Future<void> _removeCircle() async {
    await _navigationViewController.removeCircles(<Circle>[_selectedCircle!]);

    setState(() {
      _circles = _circles
          .where((Circle element) => element != _selectedCircle)
          .toList();
      _selectedCircle = null;
    });
  }

  void _onCircleClicked(String circleId) {
    final Circle circle =
        _circles.firstWhere((Circle element) => element.circleId == circleId);
    setState(() {
      _selectedCircle = circle;
    });
  }

  Future<void> _setRadius() async {
    final double oldRadius = _selectedCircle!.options.radius;
    final double newRadius = _radiusList.elementAtOrNull(
            _radiusList.indexWhere((double e) => e == oldRadius) + 1) ??
        _radiusList[0];

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(radius: newRadius));
  }

  // Android only.
  Future<void> _setStrokePattern() async {
    _selectedStrokePatternIndex =
        (_selectedStrokePatternIndex + 1) % _strokePatterns.length;
    await _updateSelectedCircleWithOptions(_selectedCircle!.options
        .copyWith(strokePattern: _strokePatterns[_selectedStrokePatternIndex]));
  }

  Future<void> _setFillColor() async {
    final Color oldColor = _selectedCircle!.options.fillColor;
    final Color newColor = _colors.elementAtOrNull(
            _colors.indexWhere((Color e) => e == oldColor) + 1) ??
        _colors[0];

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(fillColor: newColor));
  }

  Future<void> _setStrokeColor() async {
    final Color oldColor = _selectedCircle!.options.strokeColor;
    final Color newColor = _colors.elementAtOrNull(
            _colors.indexWhere((Color e) => e == oldColor) + 1) ??
        _colors[0];

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(strokeColor: newColor));
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

  Future<void> _setStrokeWidth() async {
    final double oldStrokeWidth = _selectedCircle!.options.strokeWidth;
    final double newStrokeWidth = _strokeWidths.elementAtOrNull(
            _strokeWidths.indexWhere((double e) => e == oldStrokeWidth) + 1) ??
        _strokeWidths[0];

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(strokeWidth: newStrokeWidth));
  }

  Future<void> _toggleVisibility() async {
    final bool oldVisibility = _selectedCircle!.options.visible;

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(visible: !oldVisibility));
  }

  Future<void> _setZIndex() async {
    final double oldZIndex = _selectedCircle!.options.zIndex;
    final double newZIndex = _zIndexes.elementAtOrNull(
            _zIndexes.indexWhere((double e) => e == oldZIndex) + 1) ??
        _zIndexes[0];

    await _updateSelectedCircleWithOptions(
        _selectedCircle!.options.copyWith(zIndex: newZIndex));
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
                onCircleClicked: _onCircleClicked,
              )),
              const SizedBox(height: 10),
              Text(
                _circles.isEmpty
                    ? 'No circles added. Move camera to place circle.'
                    : _selectedCircle == null
                        ? 'Click to select circle'
                        : 'Selected circle ${_selectedCircle!.circleId}',
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
                onPressed: () => _addCircle(),
                child: const Text('Add circle'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedCircle == null ? null : () => _removeCircle(),
                child: const Text('Remove circle'),
              ),
              ElevatedButton(
                onPressed: _selectedCircle == null ? null : () => _setRadius(),
                child: Text('Radius: ${_selectedCircle?.options.radius}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedCircle == null ? null : () => _setFillColor(),
                child: Text(
                    'Fill color: ${_colorName(_selectedCircle?.options.fillColor)}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedCircle == null ? null : () => _setStrokeColor(),
                child: Text(
                    'Stroke color: ${_colorName(_selectedCircle?.options.strokeColor)}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedCircle == null ? null : () => _setStrokeWidth(),
                child: Text(
                    'Stroke width: ${_selectedCircle?.options.strokeWidth}'),
              ),
              if (Platform.isAndroid)
                ElevatedButton(
                  onPressed: _selectedCircle == null
                      ? null
                      : () => _setStrokePattern(),
                  child: const Text('Change stroke pattern'),
                ),
              ElevatedButton(
                onPressed:
                    _selectedCircle == null ? null : () => _toggleVisibility(),
                child: Text('Visibility: ${_selectedCircle?.options.visible}'),
              ),
              ElevatedButton(
                onPressed: _selectedCircle == null ? null : () => _setZIndex(),
                child: Text('Z-index: ${_selectedCircle?.options.zIndex}'),
              ),
              ElevatedButton(
                onPressed: _circles.isNotEmpty
                    ? () {
                        setState(() {
                          _navigationViewController.clearCircles();
                          _circles.clear();
                          _selectedCircle = null;
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

  void showMessage(String message) {
    final SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
