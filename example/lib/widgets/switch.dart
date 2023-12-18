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

class ExampleSwitch extends StatefulWidget {
  const ExampleSwitch({
    super.key,
    required this.title,
    this.onChanged,
    required this.initialValue,
  });

  /// The title of the switch tile which is displayed next to the switch.
  final String title;

  /// Called when the user toggles the switch.
  ///
  /// If null, the switch will be disabled.
  final ValueChanged<bool>? onChanged;

  /// The initial value of the switch.
  final bool initialValue;

  @override
  State<ExampleSwitch> createState() => _ExampleSwitchState();
}

class _ExampleSwitchState extends State<ExampleSwitch> {
  late bool _flag;

  @override
  void initState() {
    super.initState();
    _flag = widget.initialValue;
  }

  void _toggleFlag(bool value) {
    setState(() {
      _flag = value;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title),
      value: _flag,
      onChanged: widget.onChanged != null ? _toggleFlag : null,
    );
  }
}
