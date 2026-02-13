package com.google.maps.flutter.navigation_example

import android.annotation.SuppressLint
import android.app.Application
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.SurfaceContainer
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarIcon
import androidx.car.app.model.Distance
import androidx.car.app.model.Pane
import androidx.car.app.model.PaneTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import androidx.car.app.model.DateTimeWithZone
import androidx.car.app.navigation.model.Maneuver
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.car.app.navigation.model.RoutingInfo
import androidx.car.app.navigation.model.Step
import androidx.car.app.navigation.model.TravelEstimate
import androidx.core.graphics.drawable.IconCompat
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.android.libraries.mapsplatform.turnbyturn.model.StepInfo
import com.google.android.libraries.navigation.Navigator
import com.google.android.libraries.navigation.NavigationApi
import com.google.maps.flutter.navigation.AndroidAutoBaseScreen
import com.google.maps.flutter.navigation.GoogleMapsNavigationNavUpdatesService
import java.util.TimeZone

class SampleAndroidAutoScreen(carContext: CarContext) : AndroidAutoBaseScreen(carContext) {

    companion object {
        private const val TAG = "SampleAndroidAutoScreen"
        // Percentage of width for navigation panel (approximately 40%)
        private const val NAVIGATION_PANEL_WIDTH_RATIO = 0.40f
        
        // Maximum value for top padding (based on car_app_bar_height from framework)
        private const val TOP_PADDING_NO_GUIDANCE_MAX = 80
    }
    
    /**
     * Formats distance with smart rounding similar to iOS CarPlay:
     * - >= 1km: show in km with 1 decimal precision
     * - >= 100m: round to nearest 50m
     * - < 100m: round to nearest 10m
     */
    private fun formatDistance(distanceMeters: Double): Distance {
        return when {
            distanceMeters >= 1000 -> {
                // >= 1km: convert to km with 1 decimal precision
                val km = distanceMeters / 1000.0
                val roundedKm = Math.round(km * 10.0) / 10.0
                Distance.create(roundedKm, Distance.UNIT_KILOMETERS)
            }
            distanceMeters >= 100 -> {
                // >= 100m: round to nearest 50m
                val roundedMeters = Math.round(distanceMeters / 50.0) * 50.0
                Distance.create(roundedMeters, Distance.UNIT_METERS)
            }
            else -> {
                // < 100m: round to nearest 10m
                val roundedMeters = Math.round(distanceMeters / 10.0) * 10.0
                Distance.create(roundedMeters, Distance.UNIT_METERS)
            }
        }
    }

    private var mTravelEstimate: TravelEstimate? = null
    private var mNavInfo: RoutingInfo? = null
    private var mNavigator: Navigator? = null
    private var mIsGuidanceRunning: Boolean = false
    private var mRouteChangedListener: Navigator.RouteChangedListener? = null
    
    // Dimensions calculated from screen
    private var mScreenWidth: Int = 0
    private var mScreenHeight: Int = 0
    private var mNavigationPanelWidth: Int = 0
    private var mTopPaddingNoGuidance: Int = 0

    init {
        GoogleMapsNavigationNavUpdatesService.navInfoLiveData.observe(this) { navInfo: NavInfo? ->
            try {
                this.buildNavInfo(navInfo)
            } catch (e: Exception) {
                Log.e(TAG, "🔷 [AndroidAuto] Error in buildNavInfo: ${e.message}")
                mNavInfo = null
                mTravelEstimate = null
                invalidate()
            }
        }
    }

    private fun buildNavInfo(navInfo: NavInfo?) {
        Log.d(TAG, "🔷 [AndroidAuto] buildNavInfo() called")
        
        checkAndUpdateGuidanceState()
        
        if (navInfo == null) {
            Log.d(TAG, "🔷 [AndroidAuto] buildNavInfo() - navInfo null, clearing overlays")
            mNavInfo = null
            mTravelEstimate = null
            invalidate()
            return
        }
        
        val currentStepInfo = navInfo.currentStep
        if (currentStepInfo == null) {
            Log.d(TAG, "🔷 [AndroidAuto] buildNavInfo() - currentStep null, clearing overlays")
            mNavInfo = null
            mTravelEstimate = null
            invalidate()
            return
        }

        try {
            val currentStep: Step = buildStepFromStepInfo(currentStepInfo)
            val distanceToStepMeters = java.lang.Double.max(
                navInfo.distanceToCurrentStepMeters?.toDouble() ?: 0.0,
                0.0
            )
            val distanceToStep = formatDistance(distanceToStepMeters)

            mNavInfo = RoutingInfo.Builder().setCurrentStep(currentStep, distanceToStep).build()
        } catch (e: Exception) {
            Log.e(TAG, "🔷 [AndroidAuto] buildNavInfo() - error building step: ${e.message}") 
            mNavInfo = null
        }

         try {
            val timeToDestinationSeconds = navInfo.timeToNextDestinationSeconds
            val distanceToDestinationMeters = navInfo.distanceToNextDestinationMeters

            if (timeToDestinationSeconds == null || distanceToDestinationMeters == null || 
                (timeToDestinationSeconds <= 0 && distanceToDestinationMeters <= 0)) {
                mTravelEstimate = null
            } else {
                val arrivalTimeMillis = System.currentTimeMillis() + (timeToDestinationSeconds * 1000)
                val arrivalTime = DateTimeWithZone.create(arrivalTimeMillis, TimeZone.getDefault())
                val remainingDistance = formatDistance(distanceToDestinationMeters.toDouble())

                mTravelEstimate = TravelEstimate.Builder(remainingDistance, arrivalTime)
                    .setRemainingTimeSeconds(timeToDestinationSeconds.toLong())
                    .build()
            }
         } catch (e: Exception) {
            Log.e(TAG, "🔷 [AndroidAuto] buildNavInfo() - error building travel estimate: ${e.message}")
            mTravelEstimate = null
        }

        invalidate()
    }

