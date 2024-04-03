// Copyright 2023 Google LLC
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

import '../../types/types.dart';
import '../method_channel.dart';

/// [NavInfoDto] convert extension.
/// @nodoc
extension ConvertNavInfoDto on NavInfoDto {
  /// Converts [NavInfoDto] to [NavInfo]
  NavInfo toNavInfo() => NavInfo(
        currentStep: currentStep?.toStepInfo(),
        remainingSteps: remainingSteps
            .whereType<StepInfoDto>()
            .map<StepInfo>((StepInfoDto stepinfo) => stepinfo.toStepInfo())
            .toList(),
        routeChanged: routeChanged,
        distanceToCurrentStepMeters: distanceToCurrentStepMeters,
        distanceToNextDestinationMeters: distanceToNextDestinationMeters,
        distanceToFinalDestinationMeters: distanceToFinalDestinationMeters,
        timeToCurrentStepSeconds: timeToCurrentStepSeconds,
        timeToNextDestinationSeconds: timeToNextDestinationSeconds,
        timeToFinalDestinationSeconds: timeToFinalDestinationSeconds,
        navState: navState.toNavState(),
      );
}

/// [StepInfoDto] convert extension.
/// @nodoc
extension ConvertStepInfoDto on StepInfoDto {
  /// Converts [StepInfoDto] to [StepInfo]
  StepInfo toStepInfo() => StepInfo(
        distanceFromPrevStepMeters: distanceFromPrevStepMeters,
        timeFromPrevStepSeconds: timeFromPrevStepSeconds,
        drivingSide: drivingSide.toDrivingSide(),
        exitNumber: exitNumber,
        fullInstructions: fullInstructions,
        fullRoadName: fullRoadName,
        simpleRoadName: simpleRoadName,
        roundaboutTurnNumber: roundaboutTurnNumber,
        stepNumber: stepNumber,
        lanes: lanes
            .whereType<LaneDto>()
            .map<Lane>((LaneDto lane) => lane.toLane())
            .toList(),
        maneuver: maneuver.toManeuver(),
      );
}

/// [NavStateDto] convert extension.
/// @nodoc
extension ConvertNavStateDto on NavStateDto {
  /// Converts [NavStateDto] to [NavState]
  NavState toNavState() {
    switch (this) {
      case NavStateDto.enroute:
        return NavState.enroute;
      case NavStateDto.rerouting:
        return NavState.rerouting;
      case NavStateDto.stopped:
        return NavState.stopped;
      case NavStateDto.unknown:
        return NavState.unknown;
    }
  }
}

/// [DrivingSideDto] convert extension.
/// @nodoc
extension ConvertDrivingSideDto on DrivingSideDto {
  /// Converts [DrivingSideDto] to [DrivingSide]
  DrivingSide toDrivingSide() {
    switch (this) {
      case DrivingSideDto.left:
        return DrivingSide.left;
      case DrivingSideDto.right:
        return DrivingSide.right;
      case DrivingSideDto.none:
        return DrivingSide.none;
    }
  }
}

