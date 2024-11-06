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
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Polygon
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.verify
import org.junit.Rule
import org.junit.Test

internal class PolygonControllerTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK(relaxUnitFun = true) lateinit var polygon: Polygon

  @Test
  fun polygonController_callsExpectedFunctions() {
    val optionsIn =
      PolygonOptionsDto(
        points = listOf(LatLngDto(50.0, 60.0)),
        holes = listOf(PolygonHoleDto(listOf(LatLngDto(70.0, 80.0)))),
        clickable = true,
        fillColor = Color.BLACK.toLong(),
        geodesic = true,
        strokeColor = Color.RED.toLong(),
        strokeWidth = 3.0,
        visible = true,
        zIndex = 5.0,
      )
    val controller = PolygonController(polygon, "Polygon_0")
    Convert.sinkPolygonOptions(optionsIn, controller, 1.0F)

    verify { polygon.points = listOf(LatLng(50.0, 60.0)) }
    verify { polygon.holes = listOf(listOf(LatLng(70.0, 80.0))) }
    verify { polygon.isClickable = true }
    verify { polygon.fillColor = Color.BLACK }
    verify { polygon.isGeodesic = true }
    verify { polygon.strokeColor = Color.RED }
    verify { polygon.strokeWidth = 3F }
    verify { polygon.isVisible = true }
    verify { polygon.zIndex = 5F }
  }
}
