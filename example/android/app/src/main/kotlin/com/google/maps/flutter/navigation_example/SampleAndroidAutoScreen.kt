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

package com.google.maps.flutter.navigation_example

import android.annotation.SuppressLint
import android.app.Application
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.CarToast
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.CarIcon
import androidx.car.app.model.Distance
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.Maneuver
import androidx.car.app.navigation.model.NavigationTemplate
import androidx.car.app.navigation.model.RoutingInfo
import androidx.car.app.navigation.model.Step
import androidx.car.app.SurfaceContainer
import androidx.core.graphics.drawable.IconCompat
import androidx.lifecycle.Observer
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.navigation.NavigationUpdatesOptions.GeneratedStepImagesType
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.android.libraries.mapsplatform.turnbyturn.model.StepInfo
import com.google.maps.flutter.navigation.AndroidAutoBaseScreen
import com.google.maps.flutter.navigation.AutoMapViewOptions
import com.google.maps.flutter.navigation.GoogleMapsNavigatorHolder
import kotlin.math.max


/**
 * Example Android Auto [androidx.car.app.Screen] that shows how to extend the SDK-provided
 * [AndroidAutoBaseScreen] to build a full turn-by-turn experience on the car head unit.
 *
 * This class is intended to be read as documentation. It demonstrates the two responsibilities an
 * app has when integrating the Google Navigation SDK with Android Auto:
 *
 * 1. Rendering the map. [AndroidAutoBaseScreen] already draws the navigation map onto the Android
 *    Auto surface, so we only need to build the [NavigationTemplate] (action strips and buttons) in
 *    [onGetTemplate].
 * 2. Feeding turn-by-turn guidance into the Android Auto navigation "turn card". Android Auto does
 *    not read guidance from the map automatically: the app must translate the SDK's turn-by-turn
 *    [NavInfo] updates into Android Auto's [RoutingInfo]/[Step]/[Maneuver] objects and hand them to
 *    the template.
 *
 * The overall data flow is:
 * ```
 * Navigator --> TurnByTurn service --> NavInfo LiveData --> SampleAndroidAutoScreen
 *     --> RoutingInfo (current/next step, distance, lanes)
 *     --> NavigationTemplate turn card
 * ```
 *
 * The turn-by-turn feed is only observed while the car surface is available AND navigation is ready
 * (see [startListeningNavInfoIfPossible]/[stopListeningNavInfo]); this avoids doing work when there
 * is no turn card to populate.
 *
 * See https://developers.google.com/maps/documentation/navigation/android-sdk/android-auto for the
 * official guide that this example follows.
 */
class SampleAndroidAutoScreen(carContext: CarContext): AndroidAutoBaseScreen(carContext) {

    /** The latest turn-by-turn guidance converted into an Android Auto [RoutingInfo], or null. */
    private var mNavInfo: RoutingInfo? = null

    /** Whether the turn-by-turn updates service is currently registered. */
    private var hasRegisteredTurnByTurnService: Boolean = false

    /** Whether we are currently observing the [NavInfo] LiveData. */
    private var hasRegisteredNavInfoObserver: Boolean = false

    /** Whether the Android Auto drawing surface is currently available. */
    private var isAutoSurfaceAvailable: Boolean = false

    /** Observer that converts each [NavInfo] update into Android Auto data structures. */
    private val navInfoObserver = Observer<NavInfo> { navInfo: NavInfo? ->
        buildNavInfo(navInfo)
    }

    init {
        // Listening is driven by lifecycle hooks rather than started here:
        // onSurfaceAvailable/onSurfaceDestroyed track surface availability and
        // onNavigationReady tracks navigator readiness. Only when both are true
        // do we observe the turn-by-turn feed (see startListeningNavInfoIfPossible).
    }

    // region Turn-by-turn feed lifecycle

    /**
     * Starts observing the turn-by-turn feed, but only when both preconditions hold:
     * the car surface is available and the navigator is ready. Called from both the
     * surface and navigation lifecycle hooks so whichever happens last triggers listening.
     */
    private fun startListeningNavInfoIfPossible() {
        if (!isAutoSurfaceAvailable || !mIsNavigationReady) {
            return
        }

        if (!hasRegisteredNavInfoObserver) {
            GoogleMapsNavigatorHolder.addNavInfoObserver(navInfoObserver)
            hasRegisteredNavInfoObserver = true
        }

        tryRegisterTurnByTurnServiceIfNeeded()
    }

    /**
     * Stops observing the turn-by-turn feed and unregisters the updates service. Called when the
     * surface is destroyed or navigation is no longer ready, so we don't process updates that
     * cannot be displayed.
     */
    private fun stopListeningNavInfo() {
        if (hasRegisteredNavInfoObserver) {
            GoogleMapsNavigatorHolder.removeNavInfoObserver(navInfoObserver)
            hasRegisteredNavInfoObserver = false
        }

        if (hasRegisteredTurnByTurnService) {
            GoogleMapsNavigatorHolder.unregisterTurnByTurnService()
            hasRegisteredTurnByTurnService = false
        }
    }

