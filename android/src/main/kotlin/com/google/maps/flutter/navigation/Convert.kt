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

import android.content.res.Resources
import android.graphics.Point
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.Circle
import com.google.android.gms.maps.model.Dash
import com.google.android.gms.maps.model.Dot
import com.google.android.gms.maps.model.Gap
import com.google.android.gms.maps.model.JointType
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.android.gms.maps.model.PatternItem
import com.google.android.gms.maps.model.Polygon
import com.google.android.gms.maps.model.Polyline
import com.google.android.gms.maps.model.StrokeStyle
import com.google.android.gms.maps.model.StyleSpan
import com.google.android.libraries.mapsplatform.turnbyturn.model.DrivingSide
import com.google.android.libraries.mapsplatform.turnbyturn.model.LaneDirection.LaneShape
import com.google.android.libraries.mapsplatform.turnbyturn.model.Maneuver
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavState
import com.google.android.libraries.mapsplatform.turnbyturn.model.StepInfo
import com.google.android.libraries.navigation.AlternateRoutesStrategy
import com.google.android.libraries.navigation.DisplayOptions
import com.google.android.libraries.navigation.NavigationRoadStretchRenderingData
import com.google.android.libraries.navigation.NavigationTrafficData
import com.google.android.libraries.navigation.Navigator
import com.google.android.libraries.navigation.Navigator.AudioGuidance
import com.google.android.libraries.navigation.Navigator.TaskRemovedBehavior
import com.google.android.libraries.navigation.RouteSegment
import com.google.android.libraries.navigation.RoutingOptions
import com.google.android.libraries.navigation.RoutingOptions.RoutingStrategy
import com.google.android.libraries.navigation.SpeedAlertOptions
import com.google.android.libraries.navigation.SpeedAlertSeverity
import com.google.android.libraries.navigation.TimeAndDistance
import com.google.android.libraries.navigation.Waypoint

/** Converters from and to Pigeon generated values. */
object Convert {
  /**
   * Converts pigeon [NavigationViewCreationOptionsDto] to [GoogleMapOptions].
   *
   * @param options pigeon message [NavigationViewCreationOptionsDto].
   * @return Google Map Options [GoogleMapOptions].
   */
  fun convertMapOptionsFromDto(options: MapOptionsDto): MapOptions {
    val googleMapOptions = GoogleMapOptions()

    googleMapOptions.camera(convertCameraPositionFromDto(options.cameraPosition))
    googleMapOptions.mapType(convertMapTypeFromDto(options.mapType))
    googleMapOptions.compassEnabled(options.compassEnabled)
    googleMapOptions.rotateGesturesEnabled(options.rotateGesturesEnabled)
    googleMapOptions.scrollGesturesEnabled(options.scrollGesturesEnabled)
    googleMapOptions.tiltGesturesEnabled(options.tiltGesturesEnabled)
    googleMapOptions.zoomGesturesEnabled(options.zoomGesturesEnabled)
    googleMapOptions.scrollGesturesEnabledDuringRotateOrZoom(
      options.scrollGesturesEnabledDuringRotateOrZoom
    )
    googleMapOptions.mapToolbarEnabled(options.mapToolbarEnabled)
    options.cameraTargetBounds?.let {
      googleMapOptions.latLngBoundsForCameraTarget(convertLatLngBoundsFromDto(it))
    }
    options.minZoomPreference?.let { googleMapOptions.minZoomPreference(it.toFloat()) }
    options.maxZoomPreference?.let { googleMapOptions.maxZoomPreference(it.toFloat()) }
    googleMapOptions.zoomControlsEnabled(options.zoomControlsEnabled)

    return MapOptions(googleMapOptions, options.padding)
  }

  /**
   * Converts pigeon [NavigationUIEnabledPreferenceDto] to [NavigationUIEnabledPreference].
   *
   * @param preference pigeon [NavigationUIEnabledPreferenceDto].
   * @return [NavigationUIEnabledPreference].
   */
  private fun convertNavigationUIEnabledPreferenceFromDto(
    preference: NavigationUIEnabledPreferenceDto
  ): NavigationUIEnabledPreference {
    return when (preference) {
      NavigationUIEnabledPreferenceDto.AUTOMATIC -> NavigationUIEnabledPreference.AUTOMATIC
      NavigationUIEnabledPreferenceDto.DISABLED -> NavigationUIEnabledPreference.DISABLED
    }
  }

  /**
   * Converts pigeon [NavigationViewOptionsDto] to [NavigationViewOptions].
   *
   * @param options pigeon message [NavigationViewOptionsDto].
   * @return [NavigationViewOptions].
   */
  fun convertNavigationViewOptionsFromDto(
    options: NavigationViewOptionsDto
  ): NavigationViewOptions {

    return NavigationViewOptions(
      navigationUiEnabledPreference =
        convertNavigationUIEnabledPreferenceFromDto(options.navigationUIEnabledPreference)
    )
  }

  /**
   * Converts pigeon [MapTypeDto] to GoogleMap [Int].
   *
   * @param mapType pigeon [MapTypeDto].
   * @return GoogleMap.MAP_TYPE [Int].
   */
  fun convertMapTypeFromDto(mapType: MapTypeDto): Int {
    return when (mapType) {
      MapTypeDto.NONE -> GoogleMap.MAP_TYPE_NONE
      MapTypeDto.NORMAL -> GoogleMap.MAP_TYPE_NORMAL
      MapTypeDto.SATELLITE -> GoogleMap.MAP_TYPE_SATELLITE
      MapTypeDto.TERRAIN -> GoogleMap.MAP_TYPE_TERRAIN
      MapTypeDto.HYBRID -> GoogleMap.MAP_TYPE_HYBRID
    }
  }

  fun convertCameraPerspectiveFromDto(perspective: CameraPerspectiveDto): Int {
    return when (perspective) {
      CameraPerspectiveDto.TILTED -> GoogleMap.CameraPerspective.TILTED
      CameraPerspectiveDto.TOPDOWNHEADINGUP -> GoogleMap.CameraPerspective.TOP_DOWN_HEADING_UP
      CameraPerspectiveDto.TOPDOWNNORTHUP -> GoogleMap.CameraPerspective.TOP_DOWN_NORTH_UP
    }
  }

