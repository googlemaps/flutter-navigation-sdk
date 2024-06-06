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

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

const Size _markerSize = Size(80, 80); // Example size in logical pixels

/// Creates a waypoint marker with the given waypoint number and registers it.
///
/// Returns an [ImageDescriptor] for the registered image.
Future<ImageDescriptor> registerWaypointMarkerImage(
    int waypointNumber, double imagePixelRatio) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final _WaypointMarkerPainter painter = _WaypointMarkerPainter(waypointNumber);

  painter.paint(canvas, _markerSize);

  final ui.Image image = await recorder
      .endRecording()
      .toImage(_markerSize.width.floor(), _markerSize.height.floor());

  final ByteData? bytes =
      await image.toByteData(format: ui.ImageByteFormat.png);

  // Call registerBitmapImage with ByteData
  return registerBitmapImage(bitmap: bytes!, imagePixelRatio: imagePixelRatio);
}

class _WaypointMarkerPainter extends CustomPainter {
  _WaypointMarkerPainter(this.waypointNumber);
  final int waypointNumber;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 6.0;

    // Draw the background circle
    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - strokeWidth / 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw the border
    final Paint borderPaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw the waypoint number
    final TextSpan textSpan = TextSpan(
      text: waypointNumber.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 50,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      maxWidth: size.width,
    );
    final Offset textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(_WaypointMarkerPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(_WaypointMarkerPainter oldDelegate) => false;
}
