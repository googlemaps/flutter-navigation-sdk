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
import XCTest

@testable import google_navigation_flutter

class MockImageRegistry: ImageRegistry {
  let image = UIImage()

  override func findRegisteredImage(imageId: String) -> RegisteredImage? {
    if imageId == "default" {
      return nil
    } else {
      return RegisteredImage(
        imageId: imageId,
        image: image,
        imagePixelRatio: 1.0,
        width: nil,
        height: nil
      )
    }
  }
}

class ConvertTests: XCTestCase {
  func testMapTypeConversion() {
    XCTAssertEqual(Convert.convertMapType(mapType: .hybrid), GMSMapViewType.hybrid)
    XCTAssertEqual(Convert.convertMapType(mapType: .satellite), GMSMapViewType.satellite)
    XCTAssertEqual(Convert.convertMapType(mapType: .normal), GMSMapViewType.normal)
    XCTAssertEqual(Convert.convertMapType(mapType: .terrain), GMSMapViewType.terrain)
    XCTAssertEqual(Convert.convertMapType(mapType: .none), GMSMapViewType.none)
  }

  func testConvertNavigationWayPoint() {
    var gmsWaypoint = GMSNavigationWaypoint(placeID: "id", title: "title")!
    var waypoint = Convert.convertNavigationWayPoint(gmsWaypoint)
    XCTAssertEqual(waypoint.title, gmsWaypoint.title)
    XCTAssertEqual(waypoint.placeID, gmsWaypoint.placeID)
    XCTAssertEqual(waypoint.preferredSegmentHeading, -1)
    XCTAssertEqual(gmsWaypoint.preferredHeading, -1)

    gmsWaypoint = GMSNavigationWaypoint(
      location: CLLocationCoordinate2D(latitude: 64.555, longitude: 65.555),
      title: "title"
    )!
    waypoint = Convert.convertNavigationWayPoint(gmsWaypoint)
    XCTAssertEqual(waypoint.title, gmsWaypoint.title)
    XCTAssertEqual(waypoint.target?.latitude, gmsWaypoint.coordinate.latitude)
    XCTAssertEqual(waypoint.target?.longitude, gmsWaypoint.coordinate.longitude)
    XCTAssertNil(waypoint.placeID)
    XCTAssertNil(gmsWaypoint.placeID)
    XCTAssertEqual(waypoint.preferredSegmentHeading, -1)
    XCTAssertEqual(waypoint.preferredSegmentHeading, -1)

    gmsWaypoint = GMSNavigationWaypoint(
      location: CLLocationCoordinate2D(latitude: 64.555, longitude: 65.555),
      title: "title",
      preferredSegmentHeading: 40
    )!
    waypoint = Convert.convertNavigationWayPoint(gmsWaypoint)
    XCTAssertEqual(waypoint.title, gmsWaypoint.title)
    XCTAssertEqual(waypoint.target?.latitude, gmsWaypoint.coordinate.latitude)
    XCTAssertEqual(waypoint.target?.longitude, gmsWaypoint.coordinate.longitude)
    XCTAssertNil(waypoint.placeID)
    XCTAssertNil(gmsWaypoint.placeID)
    XCTAssertEqual(waypoint.preferredSegmentHeading, 40)
    XCTAssertEqual(waypoint.preferredSegmentHeading, 40)

    gmsWaypoint = GMSNavigationWaypoint(
      location: CLLocationCoordinate2D(latitude: 64.555, longitude: 65.555),
      title: "title",
      preferSameSideOfRoad: true
    )!
    waypoint = Convert.convertNavigationWayPoint(gmsWaypoint)
    XCTAssertEqual(waypoint.title, gmsWaypoint.title)
    XCTAssertEqual(waypoint.target?.latitude, gmsWaypoint.coordinate.latitude)
    XCTAssertEqual(waypoint.target?.longitude, gmsWaypoint.coordinate.longitude)
    XCTAssertNil(waypoint.placeID)
    XCTAssertNil(gmsWaypoint.placeID)
    XCTAssertEqual(waypoint.preferredSegmentHeading, -1)
    XCTAssertEqual(gmsWaypoint.preferredHeading, -1)
    XCTAssertTrue(waypoint.preferSameSideOfRoad!)
    XCTAssertTrue(gmsWaypoint.preferSameSideOfRoad)
  }

