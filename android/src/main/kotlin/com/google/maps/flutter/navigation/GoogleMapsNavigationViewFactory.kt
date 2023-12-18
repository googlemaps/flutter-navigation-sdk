/*
 * Copyright 2023 Google LLC
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

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class GoogleMapsNavigationViewFactory(
  private val viewRegistry: GoogleMapsNavigationViewRegistry,
  private val navigationViewEventApi: NavigationViewEventApi,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    val params = NavigationViewCreationOptionsDto.fromList(args as List<Any?>)
    val mapOptions = Convert.convertMapOptionsFromDto(params.mapOptions)
    val navigationViewOptionsDto =
      Convert.convertNavigationViewOptionsFromDto(params.navigationViewOptions)
    return GoogleMapsNavigationView(
      context,
      mapOptions,
      navigationViewOptionsDto,
      viewId,
      viewRegistry,
      navigationViewEventApi
    )
  }
}
