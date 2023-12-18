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

enum GoogleMapsNavigationViewHandlerError: Error {
  case viewNotFound
  case badFunctionCall
}

class GoogleMapsNavigationViewMessageHandler: NavigationViewApi {
  private let viewRegistry: GoogleMapsNavigationViewRegistry

  init(viewRegistry: GoogleMapsNavigationViewRegistry) {
    self.viewRegistry = viewRegistry
  }

  private func getView(_ id: Int64) throws -> GoogleMapsNavigationView {
    guard let view = viewRegistry.getView(viewId: id) else {
      throw GoogleMapsNavigationViewHandlerError.viewNotFound
    }
    return view
  }

  func awaitMapReady(viewId: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
    do {
      let mapView = try getView(viewId)
      mapView.awaitMapReady { result in
        switch result {
        case .success:
          completion(.success(()))
        case let .failure(error):
          completion(.failure(error))
        }
      }
    } catch {
      completion(.failure(error))
    }
  }

  func enableMyLocation(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableMyLocation(enabled: enabled)
  }

  func getMapType(viewId: Int64) throws -> MapTypeDto {
    try Convert.convertMapType(gmsMapType: getView(viewId).getMapType())
  }

  func setMapType(viewId: Int64, mapType: MapTypeDto) throws {
    let gmsMapType = Convert.convertMapType(mapType: mapType)
    try getView(viewId).setMapType(mapType: gmsMapType)
  }

  func setMapStyle(viewId: Int64, styleJson: String) throws {
    try getView(viewId).setMapStyle(styleJson: styleJson)
  }

  func enableMyLocationButton(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableMyLocationButton(enabled: enabled)
  }

  func enableZoomGestures(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableZoomGestures(enabled: enabled)
  }

  func enableZoomControls(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableZoomControls(enabled: enabled)
  }

  func enableCompass(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableCompass(enabled: enabled)
  }

  func enableRotateGestures(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableRotateGestures(enabled: enabled)
  }

  func enableScrollGestures(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableScrollGestures(enabled: enabled)
  }

  func enableScrollGesturesDuringRotateOrZoom(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableScrollGesturesDuringRotateOrZoom(enabled: enabled)
  }

  func enableTiltGestures(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableTiltGestures(enabled: enabled)
  }

  func enableMapToolbar(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableMapToolbar(enabled: enabled)
  }

  func enableTraffic(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableTraffic(enabled: enabled)
  }

