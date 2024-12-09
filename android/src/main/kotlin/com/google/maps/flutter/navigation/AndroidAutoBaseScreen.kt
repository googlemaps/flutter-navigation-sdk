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
import com.google.android.libraries.navigation.NavigationViewForAuto

open class AndroidAutoBaseScreen(carContext: CarContext) :
  Screen(carContext), SurfaceCallback, NavigationReadyListener {
  private val VIRTUAL_DISPLAY_NAME = "AndroidAutoNavScreen"
  private var mVirtualDisplay: VirtualDisplay? = null
  private var mPresentation: Presentation? = null
  private var mNavigationView: NavigationViewForAuto? = null
  private var mAutoMapView: GoogleMapsAutoMapView? = null
  private var mViewRegistry: GoogleMapsViewRegistry? = null
  protected var mIsNavigationReady: Boolean = false
  var mGoogleMap: GoogleMap? = null

  init {
    initializeSurfaceCallback()
    initializeNavigationListener()
  }

  private fun initializeNavigationListener() {
    GoogleMapsNavigationSessionManager.navigationReadyListener = this
    try {
      mIsNavigationReady = GoogleMapsNavigationSessionManager.getInstance().isInitialized()
    } catch (exception: RuntimeException) {
      // If GoogleMapsNavigationSessionManager is not initialized navigation is not ready.
      mIsNavigationReady = false
    }
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

    mNavigationView = NavigationViewForAuto(carContext)
    val navigationView = mNavigationView ?: return
    navigationView.onCreate(null)
    navigationView.onStart()
    navigationView.onResume()

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
            googleMap,
          )
        sendAutoScreenAvailabilityChangedEvent(true)
        invalidate()
      }
    }
  }

  override fun onSurfaceDestroyed(surfaceContainer: SurfaceContainer) {
    super.onSurfaceDestroyed(surfaceContainer)
    sendAutoScreenAvailabilityChangedEvent(false)
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

  private fun sendAutoScreenAvailabilityChangedEvent(isAvailable: Boolean) {
    GoogleMapsNavigationPlugin.getInstance()?.autoViewEventApi?.onAutoScreenAvailabilityChanged(
      isAvailable
    ) {}
  }

  override fun onNavigationReady(ready: Boolean) {
    mIsNavigationReady = ready
  }
}