    private fun buildStepFromStepInfo(stepInfo: StepInfo): Step {
        try {
        val maneuver: Int = ManeuverConverter.getAndroidAutoManeuverType(stepInfo.maneuver)
        val maneuverBuilder = Maneuver.Builder(maneuver)
        if (stepInfo.maneuverBitmap != null) {
            val maneuverIcon = IconCompat.createWithBitmap(stepInfo.maneuverBitmap!!)
            val maneuverCarIcon = CarIcon.Builder(maneuverIcon).build()
            maneuverBuilder.setIcon(maneuverCarIcon)
        }
        val stepBuilder =
            Step.Builder()
                .setRoad(stepInfo.fullRoadName ?: "")
                .setCue(stepInfo.fullInstructionText ?: "")
                .setManeuver(maneuverBuilder.build())
        
        // Add lane guidance if available (requires both lanes data AND lanes image)
        if (stepInfo.lanes != null && stepInfo.lanes!!.isNotEmpty() && stepInfo.lanesBitmap != null) {
            val androidAutoLanes = LaneConverter.convertToAndroidAutoLanes(stepInfo.lanes)
            if (androidAutoLanes != null && androidAutoLanes.isNotEmpty()) {
                // Add lanes
                for (lane in androidAutoLanes) {
                    stepBuilder.addLane(lane)
                }
                
                // Add lanes image (REQUIRED by Android Auto when lanes are present)
                val lanesIcon = IconCompat.createWithBitmap(stepInfo.lanesBitmap!!)
                val lanesCarIcon = CarIcon.Builder(lanesIcon).build()
                stepBuilder.setLanesImage(lanesCarIcon)
                
                Log.d(TAG, "🔷 [AndroidAuto] Added ${androidAutoLanes.size} lanes with image to step")
            }
        }
        
        return stepBuilder.build()
        } catch (e: Exception) {
            Log.e(TAG, "🔷 [AndroidAuto] buildStepFromStepInfo() - error: ${e.message}")
            val defaultManeuver = Maneuver.Builder(Maneuver.TYPE_STRAIGHT).build()
            return Step.Builder()
                .setRoad("")
                .setCue("")
                .setManeuver(defaultManeuver)
                .build()
        }
    }

    override fun onSurfaceAvailable(surfaceContainer: SurfaceContainer) {
        super.onSurfaceAvailable(surfaceContainer)
        
        mScreenWidth = surfaceContainer.width
        mScreenHeight = surfaceContainer.height
        val screenDpi = surfaceContainer.dpi
        
        val density = screenDpi / 160f
        
        val navigationPanelWidthFromRatio = (mScreenWidth * NAVIGATION_PANEL_WIDTH_RATIO).toInt()
        
        mNavigationPanelWidth = navigationPanelWidthFromRatio
        mTopPaddingNoGuidance = TOP_PADDING_NO_GUIDANCE_MAX
        
        Log.d(TAG, "🟠 [AndroidAuto] onSurfaceAvailable() - density: ${density}")
        Log.d(TAG, "🟠 [AndroidAuto] onSurfaceAvailable() - screen: ${mScreenWidth}x${mScreenHeight}px")
        Log.d(TAG, "🟠 [AndroidAuto] onSurfaceAvailable() - navPanel: ${mNavigationPanelWidth}px, topPadding: ${mTopPaddingNoGuidance}px")
    }

