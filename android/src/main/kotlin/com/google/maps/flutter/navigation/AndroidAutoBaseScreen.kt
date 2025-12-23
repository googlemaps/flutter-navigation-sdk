/*
 * Copyright 2024 Google LLC
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

import android.app.Presentation
import android.graphics.Point
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import androidx.car.app.AppManager
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.SurfaceCallback
import androidx.car.app.SurfaceContainer
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.libraries.navigation.NavigationView
import com.google.android.libraries.navigation.PromptVisibilityChangedListener

open class AndroidAutoBaseScreen(carContext: CarContext) :
  Screen(carContext), SurfaceCallback, NavigationReadyListener {

  companion object {
    /**
     * Map options to use for Android Auto views. Can be set before the Android Auto screen is
     * created to customize map appearance.
     */
    var mapOptions: AutoMapViewOptions? = null
  }

  /**
   * Provides the map options to use when creating the Android Auto map view.
   *
   * Override this method in your AndroidAutoBaseScreen subclass to provide custom map options from
   * the native layer. This is useful when you want to set map configuration (like mapId) directly
   * in native code instead of from Flutter, especially when the Android Auto screen may already be
   * open.
   *
   * The default implementation returns the value from the companion object, which can be set from
   * Flutter via GoogleMapsAutoViewController.setAutoMapOptions().
   *
   * @return AutoMapViewOptions containing map configuration, or null to use defaults
   *
   * Example:
   * ```kotlin
   * override fun getAutoMapOptions(): AutoMapViewOptions? {
   *   return AutoMapViewOptions(
   *     mapId = "your-map-id",
   *     mapType = GoogleMap.MAP_TYPE_SATELLITE,
   *     mapColorScheme = UIUserInterfaceStyle.DARK,
   *     forceNightMode = NavigationView.FORCE_NIGHT_MODE_AUTO
   *   )
   * }
   * ```
   */
  public open fun getAutoMapOptions(): AutoMapViewOptions? {
    return mapOptions
  }

  private val VIRTUAL_DISPLAY_NAME = "AndroidAutoNavScreen"
  private var mVirtualDisplay: VirtualDisplay? = null
  private var mPresentation: Presentation? = null
  private var mNavigationView: NavigationView? = null
  private var mAutoMapView: GoogleMapsAutoMapView? = null
  private var mViewRegistry: GoogleMapsViewRegistry? = null
  private var mPromptVisibilityListener: PromptVisibilityChangedListener? = null
  protected var mIsNavigationReady: Boolean = false
  var mGoogleMap: GoogleMap? = null
  private var mIsPromptVisible: Boolean = false

  init {
    initializeSurfaceCallback()
    initializeNavigationListener()
  }

  private fun initializeNavigationListener() {
    GoogleMapsNavigationSessionManager.navigationReadyListener = this
    mIsNavigationReady =
      GoogleMapsNavigatorHolder.getInitializationState() ==
        GoogleNavigatorInitializationState.INITIALIZED
  }

  private fun initializeSurfaceCallback() {
    carContext.getCarService(AppManager::class.java).setSurfaceCallback(this)
  }

  private val mLifeCycleObserver: LifecycleObserver =
    object : DefaultLifecycleObserver {
      override fun onDestroy(owner: LifecycleOwner) {
        GoogleMapsNavigationSessionManager.navigationReadyListener = null
        mIsNavigationReady = false
      }
    }

  private fun isSurfaceReady(surfaceContainer: SurfaceContainer): Boolean {
    return surfaceContainer.surface != null &&
      surfaceContainer.dpi != 0 &&
      surfaceContainer.height != 0 &&
      surfaceContainer.width != 0
  }

  override fun onSurfaceAvailable(surfaceContainer: SurfaceContainer) {
    super.onSurfaceAvailable(surfaceContainer)
    lifecycle.addObserver(mLifeCycleObserver)
    if (!isSurfaceReady(surfaceContainer)) {
      return
    }
    mVirtualDisplay =
      carContext
        .getSystemService(DisplayManager::class.java)
        .createVirtualDisplay(
          VIRTUAL_DISPLAY_NAME,
          surfaceContainer.width,
          surfaceContainer.height,
          surfaceContainer.dpi,
          surfaceContainer.surface,
          DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY,
        )
    val virtualDisplay = mVirtualDisplay ?: return

    mPresentation = Presentation(carContext, virtualDisplay.display)
    val presentation = mPresentation ?: return

    // Get map options from overridable method (can be customized in subclasses)
    val autoMapOptions = getAutoMapOptions()
    val googleMapOptions =
      GoogleMapOptions().apply {
        compassEnabled(false) // Always disable compass for Android Auto

        // Apply custom map ID if provided
        autoMapOptions?.mapId?.let { mapId -> mapId(mapId) }

        // Apply map type if provided
        autoMapOptions?.mapType?.let { type -> mapType(type) }

        // Apply map color scheme if provided
        autoMapOptions?.mapColorScheme?.let { colorScheme -> mapColorScheme(colorScheme) }
      }

    // Create NavigationView with the configured options
    mNavigationView = NavigationView(carContext, googleMapOptions)
    val navigationView = mNavigationView ?: return

    // Apply force night mode if provided (separate from color scheme)
    autoMapOptions?.forceNightMode?.let { forceNightMode ->
      navigationView.setForceNightMode(forceNightMode)
    }

    // Configure NavigationView for Android Auto
    navigationView.apply {
      onCreate(null)
      onStart()
      onResume()
      setHeaderEnabled(false)
      setRecenterButtonEnabled(false)
      setEtaCardEnabled(false)
      setSpeedometerEnabled(false)
      setTripProgressBarEnabled(false)
      setReportIncidentButtonEnabled(false)
    }

    presentation.setContentView(navigationView)
    presentation.show()

    navigationView.getMapAsync { googleMap: GoogleMap ->
      val viewRegistry = GoogleMapsNavigationPlugin.getInstance()?.viewRegistry
      val imageRegistry = GoogleMapsNavigationPlugin.getInstance()?.imageRegistry
      if (viewRegistry != null && imageRegistry != null) {
        mGoogleMap = googleMap
        mViewRegistry = viewRegistry

        mAutoMapView =
          GoogleMapsAutoMapView(
            MapOptions(GoogleMapOptions(), null),
            viewRegistry,
            imageRegistry,
            navigationView,
            navigationView,
            googleMap,
          )

        // Set up prompt visibility listener with direct access to NavigationView
        mPromptVisibilityListener = PromptVisibilityChangedListener { promptVisible ->
          mIsPromptVisible = promptVisible
          onPromptVisibilityChanged(promptVisible)
        }
        navigationView.addPromptVisibilityChangedListener(mPromptVisibilityListener)

        sendAutoScreenAvailabilityChangedEvent(true)
        invalidate()
      }
    }
  }

  override fun onSurfaceDestroyed(surfaceContainer: SurfaceContainer) {
    super.onSurfaceDestroyed(surfaceContainer)
    sendAutoScreenAvailabilityChangedEvent(false)

    // Clean up prompt visibility listener
    if (mPromptVisibilityListener != null && mNavigationView != null) {
      mNavigationView?.removePromptVisibilityChangedListener(mPromptVisibilityListener)
      mPromptVisibilityListener = null
    }
    mIsPromptVisible = false

    mViewRegistry?.unregisterAndroidAutoView()
    mNavigationView?.onPause()
    mNavigationView?.onStop()
    mNavigationView?.onDestroy()
    mGoogleMap = null

    mPresentation?.dismiss()
    mVirtualDisplay?.release()
  }

  override fun onScroll(distanceX: Float, distanceY: Float) {
    mGoogleMap?.moveCamera(CameraUpdateFactory.scrollBy(distanceX, distanceY))
  }

  override fun onScale(focusX: Float, focusY: Float, scaleFactor: Float) {
    val update =
      CameraUpdateFactory.zoomBy((scaleFactor - 1), Point(focusX.toInt(), focusY.toInt()))
    mGoogleMap?.animateCamera(update) // map is set in onSurfaceAvailable.
  }

  override fun onGetTemplate(): Template {
    return NavigationTemplate.Builder()
      .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())
      .build()
  }

  fun sendCustomNavigationAutoEvent(event: String, data: Any) {
    GoogleMapsNavigationPlugin.getInstance()?.autoViewEventApi?.onCustomNavigationAutoEvent(
      event,
      data,
    ) {}
  }

  // Called when Flutter sends a custom event to native via sendCustomNavigationAutoEvent
  // Override this method in your AndroidAutoBaseScreen subclass to handle custom events from
  // Flutter
  open fun onCustomNavigationAutoEventFromFlutter(event: String, data: Any) {
    // Default implementation does nothing
    // Subclasses can override to handle custom events
  }

  private fun sendAutoScreenAvailabilityChangedEvent(isAvailable: Boolean) {
    GoogleMapsNavigationPlugin.getInstance()?.autoViewEventApi?.onAutoScreenAvailabilityChanged(
      isAvailable
    ) {}
  }

  override fun onNavigationReady(ready: Boolean) {
    mIsNavigationReady = ready
  }

  /**
   * Checks if a traffic prompt is currently visible on the Android Auto screen.
   *
   * This can be useful to dynamically adjust your UI based on prompt visibility, such as when
   * building templates or deciding whether to show custom elements.
   *
   * @return true if a prompt is currently visible, false otherwise
   *
   * Example:
   * ```kotlin
   * override fun onGetTemplate(): Template {
   *   val builder = NavigationTemplate.Builder()
   *
   *   // Only show custom actions if prompt is not visible
   *   if (!isPromptVisible()) {
   *     builder.setActionStrip(myCustomActionStrip)
   *   }
   *
   *   return builder.build()
   * }
   * ```
   */
  fun isPromptVisible(): Boolean {
    return mIsPromptVisible
  }

  /**
   * Called when traffic prompt visibility changes on the Android Auto screen.
   *
   * Override this method to add custom behavior when prompts appear or disappear, such as
   * hiding/showing your custom UI elements to avoid overlapping with system prompts.
   *
   * @param promptVisible true if the prompt is now visible, false if it's hidden
   *
   * Example:
   * ```kotlin
   * override fun onPromptVisibilityChanged(promptVisible: Boolean) {
   *   super.onPromptVisibilityChanged(promptVisible)
   *   if (promptVisible) {
   *     // Hide your custom buttons or UI elements
   *   } else {
   *     // Show your custom buttons or UI elements
   *   }
   * }
   * ```
   */
  open fun onPromptVisibilityChanged(promptVisible: Boolean) {
    // Send event to Flutter by default
    GoogleMapsNavigationPlugin.getInstance()?.autoViewEventApi?.onPromptVisibilityChanged(
      promptVisible
    ) {}
  }
}
