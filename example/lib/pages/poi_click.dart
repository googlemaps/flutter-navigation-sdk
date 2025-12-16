// Copyright 2025 Google LLC
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

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import '../widgets/page.dart';

/// Example page demonstrating POI (Point of Interest) click events.
class PoiClickPage extends ExamplePage {
  /// Creates a POI click example page.
  const PoiClickPage({super.key})
    : super(leading: const Icon(Icons.location_on), title: 'POI Click Events');

  @override
  ExamplePageState<PoiClickPage> createState() => _PoiClickPageState();
}

class _PoiClickPageState extends ExamplePageState<PoiClickPage> {
  GoogleMapViewController? _mapController;
  PointOfInterest? _lastClickedPoi;

  @override
  Widget build(BuildContext context) {
    return buildPage(
      context,
      (BuildContext context) => Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            Expanded(
              child: GoogleMapsMapView(
                onViewCreated: _onViewCreated,
                onPoiClicked: _handlePoiClick,
                initialCameraPosition: const CameraPosition(
                  // San Francisco
                  target: LatLng(latitude: 37.7749, longitude: -122.4194),
                  zoom: 14,
                ),
              ),
            ),
            if (_lastClickedPoi != null)
              Container(
                padding: const EdgeInsets.all(8),
                child: Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.top,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text('Name:'),
                        ),
                        Text(_lastClickedPoi!.name),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(right: 8, top: 4),
                          child: Text('Place ID:'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(_lastClickedPoi!.placeId),
                        ),
                      ],
                    ),
                    TableRow(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(right: 8, top: 4),
                          child: Text('Location:'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${_lastClickedPoi!.latLng.latitude.toStringAsFixed(6)}, '
                            '${_lastClickedPoi!.latLng.longitude.toStringAsFixed(6)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onViewCreated(GoogleMapViewController controller) async {
    _mapController = controller;
    await controller.setMyLocationEnabled(true);
  }

  void _handlePoiClick(PointOfInterest poi) {
    setState(() {
      _lastClickedPoi = poi;
    });
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
