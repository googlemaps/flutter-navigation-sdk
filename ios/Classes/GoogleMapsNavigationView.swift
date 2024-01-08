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

import Flutter
import GoogleNavigation
import UIKit

enum GoogleMapsNavigationViewError: Error {
  case notSupported
  case markerNotFound
  case polygonNotFound
  case polylineNotFound
  case circleNotFound
  case awaitViewReadyCalledMultipleTimes
  case mapStyleError
}

class GoogleMapsNavigationView: NSObject, FlutterPlatformView, ViewSettledDelegate {
  private var _navigationView: ViewStateAwareGMSMapView!
  private var _viewRegistry: GoogleMapsNavigationViewRegistry
  private var _navigationViewEventApi: NavigationViewEventApi
  private var _viewId: Int64
  private var _myLocationButton: Bool = true
  private var _markerControllers: [MarkerController] = []
  private var _gmsPolygons: [GMSPolygon] = []
  private var _gmsPolylines: [GMSPolyline] = []
  private var _gmsCircles: [GMSCircle] = []
  private var _mapConfiguration: MapConfiguration!
  private var _mapViewReady: Bool = false
  private var _mapReadyCallback: ((Result<Void, Error>) -> Void)?
  private var _imageRegistry: ImageRegistry
  var isAttachedToSession: Bool = false

  func view() -> UIView {
    _navigationView
  }

  init(frame: CGRect,
       viewIdentifier viewId: Int64,
       viewRegistry registry: GoogleMapsNavigationViewRegistry,
       navigationViewEventApi: NavigationViewEventApi,
       mapConfiguration: MapConfiguration, imageRegistry: ImageRegistry) {
    _viewId = viewId
    _viewRegistry = registry
    _navigationViewEventApi = navigationViewEventApi
    _mapConfiguration = mapConfiguration
    _imageRegistry = imageRegistry

    let mapViewOptions = GMSMapViewOptions()
    _mapConfiguration.apply(to: mapViewOptions, withFrame: frame)
    _navigationView = ViewStateAwareGMSMapView(options: mapViewOptions)
    _mapConfiguration.apply(to: _navigationView)

    super.init()
    registry.registerView(viewId: viewId, view: self)
    _navigationView.delegate = self
    _navigationView.viewSettledDelegate = self
  }

  deinit {
    _viewRegistry.unregisterView(viewId: _viewId)
    _navigationView.delegate = nil
  }

  func onViewSettled(_ view: UIView) {
    _mapConfiguration.applyCameraPosition(to: _navigationView)

    // Attach possible navigation session to map.
    GoogleMapsNavigationSessionManager.shared.attachNavigationSessionToMapView(
      mapView: self
    )

    // Set initial navigation UI state.
    setNavigationUIEnabled(_mapConfiguration?.navigationUIEnabled ?? isAttachedToSession)

    _navigationView.needsUpdateConstraints()

    // Inform the flutter implementation that view is ready to be controlled.
    _mapViewReady = true
    if let callback = _mapReadyCallback {
      callback(.success(()))
      _mapReadyCallback = nil
    }
  }

  func awaitMapReady(callback: @escaping (Result<Void, Error>) -> Void) {
    if _mapViewReady {
      callback(.success(()))
    } else if _mapReadyCallback != nil {
      // If there is already a callback pending, throw an error to avoid overriding it
      callback(.failure(GoogleMapsNavigationViewError.awaitViewReadyCalledMultipleTimes))
    } else {
      // Save the callback to be called once the map is initialized
      _mapReadyCallback = callback
    }
  }

  func isMyLocationEnabled() throws -> Bool {
    _navigationView.isMyLocationEnabled
  }

  private func findMarkerController(markerId: String) throws -> MarkerController {
    if let markerController = _markerControllers.first(where: { $0.markerId == markerId }) {
      return markerController
    } else {
      throw GoogleMapsNavigationViewError.markerNotFound
    }
  }

  private func findMarkerController(gmsMarker: GMSMarker) throws -> MarkerController {
    if let markerController = _markerControllers.first(where: { $0.gmsMarker == gmsMarker }) {
      return markerController
    } else {
      throw GoogleMapsNavigationViewError.markerNotFound
    }
  }

  private func findGMSPolygon(polygonId: String) throws -> GMSPolygon {
    if let polygon = _gmsPolygons.first(where: { polygon in polygon.getPolygonId() == polygonId }) {
      return polygon
    } else {
      throw GoogleMapsNavigationViewError.polygonNotFound
    }
  }

