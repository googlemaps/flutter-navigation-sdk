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

import android.content.Context
import android.content.res.Configuration
import android.view.View
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.libraries.navigation.NavigationView
import com.google.android.libraries.navigation.OnNavigationUiChangedListener
import com.google.android.libraries.navigation.PromptVisibilityChangedListener
import io.flutter.plugin.platform.PlatformView

class GoogleMapsNavigationView
internal constructor(
  context: Context,
  mapOptions: MapOptions,
  navigationOptions: NavigationViewOptions?,
  viewId: Int,
  private val viewRegistry: GoogleMapsViewRegistry,
  viewEventApi: ViewEventApi,
  private val imageRegistry: ImageRegistry,
) : PlatformView, GoogleMapsBaseNavigationView(viewId, mapOptions, viewEventApi, imageRegistry) {
  override val navigationView: NavigationView = NavigationView(context, mapOptions.googleMapOptions)

  private var _onRecenterButtonClickedListener: NavigationView.OnRecenterButtonClickedListener? =
    null
  private var _onNavigationUIEnabledChanged: OnNavigationUiChangedListener? = null

  private var _onPromptVisibilityChanged: PromptVisibilityChangedListener? = null

  override fun getView(): View {
    return navigationView
  }

  init {
    // Call all of these three lifecycle functions in sequence to fully
    // initialize the navigation view.
    navigationView.onCreate(context.applicationInfo.metaData)
    onStart()
    onResume()

    // Initialize navigation view with given navigation view options
    var navigationViewEnabled = false
    if (
      navigationOptions?.navigationUiEnabledPreference == NavigationUIEnabledPreference.AUTOMATIC &&
        GoogleMapsNavigatorHolder.getInitializationState() ==
          GoogleNavigatorInitializationState.INITIALIZED
    ) {
      navigationViewEnabled = true
    }
    navigationView.isNavigationUiEnabled = navigationViewEnabled

    // Initialize force night mode if provided
    navigationOptions?.forceNightMode?.let { forceNightMode -> setForceNightMode(forceNightMode) }

    viewRegistry.registerNavigationView(viewId, this)

    navigationView.getMapAsync { map ->
      setMap(map)

      initListeners()
      imageRegistry.mapViewInitializationComplete()

      // Re set navigation view enabled state as sometimes earlier value is not
      // respected.
      navigationView.isNavigationUiEnabled = navigationViewEnabled
      if (!navigationViewEnabled) {
        map.moveCamera(CameraUpdateFactory.newCameraPosition(mapOptions.googleMapOptions.camera))
      }

      // Call and clear view ready callback if available.
      mapReady()
      mapOptions.padding?.let { setPadding(it) }
    }
  }

  override fun dispose() {
    if (super.isDestroyed()) {
      return
    }

    viewRegistry.unregisterNavigationView(getViewId())

    // Remove navigation view specific listeners
    if (_onRecenterButtonClickedListener != null) {
      navigationView.removeOnRecenterButtonClickedListener(_onRecenterButtonClickedListener)
      _onRecenterButtonClickedListener = null
    }
    if (_onNavigationUIEnabledChanged != null) {
      navigationView.removeOnNavigationUiChangedListener(_onNavigationUIEnabledChanged)
      _onNavigationUIEnabledChanged = null
    }
    if (_onPromptVisibilityChanged != null) {
      navigationView.removePromptVisibilityChangedListener(_onPromptVisibilityChanged)
      _onPromptVisibilityChanged = null
    }

    // When view is disposed, all of these lifecycle functions must be
    // called to properly dispose navigation view and prevent leaks.
    onPause()
    onStop()
    super.onDispose()
    navigationView.onDestroy()
  }

  override fun onStart(): Boolean {
    if (super.onStart()) {
      navigationView.onStart()
      return true
    }
    return false
  }

  override fun onResume(): Boolean {
    if (super.onResume()) {
      navigationView.onResume()
      return true
    }
    return false
  }

  override fun onStop(): Boolean {
    if (super.onStop()) {
      navigationView.onStop()
      return true
    }
    return false
  }

  override fun onPause(): Boolean {
    if (super.onPause()) {
      navigationView.onPause()
      return true
    }
    return false
  }

  fun onConfigurationChanged(configuration: Configuration) {
    navigationView.onConfigurationChanged(configuration)
  }

  fun onTrimMemory(level: Int) {
    navigationView.onTrimMemory(level)
  }

  override fun initListeners() {
    _onRecenterButtonClickedListener =
      NavigationView.OnRecenterButtonClickedListener {
        viewEventApi?.onRecenterButtonClicked(getViewId().toLong()) {}
      }
    navigationView.addOnRecenterButtonClickedListener(_onRecenterButtonClickedListener)

    _onNavigationUIEnabledChanged = OnNavigationUiChangedListener {
      viewEventApi?.onNavigationUIEnabledChanged(getViewId().toLong(), it) {}
    }
    navigationView.addOnNavigationUiChangedListener(_onNavigationUIEnabledChanged)

    _onPromptVisibilityChanged = PromptVisibilityChangedListener { promptVisible ->
      viewEventApi?.onPromptVisibilityChanged(getViewId().toLong(), promptVisible) {}
    }
    navigationView.addPromptVisibilityChangedListener(_onPromptVisibilityChanged)

    super.initListeners()
  }
}
