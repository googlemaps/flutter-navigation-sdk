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

import com.google.android.libraries.mapsplatform.turnbyturn.model.Maneuver

/** Converter that converts between turn-by-turn and Android Auto Maneuvers.  */
object ManeuverConverter {
    // Map from turn-by-turn Maneuver to Android Auto Maneuver.Type.

    private val MANEUVER_TO_ANDROID_AUTO_MANEUVER_TYPE =
        mapOf(Maneuver.DEPART to androidx.car.app.navigation.model.Maneuver.TYPE_DEPART,
            Maneuver.DESTINATION to androidx.car.app.navigation.model.Maneuver.TYPE_DESTINATION,
            Maneuver.DESTINATION_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_DESTINATION_LEFT,
            Maneuver.DESTINATION_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_DESTINATION_RIGHT,
            Maneuver.STRAIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_STRAIGHT,
            Maneuver.TURN_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_TURN_NORMAL_LEFT,
            Maneuver.TURN_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_TURN_NORMAL_RIGHT,
            Maneuver.TURN_KEEP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_KEEP_LEFT,
            Maneuver.TURN_KEEP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_KEEP_RIGHT,
            Maneuver.TURN_SLIGHT_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_TURN_SLIGHT_LEFT,
            Maneuver.TURN_SLIGHT_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_TURN_SLIGHT_RIGHT,
            Maneuver.TURN_SHARP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_TURN_SHARP_LEFT,
            Maneuver.TURN_SHARP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_SHARP_RIGHT,
            Maneuver.TURN_U_TURN_CLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_U_TURN_RIGHT,
            Maneuver.TURN_U_TURN_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_U_TURN_LEFT,
            Maneuver.MERGE_UNSPECIFIED to androidx.car.app.navigation.model.Maneuver.TYPE_MERGE_SIDE_UNSPECIFIED,
            Maneuver.MERGE_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_MERGE_LEFT,
            Maneuver.MERGE_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_MERGE_RIGHT,
            Maneuver.FORK_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_FORK_LEFT,
            Maneuver.FORK_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_FORK_RIGHT,
            Maneuver.ON_RAMP_UNSPECIFIED to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_NORMAL_RIGHT,
            Maneuver.ON_RAMP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_NORMAL_LEFT,
            Maneuver.ON_RAMP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_NORMAL_RIGHT,
            Maneuver.ON_RAMP_KEEP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_NORMAL_LEFT,
            Maneuver.ON_RAMP_KEEP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_NORMAL_RIGHT,
            Maneuver.ON_RAMP_SLIGHT_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_SLIGHT_LEFT,
            Maneuver.ON_RAMP_SLIGHT_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_SLIGHT_RIGHT,
            Maneuver.ON_RAMP_SHARP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_SHARP_LEFT,
            Maneuver.ON_RAMP_SHARP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_SHARP_RIGHT,
            Maneuver.ON_RAMP_U_TURN_CLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_U_TURN_RIGHT,
            Maneuver.ON_RAMP_U_TURN_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ON_RAMP_U_TURN_LEFT,
            Maneuver.OFF_RAMP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_NORMAL_LEFT,
            Maneuver.OFF_RAMP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_NORMAL_RIGHT,
            Maneuver.OFF_RAMP_KEEP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_SLIGHT_LEFT,
            Maneuver.OFF_RAMP_KEEP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_SLIGHT_RIGHT,
            Maneuver.OFF_RAMP_SLIGHT_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_SLIGHT_LEFT,
            Maneuver.OFF_RAMP_SLIGHT_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_SLIGHT_RIGHT,
            Maneuver.OFF_RAMP_SHARP_LEFT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_NORMAL_LEFT,
            Maneuver.OFF_RAMP_SHARP_RIGHT to androidx.car.app.navigation.model.Maneuver.TYPE_OFF_RAMP_NORMAL_RIGHT,
            Maneuver.ROUNDABOUT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW,
            Maneuver.ROUNDABOUT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW,
            Maneuver.ROUNDABOUT_STRAIGHT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_ENTER_CW,
            Maneuver.ROUNDABOUT_STRAIGHT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_ENTER_CCW,
            Maneuver.ROUNDABOUT_LEFT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_LEFT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_RIGHT_CLOCKWISE to
                androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_RIGHT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SLIGHT_LEFT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SLIGHT_LEFT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SLIGHT_RIGHT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SLIGHT_RIGHT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SHARP_LEFT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SHARP_LEFT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SHARP_RIGHT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_SHARP_RIGHT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_U_TURN_CLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_U_TURN_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver
                    .TYPE_ROUNDABOUT_ENTER_AND_EXIT_CCW_WITH_ANGLE,
            Maneuver.ROUNDABOUT_EXIT_CLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_EXIT_CW,
            Maneuver.ROUNDABOUT_EXIT_COUNTERCLOCKWISE to androidx.car.app.navigation.model.Maneuver.TYPE_ROUNDABOUT_EXIT_CCW,
            Maneuver.FERRY_BOAT to androidx.car.app.navigation.model.Maneuver.TYPE_FERRY_BOAT,
            Maneuver.FERRY_TRAIN to androidx.car.app.navigation.model.Maneuver.TYPE_FERRY_TRAIN,
            Maneuver.NAME_CHANGE to androidx.car.app.navigation.model.Maneuver.TYPE_NAME_CHANGE)

