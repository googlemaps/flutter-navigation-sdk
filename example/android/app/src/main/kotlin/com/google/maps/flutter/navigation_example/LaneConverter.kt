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

import androidx.car.app.navigation.model.Lane
import androidx.car.app.navigation.model.LaneDirection
import com.google.android.libraries.mapsplatform.turnbyturn.model.LaneDirection.LaneShape

/** Converter that converts between turn-by-turn Lanes and Android Auto Lanes. */
object LaneConverter {
    
    /**
     * Converts a list of turn-by-turn lanes to Android Auto lanes.
     * 
     * @param lanes List of lanes from StepInfo
     * @return List of Android Auto Lane objects
     */
    fun convertToAndroidAutoLanes(
        lanes: List<com.google.android.libraries.mapsplatform.turnbyturn.model.Lane>?
    ): List<Lane>? {
        if (lanes.isNullOrEmpty()) {
            return null
        }
        
        return lanes.mapNotNull { lane ->
            try {
                val laneDirections = lane.laneDirections()
                if (laneDirections.isNullOrEmpty()) {
                    null
                } else {
                    val builder = Lane.Builder()
                    for (laneDirection in laneDirections) {
                        val carLaneDirection = convertLaneDirection(laneDirection)
                        builder.addDirection(carLaneDirection)
                    }
                    builder.build()
                }
            } catch (e: Exception) {
                null
            }
        }
    }
    
    /**
     * Converts a single turn-by-turn lane direction to an Android Auto LaneDirection.
     * 
     * @param laneDirection Lane direction from turn-by-turn
     * @return Android Auto LaneDirection
     */
    private fun convertLaneDirection(
        laneDirection: com.google.android.libraries.mapsplatform.turnbyturn.model.LaneDirection
    ): LaneDirection {
        val shape = convertLaneShape(laneDirection.laneShape())
        return LaneDirection.create(shape, laneDirection.isRecommended)
    }
    
    /**
     * Converts a turn-by-turn lane shape to an Android Auto lane direction shape.
     * 
     * @param laneShape Lane shape from turn-by-turn (LaneShape constant)
     * @return Android Auto LaneDirection shape constant
     */
    private fun convertLaneShape(laneShape: Int): Int {
        return when (laneShape) {
            LaneShape.STRAIGHT -> LaneDirection.SHAPE_STRAIGHT
            LaneShape.SLIGHT_LEFT -> LaneDirection.SHAPE_SLIGHT_LEFT
            LaneShape.SLIGHT_RIGHT -> LaneDirection.SHAPE_SLIGHT_RIGHT
            LaneShape.NORMAL_LEFT -> LaneDirection.SHAPE_NORMAL_LEFT
            LaneShape.NORMAL_RIGHT -> LaneDirection.SHAPE_NORMAL_RIGHT
            LaneShape.SHARP_LEFT -> LaneDirection.SHAPE_SHARP_LEFT
            LaneShape.SHARP_RIGHT -> LaneDirection.SHAPE_SHARP_RIGHT
            LaneShape.U_TURN_LEFT -> LaneDirection.SHAPE_U_TURN_LEFT
            LaneShape.U_TURN_RIGHT -> LaneDirection.SHAPE_U_TURN_RIGHT
            else -> LaneDirection.SHAPE_UNKNOWN
        }
    }
}
