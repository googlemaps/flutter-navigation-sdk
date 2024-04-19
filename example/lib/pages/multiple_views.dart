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

import 'package:flutter/material.dart';
import 'package:google_maps_navigation/google_maps_navigation.dart';
import '../widgets/widgets.dart';

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

  GoogleNavigationViewController? _firstNavigationController;
  GoogleNavigationViewController? _secondNavigationController;

  void _onViewCreated(GoogleNavigationViewController controller) {
    _firstNavigationController = controller;
  }

  void _onViewCreated2(GoogleNavigationViewController controller) {
    _secondNavigationController = controller;
  }

  Future<void> _moveCameras() async {
    await _firstNavigationController!.moveCamera(CameraUpdate.newCameraPosition(
        _cameraMoveCounter.isEven ? cameraPositionOxford : cameraPositionMIT));
    await _secondNavigationController!.moveCamera(
        CameraUpdate.newCameraPosition(_cameraMoveCounter.isOdd
            ? cameraPositionOxford
            : cameraPositionMIT));
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
                    child: GoogleMapsNavigationView(
                      onViewCreated: _onViewCreated,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: GoogleMapsNavigationView(
                      onViewCreated: _onViewCreated2,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (_firstNavigationController != null &&
                      _secondNavigationController != null)
                    ElevatedButton(
                      onPressed: _moveCameras,
                      child: const Text('Move cameras'),
                    ),
                ]),
          ));
}