  private func findGMSPolyline(polylineId: String) throws -> GMSPolyline {
    if let polyline = _gmsPolylines
      .first(where: { polyline in polyline.getPolylineId() == polylineId }) {
      return polyline
    } else {
      throw GoogleMapsNavigationViewError.polylineNotFound
    }
  }

  private func findGMSCircle(circleId: String) throws -> GMSCircle {
    if let circle = _gmsCircles
      .first(where: { circle in circle.getCircleId() == circleId }) {
      return circle
    } else {
      throw GoogleMapsNavigationViewError.circleNotFound
    }
  }

  func setMyLocationEnabled(_ enabled: Bool) throws {
    _navigationView.isMyLocationEnabled = enabled
    try updateMyLocationButton()
  }

  func getMapType() -> GMSMapViewType {
    _navigationView.mapType
  }

  func setMapType(mapType: GMSMapViewType) throws {
    _navigationView.mapType = mapType
  }

  func setMapStyle(styleJson: String) throws {
    do {
      _navigationView.mapStyle = try GMSMapStyle(jsonString: styleJson)
    } catch {
      throw GoogleMapsNavigationViewError.mapStyleError
    }
  }

  func setMyLocationButtonEnabled(_ enabled: Bool) throws {
    _myLocationButton = enabled
    try updateMyLocationButton()
  }

  func updateMyLocationButton() throws {
    // Align the behavior with Android: the default value of myLocationButton is true,
    // but it is not shown if my location is disabled.
    _navigationView.settings.myLocationButton = _navigationView
      .isMyLocationEnabled && _myLocationButton
  }

  func setZoomGesturesEnabled(_ enabled: Bool) throws {
    _navigationView.settings.zoomGestures = enabled
  }

  func setZoomControlsEnabled(_ enabled: Bool) throws {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func setCompassEnabled(_ enabled: Bool) throws {
    _navigationView.settings.compassButton = enabled
  }

  func setRotateGesturesEnabled(_ enabled: Bool) throws {
    _navigationView.settings.rotateGestures = enabled
  }

  func setScrollGesturesEnabled(_ enabled: Bool) throws {
    _navigationView.settings.scrollGestures = enabled
  }

  func setScrollGesturesDuringRotateOrZoomEnabled(_ enabled: Bool) throws {
    _navigationView.settings.allowScrollGesturesDuringRotateOrZoom = enabled
  }

  func setTiltGesturesEnabled(_ enabled: Bool) throws {
    _navigationView.settings.tiltGestures = enabled
  }

  func setMapToolbarEnabled(_ enabled: Bool) throws {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func setTrafficEnabled(_ enabled: Bool) throws {
    _navigationView.isTrafficEnabled = enabled
  }

  func isMyLocationButtonEnabled() -> Bool {
    _myLocationButton
  }

  func isZoomGesturesEnabled() -> Bool {
    _navigationView.settings.zoomGestures
  }

  func isZoomControlsEnabled() throws -> Bool {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func isCompassEnabled() -> Bool {
    _navigationView.settings.compassButton
  }

  func isRotateGesturesEnabled() -> Bool {
    _navigationView.settings.rotateGestures
  }

  func isScrollGesturesEnabled() -> Bool {
    _navigationView.settings.scrollGestures
  }

  func isScrollGesturesEnabledDuringRotateOrZoom() -> Bool {
    _navigationView.settings.allowScrollGesturesDuringRotateOrZoom
  }

  func isTiltGesturesEnabled() -> Bool {
    _navigationView.settings.tiltGestures
  }

  func isMapToolbarEnabled() throws -> Bool {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func isTrafficEnabled() -> Bool {
    _navigationView.isTrafficEnabled
  }

  func showRouteOverview() {
    _navigationView.cameraMode = .overview
  }

  func getMyLocation() -> CLLocationCoordinate2D? {
    if let location = _navigationView.myLocation {
      return location.coordinate
    } else {
      return nil
    }
  }

  func getCameraPosition() -> GMSCameraPosition {
    _navigationView.camera
  }

  func getVisibleRegion() -> GMSCoordinateBounds {
    GMSCoordinateBounds(region: _navigationView.projection.visibleRegion())
  }

  func animateCameraToCameraPosition(cameraPosition: GMSCameraPosition) {
    _navigationView.animate(with: GMSCameraUpdate.setCamera(cameraPosition))
  }

  func animateCameraToLatLng(point: CLLocationCoordinate2D) {
    _navigationView.animate(with: GMSCameraUpdate.setTarget(point))
  }

  func animateCameraToLatLngBounds(bounds: GMSCoordinateBounds, padding: Double) {
    _navigationView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: padding))
  }

  func animateCameraToLatLngZoom(point: CLLocationCoordinate2D, zoom: Double) {
    _navigationView.animate(with: GMSCameraUpdate.setTarget(point, zoom: Float(zoom)))
  }

  func animateCameraByScroll(dx: Double, dy: Double) {
    _navigationView.animate(with: GMSCameraUpdate.scrollBy(x: CGFloat(dx), y: CGFloat(dy)))
  }

  func animateCameraByZoom(zoomBy: Double, focus: CGPoint?) {
    if focus != nil {
      _navigationView.animate(with: GMSCameraUpdate.zoom(by: Float(zoomBy), at: focus!))
    } else {
      _navigationView.animate(with: GMSCameraUpdate.zoom(by: Float(zoomBy)))
    }
  }

  func animateCameraToZoom(zoom: Double) {
    _navigationView.animate(with: GMSCameraUpdate.zoom(to: Float(zoom)))
  }

  func moveCameraToCameraPosition(cameraPosition: GMSCameraPosition) {
    _navigationView.moveCamera(GMSCameraUpdate.setCamera(cameraPosition))
  }

  func moveCameraToLatLng(point: CLLocationCoordinate2D) {
    _navigationView.moveCamera(GMSCameraUpdate.setTarget(point))
  }

  func moveCameraToLatLngBounds(bounds: GMSCoordinateBounds, padding: Double) {
    _navigationView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: padding))
  }

