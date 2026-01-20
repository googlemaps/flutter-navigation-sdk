// Copyright 2026 Google LLC
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

import 'package:flutter/foundation.dart';

import '../../google_navigation_flutter.dart';

/// Cluster manager that has been added to the map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class ClusterManager {
  /// Construct [ClusterManager]
  const ClusterManager({required this.clusterManagerId});

  /// Identifies the cluster manager.
  final String clusterManagerId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ClusterManager &&
        clusterManagerId == other.clusterManagerId;
  }

  @override
  int get hashCode => clusterManagerId.hashCode;

  @override
  String toString() => 'ClusterManager(clusterManagerId: $clusterManagerId)';
}

/// Represents a cluster of markers on the map.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class Cluster {
  /// Construct [Cluster]
  const Cluster({
    required this.clusterManagerId,
    required this.position,
    required this.markerIds,
  });

  /// The cluster manager ID this cluster belongs to.
  final String clusterManagerId;

  /// The position of the cluster.
  final LatLng position;

  /// List of marker IDs contained in this cluster.
  final List<String> markerIds;

  /// The number of markers in this cluster.
  int get count => markerIds.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Cluster &&
        clusterManagerId == other.clusterManagerId &&
        position == other.position &&
        listEquals(markerIds, other.markerIds);
  }

  @override
  int get hashCode => Object.hash(
    clusterManagerId.hashCode,
    position.hashCode,
    Object.hashAll(markerIds),
  );

  @override
  String toString() =>
      'Cluster('
      'clusterManagerId: $clusterManagerId, '
      'position: $position, '
      'markerIds: $markerIds'
      ')';
}

/// Cluster event types
/// {@category Navigation View}
/// {@category Map View}
enum ClusterEventType {
  /// The cluster has been tapped.
  clicked,
}

/// Cluster event sent from platform side.
/// {@category Navigation View}
/// {@category Map View}
@immutable
class ClusterEvent {
  /// Initialize [ClusterEvent] object.
  const ClusterEvent({
    required this.clusterManagerId,
    required this.eventType,
    required this.cluster,
  });

  /// The cluster manager ID that this event belongs to.
  final String clusterManagerId;

  /// Type of the event.
  final ClusterEventType eventType;

  /// The cluster that was interacted with.
  final Cluster cluster;

  @override
  String toString() =>
      'ClusterEvent('
      'clusterManagerId: $clusterManagerId, '
      'eventType: $eventType, '
      'cluster: $cluster'
      ')';
}