  /**
   * Converts Google Navigation [CameraPosition] to Pigeon [CameraPositionDto].
   *
   * @param position Google Navigation [CameraPosition].
   * @return pigeon [CameraPositionDto].
   */
  fun convertCameraPositionToDto(position: CameraPosition): CameraPositionDto {
    return CameraPositionDto(
      position.bearing.toDouble(),
      LatLngDto(position.target.latitude, position.target.longitude),
      position.tilt.toDouble(),
      position.zoom.toDouble(),
    )
  }

  /**
   * Converts Pigeon [CameraPositionDto] to Google Navigation [CameraPosition].
   *
   * @param position Pigeon [CameraPositionDto].
   * @return Google Navigation [CameraPosition].
   */
  fun convertCameraPositionFromDto(position: CameraPositionDto): CameraPosition {
    return CameraPosition(
      convertLatLngFromDto(position.target),
      position.zoom.toFloat(),
      position.tilt.toFloat(),
      position.bearing.toFloat(),
    )
  }

  /**
   * Converts delta co-ordinates to Android [Point].
   *
   * @param dx Delta on x-axis
   * @param dy Delta ony-axis
   * @return Android [Point].
   */
  fun convertDeltaToPoint(dx: Double?, dy: Double?): Point? {
    val density = Resources.getSystem().displayMetrics.density
    var focus: Point? = null
    if (dx != null && dy != null) {
      focus =
        Point(
          convertLogicalToScreenPixel(dx, density).toInt(),
          convertLogicalToScreenPixel(dy, density).toInt(),
        )
    }
    return focus
  }

  /**
   * Converts Pigeon [LatLngDto] to Google Maps [LatLng].
   *
   * @param point Pigeon [LatLngDto].
   * @return Google Maps [LatLng].
   */
  fun convertLatLngFromDto(point: LatLngDto): LatLng {
    return LatLng(point.latitude, point.longitude)
  }

  /**
   * Converts Google Maps [LatLng] to Pigeon [LatLngDto].
   *
   * @param point Google Maps [LatLng].
   * @return Pigeon [LatLngDto].
   */
  private fun convertLatLngToDto(point: LatLng): LatLngDto {
    return LatLngDto(point.latitude, point.longitude)
  }

  /**
   * Converts logical pixel co-ordinates to screen pixels.
   *
   * @param value Screen pixel value.
   * @param value Pixel density ratio used to calculate the logical pixel value.
   * @return Logical pixel value.
   */
  fun convertLogicalToScreenPixel(value: Double, density: Float): Double {
    return density * value
  }

  /**
   * Converts screen pixel co-ordinates to logical pixels.
   *
   * @param value Screen pixel value.
   * @param value Pixel density ratio used to calculate the screen pixel value.
   * @return Logical pixel value.
   */
  private fun convertScreenToLogicalPixel(value: Double, density: Float): Double {
    return value / density
  }

  /**
   * Converts Pigeon [LatLngBoundsDto] to Google Maps [LatLngBounds].
   *
   * @param bounds Pigeon [LatLngBoundsDto].
   * @return Google Maps [LatLngBounds].
   */
  fun convertLatLngBoundsFromDto(bounds: LatLngBoundsDto): LatLngBounds {
    return LatLngBounds(
      convertLatLngFromDto(bounds.southwest),
      convertLatLngFromDto(bounds.northeast),
    )
  }

  /**
   * Converts Google Maps [LatLngBounds] to Pigeon [LatLngBoundsDto].
   *
   * @param bounds Google Maps [LatLngBounds].
   * @return Pigeon [LatLngBoundsDto].
   */
  fun convertLatLngBoundsToDto(bounds: LatLngBounds): LatLngBoundsDto {
    return LatLngBoundsDto(
      convertLatLngToDto(bounds.southwest),
      convertLatLngToDto(bounds.northeast),
    )
  }

  /**
   * Converts GoogleMap [Int] to pigeon [MapTypeDto].
   *
   * @param googleMapType [Int].
   * @return pigeon [MapTypeDto].
   */
  fun convertMapTypeToDto(googleMapType: Int): MapTypeDto {
    return when (googleMapType) {
      GoogleMap.MAP_TYPE_NONE -> MapTypeDto.NONE
      GoogleMap.MAP_TYPE_NORMAL -> MapTypeDto.NORMAL
      GoogleMap.MAP_TYPE_SATELLITE -> MapTypeDto.SATELLITE
      GoogleMap.MAP_TYPE_TERRAIN -> MapTypeDto.TERRAIN
      GoogleMap.MAP_TYPE_HYBRID -> MapTypeDto.HYBRID
      else -> {
        MapTypeDto.NONE
      }
    }
  }

  /**
   * Converts pigeon [NavigationWaypointDto] to Google Navigation [Waypoint].
   *
   * @param waypoint pigeon [NavigationWaypointDto].
   * @return Google Navigation [Waypoint].
   */
  fun convertWaypointFromDto(waypoint: NavigationWaypointDto): Waypoint {
    val builder = Waypoint.builder()
    if (waypoint.target != null) {
      builder.setLatLng(waypoint.target.latitude, waypoint.target.longitude)
    }
    if (waypoint.preferSameSideOfRoad == true) {
      builder.setPreferSameSideOfRoad(true)
    }
    if (waypoint.preferredSegmentHeading != null) {
      builder.setPreferredHeading(waypoint.preferredSegmentHeading.toInt())
    }
    if (waypoint.placeID != null) {
      builder.setPlaceIdString(waypoint.placeID)
    }
    builder.setTitle(waypoint.title)
    return builder.build()
  }

  /**
   * Converts Google Navigation [Waypoint] to pigeon [NavigationWaypointDto].
   *
   * @param waypoint Google Navigation [Waypoint].
   * @return pigeon [NavigationWaypointDto].
   */
  fun convertWaypointToDto(waypoint: Waypoint): NavigationWaypointDto {
    return NavigationWaypointDto(
      waypoint.title,
      convertLatLngToDto(waypoint.position),
      waypoint.placeId,
      waypoint.preferSameSideOfRoad,
      waypoint.preferredHeading.takeIf { it != -1 }?.toLong(),
    )
  }

  /**
   * Converts Google Navigation [TimeAndDistance] to pigeon [NavigationTimeAndDistanceDto].
   *
   * @param timeAndDistance Google Navigation [TimeAndDistance].
   * @return pigeon [NavigationTimeAndDistanceDto].
   */
  fun convertTimeAndDistanceToDto(timeAndDistance: TimeAndDistance): NavigationTimeAndDistanceDto {
    return NavigationTimeAndDistanceDto(
      timeAndDistance.seconds.toDouble(),
      timeAndDistance.meters.toDouble(),
    )
  }

