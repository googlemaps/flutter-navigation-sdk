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

import android.app.Service
import android.content.Intent
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Looper
import android.os.Message
import android.os.Messenger
import android.os.Process
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.google.android.libraries.mapsplatform.turnbyturn.TurnByTurnManager
import com.google.android.libraries.mapsplatform.turnbyturn.model.NavInfo

/**
 * Service that listens for turn-by-turn navigation updates from the Google Maps navigation SDK and
 * broadcasts these updates via LiveData.
 */
class GoogleMapsNavigationNavUpdatesService : Service() {
  /** The messenger used by the service to receive nav step updates. */
  private lateinit var incomingMessenger: Messenger

  /** Used to read incoming messages. */
  private lateinit var turnByTurnManager: TurnByTurnManager

  private inner class IncomingNavStepHandler(looper: Looper) : Handler(looper) {
    override fun handleMessage(msg: Message) {
      if (TurnByTurnManager.MSG_NAV_INFO == msg.what) {
        // Read the nav info from the message data and convert it to navInfo
        val navInfo = turnByTurnManager.readNavInfoFromBundle(msg.data)

        // Post the value to LiveData to be displayed in the nav info header.
        navInfoMutableLiveData.postValue(navInfo)
      }
    }
  }

  override fun onBind(intent: Intent): IBinder? {
    return incomingMessenger.binder
  }

  override fun onUnbind(intent: Intent): Boolean {
    return super.onUnbind(intent)
  }

  override fun onCreate() {
    super.onCreate()
    turnByTurnManager = TurnByTurnManager.createInstance()
    val thread =
      HandlerThread("GoogleMapsNavigationNavUpdatesService", Process.THREAD_PRIORITY_DEFAULT)
        .apply { start() }
    incomingMessenger = Messenger(IncomingNavStepHandler(thread.looper))
  }

  companion object {
    private val navInfoMutableLiveData = MutableLiveData<NavInfo>()
    val navInfoLiveData: LiveData<NavInfo>
      get() = navInfoMutableLiveData
  }
}
