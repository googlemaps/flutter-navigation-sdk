// Copyright 2026 Google LLC
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

/// Defines a fully custom Android navigation notification.
///
/// Supplying these options replaces the Navigation SDK's built-in turn-by-turn
/// notification. Consequently, turn-by-turn instructions are not shown in the
/// notification. This Android-only configuration is not available on iOS.
/// {@category Navigation}
class NavigationCustomNotificationOptions {
  /// Creates options for a custom Android navigation notification.
  const NavigationCustomNotificationOptions({
    required this.channelId,
    required this.title,
    required this.body,
    this.smallIconResourceName,
    this.color,
    this.resumeAppOnTap = false,
  });

  /// The ID of the Android notification channel.
  ///
  /// The plugin creates a low-importance `Navigation` channel when this channel
  /// does not already exist. Create it in host Android code first to customize
  /// its name, importance, sound, or vibration.
  final String channelId;

  /// The notification title.
  final String title;

  /// The notification body.
  final String body;

  /// Name of a drawable resource in the host app to use as the small icon.
  ///
  /// The application icon is used when null.
  final String? smallIconResourceName;

  /// Optional 32-bit ARGB accent color.
  final int? color;

  /// Whether tapping the notification opens or resumes the application.
  final bool resumeAppOnTap;
}