  /**
   * Converts pigeon [NavigationAudioGuidanceSettingsDto] to Google Navigation AudioGuidance [Int].
   *
   * @param settings pigeon [NavigationAudioGuidanceSettingsDto].
   * @return Google Navigation [AudioGuidanceTypeDto] int.
   */
  fun convertAudioGuidanceSettingsToDto(settings: NavigationAudioGuidanceSettingsDto): Int {
    var base =
      when (settings.guidanceType) {
        AudioGuidanceTypeDto.SILENT -> AudioGuidance.SILENT
        AudioGuidanceTypeDto.ALERTSONLY -> AudioGuidance.VOICE_ALERTS_ONLY
        AudioGuidanceTypeDto.ALERTSANDGUIDANCE -> AudioGuidance.VOICE_ALERTS_AND_GUIDANCE
        null -> AudioGuidance.SILENT
      }
    if (settings.isBluetoothAudioEnabled == true) {
      base = base or AudioGuidance.BLUETOOTH_AUDIO
    }
    if (settings.isVibrationEnabled == true) {
      base = base or AudioGuidance.VIBRATION
    }
    return base
  }

  /**
   * Converts pigeon [NavigationDisplayOptionsDto] to Google Navigation [DisplayOptions].
   *
   * @param displayOptions pigeon [NavigationDisplayOptionsDto].
   * @return Google Navigation [DisplayOptions].
   */
  fun convertDisplayOptionsFromDto(displayOptions: NavigationDisplayOptionsDto): DisplayOptions {
    return DisplayOptions().apply {
      if (displayOptions.showDestinationMarkers != null) {
        this.hideDestinationMarkers(!displayOptions.showDestinationMarkers)
      }
      if (displayOptions.showStopSigns != null) {
        this.showStopSigns(displayOptions.showStopSigns)
      }
      if (displayOptions.showTrafficLights != null) {
        this.showTrafficLights(displayOptions.showTrafficLights)
      }
    }
  }

  /**
   * Converts pigeon [RoutingStrategyDto] to Google Navigation RoutingStrategy [Int].
   *
   * @param routingStrategy pigeon [RoutingStrategyDto].
   * @return Google Navigation [RoutingStrategy] int.
   */
  fun convertRoutingStrategyFromDto(routingStrategy: RoutingStrategyDto): Int {
    return when (routingStrategy) {
      RoutingStrategyDto.DEFAULTBEST -> RoutingStrategy.DEFAULT_BEST
      RoutingStrategyDto.DELTATOTARGETDISTANCE -> RoutingStrategy.TARGET_DISTANCE
      RoutingStrategyDto.SHORTER -> RoutingStrategy.SHORTER
    }
  }

  /**
   * Converts pigeon [AlternateRoutesStrategyDto] to Google Navigation [AlternateRoutesStrategy].
   *
   * @param alternateRoutesStrategy pigeon [AlternateRoutesStrategyDto].
   * @return Google Navigation [AlternateRoutesStrategy].
   */
  fun convertAlternateRoutesStrategyFromDto(
    alternateRoutesStrategy: AlternateRoutesStrategyDto
  ): AlternateRoutesStrategy {
    return when (alternateRoutesStrategy) {
      AlternateRoutesStrategyDto.ALL -> AlternateRoutesStrategy.SHOW_ALL
      AlternateRoutesStrategyDto.NONE -> AlternateRoutesStrategy.SHOW_NONE
      AlternateRoutesStrategyDto.ONE -> AlternateRoutesStrategy.SHOW_ONE
    }
  }

  /**
   * Converts pigeon [TravelModeDto] to Google Navigation [@RoutingOptions.TravelMode Int].
   *
   * @param travelMode pigeon [TravelModeDto].
   * @return Google Navigation [@RoutingOptions.TravelMode Int].
   */
  fun convertTravelModeFromDto(travelMode: TravelModeDto): Int {
    return when (travelMode) {
      TravelModeDto.CYCLING -> RoutingOptions.TravelMode.CYCLING
      TravelModeDto.DRIVING -> RoutingOptions.TravelMode.DRIVING
      TravelModeDto.WALKING -> RoutingOptions.TravelMode.WALKING
      TravelModeDto.TWOWHEELER -> RoutingOptions.TravelMode.TWO_WHEELER
      TravelModeDto.TAXI -> RoutingOptions.TravelMode.TAXI
    }
  }

  /**
   * Converts pigeon [RoutingOptionsDto] to Google Navigation [RoutingOptions].
   *
   * @param routingOptions pigeon [RoutingOptionsDto].
   * @return Google Navigation [RoutingOptions].
   */
  fun convertRoutingOptionsFromDto(routingOptions: RoutingOptionsDto): RoutingOptions {
    return RoutingOptions().apply {
      if (routingOptions.alternateRoutesStrategy != null) {
        this.alternateRoutesStrategy(
          convertAlternateRoutesStrategyFromDto(routingOptions.alternateRoutesStrategy)
        )
      }
      if (routingOptions.routingStrategy != null) {
        this.routingStrategy(convertRoutingStrategyFromDto(routingOptions.routingStrategy))
      }
      if (routingOptions.targetDistanceMeters != null) {
        val distances = routingOptions.targetDistanceMeters.filterNotNull().map { it.toInt() }
        this.targetDistancesMeters(distances)
      }
      if (routingOptions.avoidFerries != null) {
        this.avoidFerries(routingOptions.avoidFerries)
      }
      if (routingOptions.avoidTolls != null) {
        this.avoidTolls(routingOptions.avoidTolls)
      }
      if (routingOptions.avoidHighways != null) {
        this.avoidHighways(routingOptions.avoidHighways)
      }
      if (routingOptions.locationTimeoutMs != null) {
        this.locationTimeoutMs(routingOptions.locationTimeoutMs)
      }
      if (routingOptions.travelMode != null) {
        this.travelMode(convertTravelModeFromDto(routingOptions.travelMode))
      }
    }
  }

