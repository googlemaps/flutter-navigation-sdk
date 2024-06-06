// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

/// Maps [Maneuver] values to Material Icons.
IconData getManeuverIcon(Maneuver maneuver) {
  switch (maneuver) {
    case Maneuver.depart:
      return Icons.departure_board;
    case Maneuver.destination:
      return Icons.flag;
    case Maneuver.destinationLeft:
      return Icons.flag;
    case Maneuver.destinationRight:
      return Icons.flag;
    case Maneuver.ferryBoat:
      return Icons.directions_boat;
    case Maneuver.ferryTrain:
      return Icons.directions_railway;
    case Maneuver.forkLeft:
      return Icons.fork_left;
    case Maneuver.forkRight:
      return Icons.fork_right;
    case Maneuver.mergeLeft:
      return Icons.merge;
    case Maneuver.mergeRight:
      return Icons.merge;
    case Maneuver.mergeUnspecified:
      return Icons.merge_type;
    case Maneuver.nameChange:
      return Icons.edit_location;
    case Maneuver.offRampKeepLeft:
      return Icons.subdirectory_arrow_left;
    case Maneuver.offRampKeepRight:
      return Icons.subdirectory_arrow_right;
    case Maneuver.offRampLeft:
      return Icons.subdirectory_arrow_left;
    case Maneuver.offRampRight:
      return Icons.subdirectory_arrow_right;
    case Maneuver.offRampSharpLeft:
      return Icons.subdirectory_arrow_left;
    case Maneuver.offRampSharpRight:
      return Icons.subdirectory_arrow_right;
    case Maneuver.offRampSlightLeft:
      return Icons.subdirectory_arrow_left;
    case Maneuver.offRampSlightRight:
      return Icons.subdirectory_arrow_right;
    case Maneuver.offRampUnspecified:
      return Icons.question_mark; // Placeholder // Placeholder
    case Maneuver.offRampUTurnClockwise:
      return Icons.subdirectory_arrow_right;
    case Maneuver.offRampUTurnCounterclockwise:
      return Icons.subdirectory_arrow_left;
    case Maneuver.onRampKeepLeft:
      return Icons.ramp_left; // Placeholder
    case Maneuver.onRampKeepRight:
      return Icons.ramp_right; // Placeholder
    case Maneuver.onRampLeft:
      return Icons.ramp_left; // Placeholder
    case Maneuver.onRampRight:
      return Icons.ramp_right; // Placeholder
    case Maneuver.onRampSharpLeft:
      return Icons.ramp_left; // Placeholder
    case Maneuver.onRampSharpRight:
      return Icons.ramp_right; // Placeholder
    case Maneuver.onRampSlightLeft:
      return Icons.ramp_left; // Placeholder
    case Maneuver.onRampSlightRight:
      return Icons.ramp_right; // Placeholder
    case Maneuver.onRampUnspecified:
      return Icons.ramp_right; // Placeholder
    case Maneuver.onRampUTurnClockwise:
      return Icons.subdirectory_arrow_right;
    case Maneuver.onRampUTurnCounterclockwise:
      return Icons.subdirectory_arrow_left;
    case Maneuver.roundaboutClockwise:
      return Icons.roundabout_right; // Placeholder
    case Maneuver.roundaboutCounterclockwise:
      return Icons.roundabout_left; // Placeholder
    case Maneuver.roundaboutExitClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutExitCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutLeftClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutLeftCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutRightClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutRightCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSharpLeftClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSharpLeftCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSharpRightClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSharpRightCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSlightLeftClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSlightLeftCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSlightRightClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutSlightRightCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutStraightClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutStraightCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutUTurnClockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.roundaboutUTurnCounterclockwise:
      return Icons.question_mark; // Placeholder
    case Maneuver.straight:
      return Icons.arrow_upward;
    case Maneuver.turnKeepLeft:
      return Icons.turn_left; // Placeholder
    case Maneuver.turnKeepRight:
      return Icons.abc_sharp; // Placeholder
    case Maneuver.turnLeft:
      return Icons.turn_left;
    case Maneuver.turnRight:
      return Icons.turn_right;
    case Maneuver.turnSharpLeft:
      return Icons.turn_sharp_left;
    case Maneuver.turnSharpRight:
      return Icons.turn_sharp_right;
    case Maneuver.turnSlightLeft:
      return Icons.turn_slight_left;
    case Maneuver.turnSlightRight:
      return Icons.turn_slight_right;
    case Maneuver.turnUTurnClockwise:
      return Icons.u_turn_right;
    case Maneuver.turnUTurnCounterclockwise:
      return Icons.u_turn_left;
    case Maneuver.unknown:
      return Icons.question_mark; // Placeholder
  }
}
