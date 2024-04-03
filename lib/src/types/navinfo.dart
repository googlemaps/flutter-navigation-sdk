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

/// A set of values that specify the navigation action to take.
/// {@category Navigation}
enum Maneuver {
  /// Arrival at a destination.
  destination,

  /// Starting point of the maneuver.
  depart,

  /// Arrival at a destination located on the left side of the road.
  destinationLeft,

  /// Arrival at a destination located on the right side of the road.
  destinationRight,

  /// Take the boat ferry.
  ferryBoat,

  /// Take the train ferry.
  ferryTrain,

  /// Current road joins another road slightly on the left.
  forkLeft,

  /// Current road joins another road slightly on the right.
  forkRight,

  /// Current road joins another on the left.
  mergeLeft,

  /// Current road joins another on the right.
  mergeRight,

  /// Current road joins another.
  mergeUnspecified,

  /// The street name changes.
  nameChange,

  /// Keep to the left side of the road when exiting a turnpike or freeway as the road diverges.
  offRampKeepLeft,

  /// Keep to the right side of the road when exiting a turnpike or freeway as the road diverges.
  offRampKeepRight,

  /// Regular left turn to exit a turnpike or freeway.
  offRampLeft,

  /// Regular right turn to exit a turnpike or freeway.
  offRampRight,

  /// Sharp left turn to exit a turnpike or freeway.
  offRampSharpLeft,

  /// Sharp right turn to exit a turnpike or freeway.
  offRampSharpRight,

  /// Slight left turn to exit a turnpike or freeway.
  offRampSlightLeft,

  /// Slight right turn to exit a turnpike or freeway.
  offRampSlightRight,

  /// Exit a turnpike or freeway.
  offRampUnspecified,

  /// Clockwise turn onto the opposite side of the street to exit a turnpike or freeway.
  offRampUTurnClockwise,

  /// Counterclockwise turn onto the opposite side of the street to exit a turnpike or freeway.
  offRampUTurnCounterclockwise,

  /// Keep to the left side of the road when entering a turnpike or freeway as the road diverges.
  onRampKeepLeft,

  /// Keep to the right side of the road when entering a turnpike or freeway as the road diverges.
  onRampKeepRight,

  /// Regular left turn to enter a turnpike or freeway.
  onRampLeft,

  /// Regular right turn to enter a turnpike or freeway.
  onRampRight,

  /// Sharp left turn to enter a turnpike or freeway.
  onRampSharpLeft,

  /// Sharp right turn to enter a turnpike or freeway.
  onRampSharpRight,

  /// Slight left turn to enter a turnpike or freeway.
  onRampSlightLeft,

  /// Slight right turn to enter a turnpike or freeway.
  onRampSlightRight,

  /// Enter a turnpike or freeway.
  onRampUnspecified,

  /// Clockwise turn onto the opposite side of the street to enter a turnpike or freeway.
  onRampUTurnClockwise,

  /// Counterclockwise turn onto the opposite side of the street to enter a turnpike or freeway.
  onRampUTurnCounterclockwise,

  /// Enter a roundabout in the clockwise direction.
  roundaboutClockwise,

  /// Enter a roundabout in the counterclockwise direction.
  roundaboutCounterclockwise,

  /// Exit a roundabout in the clockwise direction.
  roundaboutExitClockwise,

  /// Exit a roundabout in the counterclockwise direction.
  roundaboutExitCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn left.
  roundaboutLeftClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn left.
  roundaboutLeftCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn right.
  roundaboutRightClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn right.
  roundaboutRightCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn sharply to the left.
  roundaboutSharpLeftClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn sharply to the left.
  roundaboutSharpLeftCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn sharply to the right.
  roundaboutSharpRightClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn sharply to the right.
  roundaboutSharpRightCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn slightly left.
  roundaboutSlightLeftClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn slightly to the left.
  roundaboutSlightLeftCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn slightly to the right.
  roundaboutSlightRightClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn slightly to the right.
  roundaboutSlightRightCounterclockwise,

  /// Enter a roundabout in the clockwise direction and continue straight.
  roundaboutStraightClockwise,

  /// Enter a roundabout in the counterclockwise direction and continue straight.
  roundaboutStraightCounterclockwise,

  /// Enter a roundabout in the clockwise direction and turn clockwise onto the opposite side of the street.
  roundaboutUTurnClockwise,

  /// Enter a roundabout in the counterclockwise direction and turn counterclockwise onto the opposite side of the street.
  roundaboutUTurnCounterclockwise,

  /// Continue straight.
  straight,

  /// Keep left as the road diverges.
  turnKeepLeft,

  /// Keep right as the road diverges.
  turnKeepRight,

  /// Regular left turn at an intersection.
  turnLeft,

  /// Regular right turn at an intersection.
  turnRight,

  /// Sharp left turn at an intersection.
  turnSharpLeft,

  /// Sharp right turn at an intersection.
  turnSharpRight,

  /// Slight left turn at an intersection.
  turnSlightLeft,

  /// Slight right turn at an intersection.
  turnSlightRight,

  /// Clockwise turn onto the opposite side of the street.
  turnUTurnClockwise,

  /// Counterclockwise turn onto the opposite side of the street.
  turnUTurnCounterclockwise,

  /// Unknown maneuver.
  unknown,
}

