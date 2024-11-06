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

internal class PolylineBuilderTest {
  @Test
  fun polylineBuilder_returnsExpectedValue() {
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
    val builder = PolylineBuilder()
    Convert.sinkPolylineOptions(optionsIn, builder, 1.0F)
    val optionsOut = builder.build()

    assertEquals(50.0, optionsOut.points[0].latitude)
    assertEquals(60.0, optionsOut.points[0].longitude)
    assertEquals(80.0, optionsOut.points[1].latitude)
    assertEquals(90.0, optionsOut.points[1].longitude)
    assertEquals(true, optionsOut.isClickable)
    assertEquals(true, optionsOut.isGeodesic)
    assertEquals(Color.RED, optionsOut.color)
    assertEquals(emptyList(), optionsOut.pattern)
    assertEquals(3F, optionsOut.width)
    assertEquals(true, optionsOut.isVisible)
    assertEquals(5F, optionsOut.zIndex)
  }
}