/// [ManeuverDto] convert extension.
/// @nodoc
extension ConvertManeuverDto on ManeuverDto {
  /// Converts [ManeuverDto] to [Maneuver]
  Maneuver toManeuver() {
    switch (this) {
      case ManeuverDto.destination:
        return Maneuver.destination;
      case ManeuverDto.depart:
        return Maneuver.depart;
      case ManeuverDto.destinationLeft:
        return Maneuver.destinationLeft;
      case ManeuverDto.destinationRight:
        return Maneuver.destinationRight;
      case ManeuverDto.ferryBoat:
        return Maneuver.ferryBoat;
      case ManeuverDto.ferryTrain:
        return Maneuver.ferryTrain;
      case ManeuverDto.forkLeft:
        return Maneuver.forkLeft;
      case ManeuverDto.forkRight:
        return Maneuver.forkRight;
      case ManeuverDto.mergeLeft:
        return Maneuver.mergeLeft;
      case ManeuverDto.mergeRight:
        return Maneuver.mergeRight;
      case ManeuverDto.mergeUnspecified:
        return Maneuver.mergeUnspecified;
      case ManeuverDto.nameChange:
        return Maneuver.nameChange;
      case ManeuverDto.offRampKeepLeft:
        return Maneuver.offRampKeepLeft;
      case ManeuverDto.offRampKeepRight:
        return Maneuver.offRampKeepRight;
      case ManeuverDto.offRampLeft:
        return Maneuver.offRampLeft;
      case ManeuverDto.offRampRight:
        return Maneuver.offRampRight;
      case ManeuverDto.offRampSharpLeft:
        return Maneuver.offRampSharpLeft;
      case ManeuverDto.offRampSharpRight:
        return Maneuver.offRampSharpRight;
      case ManeuverDto.offRampSlightLeft:
        return Maneuver.offRampSlightLeft;
      case ManeuverDto.offRampSlightRight:
        return Maneuver.offRampSlightRight;
      case ManeuverDto.offRampUnspecified:
        return Maneuver.offRampUnspecified;
      case ManeuverDto.offRampUTurnClockwise:
        return Maneuver.offRampUTurnClockwise;
      case ManeuverDto.offRampUTurnCounterclockwise:
        return Maneuver.offRampUTurnCounterclockwise;
      case ManeuverDto.onRampKeepLeft:
        return Maneuver.onRampKeepLeft;
      case ManeuverDto.onRampKeepRight:
        return Maneuver.onRampKeepRight;
      case ManeuverDto.onRampLeft:
        return Maneuver.onRampLeft;
      case ManeuverDto.onRampRight:
        return Maneuver.onRampRight;
      case ManeuverDto.onRampSharpLeft:
        return Maneuver.onRampSharpLeft;
      case ManeuverDto.onRampSharpRight:
        return Maneuver.onRampSharpRight;
      case ManeuverDto.onRampSlightLeft:
        return Maneuver.onRampSlightLeft;
      case ManeuverDto.onRampSlightRight:
        return Maneuver.onRampSlightRight;
      case ManeuverDto.onRampUnspecified:
        return Maneuver.onRampUnspecified;
      case ManeuverDto.onRampUTurnClockwise:
        return Maneuver.onRampUTurnClockwise;
      case ManeuverDto.onRampUTurnCounterclockwise:
        return Maneuver.onRampUTurnCounterclockwise;
      case ManeuverDto.roundaboutClockwise:
        return Maneuver.roundaboutClockwise;
      case ManeuverDto.roundaboutCounterclockwise:
        return Maneuver.roundaboutCounterclockwise;
      case ManeuverDto.roundaboutExitClockwise:
        return Maneuver.roundaboutExitClockwise;
      case ManeuverDto.roundaboutExitCounterclockwise:
        return Maneuver.roundaboutExitCounterclockwise;
      case ManeuverDto.roundaboutLeftClockwise:
        return Maneuver.roundaboutLeftClockwise;
      case ManeuverDto.roundaboutLeftCounterclockwise:
        return Maneuver.roundaboutLeftCounterclockwise;
      case ManeuverDto.roundaboutRightClockwise:
        return Maneuver.roundaboutRightClockwise;
      case ManeuverDto.roundaboutRightCounterclockwise:
        return Maneuver.roundaboutRightCounterclockwise;
      case ManeuverDto.roundaboutSharpLeftClockwise:
        return Maneuver.roundaboutSharpLeftClockwise;
      case ManeuverDto.roundaboutSharpLeftCounterclockwise:
        return Maneuver.roundaboutSharpLeftCounterclockwise;
      case ManeuverDto.roundaboutSharpRightClockwise:
        return Maneuver.roundaboutSharpRightClockwise;
      case ManeuverDto.roundaboutSharpRightCounterclockwise:
        return Maneuver.roundaboutSharpRightCounterclockwise;
      case ManeuverDto.roundaboutSlightLeftClockwise:
        return Maneuver.roundaboutSlightLeftClockwise;
      case ManeuverDto.roundaboutSlightLeftCounterclockwise:
        return Maneuver.roundaboutSlightLeftCounterclockwise;
      case ManeuverDto.roundaboutSlightRightClockwise:
        return Maneuver.roundaboutSlightRightClockwise;
      case ManeuverDto.roundaboutSlightRightCounterclockwise:
        return Maneuver.roundaboutSlightRightCounterclockwise;
      case ManeuverDto.roundaboutStraightClockwise:
        return Maneuver.roundaboutStraightClockwise;
      case ManeuverDto.roundaboutStraightCounterclockwise:
        return Maneuver.roundaboutStraightCounterclockwise;
      case ManeuverDto.roundaboutUTurnClockwise:
        return Maneuver.roundaboutUTurnClockwise;
      case ManeuverDto.roundaboutUTurnCounterclockwise:
        return Maneuver.roundaboutUTurnCounterclockwise;
      case ManeuverDto.straight:
        return Maneuver.straight;
      case ManeuverDto.turnKeepLeft:
        return Maneuver.turnKeepLeft;
      case ManeuverDto.turnKeepRight:
        return Maneuver.turnKeepRight;
      case ManeuverDto.turnLeft:
        return Maneuver.turnLeft;
      case ManeuverDto.turnRight:
        return Maneuver.turnRight;
      case ManeuverDto.turnSharpLeft:
        return Maneuver.turnSharpLeft;
      case ManeuverDto.turnSharpRight:
        return Maneuver.turnSharpRight;
      case ManeuverDto.turnSlightLeft:
        return Maneuver.turnSlightLeft;
      case ManeuverDto.turnSlightRight:
        return Maneuver.turnSlightRight;
      case ManeuverDto.turnUTurnClockwise:
        return Maneuver.turnUTurnClockwise;
      case ManeuverDto.turnUTurnCounterclockwise:
        return Maneuver.turnUTurnCounterclockwise;
      case ManeuverDto.unknown:
        return Maneuver.unknown;
    }
  }
}