  /**
   * Converts Google Navigation [Navigator.RouteStatus] to pigeon [RouteStatusDto]
   *
   * @param status Google Navigation [Navigator.RouteStatus]
   * @return pigeon [RouteStatusDto]
   */
  fun convertRouteStatusToDto(status: Navigator.RouteStatus): RouteStatusDto {
    return when (status) {
      Navigator.RouteStatus.NO_ROUTE_FOUND -> RouteStatusDto.ROUTENOTFOUND
      Navigator.RouteStatus.ROUTE_CANCELED -> RouteStatusDto.STATUSCANCELED
      Navigator.RouteStatus.LOCATION_DISABLED -> RouteStatusDto.LOCATIONUNAVAILABLE
      Navigator.RouteStatus.LOCATION_UNKNOWN -> RouteStatusDto.LOCATIONUNKNOWN
      Navigator.RouteStatus.NETWORK_ERROR -> RouteStatusDto.NETWORKERROR
      Navigator.RouteStatus.OK -> RouteStatusDto.STATUSOK
      Navigator.RouteStatus.QUOTA_CHECK_FAILED -> RouteStatusDto.QUOTACHECKFAILED
      Navigator.RouteStatus.WAYPOINT_ERROR -> RouteStatusDto.WAYPOINTERROR
    }
  }

  /**
   * Converts Google Navigation [SpeedAlertSeverity] to pigeon [SpeedAlertSeverityDto]
   *
   * @param severity Google Navigation [SpeedAlertSeverity]
   * @return pigeon [SpeedAlertSeverityDto]
   */
  fun convertSpeedAlertSeverityFromDto(severity: SpeedAlertSeverity): SpeedAlertSeverityDto {
    return when (severity) {
      SpeedAlertSeverity.NONE -> SpeedAlertSeverityDto.NOTSPEEDING
      SpeedAlertSeverity.MINOR -> SpeedAlertSeverityDto.MINOR
      SpeedAlertSeverity.MAJOR -> SpeedAlertSeverityDto.MAJOR
    }
  }

  /**
   * Converts pigeon [SpeedAlertSeverityDto] to Google Navigation [SpeedAlertSeverity].
   *
   * @param severity pigeon [SpeedAlertSeverityDto].
   * @return Google Navigation [SpeedAlertSeverity].
   */
  fun convertSpeedAlertSeverityFromDto(severity: SpeedAlertSeverityDto): SpeedAlertSeverity {
    return when (severity) {
      SpeedAlertSeverityDto.NOTSPEEDING -> SpeedAlertSeverity.NONE
      SpeedAlertSeverityDto.MINOR -> SpeedAlertSeverity.MINOR
      SpeedAlertSeverityDto.MAJOR -> SpeedAlertSeverity.MAJOR
      SpeedAlertSeverityDto.UNKNOWN -> SpeedAlertSeverity.NONE
    }
  }

  /**
   * Converts pigeon [SpeedAlertOptionsDto] to Google Navigation [SpeedAlertOptions].
   *
   * @param options pigeon [SpeedAlertOptionsDto].
   * @return Google Navigation [SpeedAlertOptions].
   */
  fun convertSpeedAlertOptionsFromDto(options: SpeedAlertOptionsDto): SpeedAlertOptions {
    return SpeedAlertOptions.Builder()
      .setSeverityUpgradeDurationSeconds(options.severityUpgradeDurationSeconds)
      .setSpeedAlertThresholdPercentage(
        SpeedAlertSeverity.MINOR,
        options.minorSpeedAlertThresholdPercentage.toFloat(),
      )
      .setSpeedAlertThresholdPercentage(
        SpeedAlertSeverity.MAJOR,
        options.majorSpeedAlertThresholdPercentage.toFloat(),
      )
      .build()
  }

  /**
   * Set pigeon [MarkerOptionsDto] to [MarkerOptionsSink] instance.
   *
   * @param markerOptions pigeon [MarkerOptionsDto].
   */
  fun sinkMarkerOptions(
    markerOptions: MarkerOptionsDto,
    sink: MarkerOptionsSink,
    imageRegistry: ImageRegistry,
  ) {
    sink.setAlpha(markerOptions.alpha.toFloat())
    sink.setAnchor(markerOptions.anchor.u.toFloat(), markerOptions.anchor.v.toFloat())
    sink.setDraggable(markerOptions.draggable)
    sink.setFlat(markerOptions.flat)
    sink.setConsumeTapEvents(markerOptions.consumeTapEvents)
    sink.setInfoWindowAnchor(
      markerOptions.infoWindow.anchor.u.toFloat(),
      markerOptions.infoWindow.anchor.v.toFloat(),
    )
    sink.setPosition(LatLng(markerOptions.position.latitude, markerOptions.position.longitude))
    sink.setRotation(markerOptions.rotation.toFloat())
    sink.setSnippet(markerOptions.infoWindow.snippet)
    sink.setTitle(markerOptions.infoWindow.title)
    sink.setVisible(markerOptions.visible)
    sink.setZIndex(markerOptions.zIndex.toFloat())
    markerOptions.icon.registeredImageId?.let {
      val registeredImage = imageRegistry.findRegisteredImage(it)
      sink.setIcon(registeredImage)
    } ?: run { sink.setIcon(null) }
  }

  fun convertRouteSegmentTrafficDataToDto(
    trafficData: NavigationTrafficData
  ): RouteSegmentTrafficDataDto {
    val status =
      when (trafficData.status) {
        NavigationTrafficData.Status.OK -> RouteSegmentTrafficDataStatusDto.OK
        NavigationTrafficData.Status.UNAVAILABLE -> RouteSegmentTrafficDataStatusDto.UNAVAILABLE
        null -> {
          // Should never happen, added to suppress compiler warning.
          throw FlutterError("nullTrafficDataStatus", "Traffic data status is null")
        }
      }

    return RouteSegmentTrafficDataDto(
      status,
      trafficData.roadStretchRenderingDataList.map {
        val style =
          when (it.style) {
            NavigationRoadStretchRenderingData.Style.SLOWER_TRAFFIC ->
              RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto.SLOWERTRAFFIC
            NavigationRoadStretchRenderingData.Style.TRAFFIC_JAM ->
              RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto.TRAFFICJAM
            NavigationRoadStretchRenderingData.Style.UNKNOWN ->
              RouteSegmentTrafficDataRoadStretchRenderingDataStyleDto.UNKNOWN
            null -> {
              // Should never happen, added to suppress compiler warning.
              throw FlutterError(
                "nullTrafficDataRoadStretchRenderingDataListStyle",
                "Traffic data road stretch rendering data list style is null",
              )
            }
          }
        RouteSegmentTrafficDataRoadStretchRenderingDataDto(
          style,
          it.lengthMeters.toLong(),
          it.offsetMeters.toLong(),
        )
      },
    )
  }