  func moveCameraToLatLngZoom(point: CLLocationCoordinate2D, zoom: Double) {
    _navigationView.moveCamera(GMSCameraUpdate.setTarget(point, zoom: Float(zoom)))
  }

  func moveCameraByScroll(dx: Double, dy: Double) {
    _navigationView.moveCamera(GMSCameraUpdate.scrollBy(x: CGFloat(dx), y: CGFloat(dy)))
  }

  func moveCameraByZoom(zoomBy: Double, focus: CGPoint?) {
    if focus != nil {
      _navigationView.moveCamera(GMSCameraUpdate.zoom(by: Float(zoomBy), at: focus!))
    } else {
      _navigationView.moveCamera(GMSCameraUpdate.zoom(by: Float(zoomBy)))
    }
  }

  func moveCameraToZoom(zoom: Double) {
    _navigationView.moveCamera(GMSCameraUpdate.zoom(to: Float(zoom)))
  }

  func followMyLocation(perspective: GMSNavigationCameraPerspective, zoomLevel: Double?) {
    _navigationView.followingPerspective = perspective
    _navigationView.cameraMode = .following
    if zoomLevel != nil {
      _navigationView.followingZoomLevel = Float(zoomLevel!)
    }
  }

  @discardableResult
  func setSession(_ session: GMSNavigationSession) -> Bool {
    // Navigation UI delegate needs to be set after attaching
    // the session to the map view.

    let navigationWasEnabled = _navigationView.isNavigationEnabled

    let result = _navigationView.enableNavigation(with: session)

    if navigationWasEnabled != _navigationView.isNavigationEnabled {
      // Navigation UI got enabled, send enabled change event.
      _navigationViewEventApi
        .onNavigationUIEnabledChanged(
          viewId: _viewId,
          navigationUIEnabled: _navigationView.isNavigationEnabled
        ) { _ in }
    }

    _navigationView.navigationUIDelegate = self
    isAttachedToSession = true
    return result
  }

  func showDestinationMarkers(show: Bool) {
    _navigationView.settings.showsDestinationMarkers = show
  }

  func showTrafficLights(show: Bool) {
    _navigationView.settings.showsTrafficLights = show
  }

  func showStopSigns(show: Bool) {
    _navigationView.settings.showsDestinationMarkers = show
  }

  func isNavigationTripProgressBarEnabled() throws -> Bool {
    _navigationView.settings.isNavigationTripProgressBarEnabled
  }

  func setNavigationTripProgressBarEnabled(_ enabled: Bool) {
    _navigationView.settings.isNavigationTripProgressBarEnabled = enabled
  }