  func testConvertWaypointsFromNavigationDestinationDto() {
    let msg = DestinationsDto(
      waypoints: [],
      displayOptions: NavigationDisplayOptionsDto()
    )

    XCTAssertTrue(Convert.convertWaypoints(msg.waypoints).isEmpty)

    let msg2 = DestinationsDto(
      waypoints: [
        .init(
          title: "test",
          target: .init(
            latitude: 55.0,
            longitude: 44.0
          )
        ),
      ],
      displayOptions: NavigationDisplayOptionsDto()
    )

    XCTAssertEqual(Convert.convertWaypoints(msg2.waypoints).count, 1)
    XCTAssertEqual(Convert.convertWaypoints(msg2.waypoints)[0].title, "test")
    XCTAssertEqual(Convert.convertWaypoints(msg2.waypoints)[0].coordinate.latitude, 55.0)
    XCTAssertEqual(Convert.convertWaypoints(msg2.waypoints)[0].coordinate.longitude, 44.0)

    let msg3 = DestinationsDto(
      waypoints: [
        .init(
          title: "test",
          placeID: "id"
        ),
      ],
      displayOptions: NavigationDisplayOptionsDto()
    )

    XCTAssertEqual(Convert.convertWaypoints(msg3.waypoints).count, 1)
    XCTAssertEqual(Convert.convertWaypoints(msg3.waypoints)[0].title, "test")
    XCTAssertEqual(Convert.convertWaypoints(msg3.waypoints)[0].placeID, "id")
    XCTAssertEqual(Convert.convertWaypoints(msg3.waypoints)[0].coordinate.latitude, -180)
    XCTAssertEqual(Convert.convertWaypoints(msg3.waypoints)[0].coordinate.longitude, -180)
  }

  func testConvertRoutingOptionsFromNavigationDestinationDto() {
    let msg = DestinationsDto(
      waypoints: [],
      displayOptions: NavigationDisplayOptionsDto(),
      routingOptions: RoutingOptionsDto(
        alternateRoutesStrategy: .all,
        routingStrategy: .shorter,
        targetDistanceMeters: [40]
      )
    )

    XCTAssertEqual(
      Convert.convertRoutingOptions(msg.routingOptions).targetDistancesMeters![0].int64Value,
      msg.routingOptions!.targetDistanceMeters![0]
    )
    XCTAssertTrue(Convert.convertRoutingOptions(msg.routingOptions).alternateRoutesStrategy == .all)
    XCTAssertTrue(Convert.convertRoutingOptions(msg.routingOptions).routingStrategy == .shorter)

    let msg2 = DestinationsDto(
      waypoints: [],
      displayOptions: NavigationDisplayOptionsDto()
    )

    XCTAssertNotNil(Convert.convertRoutingOptions(msg2.routingOptions).routingStrategy)
    XCTAssertNotNil(Convert.convertRoutingOptions(msg2.routingOptions).alternateRoutesStrategy)
    XCTAssertNil(Convert.convertRoutingOptions(msg2.routingOptions).targetDistancesMeters)
  }

  func testConvertRouteStatus() {
    XCTAssertTrue(Convert.convertRouteStatus(.waypointError) == .waypointError)
    XCTAssertTrue(Convert.convertRouteStatus(.apiKeyNotAuthorized) == .apiKeyNotAuthorized)
    XCTAssertTrue(Convert.convertRouteStatus(.canceled) == .statusCanceled)
    XCTAssertTrue(Convert
      .convertRouteStatus(.duplicateWaypointsError) == .duplicateWaypointsError)
    XCTAssertTrue(Convert.convertRouteStatus(.internalError) == .internalError)
    XCTAssertTrue(Convert.convertRouteStatus(.locationUnavailable) == .locationUnavailable)
    XCTAssertTrue(Convert.convertRouteStatus(.OK) == .statusOk)
    XCTAssertTrue(Convert.convertRouteStatus(.networkError) == .networkError)
    XCTAssertTrue(Convert.convertRouteStatus(.noRouteFound) == .routeNotFound)
    XCTAssertTrue(Convert.convertRouteStatus(.noWaypointsError) == .noWaypointsError)
    XCTAssertTrue(Convert.convertRouteStatus(.quotaExceeded) == .quotaExceeded)
    XCTAssertTrue(Convert.convertRouteStatus(.quotaExceeded) == .quotaExceeded)
    XCTAssertTrue(Convert.convertRouteStatus(.waypointError) == .waypointError)
  }

