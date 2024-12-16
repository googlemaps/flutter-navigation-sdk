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
  case minZoomGreaterThanMaxZoom
  case maxZoomLessThanMinZoom
}

public class GoogleMapsNavigationView: NSObject, FlutterPlatformView, ViewSettledDelegate {
  private var _mapView: ViewStateAwareGMSMapView!
  private var _viewRegistry: GoogleMapsNavigationViewRegistry
  private var _viewEventApi: ViewEventApi?
  private var _viewId: Int64?
  private var _isNavigationView: Bool
  private var _myLocationButton: Bool = true
  private var _markerControllers: [MarkerController] = []
  private var _gmsPolygons: [GMSPolygon] = []
  private var _gmsPolylines: [GMSPolyline] = []
  private var _gmsCircles: [GMSCircle] = []
  private var _mapConfiguration: MapConfiguration!
  private var _navigationUIEnabledPreference: NavigationUIEnabledPreference!

  private var _mapViewReady: Bool = false
  private var _mapReadyCallback: ((Result<Void, Error>) -> Void)?
  private var _imageRegistry: ImageRegistry
  private var _consumeMyLocationButtonClickEventsEnabled: Bool = false
  private var _listenCameraChanges = false
  var isAttachedToSession: Bool = false
  private let _isCarPlayView: Bool

  public func view() -> UIView {
    _mapView
  }

  // Getter that wont return viewEventApi if viewId is missing.
  private func getViewEventApi() -> ViewEventApi? {
    if _viewId != nil {
      return _viewEventApi
    }
    return nil
  }

  init(frame: CGRect,
       viewIdentifier viewId: Int64?,
       isNavigationView: Bool,
       viewRegistry registry: GoogleMapsNavigationViewRegistry,
       viewEventApi: ViewEventApi?,
       navigationUIEnabledPreference: NavigationUIEnabledPreference,
       mapConfiguration: MapConfiguration,
       imageRegistry: ImageRegistry,
       isCarPlayView: Bool) {
    if !isCarPlayView, viewId == nil || viewEventApi == nil {
      fatalError("For non-carplay map view viewId and viewEventApi is required")
    }

    _viewId = viewId
    _isNavigationView = isNavigationView
    _viewRegistry = registry
    _viewEventApi = viewEventApi
    _mapConfiguration = mapConfiguration
    _imageRegistry = imageRegistry
    _isCarPlayView = isCarPlayView

    let mapViewOptions = GMSMapViewOptions()
    _mapConfiguration.apply(to: mapViewOptions, withFrame: frame)
    _mapView = ViewStateAwareGMSMapView(options: mapViewOptions)
    _mapConfiguration.apply(to: _mapView)

    super.init()
    registerView()

    _mapView.delegate = self
    _mapView.viewSettledDelegate = self

    _navigationUIEnabledPreference = navigationUIEnabledPreference
    applyNavigationUIEnabledPreference()
  }

  deinit {
    unregisterView()
    _mapView.delegate = nil
  }

  func registerView() {
    if _isCarPlayView {
      _viewRegistry.registerCarPlayView(view: self)
    } else {
      if let _viewId {
        _viewRegistry.registerView(viewId: _viewId, view: self)
      }
    }
  }

  func unregisterView() {
    if _isCarPlayView {
      _viewRegistry.unregisterCarPlayView()
    } else {
      if let _viewId {
        _viewRegistry.unregisterView(viewId: _viewId)
      }
    }
  }

  func isNavigationView() -> Bool {
    _isNavigationView
  }

  func onViewSettled(_ view: UIView) {
    _mapConfiguration.applyCameraPosition(to: _mapView)

    // Attach possible navigation session to map if map is navigation view.
    if _isNavigationView {
      GoogleMapsNavigationSessionManager.shared.attachNavigationSessionToMapView(
        mapView: self
      )
      applyNavigationUIEnabledPreference()
    }

    _mapView.needsUpdateConstraints()

    // Inform the flutter implementation that view is ready to be controlled.
    _mapViewReady = true
    if let callback = _mapReadyCallback {
      callback(.success(()))
      _mapReadyCallback = nil
    }
  }

