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
// File: gms_lat_lng_point_editor.dart

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../utils/utils.dart';
import 'widgets.dart';

/// An editor for [CameraPosition] values.
class ExampleCameraPositionEditor extends StatefulWidget {
  const ExampleCameraPositionEditor({
    super.key,
    required this.initialCameraPosition,
    required this.onChanged,
  });

  final CameraPosition initialCameraPosition;
  final ValueChanged<CameraPosition> onChanged;

  @override
  State<ExampleCameraPositionEditor> createState() =>
      _ExampleCameraPositionEditorState();
}

class _ExampleCameraPositionEditorState
    extends State<ExampleCameraPositionEditor> {
  late CameraPosition cameraPosition;

  @override
  void initState() {
    super.initState();
    cameraPosition = widget.initialCameraPosition;
  }

  void _updateCameraPosition() {
    widget.onChanged(cameraPosition);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Camera Position'),
      children: <Widget>[
        ExampleLatLngEditor(
          title: 'Coordinates',
          initialLatLng: cameraPosition.target,
          onChanged: (LatLng newTarget) {
            setState(() {
              cameraPosition = CameraPosition(
                bearing: cameraPosition.bearing,
                target: newTarget,
                tilt: cameraPosition.tilt,
                zoom: cameraPosition.zoom,
              );
            });
            _updateCameraPosition();
          },
        ),
        ExampleSlider(
          value: cameraPosition.bearing,
          onChanged: (double newValue) {
            setState(() {
              cameraPosition = CameraPosition(
                bearing: newValue,
                target: cameraPosition.target,
                tilt: cameraPosition.tilt,
                zoom: cameraPosition.zoom,
              );
            });
            _updateCameraPosition();
          },
          title: 'Bearing',
          min: 0,
          max: 360,
        ),
        ExampleSlider(
          value: cameraPosition.zoom,
          onChanged: (double newValue) {
            setState(() {
              cameraPosition = CameraPosition(
                bearing: cameraPosition.bearing,
                target: cameraPosition.target,
                tilt: cameraPosition.tilt,
                zoom: newValue,
              );
            });
            _updateCameraPosition();
          },
          title: 'Zoom',
          min: googleMapsMinZoomLevel,
          max: googleMapsMaxZoomLevel,
        ),
        ExampleSlider(
          value: cameraPosition.tilt,
          onChanged: (double newValue) {
            setState(() {
              cameraPosition = CameraPosition(
                bearing: cameraPosition.bearing,
                target: cameraPosition.target,
                tilt: newValue,
                zoom: cameraPosition.zoom,
              );
            });
            _updateCameraPosition();
          },
          title: 'Tilt',
          min: 0,
          max: 90,
        ),
      ],
    );
  }
}
