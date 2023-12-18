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
class GoogleMapsNavigationViewRegistry :
  DefaultLifecycleObserver, ComponentCallbacks, ComponentCallbacks2 {
  private val views: SparseArray<GoogleMapsNavigationView> = SparseArray()

  fun registerView(viewId: Int, view: GoogleMapsNavigationView) {
    views.put(viewId, view)
  }

  fun unregisterView(viewId: Int) {
    views.remove(viewId)
  }

  fun getView(viewId: Int): GoogleMapsNavigationView? {
    return views.get(viewId)
  }

  override fun onStart(owner: LifecycleOwner) {
    views.forEach { _, view -> view.onStart() }
  }

  override fun onResume(owner: LifecycleOwner) {
    views.forEach { _, view -> view.onResume() }
  }

  override fun onPause(owner: LifecycleOwner) {
    views.forEach { _, view -> view.onPause() }
  }

  override fun onStop(owner: LifecycleOwner) {
    views.forEach { _, view -> view.onStop() }
  }

  override fun onConfigurationChanged(configuration: Configuration) {
    views.forEach { _, view -> view.onConfigurationChanged(configuration) }
  }

  override fun onLowMemory() {
    // Ignored as NavigationView only supports onTrimMemory
  }

  override fun onTrimMemory(level: Int) {
    views.forEach { _, view -> view.onTrimMemory(level) }
  }
}
