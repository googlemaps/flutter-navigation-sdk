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

class ExampleDropdownButton<T> extends StatelessWidget {
  const ExampleDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.title,
    this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        items: items.map<DropdownMenuItem<T>>((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(value.toString().split('.').last),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