  func isMyLocationEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isMyLocationEnabled()
  }

  func isMyLocationButtonEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isMyLocationButtonEnabled()
  }

  func isZoomGesturesEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isZoomGesturesEnabled()
  }

  func isZoomControlsEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isZoomControlsEnabled()
  }

  func isCompassEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isCompassEnabled()
  }

  func isRotateGesturesEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isRotateGesturesEnabled()
  }

  func isScrollGesturesEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isScrollGesturesEnabled()
  }

  func isScrollGesturesEnabledDuringRotateOrZoom(viewId: Int64) throws -> Bool {
    try getView(viewId).isScrollGesturesEnabledDuringRotateOrZoom()
  }

  func isTiltGesturesEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isTiltGesturesEnabled()
  }

  func isMapToolbarEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isMapToolbarEnabled()
  }

  func isTrafficEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isTrafficEnabled()
  }

  func getMyLocation(viewId: Int64) throws -> LatLngDto? {
    do {
      guard let myLocation = try getView(viewId).getMyLocation() else {
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

  func getCameraPosition(viewId: Int64) throws -> CameraPositionDto {
    try Convert.convertCameraPosition(position: getView(viewId).getCameraPosition())
  }

  func getVisibleRegion(viewId: Int64) throws -> LatLngBoundsDto {
    try Convert.convertLatLngBounds(bounds: getView(viewId).getVisibleRegion())
  }

  func animateCameraToCameraPosition(viewId: Int64, cameraPosition: CameraPositionDto,
                                     duration: Int64?,
                                     completion: @escaping (Result<Bool, Error>) -> Void) {
    do {
      try getView(viewId)
        .animateCameraToCameraPosition(cameraPosition: Convert
          .convertCameraPosition(position: cameraPosition))

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLng(viewId: Int64, point: LatLngDto, duration: Int64?,
                             completion: @escaping (Result<Bool, Error>) -> Void) {
    do {
      try getView(viewId).animateCameraToLatLng(point: Convert.convertLatLng(point: point))

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLngBounds(viewId: Int64, bounds: LatLngBoundsDto,
                                   padding: Double, duration: Int64?, completion: @escaping (Result<
                                     Bool,
                                     Error
                                   >) -> Void) {
    do {
      try getView(viewId).animateCameraToLatLngBounds(
        bounds: Convert.convertLatLngBounds(bounds: bounds),
        padding: padding
      )

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToLatLngZoom(viewId: Int64, point: LatLngDto, zoom: Double,
                                 duration: Int64?,
                                 completion: @escaping (Result<Bool, Error>) -> Void) {
    do {
      try getView(viewId).animateCameraToLatLngZoom(
        point: Convert.convertLatLng(point: point),
        zoom: zoom
      )

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraByScroll(viewId: Int64, scrollByDx: Double, scrollByDy: Double,
                             duration: Int64?,
                             completion: @escaping (Result<Bool, Error>) -> Void) {
    do {
      try getView(viewId).animateCameraByScroll(dx: scrollByDx, dy: scrollByDy)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraByZoom(viewId: Int64, zoomBy: Double, focusDx: Double?,
                           focusDy: Double?, duration: Int64?, completion: @escaping (Result<
                             Bool,
                             Error
                           >) -> Void) {
    do {
      let focus = Convert.convertDeltaToPoint(dx: focusDx, dy: focusDy)
      try getView(viewId).animateCameraByZoom(zoomBy: zoomBy, focus: focus)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func animateCameraToZoom(viewId: Int64, zoom: Double, duration: Int64?,
                           completion: @escaping (Result<Bool, Error>) -> Void) {
    do {
      try getView(viewId).animateCameraToZoom(zoom: zoom)

      // No callback supported, just return immediately
      completion(.success(true))
    } catch {
      completion(.failure(error))
    }
  }

  func moveCameraToCameraPosition(viewId: Int64, cameraPosition: CameraPositionDto) throws {
    try getView(viewId)
      .moveCameraToCameraPosition(cameraPosition: Convert
        .convertCameraPosition(position: cameraPosition))
  }

  func moveCameraToLatLng(viewId: Int64, point: LatLngDto) throws {
    try getView(viewId).moveCameraToLatLng(point: Convert.convertLatLng(point: point))
  }

  func moveCameraToLatLngBounds(viewId: Int64, bounds: LatLngBoundsDto,
                                padding: Double) throws {
    try getView(viewId).moveCameraToLatLngBounds(
      bounds: Convert.convertLatLngBounds(bounds: bounds),
      padding: padding
    )
  }

  func moveCameraToLatLngZoom(viewId: Int64, point: LatLngDto, zoom: Double) throws {
    try getView(viewId).moveCameraToLatLngZoom(
      point: Convert.convertLatLng(point: point),
      zoom: zoom
    )
  }

  func moveCameraByScroll(viewId: Int64, scrollByDx: Double, scrollByDy: Double) throws {
    try getView(viewId).moveCameraByScroll(dx: scrollByDx, dy: scrollByDy)
  }

  func moveCameraByZoom(viewId: Int64, zoomBy: Double, focusDx: Double?,
                        focusDy: Double?) throws {
    let focus = Convert.convertDeltaToPoint(dx: focusDx, dy: focusDy)
    return try getView(viewId).moveCameraByZoom(zoomBy: zoomBy, focus: focus)
  }

  func moveCameraToZoom(viewId: Int64, zoom: Double) throws {
    try getView(viewId).moveCameraToZoom(zoom: zoom)
  }

  func followMyLocation(viewId: Int64, perspective: CameraPerspectiveDto,
                        zoomLevel: Double?) throws {
    try getView(viewId)
      .followMyLocation(
        perspective: Convert.convertCameraPerspective(perspective: perspective),
        zoomLevel: zoomLevel
      )
  }

  func enableNavigationHeader(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableNavigationHeader(enabled)
  }

  func enableNavigationFooter(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableNavigationFooter(enabled)
  }

  func enableRecenterButton(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableRecenterButton(enabled)
  }

  func enableSpeedLimitIcon(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableSpeedLimitIcon(enabled)
  }

  func enableSpeedometer(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableSpeedometer(enabled)
  }

  func enableIncidentCards(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableIncidentCards(enabled)
  }

  func isNavigationTripProgressBarEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isNavigationTripProgressBarEnabled()
  }

  func enableNavigationTripProgressBar(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableNavigationTripProgressBar(enabled)
  }

  func isNavigationHeaderEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isNavigationHeaderEnabled()
  }

  func isNavigationFooterEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isNavigationFooterEnabled()
  }

  func isRecenterButtonEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isRecenterButtonEnabled()
  }

  func isSpeedLimitIconEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isSpeedLimitIconEnabled()
  }

  func isSpeedometerEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isSpeedometerEnabled()
  }

  func isIncidentCardsEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isIncidentCardsEnabled()
  }

  func isNavigationUIEnabled(viewId: Int64) throws -> Bool {
    try getView(viewId).isNavigationUIEnabled()
  }

  func enableNavigationUI(viewId: Int64, enabled: Bool) throws {
    try getView(viewId).enableNavigationUI(enabled)
  }

  func showRouteOverview(viewId: Int64) throws {
    try getView(viewId).showRouteOverview()
  }

  func getMarkers(viewId: Int64) throws -> [MarkerDto] {
    try getView(viewId).getMarkers()
  }

  func addMarkers(viewId: Int64, markers: [MarkerDto]) throws -> [MarkerDto] {
    try getView(viewId).addMarkers(markers: markers)
  }

  func updateMarkers(viewId: Int64, markers: [MarkerDto]) throws -> [MarkerDto] {
    try getView(viewId).updateMarkers(markers: markers)
  }

  func removeMarkers(viewId: Int64, markers: [MarkerDto]) throws {
    try getView(viewId).removeMarkers(markers: markers)
  }

  func clearMarkers(viewId: Int64) throws {
    try getView(viewId).clearMarkers()
  }

  func getPolygons(viewId: Int64) throws -> [PolygonDto] {
    try getView(viewId).getPolygons()
  }

  func addPolygons(viewId: Int64, polygons: [PolygonDto]) throws -> [PolygonDto] {
    try getView(viewId).addPolygons(polygons: polygons)
  }

  func updatePolygons(viewId: Int64, polygons: [PolygonDto]) throws -> [PolygonDto] {
    try getView(viewId).updatePolygons(polygons: polygons)
  }

  func removePolygons(viewId: Int64, polygons: [PolygonDto]) throws {
    try getView(viewId).removePolygons(polygons: polygons)
  }

  func clearPolygons(viewId: Int64) throws {
    try getView(viewId).clearPolygons()
  }

  func getPolylines(viewId: Int64) throws -> [PolylineDto] {
    try getView(viewId).getPolylines()
  }

  func addPolylines(viewId: Int64, polylines: [PolylineDto]) throws -> [PolylineDto] {
    try getView(viewId).addPolylines(polylines: polylines)
  }

  func updatePolylines(viewId: Int64, polylines: [PolylineDto]) throws -> [PolylineDto] {
    try getView(viewId).updatePolylines(polylines: polylines)
  }

  func removePolylines(viewId: Int64, polylines: [PolylineDto]) throws {
    try getView(viewId).removePolylines(polylines: polylines)
  }

  func clearPolylines(viewId: Int64) throws {
    try getView(viewId).clearPolylines()
  }

  func getCircles(viewId: Int64) throws -> [CircleDto] {
    try getView(viewId).getCircles()
  }

  func addCircles(viewId: Int64, circles: [CircleDto]) throws -> [CircleDto] {
    try getView(viewId).addCircles(circles: circles)
  }

  func updateCircles(viewId: Int64, circles: [CircleDto]) throws -> [CircleDto] {
    try getView(viewId).updateCircles(circles: circles)
  }

  func removeCircles(viewId: Int64, circles: [CircleDto]) throws {
    try getView(viewId).removeCircles(circles: circles)
  }

  func clearCircles(viewId: Int64) throws {
    try getView(viewId).clearCircles()
  }

  func clear(viewId: Int64) throws {
    try getView(viewId).clear()
  }
}