/// [LaneDto] convert extension.
/// @nodoc
extension ConvertLaneDto on LaneDto {
  /// Converts [LaneDto] to [Lane]
  Lane toLane() => Lane(
        laneDirections: laneDirections
            .whereType<LaneDirectionDto>()
            .map<LaneDirection>((LaneDirectionDto laneDirection) =>
                laneDirection.toLaneDirection())
            .toList(),
      );
}

/// [LaneDirectionDto] convert extension.
/// @nodoc
extension ConvertLaneDirectionDto on LaneDirectionDto {
  /// Converts [LaneDirectionDto] to [LaneDirection]
  LaneDirection toLaneDirection() => LaneDirection(
        laneShape: laneShape.toLaneShape(),
        isRecommended: isRecommended,
      );
}

/// [LaneShapeDto] convert extension.
/// @nodoc
extension ConvertLaneShapeDto on LaneShapeDto {
  /// Converts [LaneShapeDto] to [LaneShape]
  LaneShape toLaneShape() {
    switch (this) {
      case LaneShapeDto.normalLeft:
        return LaneShape.normalLeft;
      case LaneShapeDto.normalRight:
        return LaneShape.normalRight;
      case LaneShapeDto.sharpLeft:
        return LaneShape.sharpLeft;
      case LaneShapeDto.sharpRight:
        return LaneShape.sharpRight;
      case LaneShapeDto.slightLeft:
        return LaneShape.slightLeft;
      case LaneShapeDto.slightRight:
        return LaneShape.slightRight;
      case LaneShapeDto.straight:
        return LaneShape.straight;
      case LaneShapeDto.unknown:
        return LaneShape.unknown;
      case LaneShapeDto.uTurnLeft:
        return LaneShape.uTurnLeft;
      case LaneShapeDto.uTurnRight:
        return LaneShape.uTurnRight;
    }
  }
}
