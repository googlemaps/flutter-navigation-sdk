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

internal class CircleBuilderTest {
  @Test
  fun circleBuilder_returnsExpectedValue() {
    val optionsIn =
      CircleOptionsDto(
        position = LatLngDto(50.0, 60.0),
        radius = 10.0,
        clickable = true,
        fillColor = Color.BLACK.toLong(),
        strokeColor = Color.RED.toLong(),
        strokeWidth = 3.0,
        visible = true,
        strokePattern = emptyList(),
        zIndex = 5.0,
      )
    val builder = CircleBuilder()
    Convert.sinkCircleOptions(optionsIn, builder, 1.0F)
    val optionsOut = builder.build()

    assertEquals(50.0, optionsOut.center.latitude)
    assertEquals(60.0, optionsOut.center.longitude)
    assertEquals(10.0, optionsOut.radius)
    assertEquals(true, optionsOut.isClickable)
    assertEquals(Color.BLACK, optionsOut.fillColor)
    assertEquals(Color.RED, optionsOut.strokeColor)
    assertEquals(emptyList(), optionsOut.strokePattern)
    assertEquals(3F, optionsOut.strokeWidth)
    assertEquals(true, optionsOut.isVisible)
    assertEquals(5F, optionsOut.zIndex)
  }
}