    /**
     * Registers the turn-by-turn updates service that feeds the [NavInfo] LiveData. The service
     * must be registered for guidance updates to flow; it is registered once and torn down in
     * [stopListeningNavInfo].
     */
    private fun tryRegisterTurnByTurnServiceIfNeeded() {
        if (hasRegisteredTurnByTurnService || !mIsNavigationReady) {
            return
        }

        val app = carContext.applicationContext as? Application ?: return

        // Register nav updates with no generated step images; we use the bitmaps already provided on
        // the NavInfo steps (maneuverBitmap/lanesBitmap) when available.
        hasRegisteredTurnByTurnService =
            GoogleMapsNavigatorHolder.registerTurnByTurnService(
                app,
                1,
                GeneratedStepImagesType.NONE,
            )
        if (!hasRegisteredTurnByTurnService) {
            Log.w("SampleAndroidAutoScreen", "Failed to register turn-by-turn nav updates service")
        }
    }

    // endregion

    // region Converting NavInfo into Android Auto data structures

    /**
     * Converts a single turn-by-turn [NavInfo] update into an Android Auto [RoutingInfo] and
     * triggers a template refresh. This is the heart of the integration and runs on every
     * guidance update.
     */
    private fun buildNavInfo(navInfo: NavInfo?) {
        if (navInfo == null || navInfo.currentStep == null) {
            // No active step means guidance is not (or no longer) running. Clear any stale turn
            // card and refresh the template.
            if (mNavInfo != null) {
                mNavInfo = null
                invalidate()
            }
            return
        }

        // Convert the current step and its distance into Android Auto types.
        val currentStep: Step = buildStepFromStepInfo(navInfo.currentStep!!)
        val distanceToStep =
            Distance.create(
                max(navInfo.distanceToCurrentStepMeters?.toDouble() ?: 0.0, 0.0),
                Distance.UNIT_METERS,
            )

        val routingInfoBuilder = RoutingInfo.Builder().setCurrentStep(currentStep, distanceToStep)

        // Include the next maneuver when available so the turn card can preview it.
        val remainingSteps = navInfo.remainingSteps
        if (!remainingSteps.isNullOrEmpty()) {
            routingInfoBuilder.setNextStep(buildStepFromStepInfo(remainingSteps[0]))
        }

        // Use the lanes bitmap as the junction image when present to show lane guidance.
        navInfo.currentStep!!.lanesBitmap?.let { lanesBitmap ->
            val lanesIcon = CarIcon.Builder(IconCompat.createWithBitmap(lanesBitmap)).build()
            routingInfoBuilder.setJunctionImage(lanesIcon)
        }

        mNavInfo = routingInfoBuilder.build()

        // Invalidate the current template, which leads to another onGetTemplate call that renders
        // the updated turn card.
        invalidate()
    }

    /**
     * Converts a turn-by-turn [StepInfo] into an Android Auto [Step], including the maneuver type,
     * its icon, the road name and the instruction cue.
     */
    private fun buildStepFromStepInfo(stepInfo: StepInfo): Step {
        val maneuverType: Int = ManeuverConverter.getAndroidAutoManeuverType(stepInfo.maneuver)
        val maneuverBuilder = Maneuver.Builder(maneuverType)

        // Roundabout maneuver types carry required metadata. Without it,
        // Maneuver.Builder.build() throws IllegalArgumentException:
        // - *_WITH_ANGLE types require a roundabout exit angle in the range [1, 360].
        // - ENTER_AND_EXIT (non-angle) types require a roundabout exit number >= 1.
        when (maneuverType) {
            Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE -> {
                ManeuverConverter.getAndroidAutoRoundaboutAngle(stepInfo.maneuver)?.let { exitAngle
                    ->
                    maneuverBuilder.setRoundaboutExitAngle(exitAngle)
                }
            }
            Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW,
            Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW -> {
                // roundaboutTurnNumber may be null or 0; fall back to 1 since the API
                // requires a valid exit number.
                val exitNumber = stepInfo.roundaboutTurnNumber ?: 0
                maneuverBuilder.setRoundaboutExitNumber(if (exitNumber >= 1) exitNumber else 1)
            }
        }

        // The maneuver icon is provided as a bitmap by the turn-by-turn feed.
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
        return stepBuilder.build()
    }

    // endregion

    // region Lifecycle hooks from AndroidAutoBaseScreen