  fun convertRouteSegmentToDto(segment: RouteSegment): RouteSegmentDto {
    return RouteSegmentDto(
      convertRouteSegmentTrafficDataToDto(segment.trafficData),
      LatLngDto(segment.destinationLatLng.latitude, segment.destinationLatLng.longitude),
      segment.latLngs.map { LatLngDto(it.latitude, it.longitude) },
      convertWaypointToDto(segment.destinationWaypoint),
    )
  }

  /**
   * Set pigeon [PolygonOptionsDto] to [PolygonOptionsSink] instance.
   *
   * @param polygonOptions pigeon [PolygonOptionsDto].
   */
  fun sinkPolygonOptions(
    polygonOptions: PolygonOptionsDto,
    sink: PolygonOptionsSink,
    density: Float,
  ) {
    sink.setPoints(polygonOptions.points.filterNotNull().map { LatLng(it.latitude, it.longitude) })
    sink.setHoles(
      polygonOptions.holes.filterNotNull().map {
        it.points.filterNotNull().map { latLng -> LatLng(latLng.latitude, latLng.longitude) }
      }
    )
    sink.setClickable(polygonOptions.clickable)
    sink.setFillColor(polygonOptions.fillColor.toInt())
    sink.setGeodesic(polygonOptions.geodesic)
    sink.setStrokeColor(polygonOptions.strokeColor.toInt())
    sink.setStrokeWidth(convertLogicalToScreenPixel(polygonOptions.strokeWidth, density).toFloat())
    sink.setVisible(polygonOptions.visible)
    sink.setZIndex(polygonOptions.zIndex.toFloat())
  }

  /**
   * Get all options from [Polygon] instance and create [PolygonOptionsDto].
   *
   * @param polygon [Polygon] instance.
   * @return [PolygonOptionsDto] with parameters set from [Polygon] instance.
   */
  fun polygonToPolygonOptions(polygon: Polygon, density: Float): PolygonOptionsDto {
    return PolygonOptionsDto(
      points = polygon.points.map { LatLngDto(it.latitude, it.longitude) },
      holes =
        polygon.holes.map { hole ->
          PolygonHoleDto(hole.map { LatLngDto(it.latitude, it.longitude) })
        },
      clickable = polygon.isClickable,
      fillColor = polygon.fillColor.toLong(),
      geodesic = polygon.isGeodesic,
      strokeWidth = convertScreenToLogicalPixel(polygon.strokeWidth.toDouble(), density),
      strokeColor = polygon.strokeColor.toLong(),
      visible = polygon.isVisible,
      zIndex = polygon.zIndex.toDouble(),
    )
  }

  /**
   * Get all options from [MarkerController] instance and create [MarkerOptionsDto].
   *
   * @param markerController [MarkerController] instance.
   * @return [MarkerOptionsDto] with parameters set from [MarkerController] instance.
   */
  fun markerControllerToMarkerOptions(markerController: MarkerController): MarkerOptionsDto {
    val marker = markerController.marker
    return MarkerOptionsDto(
      alpha = marker.alpha.toDouble(),
      anchor =
        MarkerAnchorDto(markerController.anchorU.toDouble(), markerController.anchorV.toDouble()),
      draggable = marker.isDraggable,
      flat = marker.isFlat,
      consumeTapEvents = markerController.consumeTapEvents,
      position = LatLngDto(marker.position.latitude, marker.position.longitude),
      rotation = marker.rotation.toDouble(),
      infoWindow =
        InfoWindowDto(
          marker.title,
          marker.snippet,
          MarkerAnchorDto(
            markerController.infoWindowAnchorU.toDouble(),
            markerController.infoWindowAnchorV.toDouble(),
          ),
        ),
      visible = marker.isVisible,
      zIndex = marker.zIndex.toDouble(),
      icon = registeredImageToImageDescriptorDto(markerController.registeredImage),
    )
  }

  /**
   * Convert pigeon [StyleSpanDto] to google maps [StyleSpan].
   *
   * @param span pigeon [StyleSpanDto].
   * @return google maps [StyleSpan].
   */
  private fun convertStyleSpan(span: StyleSpanDto): StyleSpan? {
    if (span.style.solidColor != null) {
      return StyleSpan(span.style.solidColor.toInt(), span.length)
    }
    if (span.style.toColor != null && span.style.fromColor != null) {
      return StyleSpan(
        StrokeStyle.gradientBuilder(span.style.fromColor.toInt(), span.style.toColor.toInt())
          .build(),
        span.length,
      )
    }
    return null
  }

  /**
   * Convert google maps [StyleSpan] to pigeon [StyleSpanDto].
   *
   * @param span google maps [StyleSpan].
   * @return pigeon [StyleSpanDto].
   */
  private fun convertStyleSpan(span: StyleSpan): StyleSpanDto {
    return StyleSpanDto(length = span.segments, style = StyleSpanStrokeStyleDto())
  }

  /**
   * Convert pigeon [StrokeJointTypeDto] to google maps [JointType]
   *
   * @param strokeJointType pigeon class [StrokeJointTypeDto]
   * @return google maps [JointType] int value
   */
  private fun convertStrokeJointType(strokeJointType: StrokeJointTypeDto): Int {
    return when (strokeJointType) {
      StrokeJointTypeDto.BEVEL -> JointType.BEVEL
      StrokeJointTypeDto.DEFAULTJOINT -> JointType.DEFAULT
      StrokeJointTypeDto.ROUND -> JointType.ROUND
    }
  }

  /**
   * Convert google maps [JointType] to pigeon [StrokeJointTypeDto]
   *
   * @param jointType google maps [JointType] int value
   * @return pigeon [StrokeJointTypeDto]
   */
  private fun convertStrokeJointType(jointType: Int): StrokeJointTypeDto {
    return when (jointType) {
      JointType.BEVEL -> StrokeJointTypeDto.BEVEL
      JointType.DEFAULT -> StrokeJointTypeDto.DEFAULTJOINT
      JointType.ROUND -> StrokeJointTypeDto.ROUND
      else -> StrokeJointTypeDto.DEFAULTJOINT
    }
  }

