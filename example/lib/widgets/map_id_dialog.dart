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

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../utils/utils.dart';

/// Shows a dialog to set or clear the Map ID.
Future<void> showMapIdDialog(
  BuildContext context,
  VoidCallback onMapIdChanged,
) async {
  final TextEditingController controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set Map ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter Map ID (leave empty to clear)',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tip: You can also set this at compile time using:',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            const Text(
              '--dart-define=MAP_ID=your_map_id',
              style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            const Text(
              'See README for more details on Map ID configuration.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              MapIdManager.instance.setMapId(
                controller.text.isEmpty ? null : controller.text,
              );
              Navigator.of(context).pop();
              onMapIdChanged();
            },
            child: const Text('Set'),
          ),
        ],
      );
    },
  );
}
