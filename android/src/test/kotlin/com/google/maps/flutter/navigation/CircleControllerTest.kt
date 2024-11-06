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
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.LatLng
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.verify
import org.junit.Rule
import org.junit.Test

internal class CircleControllerTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK(relaxUnitFun = true) lateinit var circle: Circle

  @Test
  fun circleController_callsExpectedFunctions() {
    val optionsIn =
      CircleOptionsDto(
        position = LatLngDto(50.0, 60.0),
        radius = 10.0,
        clickable = true,
        fillColor = Color.BLACK.toLong(),
        strokePattern = emptyList(),
        strokeColor = Color.RED.toLong(),
        strokeWidth = 3.0,
        visible = true,
        zIndex = 5.0,
      )
    val controller = CircleController(circle, "Circle_0")
    Convert.sinkCircleOptions(optionsIn, controller, 1.0F)

    verify { circle.center = LatLng(50.0, 60.0) }
    verify { circle.radius = 10.0 }
    verify { circle.isClickable = true }
    verify { circle.fillColor = Color.BLACK }
    verify { circle.strokePattern = emptyList() }
    verify { circle.strokeColor = Color.RED }
    verify { circle.strokeWidth = 3F }
    verify { circle.isVisible = true }
    verify { circle.zIndex = 5F }
  }
}
