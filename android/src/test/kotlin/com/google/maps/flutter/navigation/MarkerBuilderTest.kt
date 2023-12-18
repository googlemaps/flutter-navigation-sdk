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

import kotlin.test.assertEquals
import org.junit.Test

internal class MarkerBuilderTest {
  @Test
  fun markerBuilder_returnsExpectedValue() {
    val optionsIn =
      MarkerOptionsDto(
        alpha = 0.5,
        anchor = MarkerAnchorDto(0.1, 0.2),
        draggable = true,
        flat = true,
        consumeTapEvents = true,
        infoWindow = InfoWindowDto(title = "Title", snippet = "Snippet", MarkerAnchorDto(0.3, 0.4)),
        position = LatLngDto(10.0, 20.0),
        rotation = 40.0,
        visible = true,
        zIndex = 2.0
      )
    val builder = MarkerBuilder()
    Convert.sinkMarkerOptions(optionsIn, builder)
    val optionsOut = builder.build()

    assertEquals(0.5F, optionsOut.alpha)
    assertEquals(0.1F, optionsOut.anchorU)
    assertEquals(0.2F, optionsOut.anchorV)
    assertEquals(true, optionsOut.isDraggable)
    assertEquals(true, optionsOut.isFlat)
    assertEquals(true, builder.consumeTapEvents)
    assertEquals(0.3F, optionsOut.infoWindowAnchorU)
    assertEquals(0.4F, optionsOut.infoWindowAnchorV)
    assertEquals(10.0, optionsOut.position.latitude)
    assertEquals(20.0, optionsOut.position.longitude)
    assertEquals(40.0F, optionsOut.rotation)
    assertEquals("Snippet", optionsOut.snippet)
    assertEquals("Title", optionsOut.title)
    assertEquals(true, optionsOut.isVisible)
    assertEquals(2.0F, optionsOut.zIndex)
  }
}
