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

/// [RoutingOptions] convert extension.
/// @nodoc
extension ConvertRoutingOptions on RoutingOptions {
  /// Converts [RoutingOptions] to [RoutingOptionsDto]
  RoutingOptionsDto toDto() => RoutingOptionsDto(
        alternateRoutesStrategy: alternateRoutesStrategy?.toDto(),
        routingStrategy: routingStrategy?.toDto(),
        targetDistanceMeters: targetDistanceMeters,
        travelMode: travelMode?.toDto(),
        avoidFerries: avoidFerries,
        avoidHighways: avoidHighways,
        avoidTolls: avoidTolls,
        locationTimeoutMs: locationTimeoutMs,
      );
}

/// [NavigationAlternateRoutesStrategy] convert extension.
/// @nodoc
extension ConvertNavigationAlternateRoutesStrategy
    on NavigationAlternateRoutesStrategy {
  /// Converts [NavigationAlternateRoutesStrategy] to [AlternateRoutesStrategyDto]
  AlternateRoutesStrategyDto toDto() {
    switch (this) {
      case NavigationAlternateRoutesStrategy.all:
        return AlternateRoutesStrategyDto.all;
      case NavigationAlternateRoutesStrategy.none:
        return AlternateRoutesStrategyDto.none;
      case NavigationAlternateRoutesStrategy.one:
        return AlternateRoutesStrategyDto.one;
    }
  }
}

/// [NavigationRoutingStrategy] convert extension.
/// @nodoc
extension ConvertNavigationRoutingStrategy on NavigationRoutingStrategy {
  /// Converts [NavigationRoutingStrategy] to [RoutingStrategyDto]
  RoutingStrategyDto toDto() {
    switch (this) {
      case NavigationRoutingStrategy.defaultBest:
        return RoutingStrategyDto.defaultBest;
      case NavigationRoutingStrategy.deltaToTargetDistance:
        return RoutingStrategyDto.deltaToTargetDistance;
      case NavigationRoutingStrategy.shorter:
        return RoutingStrategyDto.shorter;
    }
  }
}

/// [NavigationTravelMode] convert extension.
/// @nodoc
extension ConvertNavigationTravelMode on NavigationTravelMode {
  /// Converts [NavigationTravelMode] to [TravelModeDto]
  TravelModeDto toDto() {
    switch (this) {
      case NavigationTravelMode.driving:
        return TravelModeDto.driving;
      case NavigationTravelMode.cycling:
        return TravelModeDto.cycling;
      case NavigationTravelMode.walking:
        return TravelModeDto.walking;
      case NavigationTravelMode.twoWheeler:
        return TravelModeDto.twoWheeler;
      case NavigationTravelMode.taxi:
        return TravelModeDto.taxi;
    }
  }
}