  func isNavigationHeaderEnabled() -> Bool {
    _navigationView.settings.isNavigationHeaderEnabled
  }

  func setNavigationHeaderEnabled(_ enabled: Bool) {
    _navigationView.settings.isNavigationHeaderEnabled = enabled
  }

  func isNavigationFooterEnabled() -> Bool {
    _navigationView.settings.isNavigationFooterEnabled
  }

  func setNavigationFooterEnabled(_ enabled: Bool) {
    _navigationView.settings.isNavigationFooterEnabled = enabled
  }

  func isRecenterButtonEnabled() -> Bool {
    _navigationView.settings.isRecenterButtonEnabled
  }

  func setRecenterButtonEnabled(_ enabled: Bool) {
    _navigationView.settings.isRecenterButtonEnabled = enabled
  }

  func isSpeedLimitIconEnabled() -> Bool {
    _navigationView.shouldDisplaySpeedLimit
  }

  func setSpeedLimitIconEnabled(_ enabled: Bool) {
    _navigationView.shouldDisplaySpeedLimit = enabled
  }

  func isSpeedometerEnabled() -> Bool {
    _navigationView.shouldDisplaySpeedometer
  }

  func setSpeedometerEnabled(_ enabled: Bool) {
    _navigationView.shouldDisplaySpeedometer = enabled
  }

  func isIncidentCardsEnabled() -> Bool {
    _navigationView.settings.showsIncidentCards
  }

  func setIncidentCardsEnabled(_ enabled: Bool) {
    _navigationView.settings.showsIncidentCards = enabled
  }

  func isNavigationUIEnabled() -> Bool {
    _navigationView.isNavigationEnabled
  }

  func setNavigationUIEnabled(_ enabled: Bool) {
    if _navigationView.isNavigationEnabled != enabled {
      _navigationView.isNavigationEnabled = enabled
      _navigationViewEventApi
        .onNavigationUIEnabledChanged(viewId: _viewId, navigationUIEnabled: enabled) { _ in }

      if !enabled {
        let camera = _navigationView.camera
        _navigationView.animate(to: GMSCameraPosition(
          target: camera.target,
          zoom: camera.zoom,
          bearing: 0.0,
          viewingAngle: 0.0
        ))
      }
    }
  }

  func getMarkers() -> [MarkerDto] {
    _markerControllers.map { $0.toMarkerDto() }
  }

  func addMarkers(markers: [MarkerDto]) -> [MarkerDto] {
    let markers: [MarkerDto] = markers
      .compactMap { $0 }
      .map { marker in
        let markerController = MarkerController(markerId: marker.markerId)
        markerController.update(from: marker, imageRegistry: _imageRegistry)
        // Handle visibility property on iOS by removing/not putting the marker
        // on the map.
        markerController.gmsMarker.map = marker.isVisible() ? _navigationView : nil
        _markerControllers.append(markerController)
        return marker
      }
    return markers
  }

  func updateMarkers(markers: [MarkerDto]) throws -> [MarkerDto] {
    let markers: [MarkerDto] = try markers
      .compactMap { $0 }
      .compactMap { updatedMarker in
        let markerController = try findMarkerController(markerId: updatedMarker.markerId)
        markerController.update(from: updatedMarker, imageRegistry: _imageRegistry)
        // Handle visibility property on iOS by removing/not putting the marker
        // on the map.
        markerController.gmsMarker.map = updatedMarker.isVisible() ? _navigationView : nil
        return updatedMarker
      }
    return markers
  }

  func removeMarkers(markers: [MarkerDto]) throws {
    try markers
      .compactMap { $0 }
      .forEach { markerDto in
        let markerController = try findMarkerController(markerId: markerDto.markerId)
        markerController.gmsMarker.map = nil
        _markerControllers = _markerControllers.filter { $0.markerId != markerController.markerId }
      }
  }

  func clearMarkers() {
    _markerControllers.forEach { markerController in
      markerController.gmsMarker.map = nil
    }
    _markerControllers.removeAll()
  }

  func getPolygons() -> [PolygonDto] {
    _gmsPolygons.map { $0.toPigeonPolygon() }
  }

