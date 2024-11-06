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
import kotlin.test.assertEquals
import org.junit.Test

internal class PolygonBuilderTest {
  @Test
  fun polygonBuilder_returnsExpectedValue() {
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
    val builder = PolygonBuilder()
    Convert.sinkPolygonOptions(optionsIn, builder, 1.0F)
    val optionsOut = builder.build()

    assertEquals(50.0, optionsOut.points[0].latitude)
    assertEquals(60.0, optionsOut.points[0].longitude)
    assertEquals(70.0, optionsOut.holes[0][0].latitude)
    assertEquals(80.0, optionsOut.holes[0][0].longitude)
    assertEquals(true, optionsOut.isClickable)
    assertEquals(Color.BLACK, optionsOut.fillColor)
    assertEquals(true, optionsOut.isGeodesic)
    assertEquals(Color.RED, optionsOut.strokeColor)
    assertEquals(3F, optionsOut.strokeWidth)
    assertEquals(true, optionsOut.isVisible)
    assertEquals(5F, optionsOut.zIndex)
  }
}
