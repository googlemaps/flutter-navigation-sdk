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

/// Controller for managing multiple ClusterManager instances.
class ClusterManagersController {
  private let mapView: GMSMapView
  private let viewEventApi: ViewEventApi?
  private let viewId: Int64?
  private let imageRegistry: ImageRegistry

  private var clusterManagers: [String: ClusterManagerController] = [:]
  private var clusterItemsByManager: [String: [String: MarkerClusterItem]] = [:]

  init(
    mapView: GMSMapView,
    viewEventApi: ViewEventApi?,
    viewId: Int64?,
    imageRegistry: ImageRegistry
  ) {
    self.mapView = mapView
    self.viewEventApi = viewEventApi
    self.viewId = viewId
    self.imageRegistry = imageRegistry
  }

  /// Adds a new cluster manager.
  func addClusterManager(clusterManagerId: String) -> ClusterManagerController? {
    if let existingManager = clusterManagers[clusterManagerId] {
      return existingManager
    }

    let controller = ClusterManagerController(
      clusterManagerId: clusterManagerId,
      mapView: mapView,
      viewEventApi: viewEventApi,
      viewId: viewId,
      imageRegistry: imageRegistry
    )

    clusterManagers[clusterManagerId] = controller
    clusterItemsByManager[clusterManagerId] = [:]

    return controller
  }

  /// Removes a cluster manager.
  func removeClusterManager(clusterManagerId: String) {
    clusterManagers[clusterManagerId]?.clearItems()
    clusterManagers.removeValue(forKey: clusterManagerId)
    clusterItemsByManager.removeValue(forKey: clusterManagerId)
  }

  /// Clears all cluster managers.
  func clearClusterManagers() {
    for controller in clusterManagers.values {
      controller.clearItems()
    }
    clusterManagers.removeAll()
    clusterItemsByManager.removeAll()
  }

  /// Gets a cluster manager by ID.
  func getClusterManager(clusterManagerId: String) -> ClusterManagerController? {
    clusterManagers[clusterManagerId]
  }

  /// Gets all cluster manager IDs.
  func getClusterManagerIds() -> [String] {
    Array(clusterManagers.keys)
  }

  /// Adds a marker to its cluster manager.
  func addMarkerToCluster(
    markerDto: MarkerDto,
    registeredImage: RegisteredImage?,
    consumeTapEvents: Bool
  ) {
    guard let clusterManagerId = markerDto.options.clusterManagerId else { return }
    guard let controller = clusterManagers[clusterManagerId] else { return }

    let item = MarkerClusterItem(
      markerId: markerDto.markerId,
      clusterManagerId: clusterManagerId,
      markerDto: markerDto,
      registeredImage: registeredImage,
      consumeTapEvents: consumeTapEvents
    )

    controller.addItem(item)
    clusterItemsByManager[clusterManagerId]?[markerDto.markerId] = item
    controller.cluster()
  }

  /// Removes a marker from its cluster manager.
  func removeMarkerFromCluster(markerId: String, clusterManagerId: String) {
    guard let controller = clusterManagers[clusterManagerId] else { return }
    guard let item = clusterItemsByManager[clusterManagerId]?[markerId] else { return }

    clusterItemsByManager[clusterManagerId]?.removeValue(forKey: markerId)
    controller.removeItem(item)
    controller.cluster()
  }

  /// Updates a marker in its cluster manager.
  func updateMarkerInCluster(
    markerDto: MarkerDto,
    registeredImage: RegisteredImage?,
    consumeTapEvents: Bool
  ) {
    guard let clusterManagerId = markerDto.options.clusterManagerId else { return }

    // Remove old item and add updated one
    removeMarkerFromCluster(markerId: markerDto.markerId, clusterManagerId: clusterManagerId)
    addMarkerToCluster(
      markerDto: markerDto,
      registeredImage: registeredImage,
      consumeTapEvents: consumeTapEvents
    )
  }

  /// Called when camera stops moving to refresh all clusters.
  func onCameraIdle() {
    for controller in clusterManagers.values {
      controller.cluster()
    }
  }

  /// Finds which cluster manager owns a marker.
  func findClusterItem(marker: GMSMarker) -> MarkerClusterItem? {
    for controller in clusterManagers.values {
      if let item = controller.findClusterItem(marker: marker) {
        return item
      }
    }
    return nil
  }

  /// Gets clusters for a specific cluster manager.
  func getClusters(clusterManagerId: String) -> [ClusterDto] {
    clusterManagers[clusterManagerId]?.getClusters() ?? []
  }

  /// Gets all clusters from all cluster managers.
  func getAllClusters() -> [ClusterDto] {
    var allClusters: [ClusterDto] = []
    for controller in clusterManagers.values {
      allClusters.append(contentsOf: controller.getClusters())
    }
    return allClusters
  }
}