  func addPolygons(polygons: [PolygonDto]) -> [PolygonDto] {
    let polygons: [PolygonDto] = polygons
      .compactMap { $0 }
      .map { polygon in
        let gmsPolygon = GMSPolygon()
        gmsPolygon.update(from: polygon)
        gmsPolygon.setPolygonId(polygon.polygonId)
        // Handle visibility property on iOS by removing/not putting the polygon
        // on the map.
        gmsPolygon.map = polygon.isVisible() ? _navigationView : nil
        _gmsPolygons.append(gmsPolygon)
        return polygon
      }
    return polygons
  }

  func updatePolygons(polygons: [PolygonDto]) throws -> [PolygonDto] {
    let polygons: [PolygonDto] = try polygons
      .compactMap { $0 }
      .compactMap { pigeonPolygon in
        let gmsPolygon = try findGMSPolygon(polygonId: pigeonPolygon.polygonId)
        gmsPolygon.update(from: pigeonPolygon)
        // Handle visibility property on iOS by removing/not putting the polygon
        // on the map.
        gmsPolygon.map = pigeonPolygon.isVisible() ? _navigationView : nil
        return pigeonPolygon
      }
    return polygons
  }

  func removePolygons(polygons: [PolygonDto]) throws {
    try polygons
      .compactMap { $0 }
      .forEach { pigeonPolygon in
        let gmsPolygon = try findGMSPolygon(polygonId: pigeonPolygon.polygonId)
        gmsPolygon.map = nil
        _gmsPolygons.remove(at: _gmsPolygons.firstIndex(of: gmsPolygon)!)
      }
  }

  func clearPolygons() {
    _gmsPolygons.forEach { gmsPolygon in
      gmsPolygon.map = nil
    }
    _gmsPolygons.removeAll()
  }

  func getPolylines() -> [PolylineDto] {
    _gmsPolylines.map { $0.toPigeonPolyline() }
  }

  func addPolylines(polylines: [PolylineDto]) -> [PolylineDto] {
    let polylines: [PolylineDto] = polylines
      .compactMap { $0 }
      .map { polyline in
        let gmsPolyline = GMSPolyline()
        gmsPolyline.update(from: polyline)
        gmsPolyline.setPolylineId(polyline.polylineId)
        // Handle visibility property on iOS by removing/not putting the polyline
        // on the map.
        gmsPolyline.map = polyline.isVisible() ? _navigationView : nil
        _gmsPolylines.append(gmsPolyline)
        return polyline
      }
    return polylines
  }

  func updatePolylines(polylines: [PolylineDto]) throws -> [PolylineDto] {
    let polylines: [PolylineDto] = try polylines
      .compactMap { $0 }
      .compactMap { pigeonPolyline in
        let gmsPolyline = try findGMSPolyline(polylineId: pigeonPolyline.polylineId)
        gmsPolyline.update(from: pigeonPolyline)
        // Handle visibility property on iOS by removing/not putting the polyline
        // on the map.
        gmsPolyline.map = pigeonPolyline.isVisible() ? _navigationView : nil
        return pigeonPolyline
      }
    return polylines
  }

  func removePolylines(polylines: [PolylineDto]) throws {
    try polylines
      .compactMap { $0 }
      .forEach { pigeonPolyline in
        let gmsPolyline = try findGMSPolyline(polylineId: pigeonPolyline.polylineId)
        gmsPolyline.map = nil
        _gmsPolylines.remove(at: _gmsPolylines.firstIndex(of: gmsPolyline)!)
      }
  }

  func clearPolylines() {
    _gmsPolylines.forEach { gmsPolyline in
      gmsPolyline.map = nil
    }
    _gmsPolylines.removeAll()
  }

  func getCircles() -> [CircleDto] {
    _gmsCircles.map { $0.toPigeonCircle() }
  }

  func addCircles(circles: [CircleDto]) -> [CircleDto] {
    let circles: [CircleDto] = circles
      .compactMap { $0 }
      .map { circle in
        let gmsCircle = GMSCircle()
        gmsCircle.update(from: circle)
        gmsCircle.setCircleId(circle.circleId)
        // Handle visibility property on iOS by removing/not putting the circle
        // on the map.
        gmsCircle.map = circle.isVisible() ? _navigationView : nil
        _gmsCircles.append(gmsCircle)
        return circle
      }
    return circles
  }

