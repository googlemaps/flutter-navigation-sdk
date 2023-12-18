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

import android.os.Handler
import android.os.Looper
import android.view.Choreographer

/**
 * A helper class to schedule an action to be executed after a specified number of frames have
 * elapsed.
 *
 * This is particularly useful when working with a GL renderer that doesn't use standard Android
 * views and instead uses GL directly. In such cases, it may be necessary to ensure that all drawing
 * operations have been flushed before proceeding with further actions like invalidating a view.
 *
 * It's noted that the `GoogleMap.OnMapLoadedCallback` is fired when the map is ready to be used,
 * but it doesn't guarantee that the GL surface has been rendered. Hence, waiting for a certain
 * number of frames ensures that at least the frame budget time has passed since the drawing
 * operation was issued, allowing the GL rendering to complete.
 *
 * @param delayInFrames The number of frames to wait before executing the action.
 */
class FrameDelayHandler(private val delayInFrames: Int) {

  private var frameCounter = 0
  private val handler = Handler(Looper.getMainLooper())

  /**
   * Schedules the given action to be executed after the specified number of frames have elapsed.
   *
   * This method uses the [Choreographer] to count the number of frames, and executes the action on
   * the UI thread once the target frame count is reached.
   *
   * @param action The action to be executed.
   */
  fun scheduleActionWithFrameDelay(action: () -> Unit) {
    resetFrameCounter()
    scheduleNextFrameCheck(action)
  }

  /** Resets the frame counter to zero. */
  private fun resetFrameCounter() {
    frameCounter = 0
  }

  /**
   * Schedules a frame callback to check the frame count on the next frame.
   *
   * If the target frame count has not been reached, this method schedules another check on the next
   * frame. Once the target frame count is reached, the specified action is executed on the UI
   * thread.
   *
   * @param action The action to be executed.
   */
  private fun scheduleNextFrameCheck(action: () -> Unit) {
    Choreographer.getInstance().postFrameCallback {
      frameCounter++
      if (frameCounter < delayInFrames) {
        // If the target number of frames has not been reached, schedule another check on the next
        // frame
        scheduleNextFrameCheck(action)
      } else {
        // Once the target number of frames has been reached, execute the action
        handler.post { action() }
      }
    }
  }
}