  /**
   * Convert pigeon [PatternItemDto] to google maps [PatternItem]
   *
   * @param patternItem pigeon class [PatternItemDto]
   * @return google maps [PatternItem] class
   */
  private fun convertPatternItem(patternItem: PatternItemDto): PatternItem {
    return when (patternItem.type) {
      PatternTypeDto.DASH -> Dash(patternItem.length?.toFloat() ?: 0F)
      PatternTypeDto.DOT -> Dot()
      PatternTypeDto.GAP -> Gap(patternItem.length?.toFloat() ?: 0F)
    }
  }

  /**
   * Convert google maps [PatternItem] to pigeon [PatternItemDto].
   *
   * @param patternItem google maps [PatternItem].
   * @return pigeon [PatternItemDto].
   */
  private fun convertPatternItem(patternItem: PatternItem): PatternItemDto {
    return when (patternItem) {
      is Dash -> PatternItemDto(PatternTypeDto.DASH, patternItem.length.toDouble())
      is Dot -> PatternItemDto(PatternTypeDto.DOT)
      is Gap -> PatternItemDto(PatternTypeDto.GAP, patternItem.length.toDouble())
      else -> throw FlutterError("convertError", "Could not convert pattern item")
    }
  }

  fun convertNavInfo(navInfo: NavInfo): NavInfoDto {
    return NavInfoDto(
      currentStep = navInfo.currentStep?.let { convertNavInfoStepInfo(it) },
      remainingSteps = navInfo.remainingSteps.map { convertNavInfoStepInfo(it) },
      routeChanged = navInfo.routeChanged,
      distanceToCurrentStepMeters = navInfo.distanceToCurrentStepMeters?.toLong(),
      distanceToNextDestinationMeters = navInfo.distanceToNextDestinationMeters?.toLong(),
      distanceToFinalDestinationMeters = navInfo.distanceToFinalDestinationMeters?.toLong(),
      timeToCurrentStepSeconds = navInfo.timeToCurrentStepSeconds?.toLong(),
      timeToNextDestinationSeconds = navInfo.timeToNextDestinationSeconds?.toLong(),
      timeToFinalDestinationSeconds = navInfo.timeToFinalDestinationSeconds?.toLong(),
      navState = convertNavState(navInfo.navState),
    )
  }

  private fun convertNavState(state: Int): NavStateDto {
    return when (state) {
      NavState.ENROUTE -> NavStateDto.ENROUTE
      NavState.REROUTING -> NavStateDto.REROUTING
      NavState.STOPPED -> NavStateDto.STOPPED
      NavState.UNKNOWN -> NavStateDto.UNKNOWN
      else -> NavStateDto.UNKNOWN
    }
  }

  private fun convertNavInfoStepInfo(stepInfo: StepInfo): StepInfoDto {
    return StepInfoDto(
      distanceFromPrevStepMeters = stepInfo.distanceFromPrevStepMeters.toLong(),
      timeFromPrevStepSeconds = stepInfo.timeFromPrevStepSeconds.toLong(),
      drivingSide = convertDrivingSide(stepInfo.drivingSide),
      exitNumber = stepInfo.exitNumber,
      fullInstructions = stepInfo.fullInstructionText,
      fullRoadName = stepInfo.fullRoadName,
      simpleRoadName = stepInfo.simpleRoadName,
      roundaboutTurnNumber = stepInfo.roundaboutTurnNumber.toLong(),
      stepNumber = stepInfo.stepNumber.toLong(),
      lanes =
        stepInfo.lanes.map { lane ->
          LaneDto(
            laneDirections =
              lane.laneDirections().map { laneDirection ->
                LaneDirectionDto(
                  laneShape = convertLaneShape(laneDirection.laneShape()),
                  isRecommended = laneDirection.isRecommended,
                )
              }
          )
        },
      maneuver = convertManeuver(stepInfo.maneuver),
    )
  }

  private fun convertLaneShape(laneShape: Int): LaneShapeDto {
    return when (laneShape) {
      LaneShape.UNKNOWN -> LaneShapeDto.UNKNOWN
      LaneShape.STRAIGHT -> LaneShapeDto.STRAIGHT
      LaneShape.SLIGHT_LEFT -> LaneShapeDto.SLIGHTLEFT
      LaneShape.SLIGHT_RIGHT -> LaneShapeDto.SLIGHTRIGHT
      LaneShape.SHARP_LEFT -> LaneShapeDto.SHARPLEFT
      LaneShape.SHARP_RIGHT -> LaneShapeDto.SHARPRIGHT
      LaneShape.NORMAL_LEFT -> LaneShapeDto.NORMALLEFT
      LaneShape.NORMAL_RIGHT -> LaneShapeDto.NORMALRIGHT
      LaneShape.U_TURN_LEFT -> LaneShapeDto.UTURNLEFT
      LaneShape.U_TURN_RIGHT -> LaneShapeDto.UTURNRIGHT
      else -> LaneShapeDto.UNKNOWN
    }
  }

