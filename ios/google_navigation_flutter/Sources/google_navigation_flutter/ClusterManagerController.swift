// Copyright 2026 Google LLC
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

import Foundation
import GoogleMaps
import GoogleMapsUtils

/// Controller for managing a single GMUClusterManager instance.
class ClusterManagerController: NSObject {
  let clusterManagerId: String
  private let mapView: GMSMapView
  private let viewEventApi: ViewEventApi?
  private let viewId: Int64?
  private let imageRegistry: ImageRegistry

  private var clusterManager: GMUClusterManager!
  private var clusterRenderer: ClusterRenderer!
  private var markerToClusterItem: [GMSMarker: MarkerClusterItem] = [:]

  init(
    clusterManagerId: String,
    mapView: GMSMapView,
    viewEventApi: ViewEventApi?,
    viewId: Int64?,
    imageRegistry: ImageRegistry
  ) {
    self.clusterManagerId = clusterManagerId
    self.mapView = mapView
    self.viewEventApi = viewEventApi
    self.viewId = viewId
    self.imageRegistry = imageRegistry
    super.init()

    // Initialize cluster manager with custom renderer
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    clusterRenderer = ClusterRenderer(
      mapView: mapView,
      clusterIconGenerator: iconGenerator,
      imageRegistry: imageRegistry
    )
    clusterRenderer.customDelegate = self

    clusterManager = GMUClusterManager(
      map: mapView,
      algorithm: algorithm,
      renderer: clusterRenderer
    )
  }

  /// Adds a marker item to the cluster.
  func addItem(_ item: MarkerClusterItem) {
    clusterManager.add(item)
  }

  /// Removes a marker item from the cluster.
  func removeItem(_ item: MarkerClusterItem) {
    clusterManager.remove(item)
  }

  /// Clears all items from the cluster.
  func clearItems() {
    clusterManager.clearItems()
    markerToClusterItem.removeAll()
  }

  /// Triggers clustering calculation.
  func cluster() {
    clusterManager.cluster()
  }

  /// Returns the underlying GMUClusterManager instance.
  func getClusterManager() -> GMUClusterManager {
    clusterManager
  }

  /// Gets all current clusters.
  func getClusters() -> [ClusterDto] {
    var clusters: [ClusterDto] = []

    // Get all clusters from the algorithm
    if let algorithm = clusterManager.algorithm as? GMUNonHierarchicalDistanceBasedAlgorithm {
      for item in algorithm.clusters(atZoom: mapView.camera.zoom) {
        if let cluster = item as? GMUStaticCluster {
          let markerIds = cluster.items.compactMap { ($0 as? MarkerClusterItem)?.markerId }
          let position = LatLngDto(
            latitude: cluster.position.latitude,
            longitude: cluster.position.longitude
          )

          clusters.append(
            ClusterDto(
              clusterManagerId: clusterManagerId,
              position: position,
              markerIds: markerIds
            ))
        }
      }
    }

    return clusters
  }

  /// Finds the cluster item associated with a marker.
  func findClusterItem(marker: GMSMarker) -> MarkerClusterItem? {
    markerToClusterItem[marker]
  }

  /// Custom renderer for cluster items.
  /// Handles marker rendering and stores marker-to-item mapping.
  class ClusterRenderer: GMUDefaultClusterRenderer, GMUClusterRendererDelegate {
    weak var customDelegate: ClusterRendererDelegate?
    private let imageRegistry: ImageRegistry

    init(
      mapView: GMSMapView,
      clusterIconGenerator: GMUClusterIconGenerator,
      imageRegistry: ImageRegistry
    ) {
      self.imageRegistry = imageRegistry
      super.init(mapView: mapView, clusterIconGenerator: clusterIconGenerator)
      self.delegate = self
    }

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
      guard let item = marker.userData as? MarkerClusterItem else {
        return
      }

      let itemOptions = item.getMarkerDto().options

      marker.title = itemOptions.infoWindow.title
      marker.snippet = itemOptions.infoWindow.snippet
      marker.opacity = Float(itemOptions.alpha)
      marker.isDraggable = itemOptions.draggable
      marker.isFlat = itemOptions.flat
      marker.isTappable = true
      marker.rotation = itemOptions.rotation
      marker.zIndex = Int32(itemOptions.zIndex)
      marker.groundAnchor = CGPoint(x: itemOptions.anchor.u, y: itemOptions.anchor.v)
      marker.infoWindowAnchor = CGPoint(
        x: itemOptions.infoWindow.anchor.u,
        y: itemOptions.infoWindow.anchor.v
      )

      if let registeredImage = item.registeredImage {
        marker.icon = registeredImage.image
      }

      // Store the mapping between marker and cluster item
      customDelegate?.clusterRenderer(self, didRenderMarker: marker, forClusterItem: item)
    }
  }
}

/// Protocol for cluster renderer callbacks.
protocol ClusterRendererDelegate: AnyObject {
  func clusterRenderer(
    _ renderer: ClusterManagerController.ClusterRenderer,
    didRenderMarker marker: GMSMarker,
    forClusterItem item: MarkerClusterItem
  )
}

extension ClusterManagerController: ClusterRendererDelegate {
  func clusterRenderer(
    _ renderer: ClusterRenderer,
    didRenderMarker marker: GMSMarker,
    forClusterItem item: MarkerClusterItem
  ) {
    markerToClusterItem[marker] = item
  }
}
