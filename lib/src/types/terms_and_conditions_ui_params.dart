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

import 'dart:ui';

import '../method_channel/messages.g.dart';

/// UI customization parameters for the Terms and Conditions dialog.
///
/// Allows customization of the dialog's appearance by specifying custom colors
/// for various UI elements. All color parameters are optional - if not provided,
/// platform defaults will be used.
///
/// Example usage:
/// ```dart
/// final customization = TermsAndConditionsUIParams(
///   backgroundColor: Colors.white,
///   titleColor: Colors.blue,
///   mainTextColor: Colors.black87,
///   acceptButtonTextColor: Colors.green,
///   cancelButtonTextColor: Colors.red,
/// );
///
/// await GoogleMapsNavigator.showTermsAndConditionsDialog(
///   'Terms of Service',
///   'My Company',
///   uiParams: customization,
/// );
/// ```
class TermsAndConditionsUIParams {
  /// Creates a new [TermsAndConditionsUIParams] with the specified colors.
  ///
  /// All parameters are optional. If a parameter is null, the platform default
  /// color will be used for that element.
  const TermsAndConditionsUIParams({
    this.backgroundColor,
    this.titleColor,
    this.mainTextColor,
    this.acceptButtonTextColor,
    this.cancelButtonTextColor,
  });

  /// Background color of the dialog box.
  final Color? backgroundColor;

  /// Text color for the dialog title.
  final Color? titleColor;

  /// Text color for the main terms and conditions text.
  final Color? mainTextColor;

  /// Text color for the accept button.
  final Color? acceptButtonTextColor;

  /// Text color for the cancel button.
  final Color? cancelButtonTextColor;

  /// @nodoc
  /// Converts this [TermsAndConditionsUIParams] to a [TermsAndConditionsUIParamsDto]
  /// for internal use with the platform channels.
  TermsAndConditionsUIParamsDto toDto() {
    return TermsAndConditionsUIParamsDto(
      backgroundColor: backgroundColor?.value,
      titleColor: titleColor?.value,
      mainTextColor: mainTextColor?.value,
      acceptButtonTextColor: acceptButtonTextColor?.value,
      cancelButtonTextColor: cancelButtonTextColor?.value,
    );
  }
}
