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
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.JointType
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.Polygon
import com.google.android.gms.maps.model.Polyline
import com.google.android.libraries.navigation.AlternateRoutesStrategy
import com.google.android.libraries.navigation.NavigationRoadStretchRenderingData
import com.google.android.libraries.navigation.NavigationTrafficData
import com.google.android.libraries.navigation.Navigator.AudioGuidance
import com.google.android.libraries.navigation.Navigator.TaskRemovedBehavior
import com.google.android.libraries.navigation.RoutingOptions.RoutingStrategy
import com.google.android.libraries.navigation.SpeedAlertSeverity
import com.google.android.libraries.navigation.TimeAndDistance
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.junit4.MockKRule
import kotlin.test.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
internal class ConvertTest {
  @get:Rule val mockkRule = MockKRule(this)

  @MockK(relaxUnitFun = true) lateinit var polygon: Polygon

  @MockK(relaxUnitFun = true) lateinit var marker: Marker

  @MockK(relaxUnitFun = true) lateinit var circle: Circle

  @MockK(relaxUnitFun = true) lateinit var polyline: Polyline

  @MockK(relaxUnitFun = true) lateinit var bitmapDescriptor: BitmapDescriptor

  @Test
  fun convertMapType_returnsExpectedValue() {
    assertEquals(GoogleMap.MAP_TYPE_NONE, Convert.convertMapTypeFromDto(MapTypeDto.NONE))
    assertEquals(GoogleMap.MAP_TYPE_NORMAL, Convert.convertMapTypeFromDto(MapTypeDto.NORMAL))
    assertEquals(GoogleMap.MAP_TYPE_SATELLITE, Convert.convertMapTypeFromDto(MapTypeDto.SATELLITE))
    assertEquals(GoogleMap.MAP_TYPE_TERRAIN, Convert.convertMapTypeFromDto(MapTypeDto.TERRAIN))
    assertEquals(GoogleMap.MAP_TYPE_HYBRID, Convert.convertMapTypeFromDto(MapTypeDto.HYBRID))
  }

  @Test
  fun convertGoogleMapType_returnsExpectedValue() {
    assertEquals(MapTypeDto.NONE, Convert.convertMapTypeToDto(GoogleMap.MAP_TYPE_NONE))
    assertEquals(MapTypeDto.NORMAL, Convert.convertMapTypeToDto(GoogleMap.MAP_TYPE_NORMAL))
    assertEquals(MapTypeDto.SATELLITE, Convert.convertMapTypeToDto(GoogleMap.MAP_TYPE_SATELLITE))
    assertEquals(MapTypeDto.TERRAIN, Convert.convertMapTypeToDto(GoogleMap.MAP_TYPE_TERRAIN))
    assertEquals(MapTypeDto.HYBRID, Convert.convertMapTypeToDto(GoogleMap.MAP_TYPE_HYBRID))
  }

  @Test
  fun convertTimeAndDistance_returnsExpectedValue() {
    val timeAndDistance = TimeAndDistance(111, 222)
    val converted = Convert.convertTimeAndDistanceToDto(timeAndDistance)
    assertEquals(111.0, converted.time)
    assertEquals(222.0, converted.distance)
  }

