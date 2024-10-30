package com.google.maps.flutter.navigation_example

import android.annotation.SuppressLint
import androidx.car.app.CarContext
import androidx.car.app.model.Action
import androidx.car.app.model.ActionStrip
import androidx.car.app.model.Template
import androidx.car.app.navigation.model.NavigationTemplate
import com.google.android.gms.maps.GoogleMap
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo
import com.google.maps.flutter.navigation.AndroidAutoBaseScreen

class SampleAndroidAutoScreen(carContext: CarContext): AndroidAutoBaseScreen(carContext) {
    override fun onGetTemplate(): Template {
        // Suppresses the missing permission check for the followMyLocation method, which requires
        // "android.permission.ACCESS_COARSE_LOCATION" or "android.permission.ACCESS_FINE_LOCATION", as
        // these permissions are already handled elsewhere.
        @SuppressLint("MissingPermission") val navigationTemplateBuilder =
            NavigationTemplate.Builder()
                .setActionStrip(
                    ActionStrip.Builder()
                        .addAction(
                            Action.Builder()
                                .setTitle("Re-center")
                                .setOnClickListener {
                                    if (mGoogleMap == null) return@setOnClickListener
                                    mGoogleMap!!.followMyLocation(GoogleMap.CameraPerspective.TILTED)
                                }
                                .build())
                        .addAction(
                            Action.Builder()
                                .setTitle("Custom event")
                                .setOnClickListener {
                                }
                                .build())
                        .build())
                .setMapActionStrip(ActionStrip.Builder().addAction(Action.PAN).build())


        // Show turn-by-turn navigation information if available.
        //if (mNavInfo != null) {
        //    navigationTemplateBuilder.setNavigationInfo(mNavInfo)
        //}

        return navigationTemplateBuilder.build()
    }

}