    override fun onNavigationReady(ready: Boolean) {
        super.onNavigationReady(ready)

         if (ready && mNavigator == null) {
            Log.d(TAG, "✅ [AndroidAuto] onNavigationReady() - getting Navigator")
            NavigationApi.getNavigator(
                carContext.applicationContext as Application,
                object : NavigationApi.NavigatorListener {
                    override fun onNavigatorReady(navigator: Navigator) {
                        Log.d(TAG, "✅ [AndroidAuto] onNavigatorReady() - Navigator ready")
                        mNavigator = navigator
                        
                        // Add listener to detect route changes
                        mRouteChangedListener = Navigator.RouteChangedListener {
                            Log.d(TAG, "🗺️ [AndroidAuto] onRouteChanged() - route changed, invalidating template")
                            invalidate()
                        }
                        navigator.addRouteChangedListener(mRouteChangedListener)
                        
                        checkAndUpdateGuidanceState()
                        invalidate()
                    }

                    override fun onError(errorCode: Int) {
                        Log.e(TAG, "✅ [AndroidAuto] onNavigatorReady() - error: $errorCode")
                    }
                }
            )
        }

        checkAndUpdateGuidanceState()
        invalidate()
    }

    override fun onGetTemplate(): Template {
        // Single waiting screen for both cases: navigation not ready OR no route available
        if (!mIsNavigationReady || mNavigator?.currentRouteSegment == null) {
            Log.d(TAG, "🔷 [AndroidAuto] onGetTemplate() - waiting (navReady: $mIsNavigationReady, hasRoute: ${mNavigator?.currentRouteSegment != null})")
            return PaneTemplate.Builder(
                Pane.Builder()
                    .addRow(
                        Row.Builder()
                            .setTitle("Waiting")
                            .addText("Waiting for navigation session...")
                            .build()
                    )
                    .build()
            )
                .build()
        }
        // Suppresses the missing permission check for the followMyLocation method, which requires
        // "android.permission.ACCESS_COARSE_LOCATION" or "android.permission.ACCESS_FINE_LOCATION", as
        // these permissions are already handled elsewhere.
        @SuppressLint("MissingPermission")
        val actionStripBuilder = ActionStrip.Builder()
            .addAction(
                            Action.Builder()
                            .setTitle(getStartStopButtonTitle())
                                .setOnClickListener {
                                    mNavigator?.let { navigator ->
                                        try {
                                            if (navigator.isGuidanceRunning) {
                                                Log.d(TAG, "🔵 [AndroidAuto] Stop button pressed")
                                                sendCustomNavigationAutoEvent("AutoEventStop", mapOf("timestamp" to System.currentTimeMillis().toString()))
                                                navigator.stopGuidance()
                                            } else {
                                                Log.d(TAG, "🔵 [AndroidAuto] Start button pressed")
                                                sendCustomNavigationAutoEvent("AutoEventStart", mapOf("timestamp" to System.currentTimeMillis().toString()))
                                                navigator.startGuidance()
                                            }
                                            invalidate()
                                        } catch (e: Exception) {
                                            Log.e(TAG, "🔵 [AndroidAuto] Error toggling guidance: ${e.message}")
                                        }
                                    }
                                
                                }
                            .build())
        
        // Add the "show itinerary" button only if guidance is not active
        if (mNavigator?.isGuidanceRunning == false) {
            actionStripBuilder.addAction(
                Action.Builder()
                .setTitle("Route")
                    .setOnClickListener {
                    Log.d(TAG, "🔵 [AndroidAuto] Itinerary button pressed")
                    sendCustomNavigationAutoEvent("show_itinerary_button_pressed", mapOf("timestamp" to System.currentTimeMillis().toString()))
                    showRouteOverview()
                    }
                .build())
        }
        
        actionStripBuilder.addAction(
            Action.Builder()
            .setTitle("Recenter")
                .setOnClickListener {
                Log.d(TAG, "🔵 [AndroidAuto] Recenter button pressed")
                mGoogleMap?.followMyLocation(GoogleMap.CameraPerspective.TILTED)
                sendCustomNavigationAutoEvent("recenter_button_pressed", mapOf("timestamp" to System.currentTimeMillis().toString()))
                }
            .build())
        
        val navigationTemplateBuilder =
            NavigationTemplate.Builder()
                .setActionStrip(actionStripBuilder.build())
                .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())

        if (mNavInfo != null) {
            navigationTemplateBuilder.setNavigationInfo(mNavInfo!!)
        }

        mTravelEstimate?.let { travelEstimate ->
            navigationTemplateBuilder.setDestinationTravelEstimate(travelEstimate)
        }

