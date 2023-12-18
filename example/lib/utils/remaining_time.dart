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

String formatRemainingDuration(Duration duration) {
  // Get total number of hours, minutes, and seconds.
  final int hours = duration.inHours;
  final int minutes = duration.inMinutes.remainder(60);
  final int seconds = duration.inSeconds.remainder(60);

  // Build the output based on the conditions.
  if (hours > 0) {
    // When hours are present, format as "HH:MM".
    return '$hours hours $minutes minutes';
  } else if (minutes > 5) {
    // Otherwise, format as "MM" minutes.
    return '$minutes minutes';
  } else if (minutes > 0) {
    // When there are fewer than 5 minutes, format as "MM:SS".
    return '$minutes minutes $seconds seconds';
  } else {
    // When there are fewer than 1 minutes, format as "SS".
    return '$seconds seconds';
  }
}
