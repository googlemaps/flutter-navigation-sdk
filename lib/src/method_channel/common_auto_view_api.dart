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

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../google_navigation_flutter.dart';
import '../google_navigation_flutter_platform_interface.dart';
import 'method_channel.dart';

/// @nodoc
/// Class that handles map view and navigation view communications.
mixin CommonAutoMapViewAPI on AutoMapViewAPIInterface {
  final AutoMapViewApi _viewApi = AutoMapViewApi();

  @override
  Future<void> setMapTypeForAuto({required MapType mapType}) {
    return _viewApi.setMapType(mapType.toDto());
  }
}
