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
import 'dart:ui';

int? colorToInt(Color? color) {
  if (color == null) {
    return null;
  }

  int floatToInt8(double x) => (x * 255.0).round() & 0xff;

  return (floatToInt8(color.a) << 24) |
      (floatToInt8(color.r) << 16) |
      (floatToInt8(color.g) << 8) |
      (floatToInt8(color.b));
}