  private fun convertManeuver(maneuver: Int): ManeuverDto {
    return when (maneuver) {
      Maneuver.DEPART -> ManeuverDto.DEPART
      Maneuver.DESTINATION -> ManeuverDto.DESTINATION
      Maneuver.DESTINATION_LEFT -> ManeuverDto.DESTINATIONLEFT
      Maneuver.DESTINATION_RIGHT -> ManeuverDto.DESTINATIONRIGHT
      Maneuver.FERRY_BOAT -> ManeuverDto.FERRYBOAT
      Maneuver.FERRY_TRAIN -> ManeuverDto.FERRYTRAIN
      Maneuver.FORK_LEFT -> ManeuverDto.FORKLEFT
      Maneuver.FORK_RIGHT -> ManeuverDto.FORKRIGHT
      Maneuver.MERGE_LEFT -> ManeuverDto.MERGELEFT
      Maneuver.MERGE_RIGHT -> ManeuverDto.MERGERIGHT
      Maneuver.MERGE_UNSPECIFIED -> ManeuverDto.MERGEUNSPECIFIED
      Maneuver.NAME_CHANGE -> ManeuverDto.NAMECHANGE
      Maneuver.OFF_RAMP_KEEP_LEFT -> ManeuverDto.OFFRAMPKEEPLEFT
      Maneuver.OFF_RAMP_KEEP_RIGHT -> ManeuverDto.OFFRAMPKEEPRIGHT
      Maneuver.OFF_RAMP_LEFT -> ManeuverDto.OFFRAMPLEFT
      Maneuver.OFF_RAMP_RIGHT -> ManeuverDto.OFFRAMPRIGHT
      Maneuver.OFF_RAMP_SHARP_LEFT -> ManeuverDto.OFFRAMPSHARPLEFT
      Maneuver.OFF_RAMP_SHARP_RIGHT -> ManeuverDto.OFFRAMPSHARPRIGHT
      Maneuver.OFF_RAMP_SLIGHT_LEFT -> ManeuverDto.OFFRAMPSLIGHTLEFT
      Maneuver.OFF_RAMP_SLIGHT_RIGHT -> ManeuverDto.OFFRAMPSLIGHTRIGHT
      Maneuver.OFF_RAMP_U_TURN_CLOCKWISE -> ManeuverDto.OFFRAMPUNSPECIFIED
      Maneuver.OFF_RAMP_U_TURN_COUNTERCLOCKWISE -> ManeuverDto.OFFRAMPUTURNCLOCKWISE
      Maneuver.OFF_RAMP_UNSPECIFIED -> ManeuverDto.OFFRAMPUTURNCOUNTERCLOCKWISE
      Maneuver.ON_RAMP_KEEP_LEFT -> ManeuverDto.ONRAMPKEEPLEFT
      Maneuver.ON_RAMP_KEEP_RIGHT -> ManeuverDto.ONRAMPKEEPRIGHT
      Maneuver.ON_RAMP_LEFT -> ManeuverDto.ONRAMPLEFT
      Maneuver.ON_RAMP_RIGHT -> ManeuverDto.ONRAMPRIGHT
      Maneuver.ON_RAMP_SHARP_LEFT -> ManeuverDto.ONRAMPSHARPLEFT
      Maneuver.ON_RAMP_SHARP_RIGHT -> ManeuverDto.ONRAMPSHARPRIGHT
      Maneuver.ON_RAMP_SLIGHT_LEFT -> ManeuverDto.ONRAMPSLIGHTLEFT
      Maneuver.ON_RAMP_SLIGHT_RIGHT -> ManeuverDto.ONRAMPSLIGHTRIGHT
      Maneuver.ON_RAMP_U_TURN_CLOCKWISE -> ManeuverDto.ONRAMPUNSPECIFIED
      Maneuver.ON_RAMP_U_TURN_COUNTERCLOCKWISE -> ManeuverDto.ONRAMPUTURNCLOCKWISE
      Maneuver.ON_RAMP_UNSPECIFIED -> ManeuverDto.ONRAMPUTURNCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_CLOCKWISE -> ManeuverDto.ROUNDABOUTCLOCKWISE
      Maneuver.ROUNDABOUT_COUNTERCLOCKWISE -> ManeuverDto.ROUNDABOUTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_EXIT_CLOCKWISE -> ManeuverDto.ROUNDABOUTEXITCLOCKWISE
      Maneuver.ROUNDABOUT_EXIT_COUNTERCLOCKWISE -> ManeuverDto.ROUNDABOUTEXITCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_LEFT_CLOCKWISE -> ManeuverDto.ROUNDABOUTLEFTCLOCKWISE
      Maneuver.ROUNDABOUT_LEFT_COUNTERCLOCKWISE -> ManeuverDto.ROUNDABOUTLEFTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_RIGHT_CLOCKWISE -> ManeuverDto.ROUNDABOUTRIGHTCLOCKWISE
      Maneuver.ROUNDABOUT_RIGHT_COUNTERCLOCKWISE -> ManeuverDto.ROUNDABOUTRIGHTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_SHARP_LEFT_CLOCKWISE -> ManeuverDto.ROUNDABOUTSHARPLEFTCLOCKWISE
      Maneuver.ROUNDABOUT_SHARP_LEFT_COUNTERCLOCKWISE ->
        ManeuverDto.ROUNDABOUTSHARPLEFTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_SHARP_RIGHT_CLOCKWISE -> ManeuverDto.ROUNDABOUTSHARPRIGHTCLOCKWISE
      Maneuver.ROUNDABOUT_SHARP_RIGHT_COUNTERCLOCKWISE ->
        ManeuverDto.ROUNDABOUTSHARPRIGHTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_SLIGHT_LEFT_CLOCKWISE -> ManeuverDto.ROUNDABOUTSLIGHTLEFTCLOCKWISE
      Maneuver.ROUNDABOUT_SLIGHT_LEFT_COUNTERCLOCKWISE ->
        ManeuverDto.ROUNDABOUTSLIGHTLEFTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_SLIGHT_RIGHT_CLOCKWISE -> ManeuverDto.ROUNDABOUTSLIGHTRIGHTCLOCKWISE
      Maneuver.ROUNDABOUT_SLIGHT_RIGHT_COUNTERCLOCKWISE ->
        ManeuverDto.ROUNDABOUTSLIGHTRIGHTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_STRAIGHT_CLOCKWISE -> ManeuverDto.ROUNDABOUTSTRAIGHTCLOCKWISE
      Maneuver.ROUNDABOUT_STRAIGHT_COUNTERCLOCKWISE ->
        ManeuverDto.ROUNDABOUTSTRAIGHTCOUNTERCLOCKWISE
      Maneuver.ROUNDABOUT_U_TURN_CLOCKWISE -> ManeuverDto.ROUNDABOUTUTURNCLOCKWISE
      Maneuver.ROUNDABOUT_U_TURN_COUNTERCLOCKWISE -> ManeuverDto.ROUNDABOUTUTURNCOUNTERCLOCKWISE
      Maneuver.STRAIGHT -> ManeuverDto.STRAIGHT
      Maneuver.TURN_KEEP_LEFT -> ManeuverDto.TURNKEEPLEFT
      Maneuver.TURN_KEEP_RIGHT -> ManeuverDto.TURNKEEPRIGHT
      Maneuver.TURN_LEFT -> ManeuverDto.TURNLEFT
      Maneuver.TURN_RIGHT -> ManeuverDto.TURNRIGHT
      Maneuver.TURN_SHARP_LEFT -> ManeuverDto.TURNSHARPLEFT
      Maneuver.TURN_SHARP_RIGHT -> ManeuverDto.TURNSHARPRIGHT
      Maneuver.TURN_SLIGHT_LEFT -> ManeuverDto.TURNSLIGHTLEFT
      Maneuver.TURN_SLIGHT_RIGHT -> ManeuverDto.TURNSLIGHTRIGHT
      Maneuver.TURN_U_TURN_CLOCKWISE -> ManeuverDto.TURNUTURNCLOCKWISE
      Maneuver.TURN_U_TURN_COUNTERCLOCKWISE -> ManeuverDto.TURNUTURNCOUNTERCLOCKWISE
      Maneuver.UNKNOWN -> ManeuverDto.UNKNOWN
      else -> ManeuverDto.UNKNOWN
    }
  }

