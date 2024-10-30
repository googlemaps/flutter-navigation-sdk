package com.google.maps.flutter.navigation_example

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.CarToast
import androidx.car.app.Screen
import androidx.car.app.Session
import androidx.car.app.SessionInfo
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

class SampleAndroidAutoSession(sessionInfo: SessionInfo): Session() {

    val TAG: String = SampleAndroidAutoSession::class.java.simpleName

    init {
        if (sessionInfo.displayType == SessionInfo.DISPLAY_TYPE_MAIN) {
            lifecycle.addObserver(object: DefaultLifecycleObserver {
                override fun onCreate(owner: LifecycleOwner) {
                    Log.i(TAG, "In onCreate()")
                }

                override fun onStart(owner: LifecycleOwner) {
                    Log.i(TAG, "In onStart()")
                    carContext
                        .bindService(
                            Intent(carContext, SampleAndroidAutoService::class.java),
                            mServiceConnection,
                            Context.BIND_AUTO_CREATE
                        )
                }

                override fun onResume(owner: LifecycleOwner) {
                    Log.i(TAG, "In onResume()")
                }

                override fun onPause(owner: LifecycleOwner) {
                    Log.i(TAG, "In onPause()")
                }

                override fun onStop(owner: LifecycleOwner) {
                    Log.i(TAG, "In onStop()")
                    carContext.unbindService(mServiceConnection)
                }

                override fun onDestroy(owner: LifecycleOwner) {
                    Log.i(TAG, "In onDestroy()")
                }
            })
        }
    }

    // Monitors the state of the connection to the Navigation service.
    val mServiceConnection: ServiceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName, service: IBinder) {
            Log.i(TAG, "In onServiceConnected() component:$name")
        }

        override fun onServiceDisconnected(name: ComponentName) {
            Log.i(
                TAG,
                "In onServiceDisconnected() component:$name"
            )
        }
    }

    override fun onCreateScreen(intent: Intent): Screen {
        Log.i(TAG, "In onCreateScreen()")

        val action = intent.action
        if (action != null && CarContext.ACTION_NAVIGATE == action) {
            CarToast.makeText(
                carContext, "Navigation intent: " + intent.dataString, CarToast.LENGTH_LONG
            )
                .show()
        }

        return SampleAndroidAutoScreen(carContext)
    }
}