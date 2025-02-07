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

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../widgets/widgets.dart';

class PolygonsPage extends ExamplePage {
  const PolygonsPage({super.key})
      : super(leading: const Icon(Icons.square), title: 'Polygons');
  @override
  ExamplePageState<PolygonsPage> createState() => _PolygonsPageState();
}

class _PolygonsPageState extends ExamplePageState<PolygonsPage> {
  late final GoogleNavigationViewController _navigationViewController;
  List<Polygon> _polygons = <Polygon>[];
  Polygon? _selectedPolygon;

  final List<Color> _colors = <Color>[
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue
  ];
  final List<double> _strokeWidths = <double>[2, 6, 10];
  final List<double> _zIndexes = <double>[-1, 0, 1];

  // ignore: use_setters_to_change_properties
  void _onViewCreated(GoogleNavigationViewController controller) {
    _navigationViewController = controller;
  }

  Future<void> _addPolygon() async {
    // Add square polygon on the current camera position.
    final LatLngBounds cameraBounds =
        await _navigationViewController.getVisibleRegion();

    final List<LatLng> points = _createInsetSquare(cameraBounds, 0.2);

    final PolygonOptions options = PolygonOptions(
      points: points,
      clickable: true,
      fillColor: Colors.red,
    );
    final List<Polygon?> polygons =
        await _navigationViewController.addPolygons(<PolygonOptions>[options]);
    final Polygon? polygon = polygons.firstOrNull;
    if (polygon != null) {
      setState(() {
        _polygons = _polygons + <Polygon>[polygon];
        _selectedPolygon = polygon;
      });
    }
  }

  /// Creates list of 4 coordinates, for each corner of the square.
  /// Each point is offset away from the center point.
  List<LatLng> _createInsetSquare(LatLngBounds bounds, double insetFraction) {
    final double latInsetAmount = (bounds.latitudeSpan) * insetFraction;
    final double lonInsetAmount = (bounds.longitudeSpan) * insetFraction;

    final LatLng northWest = bounds.northwest
        .offset(LatLng(longitude: lonInsetAmount, latitude: -latInsetAmount));
    final LatLng northEast = bounds.northeast
        .offset(LatLng(longitude: -lonInsetAmount, latitude: -latInsetAmount));
    final LatLng southEast = bounds.southeast
        .offset(LatLng(longitude: -lonInsetAmount, latitude: latInsetAmount));
    final LatLng southWest = bounds.southwest
        .offset(LatLng(longitude: lonInsetAmount, latitude: latInsetAmount));
    return <LatLng>[northWest, northEast, southEast, southWest];
  }

  /// Creates square, 4 coordinates, from top left and bottom right coordinates.
  List<LatLng> _createSquare(LatLngBounds bounds) {
    return <LatLng>[
      bounds.northwest,
      bounds.northeast,
      bounds.southeast,
      bounds.southwest
    ];
  }

  Future<void> _toggleHoles() async {
    if (_selectedPolygon!.options.holes.isEmpty) {
      await _addHoles();
    } else {
      await _removeHoles();
    }
  }

  Future<void> _addHoles() async {
    // Get min and max coordinates from the existing polygon.
    final List<LatLng> points = _selectedPolygon!.options.points;

    // Create bounds from the existing polygon points.
    final LatLngBounds bounds = LatLngBounds.createBoundsFromPoints(points);

    // Calculate width and height of the polygon.
    final double height = bounds.latitudeSpan;
    final double width = bounds.longitudeSpan;

    // Offsets for creating holes.
    final LatLng firstHoleCornerOffset =
        LatLng(latitude: height * 0.1, longitude: width * 0.1);
    final LatLng secondHoleCornerOffset =
        LatLng(latitude: height * 0.4, longitude: width * 0.4);

    // Create hole that is 30% of the total rectangle width,
    // hole will be 10% of width away from the southwest corner.
    final List<LatLng> firstHole = _createSquare(LatLngBounds(
      southwest: bounds.southwest.offset(firstHoleCornerOffset),
      northeast: bounds.southwest.offset(secondHoleCornerOffset),
    ));

    // Create hole that is 30% of the total rectangle width,
    // hole will be 10% of width away from the northeast corner.
    final List<LatLng> secondHole = _createSquare(LatLngBounds(
      southwest: bounds.northeast.offset(-secondHoleCornerOffset),
      northeast: bounds.northeast.offset(-firstHoleCornerOffset),
    ));

    await _updateSelectedPolygonWithOptions(_selectedPolygon!.options
        .copyWith(holes: <List<LatLng>>[firstHole, secondHole]));
  }

