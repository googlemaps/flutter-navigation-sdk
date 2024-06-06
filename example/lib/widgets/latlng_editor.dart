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

import 'widgets.dart';

class ExampleLatLngEditor extends StatefulWidget {
  const ExampleLatLngEditor({
    super.key,
    required this.initialLatLng,
    required this.onChanged,
    required this.title,
  });

  final LatLng initialLatLng;
  final ValueChanged<LatLng> onChanged;
  final String title;

  @override
  State<ExampleLatLngEditor> createState() => _ExampleLatLngEditorState();
}

class _ExampleLatLngEditorState extends State<ExampleLatLngEditor> {
  bool _useSlider = true;

  void _toggleEditorType() {
    setState(() {
      _useSlider = !_useSlider;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(widget.title),
          trailing: IconButton(
            icon: Icon(_useSlider ? Icons.text_fields : Icons.tune),
            onPressed: _toggleEditorType,
          ),
        ),
        if (_useSlider)
          ExampleLatLngSlideEditor(
            initialLatLng: widget.initialLatLng,
            onChanged: widget.onChanged,
          )
        else
          ExampleLatLngTextEditor(
            initialLatLng: widget.initialLatLng,
            onChanged: widget.onChanged,
          ),
      ],
    );
  }
}

class ExampleLatLngTextEditor extends StatelessWidget {
  const ExampleLatLngTextEditor({
    super.key,
    required this.initialLatLng,
    required this.onChanged,
  });

  final LatLng initialLatLng;
  final ValueChanged<LatLng> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
        child: TextFormField(
          initialValue: initialLatLng.latitude.toString(),
          decoration: const InputDecoration(labelText: 'Latitude'),
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            onChanged(
              LatLng(
                latitude: double.parse(value),
                longitude: initialLatLng.longitude,
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
        child: TextFormField(
          initialValue: initialLatLng.longitude.toString(),
          decoration: const InputDecoration(labelText: 'Longitude'),
          keyboardType: TextInputType.number,
          onChanged: (String value) {
            onChanged(
              LatLng(
                latitude: initialLatLng.latitude,
                longitude: double.parse(value),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class ExampleLatLngSlideEditor extends StatefulWidget {
  const ExampleLatLngSlideEditor({
    super.key,
    required this.initialLatLng,
    required this.onChanged,
  });

  final LatLng initialLatLng;
  final ValueChanged<LatLng> onChanged;

  @override
  ExampleLatLngSlideEditorState createState() =>
      ExampleLatLngSlideEditorState();
}

class ExampleLatLngSlideEditorState extends State<ExampleLatLngSlideEditor> {
  late double latitude;
  late double longitude;

  @override
  void initState() {
    super.initState();
    latitude = widget.initialLatLng.latitude;
    longitude = widget.initialLatLng.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ExampleSlider(
          value: latitude,
          onChanged: (double newValue) {
            setState(() {
              latitude = newValue;
            });
            widget.onChanged(
              LatLng(latitude: newValue, longitude: longitude),
            );
          },
          title: 'Latitude',
          min: -90,
          max: 90,
        ),
        ExampleSlider(
          value: longitude,
          onChanged: (double newValue) {
            setState(() {
              longitude = newValue;
            });
            widget.onChanged(
              LatLng(latitude: latitude, longitude: newValue),
            );
          },
          title: 'Longitude',
          min: -180,
          max: 180,
        ),
      ],
    );
  }
}
