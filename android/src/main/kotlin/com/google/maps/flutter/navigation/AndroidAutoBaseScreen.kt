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
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.navigation.NavigationViewForAuto

open class AndroidAutoBaseScreen(carContext: CarContext): Screen(carContext), SurfaceCallback {
    private val VIRTUAL_DISPLAY_NAME = "AndroidAutoNavScreen"
    private var mVirtualDisplay: VirtualDisplay? = null
    private var mPresentation: Presentation? = null
    private var mNavigationView: NavigationViewForAuto? = null
    var mGoogleMap: GoogleMap? = null

    init {
        initializeSurfaceCallback()
    }

    private fun initializeSurfaceCallback() {
        carContext.getCarService(AppManager::class.java).setSurfaceCallback(this)
    }

    private fun isSurfaceReady(surfaceContainer: SurfaceContainer): Boolean {
        return surfaceContainer.surface != null && surfaceContainer.dpi != 0 && surfaceContainer.height != 0 && surfaceContainer.width != 0
    }

    override fun onSurfaceAvailable(surfaceContainer: SurfaceContainer) {
        super.onSurfaceAvailable(surfaceContainer)
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
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY
                )
        mPresentation = Presentation(carContext, mVirtualDisplay!!.display)

        mNavigationView = NavigationViewForAuto(carContext)
        mNavigationView!!.onCreate(null)
        mNavigationView!!.onStart()
        mNavigationView!!.onResume()

        mPresentation!!.setContentView(mNavigationView!!)
        mPresentation!!.show()

        mNavigationView!!.getMapAsync { googleMap: GoogleMap ->
            mGoogleMap = googleMap
            //mMapViewController = MapViewController()
            //mMapViewController.initialize(googleMap) { null }
            //registerControllersForAndroidAutoModule()
            invalidate()
        }
    }

    override fun onSurfaceDestroyed(surfaceContainer: SurfaceContainer) {
        super.onSurfaceDestroyed(surfaceContainer)
        //unRegisterControllersForAndroidAutoModule()
        mNavigationView!!.onPause()
        mNavigationView!!.onStop()
        mNavigationView!!.onDestroy()
        mGoogleMap = null

        mPresentation!!.dismiss()
        mVirtualDisplay!!.release()
    }

    override fun onScroll(distanceX: Float, distanceY: Float) {
        if (mGoogleMap == null) {
            return
        }
        mGoogleMap!!.moveCamera(CameraUpdateFactory.scrollBy(distanceX, distanceY))
    }

    override fun onScale(focusX: Float, focusY: Float, scaleFactor: Float) {
        if (mGoogleMap == null) {
            return
        }
        val update =
            CameraUpdateFactory.zoomBy((scaleFactor - 1), Point(focusX.toInt(), focusY.toInt()))
        mGoogleMap!!.animateCamera(update) // map is set in onSurfaceAvailable.
    }

    override fun onGetTemplate(): Template {
        return NavigationTemplate.Builder()
            .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())
            .build()
    }
}

