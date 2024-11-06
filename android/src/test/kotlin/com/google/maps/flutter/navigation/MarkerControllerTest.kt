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

import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import io.mockk.verify
import kotlin.test.assertEquals
import org.junit.Rule
import org.junit.Test

internal class MarkerControllerTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK(relaxUnitFun = true) lateinit var marker: Marker
  @MockK(relaxUnitFun = true) lateinit var imageRegistry: ImageRegistry
  @MockK(relaxUnitFun = true) lateinit var bitmapDescriptor: BitmapDescriptor

  @Test
  fun markerController_callsExpectedFunctions() {
    every { imageRegistry.findRegisteredImage("default") } returns null
    every { imageRegistry.findRegisteredImage("Image_0") } returns
      RegisteredImage("Image_0", bitmapDescriptor, 1.0, null, null)

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
        zIndex = 2.0,
        icon = ImageDescriptorDto("default", 1.0),
      )
    val controller = MarkerController(marker, "Marker_0", true, 0.1F, 0.2F, 0.3F, 0.4F, null)
    Convert.sinkMarkerOptions(optionsIn, controller, imageRegistry)

    verify { marker.alpha = 0.5F }
    verify { marker.setAnchor(0.1F, 0.2F) }
    verify { marker.isDraggable = true }
    verify { marker.isFlat = true }
    assertEquals(true, controller.consumeTapEvents)
    verify { marker.setInfoWindowAnchor(0.3F, 0.4F) }
    verify { marker.position = LatLng(10.0, 20.0) }
    verify { marker.rotation = 40.0F }
    verify { marker.snippet = "Snippet" }
    verify { marker.title = "Title" }
    verify { marker.isVisible = true }
    verify { marker.zIndex = 2.0F }
    assertEquals(0.1F, controller.anchorU)
    assertEquals(0.2F, controller.anchorV)
    assertEquals(0.3F, controller.infoWindowAnchorU)
    assertEquals(0.4F, controller.infoWindowAnchorV)
    verify { marker.setIcon(null) }

    val optionsWithIcon = optionsIn.copy(icon = ImageDescriptorDto("Image_0", 1.0))
    Convert.sinkMarkerOptions(optionsWithIcon, controller, imageRegistry)
    verify { marker.setIcon(bitmapDescriptor) }
  }
}