  func applyNavigationUIEnabledPreference() {
    var navigationUIEnabled = false
    // Set initial navigation UI state.
    if GoogleMapsNavigationSessionManager.shared.isInitialized() {
      if _navigationUIEnabledPreference == .automatic {
        navigationUIEnabled = true
      }
    }
    setNavigationUIEnabled(navigationUIEnabled)
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
    _mapView.isMyLocationEnabled
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
    _mapView.isMyLocationEnabled = enabled
    try updateMyLocationButton()
  }

  public func getMapType() -> GMSMapViewType {
    _mapView.mapType
  }

  public func setMapType(mapType: GMSMapViewType) throws {
    _mapView.mapType = mapType
  }

  func setMapStyle(styleJson: String) throws {
    do {
      _mapView.mapStyle = try GMSMapStyle(jsonString: styleJson)
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
    _mapView.settings.myLocationButton = _mapView
      .isMyLocationEnabled && _myLocationButton
  }

  func setZoomGesturesEnabled(_ enabled: Bool) throws {
    _mapView.settings.zoomGestures = enabled
  }

  func setZoomControlsEnabled(_ enabled: Bool) throws {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func setCompassEnabled(_ enabled: Bool) throws {
    _mapView.settings.compassButton = enabled
  }

  func setRotateGesturesEnabled(_ enabled: Bool) throws {
    _mapView.settings.rotateGestures = enabled
  }

  func setScrollGesturesEnabled(_ enabled: Bool) throws {
    _mapView.settings.scrollGestures = enabled
  }

  func setScrollGesturesDuringRotateOrZoomEnabled(_ enabled: Bool) throws {
    _mapView.settings.allowScrollGesturesDuringRotateOrZoom = enabled
  }

  func setTiltGesturesEnabled(_ enabled: Bool) throws {
    _mapView.settings.tiltGestures = enabled
  }

  func setMapToolbarEnabled(_ enabled: Bool) throws {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func setTrafficEnabled(_ enabled: Bool) throws {
    _mapView.isTrafficEnabled = enabled
  }

  func isMyLocationButtonEnabled() -> Bool {
    _myLocationButton
  }

  func isZoomGesturesEnabled() -> Bool {
    _mapView.settings.zoomGestures
  }

  func isZoomControlsEnabled() throws -> Bool {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func isCompassEnabled() -> Bool {
    _mapView.settings.compassButton
  }

  func isRotateGesturesEnabled() -> Bool {
    _mapView.settings.rotateGestures
  }

  func isScrollGesturesEnabled() -> Bool {
    _mapView.settings.scrollGestures
  }

  func isScrollGesturesEnabledDuringRotateOrZoom() -> Bool {
    _mapView.settings.allowScrollGesturesDuringRotateOrZoom
  }

  func isTiltGesturesEnabled() -> Bool {
    _mapView.settings.tiltGestures
  }

  func isMapToolbarEnabled() throws -> Bool {
    throw GoogleMapsNavigationViewError.notSupported
  }

  func isTrafficEnabled() -> Bool {
    _mapView.isTrafficEnabled
  }

  func showRouteOverview() {
    _mapView.cameraMode = .overview
  }

  public func getMyLocation() -> CLLocationCoordinate2D? {
    if let location = _mapView.myLocation {
      return location.coordinate
    } else {
      return nil
    }
  }

  public func getCameraPosition() -> GMSCameraPosition {
    _mapView.camera
  }

  public func getVisibleRegion() -> GMSCoordinateBounds {
    GMSCoordinateBounds(region: _mapView.projection.visibleRegion())
  }

  public func animateCameraToCameraPosition(cameraPosition: GMSCameraPosition) {
    _mapView.animate(with: GMSCameraUpdate.setCamera(cameraPosition))
  }

  public func animateCameraToLatLng(point: CLLocationCoordinate2D) {
    _mapView.animate(with: GMSCameraUpdate.setTarget(point))
  }

  public func animateCameraToLatLngBounds(bounds: GMSCoordinateBounds, padding: Double) {
    _mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: padding))
  }

  public func animateCameraToLatLngZoom(point: CLLocationCoordinate2D, zoom: Double) {
    _mapView.animate(with: GMSCameraUpdate.setTarget(point, zoom: Float(zoom)))
  }

  public func animateCameraByScroll(dx: Double, dy: Double) {
    _mapView.animate(with: GMSCameraUpdate.scrollBy(x: CGFloat(dx), y: CGFloat(dy)))
  }

  public func animateCameraByZoom(zoomBy: Double, focus: CGPoint?) {
    if focus != nil {
      _mapView.animate(with: GMSCameraUpdate.zoom(by: Float(zoomBy), at: focus!))
    } else {
      _mapView.animate(with: GMSCameraUpdate.zoom(by: Float(zoomBy)))
    }
  }

  public func animateCameraToZoom(zoom: Double) {
    _mapView.animate(with: GMSCameraUpdate.zoom(to: Float(zoom)))
  }

  public func moveCameraToCameraPosition(cameraPosition: GMSCameraPosition) {
    _mapView.moveCamera(GMSCameraUpdate.setCamera(cameraPosition))
  }

  public func moveCameraToLatLng(point: CLLocationCoordinate2D) {
    _mapView.moveCamera(GMSCameraUpdate.setTarget(point))
  }

  public func moveCameraToLatLngBounds(bounds: GMSCoordinateBounds, padding: Double) {
    _mapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: padding))
  }