    /**
     * Called when navigator readiness changes. We start or stop listening to the turn-by-turn feed
     * accordingly and refresh the template, since [onGetTemplate] renders differently depending on
     * readiness.
     */
    override fun onNavigationReady(ready: Boolean) {
        super.onNavigationReady(ready)
        if (ready) {
            startListeningNavInfoIfPossible()
        } else {
            stopListeningNavInfo()
        }
        // Invalidate template layout because of conditional rendering in the
        // onGetTemplate method.
        invalidate()
    }

    /** Called when the Android Auto drawing surface becomes available. */
    override fun onSurfaceAvailable(surfaceContainer: SurfaceContainer) {
        super.onSurfaceAvailable(surfaceContainer)
        isAutoSurfaceAvailable = true
        startListeningNavInfoIfPossible()
    }

    /** Called when the Android Auto drawing surface is torn down. */
    override fun onSurfaceDestroyed(surfaceContainer: SurfaceContainer) {
        super.onSurfaceDestroyed(surfaceContainer)
        isAutoSurfaceAvailable = false
        stopListeningNavInfo()
    }

    // endregion

    // region Custom events and prompts

    /**
     * Called when a traffic/incident prompt appears or disappears on the Android Auto screen.
     * Always call super so the event is forwarded to Flutter; add custom UI adjustments afterwards
     * if needed.
     */
    override fun onPromptVisibilityChanged(promptVisible: Boolean) {
        super.onPromptVisibilityChanged(promptVisible) // This sends the event to Flutter
        Log.d("SampleAndroidAutoScreen", "Prompt visibility changed to: $promptVisible")

        // You can add custom logic here, such as:
        // - Hiding/showing custom action buttons when prompts appear
        // - Adjusting your template layout
        // - Updating custom UI elements

        // For example, you might want to refresh the template:
        // invalidate()
    }

    /**
     * Called when Flutter sends a custom event to the native side via
     * `GoogleMapsAutoViewController.sendCustomNavigationAutoEvent`. This example surfaces the
     * message as a [CarToast].
     */
    override fun onCustomNavigationAutoEventFromFlutter(event: String, data: Any) {
        Log.d("SampleAndroidAutoScreen", "Received custom event from Flutter: event=$event, data=$data")

        val message = (data as? Map<*, *>)?.get("message")?.toString()?.take(120)
            ?: "No message"
        CarToast.makeText(
            carContext,
            message,
            CarToast.LENGTH_SHORT,
        ).show()
    }

    /**
     * Provides the map options used when [AndroidAutoBaseScreen] creates the Android Auto map.
     * Returning super's value uses the options supplied from Flutter; override to hard-code native
     * options instead.
     */
    override fun getAutoMapOptions(): AutoMapViewOptions? {
        // Call super to use Flutter-provided options.
        return super.getAutoMapOptions()

        // Or provide your own custom options:
        // return AutoMapViewOptions(
        //     mapId = "your-custom-map-id",
        //     mapType = GoogleMap.MAP_TYPE_SATELLITE,
        //     mapColorScheme = MapColorScheme.DARK,
        //     forceNightMode = NavigationForceNightMode.FORCE_NIGHT
        // )
    }

    // endregion

    // region Template

    /**
     * Builds the [NavigationTemplate] shown on the Android Auto screen. Android Auto calls this
     * whenever [invalidate] is called. The template carries:
     * - an action strip with a "Re-center" button (only when navigation is ready) and a custom
     *   event button;
     * - a map action strip with the required [Action.PAN] button so the map is pannable;
     * - the turn card navigation info, when available.
     */
    override fun onGetTemplate(): Template {
        // Suppresses the missing permission check for the followMyLocation method, which requires
        // "android.permission.ACCESS_COARSE_LOCATION" or "android.permission.ACCESS_FINE_LOCATION", as
        // these permissions are already handled elsewhere.
        @SuppressLint("MissingPermission")
        val actionStripBuilder = ActionStrip.Builder()

        // The Re-center action calls GoogleMap.followMyLocation, which requires the navigator to be
        // initialized.
        if (mIsNavigationReady) {
            actionStripBuilder.addAction(
                Action.Builder()
                    .setTitle("Re-center")
                    .setOnClickListener {
                        if (mGoogleMap == null) return@setOnClickListener
                        mGoogleMap!!.followMyLocation(GoogleMap.CameraPerspective.TILTED)
                    }
                    .build())
        }

        actionStripBuilder.addAction(
            Action.Builder()
                .setTitle("Custom event")
                .setOnClickListener {
                    sendCustomNavigationAutoEvent("CustomAndroidAutoEvent", mapOf("sampleDataKey" to "sampleDataContent"))
                }
                .build())

        val navigationTemplateBuilder =
            NavigationTemplate.Builder()
                .setActionStrip(actionStripBuilder.build())
                .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())


        // Show the turn card when guidance info is available (populated by buildNavInfo).
        if (mNavInfo != null) {
            navigationTemplateBuilder.setNavigationInfo(mNavInfo!!)
        }

        return navigationTemplateBuilder.build()
    }

    // endregion
}