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

class ExampleSlider extends StatelessWidget {
  const ExampleSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.min,
    required this.max,
    this.fractionDigits,
    this.unit,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String title;
  final double min;
  final double max;
  final int? fractionDigits;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: Text(title),
          trailing:
              Text(value.toStringAsFixed(fractionDigits ?? 1) + (unit ?? '')),
        ),
        Slider(
          value: value,
          onChanged: (double newValue) {
            onChanged(newValue);
          },
          min: min,
          max: max,
        ),
      ],
    );
  }
}