  func updateCircles(circles: [CircleDto]) throws -> [CircleDto] {
    let circles: [CircleDto] = try circles
      .compactMap { $0 }
      .compactMap { pigeonCircle in
        let gmsCircle = try findGMSCircle(circleId: pigeonCircle.circleId)
        gmsCircle.update(from: pigeonCircle)
        // Handle visibility property on iOS by removing/not putting the circle
        // on the map.
        gmsCircle.map = pigeonCircle.isVisible() ? _navigationView : nil
        return pigeonCircle
      }
    return circles
  }

  func removeCircles(circles: [CircleDto]) throws {
    try circles
      .compactMap { $0 }
      .forEach { pigeonCircles in
        let gmsCircle = try findGMSCircle(circleId: pigeonCircles.circleId)
        gmsCircle.map = nil
        _gmsCircles.remove(at: _gmsCircles.firstIndex(of: gmsCircle)!)
      }
  }

  func clearCircles() {
    _gmsCircles.forEach { gmsCircle in
      gmsCircle.map = nil
    }
    _gmsCircles.removeAll()
  }

  func clear() {
    // The clear will remove everything from map view, so emptying
    // these arrays is enough.
    _markerControllers.removeAll()
    _gmsPolylines.removeAll()
    _gmsPolygons.removeAll()
    _gmsCircles.removeAll()
    _navigationView.clear()
  }

  private func sendMarkerEvent(marker: GMSMarker, eventType: MarkerEventTypeDto) {
    do {
      let markerController = try findMarkerController(gmsMarker: marker)

      _navigationViewEventApi.onMarkerEvent(
        viewId: _viewId,
        markerId: markerController.markerId,
        eventType: eventType,
        completion: { _ in }
      )
    } catch {
      // Fail silently.
    }
  }

  private func sendMarkerDragEvent(marker: GMSMarker,
                                   eventType: MarkerDragEventTypeDto) {
    do {
      let markerController = try findMarkerController(gmsMarker: marker)
      _navigationViewEventApi.onMarkerDragEvent(
        viewId: _viewId,
        markerId: markerController.markerId,
        eventType: eventType,
        position: .init(
          latitude: markerController.gmsMarker.position.latitude,
          longitude: markerController.gmsMarker.position.longitude

        ),
        completion: { _ in }
      )
    } catch {
      // Fail silently.
    }
  }
}

extension GoogleMapsNavigationView: GMSMapViewNavigationUIDelegate {
  func mapViewDidTapRecenterButton(_ mapView: GMSMapView) {
    _navigationViewEventApi.onRecenterButtonClicked(viewId: _viewId) { _ in }
  }
}

extension GoogleMapsNavigationView: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    _navigationViewEventApi.onMapClickEvent(
      viewId: _viewId,
      latLng: .init(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      completion: { _ in }
    )
  }

  func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    _navigationViewEventApi.onMapLongClickEvent(
      viewId: _viewId,
      latLng: .init(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      completion: { _ in }
    )
  }

  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    do {
      let markerController = try findMarkerController(gmsMarker: marker)
      sendMarkerEvent(marker: markerController.gmsMarker, eventType: .clicked)

      // This return value controls the default onClick behaviour,
      // return true for default behaviour to occur and false to not.
      // Default behavior is for the camera to move to the marker and an info window to
      // appear.
      return markerController.consumeTapEvents
    } catch {
      return false
    }
  }

  func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .dragStart)
  }

  func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .dragEnd)
  }

  func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .drag)
  }

  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowClicked)
  }

  func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowClosed)
  }

  func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowLongClicked)
  }

  func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
    if let polygon = overlay as? GMSPolygon {
      _navigationViewEventApi.onPolygonClicked(
        viewId: _viewId,
        polygonId: polygon.getPolygonId(),
        completion: { _ in }
      )
    } else if let polyline = overlay as? GMSPolyline {
      _navigationViewEventApi.onPolylineClicked(
        viewId: _viewId,
        polylineId: polyline.getPolylineId(),
        completion: { _ in }
      )
    } else if let circle = overlay as? GMSCircle {
      _navigationViewEventApi.onCircleClicked(
        viewId: _viewId,
        circleId: circle.getCircleId(),
        completion: { _ in }
      )
    }
  }
}

private extension MarkerDto {
  func isVisible() -> Bool {
    options.visible
  }
}

private extension PolygonDto {
  func isVisible() -> Bool {
    options.visible
  }
}

private extension PolylineDto {
  func isVisible() -> Bool {
    options.visible ?? true
  }
}

private extension CircleDto {
  func isVisible() -> Bool {
    options.visible
  }
}
