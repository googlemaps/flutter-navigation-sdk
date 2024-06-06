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

class ExampleLatLngBoundsEditor extends StatefulWidget {
  const ExampleLatLngBoundsEditor(
      {super.key,
      required this.initialBounds,
      required this.onChanged,
      required this.onAssert,
      this.initiallyExpanded = false,
      this.title = 'Bounds'});

  final LatLngBounds initialBounds;
  final bool initiallyExpanded;
  final String title;
  final ValueChanged<LatLngBounds> onChanged;

  // Called on assertion for debugging purposes only.
  final void Function(AssertionError) onAssert;

  @override
  State<ExampleLatLngBoundsEditor> createState() =>
      _ExampleLatLngBoundsEditorState();
}

class _ExampleLatLngBoundsEditorState extends State<ExampleLatLngBoundsEditor> {
  late LatLngBounds bounds;

  // Used to reset slider widgets if error happens.
  int assertCounter = 0;

  @override
  void initState() {
    super.initState();
    bounds = widget.initialBounds;
  }

  void _updateBounds(LatLng newNortheast, LatLng newSouthwest) {
    try {
      bounds = LatLngBounds(
        northeast: newNortheast,
        southwest: newSouthwest,
      );
      widget.onChanged(bounds);
    } on AssertionError catch (e) {
      // Note that AssertionErrors are available only on debug build and are not available
      // on release build and therefore should not be used to handle errors on production.
      // Instead developers should initialize bounds in proper format.
      widget.onAssert(e);
      assertCounter++;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      initiallyExpanded: widget.initiallyExpanded,
      children: <Widget>[
        ExampleLatLngEditor(
          key: ValueKey<String>('ne$assertCounter'),
          initialLatLng: bounds.northeast,
          onChanged: (LatLng value) => _updateBounds(value, bounds.southwest),
          title: 'Northeast Coordinates',
        ),
        ExampleLatLngEditor(
          key: ValueKey<String>('sw$assertCounter'),
          initialLatLng: bounds.southwest,
          onChanged: (LatLng value) => _updateBounds(bounds.northeast, value),
          title: 'Southwest Coordinates',
        ),
      ],
    );
  }
}
