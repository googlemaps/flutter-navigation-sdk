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

import android.graphics.Color
import com.google.android.gms.maps.model.JointType
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Polyline
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.verify
import org.junit.Rule
import org.junit.Test

internal class PolylineControllerTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK(relaxUnitFun = true) lateinit var polyline: Polyline

  @Test
  fun polylineController_callsExpectedFunctions() {
    val optionsIn =
      PolylineOptionsDto(
        points = listOf(LatLngDto(50.0, 60.0), LatLngDto(80.0, 90.0)),
        clickable = true,
        geodesic = true,
        strokeColor = Color.RED.toLong(),
        strokeWidth = 3.0,
        strokeJointType = StrokeJointTypeDto.DEFAULTJOINT,
        visible = true,
        strokePattern = emptyList(),
        zIndex = 5.0,
        spans = emptyList(),
      )
    val controller = PolylineController(polyline, "Polyline_0")
    Convert.sinkPolylineOptions(optionsIn, controller, 1.0F)

    verify { polyline.points = listOf(LatLng(50.0, 60.0), LatLng(80.0, 90.0)) }
    verify { polyline.isClickable = true }
    verify { polyline.isGeodesic = true }
    verify { polyline.color = Color.RED }
    verify { polyline.width = 3F }
    verify { polyline.jointType = JointType.DEFAULT }
    verify { polyline.pattern = emptyList() }
    verify { polyline.isVisible = true }
    verify { polyline.zIndex = 5F }
    verify { polyline.spans = emptyList() }
  }
}