  @Test
  fun convertAudioGuidanceSettings_returnsExpectedValue() {
    assertEquals(
      AudioGuidance.VOICE_ALERTS_AND_GUIDANCE,
      Convert.convertAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettingsDto(
          isBluetoothAudioEnabled = false,
          isVibrationEnabled = false,
          guidanceType = AudioGuidanceTypeDto.ALERTSANDGUIDANCE,
        )
      ),
    )
    assertEquals(
      AudioGuidance.SILENT,
      Convert.convertAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettingsDto(
          isBluetoothAudioEnabled = false,
          isVibrationEnabled = false,
          guidanceType = AudioGuidanceTypeDto.SILENT,
        )
      ),
    )
    assertEquals(
      AudioGuidance.VOICE_ALERTS_ONLY,
      Convert.convertAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettingsDto(
          isBluetoothAudioEnabled = false,
          isVibrationEnabled = false,
          guidanceType = AudioGuidanceTypeDto.ALERTSONLY,
        )
      ),
    )
    assertEquals(
      AudioGuidance.VOICE_ALERTS_AND_GUIDANCE or AudioGuidance.VIBRATION,
      Convert.convertAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettingsDto(
          isBluetoothAudioEnabled = false,
          isVibrationEnabled = true,
          guidanceType = AudioGuidanceTypeDto.ALERTSANDGUIDANCE,
        )
      ),
    )
    assertEquals(
      AudioGuidance.VOICE_ALERTS_AND_GUIDANCE or AudioGuidance.BLUETOOTH_AUDIO,
      Convert.convertAudioGuidanceSettingsToDto(
        NavigationAudioGuidanceSettingsDto(
          isBluetoothAudioEnabled = true,
          isVibrationEnabled = false,
          guidanceType = AudioGuidanceTypeDto.ALERTSANDGUIDANCE,
        )
      ),
    )
  }

  @Test
  fun convertDisplayOptions_returnsExpectedValue() {
    val none = NavigationDisplayOptionsDto()
    val allFalse =
      NavigationDisplayOptionsDto(
        showDestinationMarkers = false,
        showStopSigns = false,
        showTrafficLights = false,
      )
    val allTrue =
      NavigationDisplayOptionsDto(
        showDestinationMarkers = true,
        showStopSigns = true,
        showTrafficLights = true,
      )

    val convertedNone = Convert.convertDisplayOptionsFromDto(none)
    assertEquals(false, convertedNone.showStopSigns)
    assertEquals(false, convertedNone.showTrafficLights)
    assertEquals(false, convertedNone.hideDestinationMarkers)

    val convertedAllFalse = Convert.convertDisplayOptionsFromDto(allFalse)
    assertEquals(false, convertedAllFalse.showStopSigns)
    assertEquals(false, convertedAllFalse.showTrafficLights)
    assertEquals(true, convertedAllFalse.hideDestinationMarkers)

    val convertedAllTrue = Convert.convertDisplayOptionsFromDto(allTrue)
    assertEquals(true, convertedAllTrue.showStopSigns)
    assertEquals(true, convertedAllTrue.showTrafficLights)
    assertEquals(false, convertedAllTrue.hideDestinationMarkers)
  }

  @Test
  fun convertRoutingStrategy_returnsExpectedValue() {
    assertEquals(
      RoutingStrategy.DEFAULT_BEST,
      Convert.convertRoutingStrategyFromDto(RoutingStrategyDto.DEFAULTBEST),
    )
    assertEquals(
      RoutingStrategy.SHORTER,
      Convert.convertRoutingStrategyFromDto(RoutingStrategyDto.SHORTER),
    )
    assertEquals(
      RoutingStrategy.TARGET_DISTANCE,
      Convert.convertRoutingStrategyFromDto(RoutingStrategyDto.DELTATOTARGETDISTANCE),
    )
  }

  @Test
  fun convertAlternateRoutesStrategy_returnsExpectedValue() {
    assertEquals(
      AlternateRoutesStrategy.SHOW_ONE,
      Convert.convertAlternateRoutesStrategyFromDto(AlternateRoutesStrategyDto.ONE),
    )
    assertEquals(
      AlternateRoutesStrategy.SHOW_ALL,
      Convert.convertAlternateRoutesStrategyFromDto(AlternateRoutesStrategyDto.ALL),
    )
    assertEquals(
      AlternateRoutesStrategy.SHOW_NONE,
      Convert.convertAlternateRoutesStrategyFromDto(AlternateRoutesStrategyDto.NONE),
    )
  }

  @Test
  fun convertRoutingOptions_returnsExpectedValue() {
    val options =
      RoutingOptionsDto(
        AlternateRoutesStrategyDto.ONE,
        RoutingStrategyDto.DEFAULTBEST,
        null,
        TravelModeDto.DRIVING,
        avoidTolls = true,
        avoidFerries = true,
        avoidHighways = true,
        locationTimeoutMs = 5000,
      )

    val converted = Convert.convertRoutingOptionsFromDto(options)

    assertEquals(AlternateRoutesStrategy.SHOW_ONE, converted.alternateRoutesStrategy)
    assertEquals(RoutingStrategy.DEFAULT_BEST, converted.routingStrategy)
    assertEquals(true, converted.avoidFerries)
    assertEquals(true, converted.avoidHighways)
    assertEquals(true, converted.avoidTolls)
    assertEquals(5000, converted.locationTimeoutMs)

    val optionsWithTargetDistance =
      RoutingOptionsDto(
        AlternateRoutesStrategyDto.ONE,
        RoutingStrategyDto.DEFAULTBEST,
        listOf(10, 100),
      )

    val convertedWithTargetDistance =
      Convert.convertRoutingOptionsFromDto(optionsWithTargetDistance)

    assertEquals(
      AlternateRoutesStrategy.SHOW_ONE,
      convertedWithTargetDistance.alternateRoutesStrategy,
    )
    assertEquals(RoutingStrategy.TARGET_DISTANCE, convertedWithTargetDistance.routingStrategy)
    assertEquals(listOf(10, 100), convertedWithTargetDistance.targetDistancesMeters)
  }

  @Test
  fun convertSpeedAlertSeverityNativeToPigeon_returnsExpectedValue() {
    assertEquals(
      SpeedAlertSeverityDto.NOTSPEEDING,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverity.NONE),
    )
    assertEquals(
      SpeedAlertSeverityDto.MINOR,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverity.MINOR),
    )
    assertEquals(
      SpeedAlertSeverityDto.MAJOR,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverity.MAJOR),
    )
  }

  @Test
  fun convertSpeedAlertSeverityPigeonToNative_returnsExpectedValue() {
    assertEquals(
      SpeedAlertSeverity.NONE,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.NOTSPEEDING),
    )
    assertEquals(
      SpeedAlertSeverity.MINOR,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.MINOR),
    )
    assertEquals(
      SpeedAlertSeverity.MAJOR,
      Convert.convertSpeedAlertSeverityFromDto(SpeedAlertSeverityDto.MAJOR),
    )
  }

  @Test
  fun convertSpeedAlertOptions_returnsExpectedValue() {
    val testOptions = SpeedAlertOptionsDto(20.0, 40.0, 80.0)

    assertEquals(
      Convert.convertSpeedAlertOptionsFromDto(testOptions)
        .getSpeedAlertThresholdPercentage(SpeedAlertSeverity.MINOR),
      40.0F,
    )
    assertEquals(
      Convert.convertSpeedAlertOptionsFromDto(testOptions)
        .getSpeedAlertThresholdPercentage(SpeedAlertSeverity.MAJOR),
      80.0F,
    )
    assertEquals(
      Convert.convertSpeedAlertOptionsFromDto(testOptions).severityUpgradeDurationSeconds,
      20.0,
    )
  }

  @Test
  fun convertCameraPositionFromDto_returnsExpectedValue() {
    val testCameraPosition =
      CameraPositionDto(
        target = LatLngDto(latitude = 10.0, longitude = 20.0),
        bearing = 1.0,
        tilt = 2.0,
        zoom = 3.0,
      )

    val cameraPosition = Convert.convertCameraPositionFromDto(testCameraPosition)

    assertEquals(cameraPosition.target.latitude, testCameraPosition.target.latitude)

    assertEquals(cameraPosition.target.longitude, testCameraPosition.target.longitude)

    assertEquals(cameraPosition.bearing, testCameraPosition.bearing.toFloat())

    assertEquals(cameraPosition.tilt, testCameraPosition.tilt.toFloat())

    assertEquals(cameraPosition.zoom, testCameraPosition.zoom.toFloat())
  }

  @Test
  fun convertLatLngFromDto_returnsExpectedValue() {
    val testLatLng = LatLngDto(latitude = 10.0, longitude = 20.0)

    val latLng = Convert.convertLatLngFromDto(testLatLng)

    assertEquals(latLng.latitude, testLatLng.latitude)

    assertEquals(latLng.longitude, testLatLng.longitude)
  }

  @Test
  fun convertLatLngBoundsFromDto_returnsExpectedValue() {
    val testLatLngBounds =
      LatLngBoundsDto(
        northeast = LatLngDto(latitude = 30.0, longitude = 20.0),
        southwest = LatLngDto(latitude = 10.0, longitude = 40.0),
      )

    val latLngBounds = Convert.convertLatLngBoundsFromDto(testLatLngBounds)

    assertEquals(latLngBounds.northeast.latitude, testLatLngBounds.northeast.latitude)

    assertEquals(latLngBounds.northeast.longitude, testLatLngBounds.northeast.longitude)

    assertEquals(latLngBounds.southwest.latitude, testLatLngBounds.southwest.latitude)

    assertEquals(latLngBounds.southwest.longitude, testLatLngBounds.southwest.longitude)
  }

  @Test
  fun convertMapOptionsFromDto_returnsExpectedValue() {
    val testOptions =
      MapOptionsDto(
        cameraPosition =
          CameraPositionDto(
            target = LatLngDto(latitude = 10.0, longitude = 20.0),
            bearing = 1.0,
            tilt = 2.0,
            zoom = 3.0,
          ),
        mapType = MapTypeDto.HYBRID,
        compassEnabled = false,
        rotateGesturesEnabled = false,
        scrollGesturesEnabled = false,
        scrollGesturesEnabledDuringRotateOrZoom = false,
        tiltGesturesEnabled = false,
        zoomGesturesEnabled = false,
        mapToolbarEnabled = false,
        cameraTargetBounds =
          LatLngBoundsDto(
            northeast = LatLngDto(latitude = 30.0, longitude = 20.0),
            southwest = LatLngDto(latitude = 10.0, longitude = 40.0),
          ),
        minZoomPreference = 1.1,
        maxZoomPreference = 2.2,
        zoomControlsEnabled = false,
      )

    val mapOptions = Convert.convertMapOptionsFromDto(testOptions)

    assertEquals(
      mapOptions.googleMapOptions.camera.target.latitude,
      testOptions.cameraPosition.target.latitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.camera.target.longitude,
      testOptions.cameraPosition.target.longitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.camera.bearing,
      testOptions.cameraPosition.bearing.toFloat(),
    )

    assertEquals(mapOptions.googleMapOptions.camera.tilt, testOptions.cameraPosition.tilt.toFloat())

    assertEquals(mapOptions.googleMapOptions.camera.zoom, testOptions.cameraPosition.zoom.toFloat())

    assertEquals(mapOptions.googleMapOptions.mapType, GoogleMap.MAP_TYPE_HYBRID)

    assertEquals(mapOptions.googleMapOptions.compassEnabled, testOptions.compassEnabled)

    assertEquals(
      mapOptions.googleMapOptions.scrollGesturesEnabled,
      testOptions.scrollGesturesEnabled,
    )

    assertEquals(mapOptions.googleMapOptions.tiltGesturesEnabled, testOptions.tiltGesturesEnabled)

    assertEquals(mapOptions.googleMapOptions.zoomGesturesEnabled, testOptions.zoomGesturesEnabled)

    assertEquals(
      mapOptions.googleMapOptions.scrollGesturesEnabledDuringRotateOrZoom,
      testOptions.scrollGesturesEnabledDuringRotateOrZoom,
    )

    assertEquals(mapOptions.googleMapOptions.mapToolbarEnabled, testOptions.mapToolbarEnabled)

    assertEquals(
      mapOptions.googleMapOptions.latLngBoundsForCameraTarget.northeast.latitude,
      testOptions.cameraTargetBounds?.northeast?.latitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.latLngBoundsForCameraTarget.northeast.longitude,
      testOptions.cameraTargetBounds?.northeast?.longitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.latLngBoundsForCameraTarget.southwest.latitude,
      testOptions.cameraTargetBounds?.southwest?.latitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.latLngBoundsForCameraTarget.southwest.longitude,
      testOptions.cameraTargetBounds?.southwest?.longitude,
    )

    assertEquals(
      mapOptions.googleMapOptions.minZoomPreference,
      testOptions.minZoomPreference?.toFloat(),
    )

    assertEquals(
      mapOptions.googleMapOptions.maxZoomPreference,
      testOptions.maxZoomPreference?.toFloat(),
    )

    assertEquals(mapOptions.googleMapOptions.zoomControlsEnabled, testOptions.zoomControlsEnabled)

    // Test nullable values
    val testOptions2 =
      testOptions.copy(
        minZoomPreference = null,
        maxZoomPreference = null,
        cameraTargetBounds = null,
      )
    val mapOptions2 = Convert.convertMapOptionsFromDto(testOptions2)

    assertEquals(mapOptions2.googleMapOptions.minZoomPreference, null)

    assertEquals(mapOptions2.googleMapOptions.maxZoomPreference, null)

    assertEquals(mapOptions2.googleMapOptions.latLngBoundsForCameraTarget, null)
  }

  @Test
  fun convertRouteSegmentTrafficData_returnsExpectedValue() {
    var googleRenderingData =
      NavigationRoadStretchRenderingData(NavigationRoadStretchRenderingData.Style.UNKNOWN, 500, 600)
    var googleTrafficData = NavigationTrafficData(listOf(googleRenderingData))
    var trafficData = Convert.convertRouteSegmentTrafficDataToDto(googleTrafficData)

    assertEquals(
      trafficData.roadStretchRenderingDataList[0]!!.lengthMeters,
      googleRenderingData.lengthMeters.toLong(),
    )
    assertEquals(
      trafficData.roadStretchRenderingDataList[0]!!.offsetMeters,
      googleRenderingData.offsetMeters.toLong(),
    )
    assertEquals(
      trafficData.roadStretchRenderingDataList[0]!!.style.toString(),
      googleRenderingData.style.toString(),
    )
  }

  @Test
  fun polygonToPolygonOptions_returnsExpectedValue() {
    every { polygon.points } returns listOf(LatLng(10.0, 20.0))
    every { polygon.holes } returns listOf(listOf(LatLng(30.0, 40.0)))
    every { polygon.isClickable } returns true
    every { polygon.fillColor } returns Color.RED
    every { polygon.isGeodesic } returns true
    every { polygon.strokeColor } returns Color.BLACK
    every { polygon.strokeWidth } returns 2F
    every { polygon.isVisible } returns true
    every { polygon.zIndex } returns 4F
    val options = Convert.polygonToPolygonOptions(polygon, 1.0F)

    assertEquals(10.0, options.points?.get(0)?.latitude)
    assertEquals(20.0, options.points?.get(0)?.longitude)
    assertEquals(true, options.clickable)
    assertEquals(Color.RED.toLong(), options.fillColor)
    assertEquals(true, options.geodesic)
    assertEquals(Color.BLACK.toLong(), options.strokeColor)
    assertEquals(2.0, options.strokeWidth)
    assertEquals(true, options.visible)
    assertEquals(4.0, options.zIndex)
  }

  @Test
  fun markerControllerToMarkerOptions_returnsExpectedValue() {
    val controller = MarkerController(marker, "Marker_01", true, 0.1F, 0.2F, 0.3F, 0.4F, null)
    every { marker.alpha } returns 0.5F
    every { marker.isDraggable } returns true
    every { marker.isFlat } returns true
    every { marker.position } returns LatLng(10.0, 20.0)
    every { marker.rotation } returns 5.0F
    every { marker.title } returns "Title"
    every { marker.snippet } returns "Snippet"
    every { marker.isVisible } returns true
    every { marker.zIndex } returns 3.0F

    val options = Convert.markerControllerToMarkerOptions(controller)

    assertEquals(0.5, options.alpha)
    assertEquals(0.1, options.anchor.u, 0.001)
    assertEquals(0.2, options.anchor.v, 0.001)
    assertEquals(true, options.draggable)
    assertEquals(true, options.flat)
    assertEquals(true, options.consumeTapEvents)
    assertEquals(10.0, options.position.latitude)
    assertEquals(20.0, options.position.longitude)
    assertEquals(5.0, options.rotation)
    assertEquals("Title", options.infoWindow.title)
    assertEquals("Snippet", options.infoWindow.snippet)
    assertEquals(0.3, options.infoWindow.anchor.u, 0.001)
    assertEquals(0.4, options.infoWindow.anchor.v, 0.001)
    assertEquals(true, options.visible)
    assertEquals(3.0, options.zIndex)
  }

  @Test
  fun circleToCircleOptions_returnsExpectedValue() {
    every { circle.center } returns LatLng(10.0, 20.0)
    every { circle.radius } returns 10.0
    every { circle.isClickable } returns true
    every { circle.fillColor } returns Color.RED
    every { circle.strokePattern } returns emptyList()
    every { circle.strokeColor } returns Color.BLACK
    every { circle.strokeWidth } returns 2F
    every { circle.isVisible } returns true
    every { circle.zIndex } returns 4F
    val options = Convert.circleToCircleOptions(circle, 1.0F)

    assertEquals(10.0, options.position.latitude)
    assertEquals(20.0, options.position.longitude)
    assertEquals(10.0, options.radius)
    assertEquals(true, options.clickable)
    assertEquals(Color.RED.toLong(), options.fillColor)
    assertEquals(emptyList(), options.strokePattern)
    assertEquals(Color.BLACK.toLong(), options.strokeColor)
    assertEquals(2.0, options.strokeWidth)
    assertEquals(true, options.visible)
    assertEquals(4.0, options.zIndex)
  }

  @Test
  fun polylineToPolylineOptions_returnsExpectedValue() {
    every { polyline.points } returns listOf(LatLng(10.0, 20.0), LatLng(30.0, 40.0))
    every { polyline.isClickable } returns true
    every { polyline.isGeodesic } returns true
    every { polyline.pattern } returns emptyList()
    every { polyline.color } returns Color.BLACK
    every { polyline.jointType } returns JointType.DEFAULT
    every { polyline.width } returns 2F
    every { polyline.isVisible } returns true
    every { polyline.zIndex } returns 4F
    every { polyline.spans } returns emptyList()

    val options = Convert.polylineToPolylineOptions(polyline, 1.0F)

    assertEquals(10.0, options.points?.get(0)?.latitude)
    assertEquals(20.0, options.points?.get(0)?.longitude)
    assertEquals(30.0, options.points?.get(1)?.latitude)
    assertEquals(40.0, options.points?.get(1)?.longitude)
    assertEquals(true, options.clickable)
    assertEquals(true, options.geodesic)
    assertEquals(emptyList(), options.strokePattern)
    assertEquals(Color.BLACK.toLong(), options.strokeColor)
    assertEquals(2.0, options.strokeWidth)
    assertEquals(StrokeJointTypeDto.DEFAULTJOINT, options.strokeJointType)
    assertEquals(true, options.visible)
    assertEquals(4.0, options.zIndex)
    assertEquals(emptyList(), options.spans)
  }

  @Test
  fun convertRegisteredImageToImageIdDto_returnsExpectedValue() {
    val registeredImage = RegisteredImage("Image_0", bitmapDescriptor, 1.0, 10.0, 20.0)
    val imageDescriptor = Convert.registeredImageToImageDescriptorDto(registeredImage)

    assertEquals("Image_0", imageDescriptor.registeredImageId)
    assertEquals(1.0, imageDescriptor.imagePixelRatio)
    assertEquals(10.0, imageDescriptor.width)
    assertEquals(20.0, imageDescriptor.height)
  }

  @Test
  fun taskRemovedBehaviorDtoToTaskRemovedBehavior_returnsExpectedValue() {
    assertEquals(
      TaskRemovedBehavior.QUIT_SERVICE,
      Convert.taskRemovedBehaviorDtoToTaskRemovedBehavior(TaskRemovedBehaviorDto.QUITSERVICE),
    )
    assertEquals(
      TaskRemovedBehavior.CONTINUE_SERVICE,
      Convert.taskRemovedBehaviorDtoToTaskRemovedBehavior(TaskRemovedBehaviorDto.CONTINUESERVICE),
    )
    assertEquals(
      TaskRemovedBehavior.CONTINUE_SERVICE,
      Convert.taskRemovedBehaviorDtoToTaskRemovedBehavior(null),
    )
  }
}
