/*
 * Copyright 2026 Google LLC
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

import android.content.Context
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.model.Marker

/** Controller for managing multiple ClusterManager instances. */
class ClusterManagersController(
  private val context: Context,
  private val viewEventApi: ViewEventApi,
  private val viewId: Int,
) {
  private var googleMap: GoogleMap? = null
  private val clusterManagers = mutableMapOf<String, ClusterManagerController>()
  private val clusterItemsByManager = mutableMapOf<String, MutableMap<String, MarkerClusterItem>>()

  /** Initializes the controller with a GoogleMap instance. */
  fun init(googleMap: GoogleMap) {
    this.googleMap = googleMap
  }

  /** Adds a new cluster manager. */
  fun addClusterManager(clusterManagerId: String): ClusterManagerController? {
    val map = googleMap ?: return null

    if (clusterManagers.containsKey(clusterManagerId)) {
      return clusterManagers[clusterManagerId]
    }

    val controller = ClusterManagerController(clusterManagerId, context, map, viewEventApi, viewId)

    clusterManagers[clusterManagerId] = controller
    clusterItemsByManager[clusterManagerId] = mutableMapOf()

    return controller
  }

  /** Removes a cluster manager. */
  fun removeClusterManager(clusterManagerId: String) {
    clusterManagers[clusterManagerId]?.let { controller ->
      controller.clearItems()
      controller.cluster() // Force refresh to remove clusters from display
    }
    clusterManagers.remove(clusterManagerId)
    clusterItemsByManager.remove(clusterManagerId)
  }

  /** Clears all cluster managers. */
  fun clearClusterManagers() {
    clusterManagers.values.forEach { it.clearItems() }
    clusterManagers.clear()
    clusterItemsByManager.clear()
  }

  /** Gets a cluster manager by ID. */
  fun getClusterManager(clusterManagerId: String): ClusterManagerController? {
    return clusterManagers[clusterManagerId]
  }

  /** Gets all cluster manager IDs. */
  fun getClusterManagerIds(): List<String> {
    return clusterManagers.keys.toList()
  }

  /** Adds a marker to its cluster manager. */
  fun addMarkerToCluster(
    markerDto: MarkerDto,
    registeredImage: RegisteredImage?,
    consumeTapEvents: Boolean,
  ) {
    val clusterManagerId = markerDto.options.clusterManagerId ?: return
    val controller = clusterManagers[clusterManagerId] ?: return

    val item =
      MarkerClusterItem(
        markerId = markerDto.markerId,
        clusterManagerId = clusterManagerId,
        markerOptions = markerDto,
        registeredImage = registeredImage,
        consumeTapEvents = consumeTapEvents,
      )

    controller.addItem(item)
    clusterItemsByManager[clusterManagerId]?.put(markerDto.markerId, item)
    controller.cluster()
  }

  /** Removes a marker from its cluster manager. */
  fun removeMarkerFromCluster(markerId: String, clusterManagerId: String) {
    val controller = clusterManagers[clusterManagerId] ?: return
    val item = clusterItemsByManager[clusterManagerId]?.remove(markerId) ?: return

    controller.removeItem(item)
    controller.cluster()
  }

  /** Updates a marker in its cluster manager. */
  fun updateMarkerInCluster(
    markerDto: MarkerDto,
    registeredImage: RegisteredImage?,
    consumeTapEvents: Boolean,
  ) {
    val clusterManagerId = markerDto.options.clusterManagerId ?: return

    // Remove old item and add updated one
    removeMarkerFromCluster(markerDto.markerId, clusterManagerId)
    addMarkerToCluster(markerDto, registeredImage, consumeTapEvents)
  }

  /** Called when camera stops moving to refresh all clusters. */
  fun onCameraIdle() {
    clusterManagers.values.forEach { it.onCameraIdle() }
  }

  /** Finds which cluster manager owns a marker. */
  fun findClusterItem(marker: Marker): MarkerClusterItem? {
    for (controller in clusterManagers.values) {
      val item = controller.findClusterItem(marker)
      if (item != null) {
        return item
      }
    }
    return null
  }

  /** Gets clusters for a specific cluster manager. */
  fun getClusters(clusterManagerId: String): List<ClusterDto> {
    return clusterManagers[clusterManagerId]?.getClusters() ?: emptyList()
  }

  /** Gets all clusters from all cluster managers. */
  fun getAllClusters(): List<ClusterDto> {
    val allClusters = mutableListOf<ClusterDto>()
    clusterManagers.values.forEach { controller -> allClusters.addAll(controller.getClusters()) }
    return allClusters
  }
}