  public func moveCameraToLatLngZoom(point: CLLocationCoordinate2D, zoom: Double) {
    _mapView.moveCamera(GMSCameraUpdate.setTarget(point, zoom: Float(zoom)))
  }

  public func moveCameraByScroll(dx: Double, dy: Double) {
    _mapView.moveCamera(GMSCameraUpdate.scrollBy(x: CGFloat(dx), y: CGFloat(dy)))
  }

  public func moveCameraByZoom(zoomBy: Double, focus: CGPoint?) {
    if focus != nil {
      _mapView.moveCamera(GMSCameraUpdate.zoom(by: Float(zoomBy), at: focus!))
    } else {
      _mapView.moveCamera(GMSCameraUpdate.zoom(by: Float(zoomBy)))
    }
  }

  public func moveCameraToZoom(zoom: Double) {
    _mapView.moveCamera(GMSCameraUpdate.zoom(to: Float(zoom)))
  }

  public func followMyLocation(perspective: GMSNavigationCameraPerspective, zoomLevel: Double?) {
    _mapView.followingPerspective = perspective
    _mapView.cameraMode = .following
    if zoomLevel != nil {
      _mapView.followingZoomLevel = Float(zoomLevel!)
    }
  }

  @discardableResult
  func setSession(_ session: GMSNavigationSession) -> Bool {
    // Navigation UI delegate needs to be set after attaching
    // the session to the map view.

    if !_isNavigationView {
      // Navigation session cannot be attached to view that is not initialized as navigation view.
      return false
    }

    let navigationWasEnabled = _mapView.isNavigationEnabled

    let result = _mapView.enableNavigation(with: session)

    if navigationWasEnabled != _mapView.isNavigationEnabled {
      // Navigation UI got enabled, send enabled change event.
      getViewEventApi()?
        .onNavigationUIEnabledChanged(
          viewId: _viewId!,
          navigationUIEnabled: _mapView.isNavigationEnabled
        ) { _ in }
    }

    _mapView.navigationUIDelegate = self
    isAttachedToSession = true
    return result
  }

  func showDestinationMarkers(show: Bool) {
    _mapView.settings.showsDestinationMarkers = show
  }

  func showTrafficLights(show: Bool) {
    _mapView.settings.showsTrafficLights = show
  }

  func showStopSigns(show: Bool) {
    _mapView.settings.showsStopSigns = show
  }

  func isNavigationTripProgressBarEnabled() throws -> Bool {
    _mapView.settings.isNavigationTripProgressBarEnabled
  }

  func setNavigationTripProgressBarEnabled(_ enabled: Bool) {
    _mapView.settings.isNavigationTripProgressBarEnabled = enabled
  }

  func isNavigationHeaderEnabled() -> Bool {
    _mapView.settings.isNavigationHeaderEnabled
  }