  Future<void> _removeHoles() async {
    if (_selectedPolygon == null) {
      return;
    }

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(holes: <List<LatLng>>[]));
  }

  Future<void> _updateSelectedPolygonWithOptions(PolygonOptions options) async {
    final Polygon newPolygon = _selectedPolygon!.copyWith(options: options);

    final List<Polygon?> polygons =
        await _navigationViewController.updatePolygons(<Polygon>[newPolygon]);
    final Polygon? polygon = polygons.firstOrNull;
    if (polygon != null) {
      setState(() {
        _polygons = _polygons
            .where((Polygon element) => element != _selectedPolygon)
            .toList();
        _selectedPolygon = polygon;
        _polygons = _polygons + <Polygon>[polygon];
      });
    }
  }

  Future<void> _removePolygon() async {
    await _navigationViewController
        .removePolygons(<Polygon>[_selectedPolygon!]);

    setState(() {
      _polygons = _polygons
          .where((Polygon element) => element != _selectedPolygon)
          .toList();
      _selectedPolygon = null;
    });
  }

  void _onPolygonClicked(String polygonId) {
    final Polygon polygon = _polygons
        .firstWhere((Polygon element) => element.polygonId == polygonId);
    setState(() {
      _selectedPolygon = polygon;
    });
  }

  Future<void> _setFillColor() async {
    final Color oldColor = _selectedPolygon!.options.fillColor;
    final Color newColor = _colors.elementAtOrNull(
            _colors.indexWhere((Color e) => e == oldColor) + 1) ??
        _colors[0];

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(fillColor: newColor));
  }

  Future<void> _setStrokeColor() async {
    final Color oldColor = _selectedPolygon!.options.strokeColor;
    final Color newColor = _colors.elementAtOrNull(
            _colors.indexWhere((Color e) => e == oldColor) + 1) ??
        _colors[0];

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(strokeColor: newColor));
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
    await _updateSelectedPolygonWithOptions(_selectedPolygon!.options
        .copyWith(geodesic: !_selectedPolygon!.options.geodesic));
  }

  Future<void> _setStrokeWidth() async {
    final double oldStrokeWidth = _selectedPolygon!.options.strokeWidth;
    final double newStrokeWidth = _strokeWidths.elementAtOrNull(
            _strokeWidths.indexWhere((double e) => e == oldStrokeWidth) + 1) ??
        _strokeWidths[0];

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(strokeWidth: newStrokeWidth));
  }

  Future<void> _toggleVisibility() async {
    final bool oldVisibility = _selectedPolygon!.options.visible;

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(visible: !oldVisibility));
  }

  Future<void> _setZIndex() async {
    final double oldZIndex = _selectedPolygon!.options.zIndex;
    final double newZIndex = _zIndexes.elementAtOrNull(
            _zIndexes.indexWhere((double e) => e == oldZIndex) + 1) ??
        _zIndexes[0];

    await _updateSelectedPolygonWithOptions(
        _selectedPolygon!.options.copyWith(zIndex: newZIndex));
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
                onPolygonClicked: _onPolygonClicked,
              )),
              const SizedBox(height: 10),
              Text(
                _polygons.isEmpty
                    ? 'No polygons added. Move camera to place polygon.'
                    : _selectedPolygon == null
                        ? 'Click to select polygon'
                        : 'Selected polygon ${_selectedPolygon!.polygonId}',
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
                onPressed: () => _addPolygon(),
                child: const Text('Add polygon'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _removePolygon(),
                child: const Text('Remove polygon'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _toggleHoles(),
                child: _selectedPolygon?.options.holes.isEmpty ?? true
                    ? const Text('Add holes')
                    : const Text('Remove holes'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _toggleGeodesic(),
                child: Text('Geodesic: ${_selectedPolygon?.options.geodesic}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _setFillColor(),
                child: Text(
                    'Fill color: ${_colorName(_selectedPolygon?.options.fillColor)}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _setStrokeColor(),
                child: Text(
                    'Stroke color: ${_colorName(_selectedPolygon?.options.strokeColor)}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _setStrokeWidth(),
                child: Text(
                    'Stroke width: ${_selectedPolygon?.options.strokeWidth}'),
              ),
              ElevatedButton(
                onPressed:
                    _selectedPolygon == null ? null : () => _toggleVisibility(),
                child: Text('Visibility: ${_selectedPolygon?.options.visible}'),
              ),
              ElevatedButton(
                onPressed: _selectedPolygon == null ? null : () => _setZIndex(),
                child: Text('Z-index: ${_selectedPolygon?.options.zIndex}'),
              ),
              ElevatedButton(
                onPressed: _polygons.isNotEmpty
                    ? () {
                        setState(() {
                          _navigationViewController.clearPolygons();
                          _polygons.clear();
                          _selectedPolygon = null;
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
