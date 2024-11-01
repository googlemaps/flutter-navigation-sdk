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

import android.content.ComponentCallbacks
import android.content.ComponentCallbacks2
import android.content.res.Configuration
import android.util.SparseArray
import androidx.core.util.forEach
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

/** GoogleMapsNavigationViewRegistry */
class GoogleMapsViewRegistry : DefaultLifecycleObserver, ComponentCallbacks, ComponentCallbacks2 {
  // Separate lists for navigation views, to be able to access them separately for navigation only
  // operations.
  private val navigationViews: SparseArray<GoogleMapsNavigationView> = SparseArray()

  // This list contains all map views, including navigation views.
  private val allMapViews: SparseArray<GoogleMapsBaseMapView> = SparseArray()

  private var androidAutoView: GoogleMapsAutoMapView? = null

  fun registerNavigationView(viewId: Int, view: GoogleMapsNavigationView) {
    // Navigation views are added both lists.
    navigationViews.put(viewId, view)
    allMapViews.put(viewId, view)
  }

  fun registerMapView(viewId: Int, view: GoogleMapsBaseMapView) {
    allMapViews.put(viewId, view)
  }

  fun registerAndroidAutoView(view: GoogleMapsAutoMapView) {
    androidAutoView = view
  }

  fun unregisterNavigationView(viewId: Int) {
    // Navigation views need to be removed from both lists.
    navigationViews.remove(viewId)
    allMapViews.remove(viewId)
  }

  fun unregisterMapView(viewId: Int) {
    allMapViews.remove(viewId)
  }

  fun unregisterAndroidAutoView() {
    androidAutoView = null
  }

  fun getNavigationView(viewId: Int): GoogleMapsNavigationView? {
    return navigationViews.get(viewId)
  }

  fun getMapView(viewId: Int): GoogleMapsBaseMapView? {
    return allMapViews.get(viewId)
  }

  fun getAndroidAutoView(): GoogleMapsAutoMapView? {
    return androidAutoView
  }

  override fun onStart(owner: LifecycleOwner) {
    allMapViews.forEach { _, view -> view.onStart() }
    androidAutoView?.onStart()
  }

  override fun onResume(owner: LifecycleOwner) {
    allMapViews.forEach { _, view -> view.onResume() }
    androidAutoView?.onResume()
  }

  override fun onPause(owner: LifecycleOwner) {
    allMapViews.forEach { _, view -> view.onPause() }
    androidAutoView?.onPause()
  }

  override fun onStop(owner: LifecycleOwner) {
    allMapViews.forEach { _, view -> view.onStop() }
    androidAutoView?.onStop()
  }

  override fun onConfigurationChanged(configuration: Configuration) {
    navigationViews.forEach { _, view -> view.onConfigurationChanged(configuration) }
  }

  override fun onLowMemory() {
    // Ignored as NavigationView only supports onTrimMemory
  }

  override fun onTrimMemory(level: Int) {
    navigationViews.forEach { _, view -> view.onTrimMemory(level) }
  }
}
