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

String formatRemainingDistance(int meters) {
  if (meters >= 1000) {
    final double kilometers = meters / 1000;
    // Using toStringAsFixed to round to 1 decimal place for kilometers.
    return '${kilometers.toStringAsFixed(1)} km';
  } else {
    return '$meters m';
  }
}