  private fun convertDrivingSide(side: Int): DrivingSideDto {
    return when (side) {
      DrivingSide.LEFT -> DrivingSideDto.LEFT
      DrivingSide.RIGHT -> DrivingSideDto.RIGHT
      DrivingSide.NONE -> DrivingSideDto.NONE
      else -> DrivingSideDto.NONE
    }
  }

  /**
   * Set pigeon [PolylineOptionsDto] to [PolylineOptionsSink] instance.
   *
   * @param polylineOptions pigeon [PolylineOptionsDto].
   */
  fun sinkPolylineOptions(
    polylineOptions: PolylineOptionsDto,
    sink: PolylineOptionsSink,
    density: Float,
  ) {
    if (polylineOptions.points != null) {
      sink.setPoints(
        polylineOptions.points.filterNotNull().map { LatLng(it.latitude, it.longitude) }
      )
    }
    if (polylineOptions.clickable != null) {
      sink.setClickable(polylineOptions.clickable)
    }
    if (polylineOptions.geodesic != null) {
      sink.setGeodesic(polylineOptions.geodesic)
    }
    if (polylineOptions.strokeColor != null) {
      sink.setStrokeColor(polylineOptions.strokeColor.toInt())
    }
    if (polylineOptions.strokeJointType != null) {
      val intVal = convertStrokeJointType(polylineOptions.strokeJointType)
      sink.setStrokeJointType(intVal)
    }
    if (polylineOptions.strokePattern != null) {
      val patternItems =
        polylineOptions.strokePattern.filterNotNull().map { convertPatternItem(it) }
      sink.setStrokePattern(patternItems)
    }
    if (polylineOptions.strokeWidth != null) {
      sink.setStrokeWidth(
        convertLogicalToScreenPixel(polylineOptions.strokeWidth, density).toFloat()
      )
    }
    if (polylineOptions.visible != null) {
      sink.setVisible(polylineOptions.visible)
    }
    if (polylineOptions.zIndex != null) {
      sink.setZIndex(polylineOptions.zIndex.toFloat())
    }
    val spans = polylineOptions.spans.filterNotNull().mapNotNull { convertStyleSpan(it) }
    sink.setSpans(spans)
  }

  /**
   * Get all options from [Polyline] instance and create [PolylineOptionsDto].
   *
   * @param polyline [Polyline] instance.
   * @return [PolylineOptionsDto] with parameters set from [Polyline] instance.
   */
  fun polylineToPolylineOptions(polyline: Polyline, density: Float): PolylineOptionsDto {
    return PolylineOptionsDto(
      points = polyline.points.map { LatLngDto(it.latitude, it.longitude) },
      clickable = polyline.isClickable,
      geodesic = polyline.isGeodesic,
      strokeWidth = convertScreenToLogicalPixel(polyline.width.toDouble(), density),
      strokeColor = polyline.color.toLong(),
      strokeJointType = convertStrokeJointType(polyline.jointType),
      strokePattern = polyline.pattern?.map { convertPatternItem(it) },
      visible = polyline.isVisible,
      zIndex = polyline.zIndex.toDouble(),
      spans = polyline.spans.map { convertStyleSpan(it) },
    )
  }

  /**
   * Set pigeon [CircleOptionsDto] to [CircleOptionsSink] instance.
   *
   * @param circleOptions pigeon [CircleOptionsDto].
   */
  fun sinkCircleOptions(circleOptions: CircleOptionsDto, sink: CircleOptionsSink, density: Float) {
    sink.setPosition(LatLng(circleOptions.position.latitude, circleOptions.position.longitude))
    sink.setRadius(circleOptions.radius)
    sink.setStrokeWidth(convertLogicalToScreenPixel(circleOptions.strokeWidth, density).toFloat())
    sink.setStrokeColor(circleOptions.strokeColor.toInt())
    val patternItems = circleOptions.strokePattern.filterNotNull().map { convertPatternItem(it) }
    sink.setStrokePattern(patternItems)
    sink.setFillColor(circleOptions.fillColor.toInt())
    sink.setZIndex(circleOptions.zIndex.toFloat())
    sink.setVisible(circleOptions.visible)
    sink.setClickable(circleOptions.clickable)
  }

  /**
   * Get all options from [Circle] instance and create [CircleOptionsDto].
   *
   * @param circle [Circle] instance.
   * @return [CircleOptionsDto] with parameters set from [Circle] instance.
   */
  fun circleToCircleOptions(circle: Circle, density: Float): CircleOptionsDto {
    return CircleOptionsDto(
      position = LatLngDto(circle.center.latitude, circle.center.longitude),
      radius = circle.radius,
      strokeWidth = convertScreenToLogicalPixel(circle.strokeWidth.toDouble(), density),
      strokeColor = circle.strokeColor.toLong(),
      strokePattern = circle.strokePattern?.map { convertPatternItem(it) } ?: emptyList(),
      fillColor = circle.fillColor.toLong(),
      zIndex = circle.zIndex.toDouble(),
      visible = circle.isVisible,
      clickable = circle.isClickable,
    )
  }

  /**
   * Creates [ImageDescriptorDto] from [RegisteredImage] object. If registeredImage is null, returns
   * id for default marker icon.
   *
   * @param registeredImage [RegisteredImage] object.
   * @return [ImageDescriptorDto] object.
   */
  fun registeredImageToImageDescriptorDto(registeredImage: RegisteredImage?): ImageDescriptorDto {
    return if (registeredImage != null) {
      ImageDescriptorDto(
        registeredImage.imageId,
        registeredImage.imagePixelRatio,
        registeredImage.width,
        registeredImage.height,
      )
    } else {
      // For default marker icon
      ImageDescriptorDto()
    }
  }

  fun taskRemovedBehaviorDtoToTaskRemovedBehavior(
    behavior: TaskRemovedBehaviorDto?
  ): @TaskRemovedBehavior Int {
    return when (behavior) {
      TaskRemovedBehaviorDto.CONTINUESERVICE -> TaskRemovedBehavior.CONTINUE_SERVICE
      TaskRemovedBehaviorDto.QUITSERVICE -> TaskRemovedBehavior.QUIT_SERVICE
      else -> TaskRemovedBehavior.CONTINUE_SERVICE
    }
  }
}