/// Whether this step is on a drive-on-right or drive-on-left route.
/// {@category Navigation}
enum DrivingSide {
  /// Drive-on-left side.
  left,

  /// Unspecified side.
  none,

  /// Drive-on-right side.
  right,
}

/// The state of navigation.
/// {@category Navigation}
enum NavState {
  /// Actively navigating.
  enroute,

  /// Actively navigating but searching for a new route.
  rerouting,

  /// Navigation has ended.
  stopped,

  /// Error or unspecified state.
  unknown,
}

/// A set of values that specify the shape of the road path continuing from the Lane.
/// {@category Navigation}
enum LaneShape {
  /// Normal left turn (45-135 degrees).
  normalLeft,

  /// Normal right turn (45-135 degrees).
  normalRight,

  /// Sharp left turn (135-175 degrees).
  sharpLeft,

  /// Sharp right turn (135-175 degrees).
  sharpRight,

  /// Slight left turn (10-45 degrees).
  slightLeft,

  /// Slight right turn (10-45 degrees).
  slightRight,

  /// No turn.
  straight,

  /// Shape is unknown.
  unknown,

  /// A left turn onto the opposite side of the same street (175-180 degrees).
  uTurnLeft,

  /// A right turn onto the opposite side of the same street (175-180 degrees).
  uTurnRight,
}

/// One of the possible directions from a lane at the end of a route step, and whether it is on the recommended route.
/// {@category Navigation}
class LaneDirection {
  /// Construct [LaneDirection].
  LaneDirection({
    required this.laneShape,
    required this.isRecommended,
  });

  /// Shape for this lane direction.
  final LaneShape laneShape;

  /// Whether this lane is recommended.
  final bool isRecommended;
}

/// Single lane on the road at the end of a route step.
/// {@category Navigation}
class Lane {
  /// Construct [Lane].
  Lane({
    required this.laneDirections,
  });

  /// List of possible directions a driver can follow when using this lane at the end of the respective route step
  final List<LaneDirection> laneDirections;
}

/// Information about a single step along a navigation route.
/// {@category Navigation}
class StepInfo {
  /// Construct [StepInfo].
  StepInfo({
    required this.distanceFromPrevStepMeters,
    required this.timeFromPrevStepSeconds,
    required this.drivingSide,
    required this.exitNumber,
    required this.fullInstructions,
    required this.fullRoadName,
    required this.simpleRoadName,
    required this.roundaboutTurnNumber,
    required this.stepNumber,
    required this.lanes,
    required this.maneuver,
  });

  /// Distance in meters from the previous step to this step.
  final int distanceFromPrevStepMeters;

  /// Time in seconds from the previous step to this step.
  final int timeFromPrevStepSeconds;

  /// Whether this step is on a drive-on-right or drive-on-left route.
  final DrivingSide drivingSide;

  /// The exit number if it exists.
  final String? exitNumber;

  /// The full text of the instruction for this step.
  final String fullInstructions;

  /// The full road name for this step.
  final String fullRoadName;

  /// The simplified version of the road name.
  final String simpleRoadName;

  /// The counted number of the exit to take relative to the location where the
  /// roundabout was entered.
  final int roundaboutTurnNumber;

  /// The list of available lanes at the end of this route step.
  ///
  /// Android only.
  final List<Lane> lanes;

  /// The maneuver for this step.
  final Maneuver maneuver;

  /// The index of the step in the list of all steps in the route.
  final int stepNumber;
}

/// Contains information about the state of navigation, the current nav step if
/// available, and remaining steps if available.
/// {@category Navigation}
class NavInfo {
  /// Construct [NavInfo].
  NavInfo({
    required this.currentStep,
    required this.remainingSteps,
    required this.routeChanged,
    required this.distanceToCurrentStepMeters,
    required this.distanceToFinalDestinationMeters,
    required this.distanceToNextDestinationMeters,
    required this.timeToCurrentStepSeconds,
    required this.timeToFinalDestinationSeconds,
    required this.timeToNextDestinationSeconds,
    required this.navState,
  });

  /// The current state of navigation.
  NavState navState;

  /// Information about the upcoming maneuver step.
  StepInfo? currentStep;

  /// The remaining steps after the current step.
  List<StepInfo> remainingSteps;

  /// Whether the route has changed since the last sent message.
  bool routeChanged;

  /// Estimated remaining distance in meters along the route to the
  /// current step.
  final int? distanceToCurrentStepMeters;

  /// The estimated remaining distance in meters to the final destination which
  /// is the last destination in a multi-destination trip.
  final int? distanceToFinalDestinationMeters;

  /// The estimated remaining distance in meters to the next destination.
  ///
  /// Android only.
  final int? distanceToNextDestinationMeters;

  /// The estimated remaining time in seconds along the route to the
  /// current step.
  final int? timeToCurrentStepSeconds;

  /// The estimated remaining time in seconds to the final destination which is
  /// the last destination in a multi-destination trip.
  final int? timeToFinalDestinationSeconds;

  /// The estimated remaining time in seconds to the next destination.
  ///
  /// Android only.
  final int? timeToNextDestinationSeconds;
}

/// NavInfo event message
/// {@category Navigation}
class NavInfoEvent {
  /// Initialize with [NavInfo] object.
  NavInfoEvent({
    required this.navInfo,
  });

  /// Navigation information.
  final NavInfo navInfo;
}
