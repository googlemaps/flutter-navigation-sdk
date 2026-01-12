// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import GoogleMaps

enum GoogleMapsAutoViewHandlerError: Error {
  case viewNotFound
}

class GoogleMapsAutoViewMessageHandler: AutoMapViewApi {
  private let viewRegistry: GoogleMapsNavigationViewRegistry

  init(viewRegistry: GoogleMapsNavigationViewRegistry) {
    self.viewRegistry = viewRegistry
  }

  private func getView() throws -> GoogleMapsNavigationView {
    guard let view = viewRegistry.getCarPlayView() else {
      throw GoogleMapsNavigationViewHandlerError.viewNotFound
    }
    return view
  }

  func awaitMapReady(completion: @escaping (Result<Void, Error>) -> Void) {
    do {
      let mapView = try getView()
      mapView.awaitMapReady { result in
        switch result {
        case .success:
          completion(.success(()))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    } catch {
      completion(.failure(error))
    }
  }

  func setMyLocationEnabled(enabled: Bool) throws {
    try getView().setMyLocationEnabled(enabled)
  }

  func getMapType() throws -> MapTypeDto {
    try Convert.convertMapType(gmsMapType: getView().getMapType())
  }

  func setMapType(mapType: MapTypeDto) throws {
    let gmsMapType = Convert.convertMapType(mapType: mapType)
    try getView().setMapType(mapType: gmsMapType)
  }

  func setMapStyle(styleJson: String) throws {
    try getView().setMapStyle(styleJson: styleJson)
  }

  func setMyLocationButtonEnabled(enabled: Bool) throws {
    try getView().setMyLocationButtonEnabled(enabled)
  }

  func setZoomGesturesEnabled(enabled: Bool) throws {
    try getView().setZoomGesturesEnabled(enabled)
  }

  func setZoomControlsEnabled(enabled: Bool) throws {
    try getView().setZoomControlsEnabled(enabled)
  }

  func setCompassEnabled(enabled: Bool) throws {
    try getView().setCompassEnabled(enabled)
  }

  func setRotateGesturesEnabled(enabled: Bool) throws {
    try getView().setRotateGesturesEnabled(enabled)
  }

  func setScrollGesturesEnabled(enabled: Bool) throws {
    try getView().setScrollGesturesEnabled(enabled)
  }

  func setScrollGesturesDuringRotateOrZoomEnabled(enabled: Bool) throws {
    try getView().setScrollGesturesDuringRotateOrZoomEnabled(enabled)
  }

  func setTiltGesturesEnabled(enabled: Bool) throws {
    try getView().setTiltGesturesEnabled(enabled)
  }

  func setMapToolbarEnabled(enabled: Bool) throws {
    try getView().setMapToolbarEnabled(enabled)
  }

  func setTrafficEnabled(enabled: Bool) throws {
    try getView().setTrafficEnabled(enabled)
  }

  func setTrafficPromptsEnabled(enabled: Bool) throws {
    try getView().setTrafficPromptsEnabled(enabled)
  }

  func setTrafficIncidentCardsEnabled(enabled: Bool) throws {
    try getView().setTrafficIncidentCardsEnabled(enabled)
  }

  func setReportIncidentButtonEnabled(enabled: Bool) throws {
    try getView().setReportIncidentButtonEnabled(enabled)
  }

  func setAutoMapOptions(mapOptions: AutoMapOptionsDto) throws {
    // Store the map options in BaseCarSceneDelegate static property
    let options = AutoMapViewOptions(
      cameraPosition: mapOptions.cameraPosition != nil
        ? Convert.convertCameraPosition(position: mapOptions.cameraPosition!) : nil,
      mapId: mapOptions.mapId,
      mapType: mapOptions.mapType != nil
        ? Convert.convertMapType(mapType: mapOptions.mapType!) : nil,
      mapColorScheme: mapOptions.mapColorScheme != nil
        ? Convert.convertMapColorScheme(mapColorScheme: mapOptions.mapColorScheme!) : nil,
      forceNightMode: mapOptions.forceNightMode != nil
        ? Convert.convertNavigationForceNightMode(forceNightMode: mapOptions.forceNightMode!) : nil
    )
    BaseCarSceneDelegate.mapOptions = options
  }

  func isMyLocationEnabled() throws -> Bool {
    try getView().isMyLocationEnabled()
  }

  func isMyLocationButtonEnabled() throws -> Bool {
    try getView().isMyLocationButtonEnabled()
  }

  func isZoomGesturesEnabled() throws -> Bool {
    try getView().isZoomGesturesEnabled()
  }

  func isZoomControlsEnabled() throws -> Bool {
    try getView().isZoomControlsEnabled()
  }

  func isCompassEnabled() throws -> Bool {
    try getView().isCompassEnabled()
  }

  func isRotateGesturesEnabled() throws -> Bool {
    try getView().isRotateGesturesEnabled()
  }

  func isScrollGesturesEnabled() throws -> Bool {
    try getView().isScrollGesturesEnabled()
  }

  func isScrollGesturesEnabledDuringRotateOrZoom() throws -> Bool {
    try getView().isScrollGesturesEnabledDuringRotateOrZoom()
  }

  func isTiltGesturesEnabled() throws -> Bool {
    try getView().isTiltGesturesEnabled()
  }

  func isMapToolbarEnabled() throws -> Bool {
    try getView().isMapToolbarEnabled()
  }

  func isTrafficEnabled() throws -> Bool {
    try getView().isTrafficEnabled()
  }

  func isTrafficPromptsEnabled() throws -> Bool {
    try getView().isTrafficPromptsEnabled()
  }

  func isTrafficIncidentCardsEnabled() throws -> Bool {
    try getView().isTrafficIncidentCardsEnabled()
  }

  func isReportIncidentButtonEnabled() throws -> Bool {
    try getView().isReportIncidentButtonEnabled()
  }

  func getMyLocation() throws -> LatLngDto? {
    do {
      guard let myLocation = try getView().getMyLocation() else {
        return nil
      }
      return LatLngDto(
        latitude: myLocation.latitude,
        longitude: myLocation.longitude
      )
    } catch {
      throw error
    }
  }

  func getCameraPosition() throws -> CameraPositionDto {
    try Convert.convertCameraPosition(position: getView().getCameraPosition())
  }

  func getVisibleRegion() throws -> LatLngBoundsDto {
    try Convert.convertLatLngBounds(bounds: getView().getVisibleRegion())
  }

  func animateCameraToCameraPosition(
    cameraPosition: CameraPositionDto,
    duration: Int64?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    do {
      try getView()
        .animateCameraToCameraPosition(
          cameraPosition:
            Convert
            .convertCameraPosition(position: cameraPosition))

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLng(
    point: LatLngDto, duration: Int64?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    do {
      try getView().animateCameraToLatLng(point: Convert.convertLatLngFromDto(point: point))

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLngBounds(
    bounds: LatLngBoundsDto,
    padding: Double, duration: Int64?,
    completion:
      @escaping (
        Result<
          Bool,
          Error
        >
      )
      -> Void
  ) {
    do {
      try getView().animateCameraToLatLngBounds(
        bounds: Convert.convertLatLngBounds(bounds: bounds),
        padding: padding
      )

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLngZoom(
    point: LatLngDto, zoom: Double,
    duration: Int64?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    do {
      try getView().animateCameraToLatLngZoom(
        point: Convert.convertLatLngFromDto(point: point),
        zoom: zoom
      )

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraByScroll(
    scrollByDx: Double, scrollByDy: Double,
    duration: Int64?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    do {
      try getView().animateCameraByScroll(dx: scrollByDx, dy: scrollByDy)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraByZoom(
    zoomBy: Double, focusDx: Double?,
    focusDy: Double?, duration: Int64?,
    completion:
      @escaping (
        Result<
          Bool,
          Error
        >
      ) -> Void
  ) {
    do {
      let focus = Convert.convertDeltaToPoint(dx: focusDx, dy: focusDy)
      try getView().animateCameraByZoom(zoomBy: zoomBy, focus: focus)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToZoom(
    zoom: Double, duration: Int64?,
    completion: @escaping (Result<Bool, Error>) -> Void
  ) {
    do {
      try getView().animateCameraToZoom(zoom: zoom)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func moveCameraToCameraPosition(cameraPosition: CameraPositionDto) throws {
    try getView()
      .moveCameraToCameraPosition(
        cameraPosition:
          Convert
          .convertCameraPosition(position: cameraPosition))
  }

  func moveCameraToLatLng(point: LatLngDto) throws {
    try getView().moveCameraToLatLng(point: Convert.convertLatLngFromDto(point: point))
  }

  func moveCameraToLatLngBounds(
    bounds: LatLngBoundsDto,
    padding: Double
  ) throws {
    try getView().moveCameraToLatLngBounds(
      bounds: Convert.convertLatLngBounds(bounds: bounds),
      padding: padding
    )
  }

  func moveCameraToLatLngZoom(point: LatLngDto, zoom: Double) throws {
    try getView().moveCameraToLatLngZoom(
      point: Convert.convertLatLngFromDto(point: point),
      zoom: zoom
    )
  }

  func moveCameraByScroll(scrollByDx: Double, scrollByDy: Double) throws {
    try getView().moveCameraByScroll(dx: scrollByDx, dy: scrollByDy)
  }

  func moveCameraByZoom(
    zoomBy: Double, focusDx: Double?,
    focusDy: Double?
  ) throws {
    let focus = Convert.convertDeltaToPoint(dx: focusDx, dy: focusDy)
    return try getView().moveCameraByZoom(zoomBy: zoomBy, focus: focus)
  }

  func moveCameraToZoom(zoom: Double) throws {
    try getView().moveCameraToZoom(zoom: zoom)
  }

  func followMyLocation(
    perspective: CameraPerspectiveDto,
    zoomLevel: Double?
  ) throws {
    try getView()
      .followMyLocation(
        perspective: Convert.convertCameraPerspective(perspective: perspective),
        zoomLevel: zoomLevel
      )
  }

  func getMarkers() throws -> [MarkerDto] {
    try getView().getMarkers()
  }

  func addMarkers(markers: [MarkerDto]) throws -> [MarkerDto] {
    try getView().addMarkers(markers: markers)
  }

  func updateMarkers(markers: [MarkerDto]) throws -> [MarkerDto] {
    try getView().updateMarkers(markers: markers)
  }

  func removeMarkers(markers: [MarkerDto]) throws {
    try getView().removeMarkers(markers: markers)
  }

  func clearMarkers() throws {
    try getView().clearMarkers()
  }

  func getPolygons() throws -> [PolygonDto] {
    try getView().getPolygons()
  }

  func addPolygons(polygons: [PolygonDto]) throws -> [PolygonDto] {
    try getView().addPolygons(polygons: polygons)
  }

  func updatePolygons(polygons: [PolygonDto]) throws -> [PolygonDto] {
    try getView().updatePolygons(polygons: polygons)
  }

  func removePolygons(polygons: [PolygonDto]) throws {
    try getView().removePolygons(polygons: polygons)
  }

  func clearPolygons() throws {
    try getView().clearPolygons()
  }

  func getPolylines() throws -> [PolylineDto] {
    try getView().getPolylines()
  }

  func addPolylines(polylines: [PolylineDto]) throws -> [PolylineDto] {
    try getView().addPolylines(polylines: polylines)
  }

  func updatePolylines(polylines: [PolylineDto]) throws -> [PolylineDto] {
    try getView().updatePolylines(polylines: polylines)
  }

  func removePolylines(polylines: [PolylineDto]) throws {
    try getView().removePolylines(polylines: polylines)
  }

  func clearPolylines() throws {
    try getView().clearPolylines()
  }

  func getCircles() throws -> [CircleDto] {
    try getView().getCircles()
  }

  func addCircles(circles: [CircleDto]) throws -> [CircleDto] {
    try getView().addCircles(circles: circles)
  }

  func updateCircles(circles: [CircleDto]) throws -> [CircleDto] {
    try getView().updateCircles(circles: circles)
  }

  func removeCircles(circles: [CircleDto]) throws {
    try getView().removeCircles(circles: circles)
  }

  func clearCircles() throws {
    try getView().clearCircles()
  }

  func clear() throws {
    try getView().clear()
  }

  func setConsumeMyLocationButtonClickEventsEnabled(enabled: Bool) throws {
    try getView().setConsumeMyLocationButtonClickEventsEnabled(enabled: enabled)
  }

  func isConsumeMyLocationButtonClickEventsEnabled() throws -> Bool {
    try getView().isConsumeMyLocationButtonClickEventsEnabled()
  }

  func getMinZoomPreference() throws -> Double {
    try Double(getView().getMinZoomPreference())
  }

  func getMaxZoomPreference() throws -> Double {
    try Double(getView().getMaxZoomPreference())
  }

  func resetMinMaxZoomPreference() throws {
    try getView().resetMinMaxZoomPreference()
  }

  func setMinZoomPreference(minZoomPreference: Double) throws {
    try getView().setMinZoomPreference(minZoomPreference: Float(minZoomPreference))
  }

  func setMaxZoomPreference(maxZoomPreference: Double) throws {
    try getView().setMaxZoomPreference(maxZoomPreference: Float(maxZoomPreference))
  }

  func enableOnCameraChangedEvents() throws {
    try getView().enableOnCameraChangedEvents()
  }

  func isAutoScreenAvailable() throws -> Bool {
    viewRegistry.getCarPlayView() != nil
  }

  func setPadding(padding: MapPaddingDto) throws {
    try getView().setPadding(padding: padding)
  }

  func getPadding() throws -> MapPaddingDto {
    try getView().getPadding()
  }

  func getMapColorScheme() throws -> MapColorSchemeDto {
    try Convert.convertMapColorScheme(uiUserInterfaceStyle: getView().getMapColorScheme())
  }

  func setMapColorScheme(mapColorScheme: MapColorSchemeDto) throws {
    let colorScheme = Convert.convertMapColorScheme(mapColorScheme: mapColorScheme)
    try getView().setMapColorScheme(colorScheme: colorScheme)
  }

  func getForceNightMode() throws -> NavigationForceNightModeDto {
    try Convert.convertNavigationForceNightMode(
      gmsNavigationLightingMode: getView().getForceNightMode()
    )
  }

  func setForceNightMode(forceNightMode: NavigationForceNightModeDto) throws {
    let nightMode = Convert.convertNavigationForceNightMode(
      forceNightMode: forceNightMode
    )
    try getView().setForceNightMode(nightMode)
  }

  func sendCustomNavigationAutoEvent(event: String, data: Any) throws {
    // This method receives custom events from Flutter.
    // The implementation is left empty by design, as developers should handle
    // custom events in their BaseCarSceneDelegate subclass by overriding
    // onCustomNavigationAutoEventFromFlutter method.
    //
    // Note: If you need to handle events here, you would need to maintain a reference
    // to your CarSceneDelegate instance and call a method on it.
  }
}