    /** Represents the roundabout turn angle for a slight turn in either right or left directions.  */
    private const val ROUNDABOUT_ANGLE_SLIGHT = 10

    /** Represents the roundabout turn angle for a normal turn in either right or left directions.  */
    private const val ROUNDABOUT_ANGLE_NORMAL = 45

    /** Represents the roundabout turn angle for a sharp turn in either right or left directions.  */
    private const val ROUNDABOUT_ANGLE_SHARP = 135

    /** Represents the roundabout turn angle for a u-turn in either right or left directions.  */
    private const val ROUNDABOUT_ANGLE_U_TURN = 180

    /**
     * Returns the corresponding [androidx.car.app.navigation.model.Maneuver.Type] for the given
     * direction [Maneuver]
     *
     * @throws [IllegalArgumentException] if the given maneuver does not have a corresponding
     * Android Auto Maneuver type.
     */
    fun getAndroidAutoManeuverType(@Maneuver maneuver: Int): Int {
        if (MANEUVER_TO_ANDROID_AUTO_MANEUVER_TYPE.containsKey(maneuver)) {
            return MANEUVER_TO_ANDROID_AUTO_MANEUVER_TYPE[maneuver]!!
        }
        throw IllegalArgumentException(
            String.format(
                "Given turn-by-turn Maneuver %d cannot be converted to an Android Auto equivalent.",
                maneuver
            )
        )
    }

    /**
     * Returns the corresponding Android Auto roundabout angle for the given turn [Maneuver].
     * Returns `null` if given maneuver does not involve a roundabout with a turn.
     */
    fun getAndroidAutoRoundaboutAngle(@Maneuver maneuver: Int): Int? {
        if (maneuver == Maneuver.ROUNDABOUT_LEFT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_RIGHT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_LEFT_COUNTERCLOCKWISE || maneuver == Maneuver.ROUNDABOUT_RIGHT_COUNTERCLOCKWISE) {
            return ROUNDABOUT_ANGLE_NORMAL
        }
        if (maneuver == Maneuver.ROUNDABOUT_SHARP_LEFT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SHARP_RIGHT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SHARP_LEFT_COUNTERCLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SHARP_RIGHT_COUNTERCLOCKWISE) {
            return ROUNDABOUT_ANGLE_SHARP
        }
        if (maneuver == Maneuver.ROUNDABOUT_SLIGHT_LEFT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SLIGHT_RIGHT_CLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SLIGHT_LEFT_COUNTERCLOCKWISE || maneuver == Maneuver.ROUNDABOUT_SLIGHT_RIGHT_COUNTERCLOCKWISE) {
            return ROUNDABOUT_ANGLE_SLIGHT
        }
        if (maneuver == Maneuver.ROUNDABOUT_U_TURN_CLOCKWISE
            || maneuver == Maneuver.ROUNDABOUT_U_TURN_COUNTERCLOCKWISE
        ) {
            return ROUNDABOUT_ANGLE_U_TURN
        }
        return null
    }
}