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
import com.google.maps.android.clustering.Cluster
import com.google.maps.android.clustering.ClusterManager
import com.google.maps.android.clustering.view.DefaultClusterRenderer
import com.google.maps.android.collections.MarkerManager

/** Controller for managing a single ClusterManager instance. */
class ClusterManagerController(
  val clusterManagerId: String,
  private val context: Context,
  private val googleMap: GoogleMap,
  private val markerManager: MarkerManager,
  private val viewEventApi: ViewEventApi,
  private val viewId: Int,
) {
  private val clusterManager: ClusterManager<MarkerClusterItem>
  private val clusterRenderer: ClusterRenderer
  private val markerToClusterItem = mutableMapOf<Marker, MarkerClusterItem>()

  init {
    clusterManager = ClusterManager(context, googleMap, markerManager)
    clusterRenderer = ClusterRenderer(context, googleMap, clusterManager)
    clusterManager.renderer = clusterRenderer

    // Set up click listeners
    clusterManager.setOnClusterClickListener { cluster ->
      onClusterClick(cluster)
      // Return false to allow the default behavior of the cluster click event to occur.
      false
    }

    clusterManager.setOnClusterItemClickListener { item ->
      onClusterItemClick(item)
      item.consumeTapEvents
    }
  }

  /** Adds a marker item to the cluster. */
  fun addItem(item: MarkerClusterItem) {
    clusterManager.addItem(item)
  }

  /** Removes a marker item from the cluster. */
  fun removeItem(item: MarkerClusterItem) {
    clusterManager.removeItem(item)
  }

  /** Clears all items from the cluster. */
  fun clearItems() {
    clusterManager.clearItems()
    markerToClusterItem.clear()
  }

  /** Triggers clustering calculation. */
  fun cluster() {
    clusterManager.cluster()
  }

  /** Called when camera stops moving to refresh clusters. */
  fun onCameraIdle() {
    clusterManager.onCameraIdle()
    // Force reclustering after camera idle to ensure clusters update on zoom
    clusterManager.cluster()
  }

  /** Returns the underlying ClusterManager instance. */
  fun getClusterManager(): ClusterManager<MarkerClusterItem> {
    return clusterManager
  }

  /** Gets all items in this cluster manager. */
  fun getItems(): Collection<MarkerClusterItem> {
    return clusterManager.algorithm.items
  }

  /** Gets all current clusters. */
  fun getClusters(): List<ClusterDto> {
    val clusters = mutableListOf<ClusterDto>()

    // Get all clusters from the cluster manager algorithm
    clusterManager.algorithm.getClusters(googleMap.cameraPosition.zoom).forEach { cluster ->
      val markerIds = cluster.items.map { (it as MarkerClusterItem).markerId }
      val position =
        LatLngDto(latitude = cluster.position.latitude, longitude = cluster.position.longitude)

      clusters.add(
        ClusterDto(clusterManagerId = clusterManagerId, position = position, markerIds = markerIds)
      )
    }

    return clusters
  }

  private fun onClusterClick(cluster: Cluster<MarkerClusterItem>) {
    if (cluster.size > 0) {
      val markerIds = cluster.items.map { it.markerId }
      val position =
        LatLngDto(latitude = cluster.position.latitude, longitude = cluster.position.longitude)

      val clusterDto =
        ClusterDto(clusterManagerId = clusterManagerId, position = position, markerIds = markerIds)

      viewEventApi.onClusterEvent(
        viewId.toLong(),
        clusterManagerId,
        ClusterEventTypeDto.CLICKED,
        clusterDto,
      ) {}
    }
  }

  private fun onClusterItemClick(item: MarkerClusterItem) {
    viewEventApi.onMarkerEvent(viewId.toLong(), item.markerId, MarkerEventTypeDto.CLICKED) {}
  }

  /**
   * Custom renderer for cluster items. Handles marker rendering and stores marker-to-item mapping.
   */
  inner class ClusterRenderer(
    context: Context,
    map: GoogleMap,
    clusterManager: ClusterManager<MarkerClusterItem>,
  ) : DefaultClusterRenderer<MarkerClusterItem>(context, map, clusterManager) {

    override fun onBeforeClusterItemRendered(
      item: MarkerClusterItem,
      markerOptions: com.google.android.gms.maps.model.MarkerOptions,
    ) {
      // Apply marker options from the cluster item
      val itemOptions = item.getMarkerDto().options
      markerOptions.apply {
        position(Convert.convertLatLngFromDto(itemOptions.position))
        title(itemOptions.infoWindow.title)
        snippet(itemOptions.infoWindow.snippet)
        alpha(itemOptions.alpha.toFloat())
        draggable(itemOptions.draggable)
        flat(itemOptions.flat)
        rotation(itemOptions.rotation.toFloat())
        visible(itemOptions.visible)
        zIndex(itemOptions.zIndex.toFloat())
        anchor(itemOptions.anchor.u.toFloat(), itemOptions.anchor.v.toFloat())
        infoWindowAnchor(
          itemOptions.infoWindow.anchor.u.toFloat(),
          itemOptions.infoWindow.anchor.v.toFloat(),
        )

        // Set custom icon if available
        item.registeredImage?.let { icon(it.bitmapDescriptor) }
      }
    }

    override fun onClusterItemRendered(item: MarkerClusterItem, marker: Marker) {
      // Store the mapping between marker and cluster item
      markerToClusterItem[marker] = item
    }
  }

  /** Finds the cluster item associated with a marker. */
  fun findClusterItem(marker: Marker): MarkerClusterItem? {
    return markerToClusterItem[marker]
  }
}
