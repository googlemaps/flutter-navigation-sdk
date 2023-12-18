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

import 'dart:io';

import 'package:flutter/material.dart';

/// Builds options button Widget for the example app.
Widget getOptionsButton(
  BuildContext context, {
  required void Function()? onPressed,
  ButtonStyle? style,
}) =>
    ElevatedButton.icon(
      style: style ?? ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
      icon: const Icon(Icons.settings),
      onPressed: onPressed,
      label: const Text('Options'),
    );

/// Builds options button Widget with positioned alignment for the example app.
Widget getOverlayOptionsButton(BuildContext context,
        {required void Function()? onPressed, ButtonStyle? style}) =>
    SafeArea(
      child: Align(
        alignment:
            Platform.isAndroid ? Alignment.bottomCenter : Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: getOptionsButton(context, onPressed: onPressed, style: style),
        ),
      ),
    );