  func setNavigationHeaderEnabled(_ enabled: Bool) {
    _mapView.settings.isNavigationHeaderEnabled = enabled
  }

  func isNavigationFooterEnabled() -> Bool {
    _mapView.settings.isNavigationFooterEnabled
  }

  func setNavigationFooterEnabled(_ enabled: Bool) {
    _mapView.settings.isNavigationFooterEnabled = enabled
  }

  func isRecenterButtonEnabled() -> Bool {
    _mapView.settings.isRecenterButtonEnabled
  }

  func setRecenterButtonEnabled(_ enabled: Bool) {
    _mapView.settings.isRecenterButtonEnabled = enabled
  }

  func isSpeedLimitIconEnabled() -> Bool {
    _mapView.shouldDisplaySpeedLimit
  }

  func setSpeedLimitIconEnabled(_ enabled: Bool) {
    _mapView.shouldDisplaySpeedLimit = enabled
  }

  func isSpeedometerEnabled() -> Bool {
    _mapView.shouldDisplaySpeedometer
  }

  func setSpeedometerEnabled(_ enabled: Bool) {
    _mapView.shouldDisplaySpeedometer = enabled
  }

  func isTrafficIncidentCardsEnabled() -> Bool {
    _mapView.settings.showsIncidentCards
  }

  func setTrafficIncidentCardsEnabled(_ enabled: Bool) {
    _mapView.settings.showsIncidentCards = enabled
  }

  func isNavigationUIEnabled() -> Bool {
    _mapView.isNavigationEnabled
  }

  func setNavigationUIEnabled(_ enabled: Bool) {
    if _mapView.isNavigationEnabled != enabled {
      _mapView.isNavigationEnabled = enabled
      getViewEventApi()?
        .onNavigationUIEnabledChanged(viewId: _viewId!, navigationUIEnabled: enabled) { _ in }

      if !enabled {
        let camera = _mapView.camera
        _mapView.animate(to: GMSCameraPosition(
          target: camera.target,
          zoom: camera.zoom,
          bearing: 0.0,
          viewingAngle: 0.0
        ))
      }
    }
  }

  public func getMinZoomPreference() -> Float {
    _mapView.minZoom
  }

  public func getMaxZoomPreference() -> Float {
    _mapView.maxZoom
  }

  public func resetMinMaxZoomPreference() {
    _mapView.setMinZoom(kGMSMinZoomLevel, maxZoom: kGMSMaxZoomLevel)
  }

  public func setMinZoomPreference(minZoomPreference: Float) throws {
    if minZoomPreference > _mapView.maxZoom {
      throw GoogleMapsNavigationViewError.minZoomGreaterThanMaxZoom
    }

    _mapView.setMinZoom(minZoomPreference, maxZoom: _mapView.maxZoom)
  }

