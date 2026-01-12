/*
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.maps.flutter.navigation

/**
 * Options for configuring Android Auto map views. Contains only settings relevant for Android Auto
 * views.
 */
public data class AutoMapViewOptions(
  /** The initial camera position for the map view. */
  val cameraPosition: CameraPositionDto? = null,

  /** Cloud-based map ID for custom styling. */
  val mapId: String? = null,

  /** The type of map to display. */
  val mapType: Int? = null,

  /** The color scheme for the map. */
  val mapColorScheme: Int? = null,

  /** Forces night mode regardless of system settings. */
  val forceNightMode: Int? = null,
)