  func testConvertTravelMode() {
    XCTAssertTrue(Convert.convertTravelMode(nil) == .driving)
    XCTAssertTrue(Convert.convertTravelMode(.driving) == .driving)
    XCTAssertTrue(Convert.convertTravelMode(.cycling) == .cycling)
    XCTAssertTrue(Convert.convertTravelMode(.walking) == .walking)
    XCTAssertTrue(Convert.convertTravelMode(.taxi) == .taxicab)
    XCTAssertTrue(Convert.convertTravelMode(.twoWheeler) == .twoWheeler)
  }

  func testConvertGMSSpeedAlertSeverity() {
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(gmsSpeedAlertSeverity: .unknown) == .unknown)
    XCTAssertTrue(Convert
      .convertSpeedAlertSeverity(gmsSpeedAlertSeverity: .notSpeeding) == .notSpeeding)
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(gmsSpeedAlertSeverity: .minor) == .minor)
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(gmsSpeedAlertSeverity: .major) == .major)
  }

  func testConvertSpeedAlertSeverity() {
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(speedAlertSeverity: .unknown) == .unknown)
    XCTAssertTrue(Convert
      .convertSpeedAlertSeverity(speedAlertSeverity: .notSpeeding) == .notSpeeding)
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(speedAlertSeverity: .minor) == .minor)
    XCTAssertTrue(Convert.convertSpeedAlertSeverity(speedAlertSeverity: .major) == .major)
  }

  func testConvertNavigationAudioGuidanceType() {
    XCTAssertTrue(Convert.convertNavigationAudioGuidanceType(.silent) == .silent)
    XCTAssertTrue(Convert.convertNavigationAudioGuidanceType(.alertsOnly) == .alertsOnly)
    XCTAssertTrue(Convert
      .convertNavigationAudioGuidanceType(.alertsAndGuidance) == .alertsAndGuidance)
  }

  func testMarkerDtoToGMSMarkerAndBack() {
    var markerDto = MarkerDto(
      markerId: "1345",
      options: .init(
        alpha: 0.5,
        anchor: MarkerAnchorDto(u: 0.5, v: 0.7),
        draggable: false,
        flat: false,
        consumeTapEvents: false,
        position: LatLngDto(latitude: 23.0, longitude: 24.0),
        rotation: 45.0,
        infoWindow: InfoWindowDto(
          title: "title",
          snippet: "snippet",
          anchor: MarkerAnchorDto(u: 0.6, v: 0.8)
        ),
        visible: false,
        zIndex: 4.0,
        icon: ImageDescriptorDto(registeredImageId: "default", imagePixelRatio: 1.0)
      )
    )

    let imageRegistry = MockImageRegistry()
    let markerController = MarkerController(markerId: markerDto.markerId)
    markerController.update(from: markerDto, imageRegistry: imageRegistry)
    let gmsMarker = markerController.gmsMarker

    XCTAssertEqual(Double(gmsMarker.opacity), markerDto.options.alpha)
    XCTAssertEqual(gmsMarker.groundAnchor.y, markerDto.options.anchor.v)
    XCTAssertEqual(gmsMarker.groundAnchor.x, markerDto.options.anchor.u)
    XCTAssertEqual(gmsMarker.isDraggable, markerDto.options.draggable)
    XCTAssertEqual(gmsMarker.isFlat, markerDto.options.flat)
    XCTAssertEqual(gmsMarker.isTappable, true)
    XCTAssertEqual(markerController.consumeTapEvents, markerDto.options.consumeTapEvents)
    XCTAssertEqual(gmsMarker.infoWindowAnchor.y, markerDto.options.infoWindow.anchor.v)
    XCTAssertEqual(gmsMarker.infoWindowAnchor.x, markerDto.options.infoWindow.anchor.u)
    XCTAssertEqual(gmsMarker.position.longitude, markerDto.options.position.longitude)
    XCTAssertEqual(gmsMarker.position.latitude, markerDto.options.position.latitude)
    XCTAssertEqual(gmsMarker.rotation, markerDto.options.rotation)
    XCTAssertEqual(gmsMarker.snippet, markerDto.options.infoWindow.snippet)
    XCTAssertEqual(gmsMarker.title, markerDto.options.infoWindow.title)
    XCTAssertEqual(gmsMarker.zIndex, Int32(markerDto.options.zIndex))
    XCTAssertNil(gmsMarker.icon)

    markerDto = markerController.toMarkerDto()

    XCTAssertEqual(markerDto.options.alpha, Double(gmsMarker.opacity))
    XCTAssertEqual(markerDto.options.anchor.u, gmsMarker.groundAnchor.x)
    XCTAssertEqual(markerDto.options.anchor.v, gmsMarker.groundAnchor.y)
    XCTAssertEqual(markerDto.options.draggable, gmsMarker.isDraggable)
    XCTAssertEqual(markerDto.options.flat, gmsMarker.isFlat)
    XCTAssertEqual(markerDto.options.consumeTapEvents, markerController.consumeTapEvents)
    XCTAssertEqual(markerDto.options.infoWindow.anchor.u, gmsMarker.infoWindowAnchor.x)
    XCTAssertEqual(markerDto.options.infoWindow.anchor.v, gmsMarker.infoWindowAnchor.y)
    XCTAssertEqual(markerDto.options.position.latitude, gmsMarker.position.latitude)
    XCTAssertEqual(markerDto.options.position.longitude, gmsMarker.position.longitude)
    XCTAssertEqual(markerDto.options.rotation, gmsMarker.rotation)
    XCTAssertEqual(markerDto.options.infoWindow.title, gmsMarker.title)
    XCTAssertEqual(markerDto.options.infoWindow.snippet, gmsMarker.snippet)
    XCTAssertEqual(Int32(markerDto.options.zIndex), gmsMarker.zIndex)
    XCTAssertNil(markerDto.options.icon.registeredImageId)
  }

  func testUpdateGMSMarker() {
    let marker = MarkerDto(
      markerId: "1345",
      options: .init(
        alpha: 0.5,
        anchor: MarkerAnchorDto(u: 0.5, v: 0.7),
        draggable: false,
        flat: false,
        consumeTapEvents: false,
        position: LatLngDto(latitude: 23.0, longitude: 24.0),
        rotation: 45.0,
        infoWindow: InfoWindowDto(
          title: "title",
          snippet: "snippet",
          anchor: MarkerAnchorDto(u: 0.6, v: 0.8)
        ),
        visible: false,
        zIndex: 4.0,
        icon: ImageDescriptorDto(registeredImageId: "default", imagePixelRatio: 1.0)
      )
    )

    let markerController = MarkerController(markerId: marker.markerId)
    let imageRegistry = MockImageRegistry()
    markerController.update(from: marker, imageRegistry: imageRegistry)

    let updatedMarker = MarkerDto(
      markerId: "1345",
      options: .init(
        alpha: 0.5,
        anchor: MarkerAnchorDto(u: 0.5, v: 0.7),
        draggable: false,
        flat: false,
        consumeTapEvents: false,
        position: LatLngDto(latitude: 23.0, longitude: 24.0),
        rotation: 45.0,
        infoWindow: InfoWindowDto(
          title: "title",
          snippet: "snippet",
          anchor: MarkerAnchorDto(u: 0.6, v: 0.8)
        ),
        visible: false,
        zIndex: 4.0,
        icon: ImageDescriptorDto(registeredImageId: "Image_0", imagePixelRatio: 1.0)
      )
    )

    markerController.update(from: updatedMarker, imageRegistry: imageRegistry)
    let gmsMarker = markerController.gmsMarker

    XCTAssertEqual(Double(gmsMarker.opacity), updatedMarker.options.alpha)
    XCTAssertEqual(gmsMarker.groundAnchor.y, updatedMarker.options.anchor.v)
    XCTAssertEqual(gmsMarker.groundAnchor.x, updatedMarker.options.anchor.u)
    XCTAssertEqual(gmsMarker.isDraggable, updatedMarker.options.draggable)
    XCTAssertEqual(gmsMarker.isFlat, updatedMarker.options.flat)
    XCTAssertEqual(gmsMarker.isTappable, true)
    XCTAssertEqual(markerController.consumeTapEvents, updatedMarker.options.consumeTapEvents)
    XCTAssertEqual(
      gmsMarker.infoWindowAnchor.y,
      updatedMarker.options.infoWindow.anchor.v
    )
    XCTAssertEqual(
      gmsMarker.infoWindowAnchor.x,
      updatedMarker.options.infoWindow.anchor.u
    )
    XCTAssertEqual(
      gmsMarker.position.longitude,
      updatedMarker.options.position.longitude
    )
    XCTAssertEqual(
      gmsMarker.position.latitude,
      updatedMarker.options.position.latitude
    )
    XCTAssertEqual(gmsMarker.rotation, updatedMarker.options.rotation)
    XCTAssertEqual(gmsMarker.snippet, updatedMarker.options.infoWindow.snippet)
    XCTAssertEqual(gmsMarker.title, updatedMarker.options.infoWindow.title)
    XCTAssertEqual(gmsMarker.zIndex, Int32(updatedMarker.options.zIndex))
    XCTAssertEqual(gmsMarker.icon, imageRegistry.image)
  }

  func testPigeonPolygonToGmsPolygon() {
    let polygon = PolygonDto(
      polygonId: "Polygon_0",
      options: .init(
        points: [LatLngDto(latitude: 10.0, longitude: 20.0),
                 LatLngDto(latitude: 30.0, longitude: 40.0)],
        holes: [PolygonHoleDto(points: [
          LatLngDto(latitude: 50.0, longitude: 60.0),
          LatLngDto(latitude: 70.0, longitude: 80.0),
        ])],
        clickable: true,
        fillColor: UIColor.red.toRgb()!,
        geodesic: true,
        strokeColor: UIColor.blue.toRgb()!,
        strokeWidth: 3.0,
        visible: true,
        zIndex: 2.0
      )
    )

    let gmsPolygon = GMSPolygon()
    gmsPolygon.update(from: polygon)

    XCTAssertEqual(gmsPolygon.path?.coordinate(at: 0).latitude, 10.0)
    XCTAssertEqual(gmsPolygon.path?.coordinate(at: 0).longitude, 20.0)
    XCTAssertEqual(gmsPolygon.path?.coordinate(at: 1).latitude, 30.0)
    XCTAssertEqual(gmsPolygon.path?.coordinate(at: 1).longitude, 40.0)
    XCTAssertEqual(gmsPolygon.holes?[0].coordinate(at: 0).latitude, 50.0)
    XCTAssertEqual(gmsPolygon.holes?[0].coordinate(at: 0).longitude, 60.0)
    XCTAssertEqual(gmsPolygon.holes?[0].coordinate(at: 1).latitude, 70.0)
    XCTAssertEqual(gmsPolygon.holes?[0].coordinate(at: 1).longitude, 80.0)
    XCTAssertEqual(gmsPolygon.isTappable, true)
    XCTAssertEqual(gmsPolygon.fillColor, UIColor.red)
    XCTAssertEqual(gmsPolygon.geodesic, true)
    XCTAssertEqual(gmsPolygon.strokeColor, UIColor.blue)
    XCTAssertEqual(gmsPolygon.strokeWidth, 3.0)
    XCTAssertEqual(gmsPolygon.zIndex, 2)
  }

  func testUpdatedGmsPolygon() {
    let polygon = PolygonDto(
      polygonId: "Polygon_0",
      options: .init(
        points: [LatLngDto(latitude: 10.0, longitude: 20.0),
                 LatLngDto(latitude: 30.0, longitude: 40.0)],
        holes: [PolygonHoleDto(points: [
          LatLngDto(latitude: 50.0, longitude: 60.0),
          LatLngDto(latitude: 70.0, longitude: 80.0),
        ])],
        clickable: true,
        fillColor: UIColor.red.toRgb()!,
        geodesic: true,
        strokeColor: UIColor.blue.toRgb()!,
        strokeWidth: 3.0,
        visible: true,
        zIndex: 2.0
      )
    )

    let gmsPolygon = GMSPolygon()
    gmsPolygon.update(from: polygon)

    let updatedPolygon = PolygonDto(
      polygonId: "Polygon_0",
      options: .init(
        points: [],
        holes: [],
        clickable: false,
        fillColor: UIColor.green.toRgb()!,
        geodesic: false,
        strokeColor: UIColor.red.toRgb()!,
        strokeWidth: 4.0,
        visible: false,
        zIndex: 3.0
      )
    )

    gmsPolygon.update(from: updatedPolygon)

    XCTAssertEqual(gmsPolygon.path?.count(), 0)
    XCTAssertEqual(gmsPolygon.holes?.count, 0)
    XCTAssertEqual(gmsPolygon.isTappable, false)
    XCTAssertEqual(gmsPolygon.fillColor, UIColor.green)
    XCTAssertEqual(gmsPolygon.geodesic, false)
    XCTAssertEqual(gmsPolygon.strokeColor, UIColor.red)
    XCTAssertEqual(gmsPolygon.strokeWidth, 4.0)
    XCTAssertEqual(gmsPolygon.zIndex, 3)
  }

  func testGmsPolygonToPigeonPolygon() {
    let gmsPolygon = GMSPolygon()

    let path = GMSMutablePath()
    path.add(.init(latitude: 10.0, longitude: 20.0))
    path.add(.init(latitude: 30.0, longitude: 40.0))
    gmsPolygon.path = path

    let hole = GMSMutablePath()
    hole.add(.init(latitude: 50.0, longitude: 60.0))
    gmsPolygon.holes = [hole]

    gmsPolygon.isTappable = true
    gmsPolygon.fillColor = UIColor.red
    gmsPolygon.geodesic = true
    gmsPolygon.strokeColor = UIColor.blue
    gmsPolygon.strokeWidth = 3.0
    gmsPolygon.zIndex = 2

    let polygon = gmsPolygon.toPigeonPolygon()

    XCTAssertEqual(polygon.options.points[0]?.latitude, 10.0)
    XCTAssertEqual(polygon.options.points[0]?.longitude, 20.0)
    XCTAssertEqual(polygon.options.points[1]?.latitude, 30.0)
    XCTAssertEqual(polygon.options.points[1]?.longitude, 40.0)
    XCTAssertEqual(polygon.options.holes[0]?.points[0]?.latitude, 50.0)
    XCTAssertEqual(polygon.options.holes[0]?.points[0]?.longitude, 60.0)
    XCTAssertEqual(polygon.options.clickable, true)
    XCTAssertEqual(polygon.options.fillColor, UIColor.red.toRgb())
    XCTAssertEqual(polygon.options.geodesic, true)
    XCTAssertEqual(polygon.options.strokeColor, UIColor.blue.toRgb())
    XCTAssertEqual(polygon.options.strokeWidth, 3.0)
    XCTAssertEqual(polygon.options.zIndex, 2.0)
  }

  func testConvertCameraPositionItem() {
    let cameraPositionItem = CameraPositionDto(
      bearing: 5.0,
      target: .init(latitude: 23.23, longitude: 44.44),
      tilt: 90.0,
      zoom: 2.0
    )
    let gmsCameraPosition = Convert.convertCameraPosition(position: cameraPositionItem)

    XCTAssertEqual(gmsCameraPosition.bearing, cameraPositionItem.bearing)
    XCTAssertEqual(gmsCameraPosition.viewingAngle, cameraPositionItem.tilt)
    XCTAssertEqual(Double(gmsCameraPosition.zoom), cameraPositionItem.zoom)
    XCTAssertEqual(gmsCameraPosition.target.longitude, cameraPositionItem.target.longitude)
    XCTAssertEqual(gmsCameraPosition.target.latitude, cameraPositionItem.target.latitude)
  }

  func testConvertLatLngItem() {
    let latLngPoint = LatLngDto(latitude: 44.0, longitude: 55.0)
    let coordinate = Convert.convertLatLngFromDto(point: latLngPoint)

    XCTAssertEqual(latLngPoint.latitude, coordinate.latitude)
    XCTAssertEqual(latLngPoint.longitude, coordinate.longitude)
  }

  func testConvertLatLngBoundsDto() {
    let boundsItem = LatLngBoundsDto(
      southwest: .init(latitude: 22.0, longitude: 33.0),
      northeast: .init(latitude: 44.0, longitude: 55.0)
    )

    let gmsCoordinateBounds = Convert.convertLatLngBounds(bounds: boundsItem)

    XCTAssertEqual(boundsItem.southwest.longitude, gmsCoordinateBounds.southWest.longitude)
    XCTAssertEqual(boundsItem.southwest.latitude, gmsCoordinateBounds.southWest.latitude)
    XCTAssertEqual(boundsItem.northeast.longitude, gmsCoordinateBounds.northEast.longitude)
    XCTAssertEqual(boundsItem.northeast.latitude, gmsCoordinateBounds.northEast.latitude)
  }

  func testConvertMapOptions() {
    let mapOptions = MapOptionsDto(
      cameraPosition: .init(
        bearing: 40.0,
        target: .init(latitude: 44.0, longitude: 55.0),
        tilt: 30.0,
        zoom: 2.0
      ),
      mapType: .normal,
      compassEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomGesturesEnabled: false,
      scrollGesturesEnabledDuringRotateOrZoom: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false
    )

    let navigationViewOptions =
      NavigationViewOptionsDto(navigationUIEnabledPreference: NavigationUIEnabledPreferenceDto
        .automatic)

    let configuration = Convert.convertMapOptions(mapOptions)

    // Make sure these match because comparison between different enums is complicated.
    XCTAssert(mapOptions.mapType == .normal)
    XCTAssert(configuration.mapType == .normal)
    XCTAssertEqual(mapOptions.cameraPosition.bearing, configuration.cameraPosition!.bearing)
    XCTAssertEqual(
      mapOptions.cameraPosition.target.latitude,
      configuration.cameraPosition!.target.latitude
    )
    XCTAssertEqual(
      mapOptions.cameraPosition.target.longitude,
      configuration.cameraPosition!.target.longitude
    )
    XCTAssertEqual(mapOptions.cameraPosition.tilt, configuration.cameraPosition!.viewingAngle)
    XCTAssertEqual(mapOptions.cameraPosition.zoom, Double(configuration.cameraPosition!.zoom))
    XCTAssertEqual(mapOptions.compassEnabled, configuration.compassEnabled)
    XCTAssertEqual(mapOptions.rotateGesturesEnabled, configuration.rotateGesturesEnabled)
    XCTAssertEqual(mapOptions.scrollGesturesEnabled, configuration.scrollGesturesEnabled)
    XCTAssertEqual(mapOptions.tiltGesturesEnabled, configuration.tiltGesturesEnabled)
    XCTAssertEqual(mapOptions.zoomControlsEnabled, configuration.zoomGesturesEnabled)
    XCTAssertEqual(
      mapOptions.scrollGesturesEnabledDuringRotateOrZoom,
      configuration.scrollGesturesEnabledDuringRotateOrZoom
    )
  }

  func testConvertPath() {
    let mutableGMSPath = GMSMutablePath()
    mutableGMSPath.add(.init(latitude: 44.0, longitude: 55.0))
    let path = Convert.convertPath(mutableGMSPath)
    XCTAssertEqual(path.count, Int(mutableGMSPath.count()))
    XCTAssertEqual(mutableGMSPath.coordinate(at: 0).longitude, path[0].longitude)
    XCTAssertEqual(mutableGMSPath.coordinate(at: 0).latitude, path[0].latitude)
  }

  func testUpdateGMSPolylineFromPigeonPolyline() {
    let gmsPolyline = GMSPolyline()
    let polyline = PolylineDto(
      polylineId: "test_id_1",
      options: .init(
        points: [.init(latitude: 44.0, longitude: 55.0)],
        clickable: true,
        geodesic: true,
        strokeColor: 55,
        strokeJointType: .bevel,
        strokePattern: [.init(type: .dash, length: 22)],
        strokeWidth: 44.0,
        visible: true,
        zIndex: 4.0,
        spans: [.init(length: 99, style: .init(solidColor: 44))]
      )
    )
    gmsPolyline.update(from: polyline)
    XCTAssertEqual(
      gmsPolyline.path?.coordinate(at: 0).latitude,
      polyline.options.points![0]!.latitude
    )
    XCTAssertEqual(
      gmsPolyline.path?.coordinate(at: 0).longitude,
      polyline.options.points![0]!.longitude
    )
    XCTAssertEqual(gmsPolyline.isTappable, polyline.options.clickable)
    XCTAssertEqual(gmsPolyline.geodesic, polyline.options.geodesic)
    XCTAssertEqual(gmsPolyline.strokeColor, UIColor(from: polyline.options.strokeColor!))
    XCTAssertEqual(gmsPolyline.strokeWidth, polyline.options.strokeWidth)
    XCTAssertEqual(gmsPolyline.zIndex, Int32(polyline.options.zIndex!))
    XCTAssertEqual(gmsPolyline.spans![0].segments, polyline.options.spans[0]!.length)
  }

  func testSetPolylineId() {
    let gmsPolyline = GMSPolyline()
    let testId = "test_id_1"
    gmsPolyline.setPolylineId(testId)
    XCTAssertEqual(gmsPolyline.getPolylineId(), testId)
  }

  func testPigeonPolylineToGMSAndBackToPigeon() {
    let gmsPolyline = GMSPolyline()
    let polyline = PolylineDto(
      polylineId: "test_id_1",
      options: .init(
        points: [.init(latitude: 44.0, longitude: 55.0)],
        clickable: true,
        geodesic: true,
        strokeColor: 55,
        strokeJointType: .bevel,
        strokePattern: [.init(type: .dash, length: 22)],
        strokeWidth: 44.0,
        visible: true,
        zIndex: 4.0,
        spans: [.init(length: 99, style: .init(solidColor: 44))]
      )
    )
    gmsPolyline.update(from: polyline)

    let pigeonPolyline = gmsPolyline.toPigeonPolyline()
    XCTAssertEqual(
      pigeonPolyline.options.points![0]!.latitude,
      polyline.options.points![0]!.latitude
    )
    XCTAssertEqual(
      pigeonPolyline.options.points![0]!.longitude,
      polyline.options.points![0]!.longitude
    )
    XCTAssertEqual(pigeonPolyline.options.clickable, polyline.options.clickable)
    XCTAssertEqual(pigeonPolyline.options.geodesic, polyline.options.geodesic)
    XCTAssertEqual(pigeonPolyline.options.strokeColor, polyline.options.strokeColor)
    XCTAssertEqual(pigeonPolyline.options.strokeWidth, polyline.options.strokeWidth)
    XCTAssertEqual(pigeonPolyline.options.zIndex, polyline.options.zIndex)
    XCTAssertEqual(pigeonPolyline.options.spans[0]!.length, polyline.options.spans[0]!.length)
  }

  func testUpdateGMSCircleFromPigeonCircle() {
    let gmsCircle = GMSCircle()
    let circle = CircleDto(
      circleId: "test_id_1",
      options: .init(
        position: .init(latitude: 44.0, longitude: 55.0),
        radius: 1000.0,
        strokeWidth: 43,
        strokeColor: UIColor.black.toRgb()!,
        strokePattern: [],
        fillColor: UIColor.black.toRgb()!,
        zIndex: 1,
        visible: true,
        clickable: true
      )
    )
    gmsCircle.update(from: circle)
    XCTAssertEqual(
      gmsCircle.position.latitude,
      circle.options.position.latitude
    )
    XCTAssertEqual(
      gmsCircle.position.longitude,
      circle.options.position.longitude
    )
    XCTAssertEqual(gmsCircle.radius, circle.options.radius)
    XCTAssertEqual(gmsCircle.strokeWidth, circle.options.strokeWidth)
    XCTAssertEqual(gmsCircle.strokeColor?.toRgb()!, circle.options.strokeColor)
    XCTAssertEqual(gmsCircle.fillColor?.toRgb()!, circle.options.fillColor)
    XCTAssertEqual(gmsCircle.zIndex, Int32(circle.options.zIndex))
    XCTAssertEqual(gmsCircle.isTappable, circle.options.clickable)
  }

  func testSetCircleId() {
    let gmsCircle = GMSCircle()
    let testId = "test_id_1"
    gmsCircle.setCircleId(testId)
    XCTAssertEqual(gmsCircle.getCircleId(), testId)
  }

  func testPigeonCircleToGMSAndBackToPigeon() {
    let gmsCircle = GMSCircle()
    let circle = CircleDto(
      circleId: "test_id_1",
      options: .init(
        position: .init(latitude: 44.0, longitude: 55.0),
        radius: 1000.0,
        strokeWidth: 43,
        strokeColor: UIColor.black.toRgb()!,
        strokePattern: [],
        fillColor: UIColor.black.toRgb()!,
        zIndex: 1,
        visible: true,
        clickable: true
      )
    )
    gmsCircle.update(from: circle)

    let pigeonCircle = gmsCircle.toPigeonCircle()
    XCTAssertEqual(
      pigeonCircle.options.position.latitude,
      circle.options.position.latitude
    )
    XCTAssertEqual(
      pigeonCircle.options.position.longitude,
      circle.options.position.longitude
    )
    XCTAssertEqual(pigeonCircle.options.radius, circle.options.radius)
    XCTAssertEqual(pigeonCircle.options.strokeWidth, circle.options.strokeWidth)
    XCTAssertEqual(pigeonCircle.options.strokeColor, circle.options.strokeColor)
    XCTAssertEqual(pigeonCircle.options.fillColor, circle.options.fillColor)
    XCTAssertEqual(pigeonCircle.options.zIndex, circle.options.zIndex)
    XCTAssertEqual(pigeonCircle.options.clickable, circle.options.clickable)
  }
}
