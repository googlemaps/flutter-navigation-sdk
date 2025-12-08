/*
 * Copyright 2025 Google LLC
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

import android.app.Application
import android.util.DisplayMetrics
import androidx.lifecycle.Observer
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.android.libraries.navigation.NavigationApi
import com.google.android.libraries.navigation.NavigationUpdatesOptions
import com.google.android.libraries.navigation.NavigationUpdatesOptions.GeneratedStepImagesType
import com.google.android.libraries.navigation.Navigator

/**
 * Singleton holder for the shared Navigator instance. Multiple GoogleMapsNavigationSessionManager
 * instances share the same Navigator.
 */
enum class GoogleNavigatorInitializationState {
  NOT_INITIALIZED,
  INITIALIZING,
  INITIALIZED,
}

object GoogleMapsNavigatorHolder {
  @Volatile private var navigator: Navigator? = null
  private var initializationState = GoogleNavigatorInitializationState.NOT_INITIALIZED
  private val initializationCallbacks = mutableListOf<NavigationApi.NavigatorListener>()

  // Turn-by-turn navigation service management
  private var turnByTurnServiceRegistered = false
  private val navInfoObservers = mutableListOf<Observer<NavInfo>>()

  @Synchronized fun getNavigator(): Navigator? = navigator

  @Synchronized
  fun setNavigator(nav: Navigator?) {
    navigator = nav
    initializationState =
      if (nav != null) {
        GoogleNavigatorInitializationState.INITIALIZED
      } else {
        GoogleNavigatorInitializationState.NOT_INITIALIZED
      }
  }

  @Synchronized
  fun getInitializationState(): GoogleNavigatorInitializationState = initializationState

  @Synchronized
  fun setInitializationState(state: GoogleNavigatorInitializationState) {
    initializationState = state
  }

  @Synchronized
  fun addInitializationCallback(callback: NavigationApi.NavigatorListener) {
    initializationCallbacks.add(callback)
  }

  @Synchronized
  fun getAndClearInitializationCallbacks(): List<NavigationApi.NavigatorListener> {
    val callbacks = initializationCallbacks.toList()
    initializationCallbacks.clear()
    return callbacks
  }

  @Synchronized
  fun registerTurnByTurnService(
    application: Application,
    numNextStepsToPreview: Int,
    type: @NavigationUpdatesOptions.GeneratedStepImagesType Int,
  ): Boolean {
    val nav = navigator ?: return false

    if (!turnByTurnServiceRegistered) {
      // DisplayMetrics is required to be set for turn-by-turn updates.
      // But not used as image generation is disabled.
      val displayMetrics = DisplayMetrics()
      displayMetrics.density = 2.0f

      val options =
        NavigationUpdatesOptions.builder()
          .setNumNextStepsToPreview(numNextStepsToPreview)
          .setGeneratedStepImagesType(type)
          .setDisplayMetrics(displayMetrics)
          .build()

      val success =
        nav.registerServiceForNavUpdates(
          application.packageName,
          GoogleMapsNavigationNavUpdatesService::class.java.name,
          options,
        )

      if (success) {
        turnByTurnServiceRegistered = true
      }
      return success
    }
    return true // Already registered
  }

  @Synchronized
  fun addNavInfoObserver(observer: Observer<NavInfo>) {
    if (!navInfoObservers.contains(observer)) {
      navInfoObservers.add(observer)
      GoogleMapsNavigationNavUpdatesService.navInfoLiveData.observeForever(observer)
    }
  }

  @Synchronized
  fun removeNavInfoObserver(observer: Observer<NavInfo>) {
    if (navInfoObservers.remove(observer)) {
      GoogleMapsNavigationNavUpdatesService.navInfoLiveData.removeObserver(observer)
    }
  }

  @Synchronized
  fun unregisterTurnByTurnService(): Boolean {
    val nav = navigator ?: return false

    if (turnByTurnServiceRegistered && navInfoObservers.isEmpty()) {
      val success = nav.unregisterServiceForNavUpdates()
      if (success) {
        turnByTurnServiceRegistered = false
      }
      return success
    }
    return true
  }

  @Synchronized
  fun reset() {
    // Clean up turn-by-turn service
    if (turnByTurnServiceRegistered) {
      for (observer in navInfoObservers.toList()) {
        GoogleMapsNavigationNavUpdatesService.navInfoLiveData.removeObserver(observer)
      }
      navInfoObservers.clear()
      navigator?.unregisterServiceForNavUpdates()
      turnByTurnServiceRegistered = false
    }

    navigator = null
    initializationState = GoogleNavigatorInitializationState.NOT_INITIALIZED
    initializationCallbacks.clear()
  }
}