        return navigationTemplateBuilder.build()
    }

    private fun getStartStopButtonTitle(): String {
        return if (mNavigator == null) {
            ""
        } else {
            try {
                if (mNavigator?.isGuidanceRunning == true) "Stop" else "Start"
            } catch (e: Exception) {
                Log.e(TAG, "🔵 [AndroidAuto] getStartStopButtonTitle() - error: ${e.message}")
                "Start"
            }
        }
    }

    private fun checkAndUpdateGuidanceState() {
        try {
            val isGuidanceRunning = mNavigator?.isGuidanceRunning ?: false
            
            if (isGuidanceRunning != mIsGuidanceRunning) {
                Log.d(TAG, "⏱️ [AndroidAuto] Guidance state changed to: $isGuidanceRunning")
                mIsGuidanceRunning = isGuidanceRunning
                updateMapPaddingForGuidance(isGuidanceRunning)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "⏱️ [AndroidAuto] checkAndUpdateGuidanceState() - error: ${e.message}")
        }
    }

    private fun updateMapPaddingForGuidance(isGuidanceActive: Boolean) {
        try {
            val leftPadding: Int
            val topPadding: Int
            
            if (isGuidanceActive) {
                leftPadding = mNavigationPanelWidth
                topPadding = 0
            } else {
                leftPadding = 0
                topPadding = mTopPaddingNoGuidance
            }
            
            mGoogleMap?.setPadding(leftPadding, topPadding, 0, 0)
            
            Log.d(TAG, "🗺️ [AndroidAuto] Map padding updated - left: ${leftPadding}px, top: ${topPadding}px")
        } catch (e: Exception) {
            Log.e(TAG, "🗺️ [AndroidAuto] updateMapPaddingForGuidance() - error: ${e.message}")
        }
    }

    @SuppressLint("MissingPermission")
    private fun showRouteOverview() {
        try {
            Log.d(TAG, "🗺️ [AndroidAuto] showRouteOverview() called")
            
            val googleMap = mGoogleMap
            if (googleMap == null) {
                Log.w(TAG, "🗺️ [AndroidAuto] showRouteOverview() - GoogleMap null")
                return
            }

            // Force padding update before calculating bounds
            val isGuidanceRunning = mNavigator?.isGuidanceRunning ?: false
            updateMapPaddingForGuidance(isGuidanceRunning)

            val navigator = mNavigator
            if (navigator == null) {
                Log.w(TAG, "🗺️ [AndroidAuto] showRouteOverview() - Navigator null")
                return
            }

            val currentRouteSegment = navigator.currentRouteSegment
            if (currentRouteSegment == null) {
                Log.w(TAG, "🗺️ [AndroidAuto] showRouteOverview() - no route segment")
                return
            }

            val pathBuilder = com.google.android.gms.maps.model.LatLngBounds.Builder()
            var hasPoints = false
            
            googleMap.myLocation?.let { location ->
                pathBuilder.include(com.google.android.gms.maps.model.LatLng(location.latitude, location.longitude))
                hasPoints = true
            }
            
            val routeSegments = navigator.routeSegments
            if (routeSegments != null && routeSegments.isNotEmpty()) {
                for (segment in routeSegments) {
                    val latLngs = segment.latLngs
                    if (latLngs != null && latLngs.isNotEmpty()) {
                        for (latLng in latLngs) {
                            pathBuilder.include(latLng)
                            hasPoints = true
                        }
                    }
                    
                    segment.destinationWaypoint?.position?.let { position ->
                        pathBuilder.include(com.google.android.gms.maps.model.LatLng(position.latitude, position.longitude))
                        hasPoints = true
                    }
                }
            }
            
            if (!hasPoints) {
                Log.w(TAG, "🗺️ [AndroidAuto] showRouteOverview() - no points to build bounds")
                return
            }
            
            try {
                val originalBounds = pathBuilder.build()                
                val padding = 20
                val cameraUpdate = com.google.android.gms.maps.CameraUpdateFactory.newLatLngBounds(
                    originalBounds,
                    padding
                )
                googleMap.animateCamera(cameraUpdate, 500, null)
                Log.d(TAG, "🗺️ [AndroidAuto] showRouteOverview() - success")
            } catch (e: IllegalStateException) {
                Log.w(TAG, "🗺️ [AndroidAuto] showRouteOverview() - could not build bounds: ${e.message}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "🗺️ [AndroidAuto] showRouteOverview() - error: ${e.message}")
        }
    }
    
    override fun onSurfaceDestroyed(surfaceContainer: androidx.car.app.SurfaceContainer) {
        super.onSurfaceDestroyed(surfaceContainer)
        
        // Clean up route changed listener
        mRouteChangedListener?.let { listener ->
            mNavigator?.removeRouteChangedListener(listener)
            Log.d(TAG, "🔴 [AndroidAuto] onSurfaceDestroyed() - RouteChangedListener removed")
        }
        mRouteChangedListener = null
        mNavigator = null
    }
}