  public func setMaxZoomPreference(maxZoomPreference: Float) throws {
    if maxZoomPreference < _mapView.minZoom {
      throw GoogleMapsNavigationViewError.maxZoomLessThanMinZoom
    }

    _mapView.setMinZoom(_mapView.minZoom, maxZoom: maxZoomPreference)
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
        markerController.gmsMarker.map = marker.isVisible() ? _mapView : nil
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
        markerController.gmsMarker.map = updatedMarker.isVisible() ? _mapView : nil
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
    for markerController in _markerControllers {
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
        gmsPolygon.map = polygon.isVisible() ? _mapView : nil
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
        gmsPolygon.map = pigeonPolygon.isVisible() ? _mapView : nil
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
    for gmsPolygon in _gmsPolygons {
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
        gmsPolyline.map = polyline.isVisible() ? _mapView : nil
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
        gmsPolyline.map = pigeonPolyline.isVisible() ? _mapView : nil
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
    for gmsPolyline in _gmsPolylines {
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
        gmsCircle.map = circle.isVisible() ? _mapView : nil
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
        gmsCircle.map = pigeonCircle.isVisible() ? _mapView : nil
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
    for gmsCircle in _gmsCircles {
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
    _mapView.clear()
  }

  private func sendMarkerEvent(marker: GMSMarker, eventType: MarkerEventTypeDto) {
    do {
      let markerController = try findMarkerController(gmsMarker: marker)

      getViewEventApi()?.onMarkerEvent(
        viewId: _viewId!,
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
      getViewEventApi()?.onMarkerDragEvent(
        viewId: _viewId!,
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

  func setConsumeMyLocationButtonClickEventsEnabled(enabled: Bool) {
    _consumeMyLocationButtonClickEventsEnabled = enabled
  }

  func isConsumeMyLocationButtonClickEventsEnabled() -> Bool {
    _consumeMyLocationButtonClickEventsEnabled
  }

  func registerOnCameraChangedListener() {
    // Camera listeners cannot be controlled at runtime, so use this
    // boolean to control if camera changes are sent over the event channel.
    _listenCameraChanges = true
  }

  func setPadding(padding: MapPaddingDto) throws {
    _mapView.padding = UIEdgeInsets(
      top: CGFloat(padding.top),
      left: CGFloat(padding.left),
      bottom: CGFloat(padding.bottom),
      right: CGFloat(padding.right)
    )
  }

  func getPadding() throws -> MapPaddingDto {
    MapPaddingDto(
      top: Int64(_mapView.padding.top),
      left: Int64(_mapView.padding.left),
      bottom: Int64(_mapView.padding.bottom),
      right: Int64(_mapView.padding.right)
    )
  }
}

extension GoogleMapsNavigationView: GMSMapViewNavigationUIDelegate {
  public func mapViewDidTapRecenterButton(_ mapView: GMSMapView) {
    getViewEventApi()?.onRecenterButtonClicked(viewId: _viewId!) { _ in }
  }
}

extension GoogleMapsNavigationView: GMSMapViewDelegate {
  public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    getViewEventApi()?.onMapClickEvent(
      viewId: _viewId!,
      latLng: .init(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      completion: { _ in }
    )
  }

  public func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    getViewEventApi()?.onMapLongClickEvent(
      viewId: _viewId!,
      latLng: .init(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude
      ),
      completion: { _ in }
    )
  }

  public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
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

  public func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .dragStart)
  }

  public func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .dragEnd)
  }

  public func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
    sendMarkerDragEvent(marker: marker, eventType: .drag)
  }

  public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowClicked)
  }

  public func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowClosed)
  }

  public func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
    sendMarkerEvent(marker: marker, eventType: .infoWindowLongClicked)
  }

  public func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
    if let polygon = overlay as? GMSPolygon {
      getViewEventApi()?.onPolygonClicked(
        viewId: _viewId!,
        polygonId: polygon.getPolygonId(),
        completion: { _ in }
      )
    } else if let polyline = overlay as? GMSPolyline {
      getViewEventApi()?.onPolylineClicked(
        viewId: _viewId!,
        polylineId: polyline.getPolylineId(),
        completion: { _ in }
      )
    } else if let circle = overlay as? GMSCircle {
      getViewEventApi()?.onCircleClicked(
        viewId: _viewId!,
        circleId: circle.getCircleId(),
        completion: { _ in }
      )
    }
  }

  public func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
    getViewEventApi()?.onMyLocationClicked(viewId: _viewId!, completion: { _ in })
  }

  public func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    getViewEventApi()?.onMyLocationButtonClicked(viewId: _viewId!, completion: { _ in })
    return _consumeMyLocationButtonClickEventsEnabled
  }

  public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    if _listenCameraChanges {
      let position = Convert.convertCameraPosition(position: mapView.camera)
      getViewEventApi()?.onCameraChanged(
        viewId: _viewId!,
        eventType: gesture ? .moveStartedByGesture : .moveStartedByApi,
        position: position,
        completion: { _ in }
      )
    }
  }

  public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    if _listenCameraChanges {
      getViewEventApi()?.onCameraChanged(
        viewId: _viewId!,
        eventType: .onCameraIdle,
        position: Convert.convertCameraPosition(position: position),
        completion: { _ in }
      )
    }
  }

  public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if _listenCameraChanges {
      getViewEventApi()?.onCameraChanged(
        viewId: _viewId!,
        eventType: .onCameraMove,
        position: Convert.convertCameraPosition(position: position),
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
