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

// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'shared.dart';

void main() {
  final mapTypeVariants = getMapTypeVariants();

  patrol('Clustering tests - Basic operations', (
    PatrolIntegrationTester $,
  ) async {
    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
          $,
          testMapType: mapTypeVariants.currentValue!,
          initializeNavigation: false,
          simulateLocation: false,
        );

    // Test adding a single cluster manager
    final List<ClusterManager> addedClusterManagers = await viewController
        .addClusterManagers(<String>['cluster_1']);
    expect(addedClusterManagers.length, 1);
    expect(addedClusterManagers.first.clusterManagerId, 'cluster_1');

    // Test getting cluster managers
    final List<ClusterManager> getClusterManagers =
        await viewController.getClusterManagers();
    expect(getClusterManagers.length, 1);
    expect(getClusterManagers.first.clusterManagerId, 'cluster_1');

    // Test adding multiple cluster managers at once
    final List<ClusterManager> addedClusterManagers2 = await viewController
        .addClusterManagers(<String>['cluster_2', 'cluster_3']);
    expect(addedClusterManagers2.length, 2);
    expect(addedClusterManagers2[0].clusterManagerId, 'cluster_2');
    expect(addedClusterManagers2[1].clusterManagerId, 'cluster_3');

    // Verify all cluster managers are present
    final List<ClusterManager> allClusterManagers =
        await viewController.getClusterManagers();
    expect(allClusterManagers.length, 3);
    expect(
      allClusterManagers
          .map((ClusterManager cm) => cm.clusterManagerId)
          .toList(),
      containsAll(<String>['cluster_1', 'cluster_2', 'cluster_3']),
    );

    // Test removing a single cluster manager
    await viewController.removeClusterManagers(<ClusterManager>[
      addedClusterManagers.first,
    ]);
    final List<ClusterManager> afterRemove =
        await viewController.getClusterManagers();
    expect(afterRemove.length, 2);
    expect(
      afterRemove.map((ClusterManager cm) => cm.clusterManagerId).toList(),
      containsAll(<String>['cluster_2', 'cluster_3']),
    );
    expect(
      afterRemove.map((ClusterManager cm) => cm.clusterManagerId).toList(),
      isNot(contains('cluster_1')),
    );

    // Test removing multiple cluster managers at once
    await viewController.removeClusterManagers(addedClusterManagers2);
    final List<ClusterManager> afterRemove2 =
        await viewController.getClusterManagers();
    expect(afterRemove2.length, 0);

    // Add some cluster managers to test clearClusterManagers
    await viewController.addClusterManagers(<String>['cluster_4', 'cluster_5']);
    final List<ClusterManager> beforeClear =
        await viewController.getClusterManagers();
    expect(beforeClear.length, 2);

    // Test clearClusterManagers
    await viewController.clearClusterManagers();
    final List<ClusterManager> afterClear =
        await viewController.getClusterManagers();
    expect(afterClear.length, 0);
  }, variant: mapTypeVariants);

  patrol('Clustering tests - Markers with cluster managers', (
    PatrolIntegrationTester $,
  ) async {
    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
          $,
          testMapType: mapTypeVariants.currentValue!,
          initializeNavigation: false,
          simulateLocation: false,
        );

    // Add a cluster manager
    final List<ClusterManager> addedClusterManagers = await viewController
        .addClusterManagers(<String>['cluster_manager_1']);
    expect(addedClusterManagers.length, 1);
    final ClusterManager clusterManager = addedClusterManagers.first;

    // Add markers with clusterManagerId
    const MarkerOptions markerOptions1 = MarkerOptions(
      position: LatLng(
        latitude: 60.34856639667419,
        longitude: 25.03459821831162,
      ),
      infoWindow: InfoWindow(title: 'Marker 1', snippet: 'clustered'),
      clusterManagerId: 'cluster_manager_1',
    );

    const MarkerOptions markerOptions2 = MarkerOptions(
      position: LatLng(latitude: 60.35, longitude: 25.04),
      infoWindow: InfoWindow(title: 'Marker 2', snippet: 'clustered'),
      clusterManagerId: 'cluster_manager_1',
    );

    const MarkerOptions markerOptions3 = MarkerOptions(
      position: LatLng(latitude: 60.36, longitude: 25.05),
      infoWindow: InfoWindow(title: 'Marker 3', snippet: 'non-clustered'),
    );

    final List<Marker?> addedMarkers = await viewController.addMarkers(
      <MarkerOptions>[markerOptions1, markerOptions2, markerOptions3],
    );
    expect(addedMarkers.length, 3);

    // Verify markers were added with correct clusterManagerId
    final Marker? marker1 = addedMarkers[0];
    final Marker? marker2 = addedMarkers[1];
    final Marker? marker3 = addedMarkers[2];
    expect(marker1, isNotNull);
    expect(marker2, isNotNull);
    expect(marker3, isNotNull);
    expect(marker1!.options.clusterManagerId, 'cluster_manager_1');
    expect(marker2!.options.clusterManagerId, 'cluster_manager_1');
    expect(marker3!.options.clusterManagerId, isNull);

    // Get markers and verify
    final List<Marker?> getMarkers = await viewController.getMarkers();
    expect(getMarkers.length, 3);

    // Test removing cluster manager removes clustered markers
    await viewController.removeClusterManagers(<ClusterManager>[
      clusterManager,
    ]);

    final List<Marker?> afterClusterRemoval = await viewController.getMarkers();
    // Only the non-clustered marker should remain
    expect(afterClusterRemoval.length, 1);
    expect(afterClusterRemoval.first!.options.clusterManagerId, isNull);
    expect(afterClusterRemoval.first!.options.infoWindow.title, 'Marker 3');

    // Clean up
    await viewController.clearMarkers();
  }, variant: mapTypeVariants);

  patrol('Clustering tests - Updating clustered markers', (
    PatrolIntegrationTester $,
  ) async {
    /// Get viewController for the test type (navigation map or regular map).
    final GoogleMapViewController viewController =
        await getMapViewControllerForTestMapType(
          $,
          testMapType: mapTypeVariants.currentValue!,
          initializeNavigation: false,
          simulateLocation: false,
        );

    // Add cluster managers
    await viewController.addClusterManagers(<String>['cluster_A', 'cluster_B']);

    // Add a marker to cluster_A
    const MarkerOptions markerOptions = MarkerOptions(
      position: LatLng(
        latitude: 60.34856639667419,
        longitude: 25.03459821831162,
      ),
      infoWindow: InfoWindow(title: 'Test Marker', snippet: 'initial'),
      clusterManagerId: 'cluster_A',
      alpha: 1.0,
    );

    final List<Marker?> addedMarkers = await viewController.addMarkers(
      <MarkerOptions>[markerOptions],
    );
    expect(addedMarkers.length, 1);
    final Marker addedMarker = addedMarkers.first!;
    expect(addedMarker.options.clusterManagerId, 'cluster_A');
    expect(addedMarker.options.alpha, 1.0);

    // Update marker properties while keeping it in the same cluster
    final Marker updatedMarkerSameCluster = addedMarker.copyWith(
      options: markerOptions.copyWith(
        alpha: 0.5,
        infoWindow: const InfoWindow(
          title: 'Updated Marker',
          snippet: 'updated',
        ),
      ),
    );

    final List<Marker?> updatedMarkers = await viewController.updateMarkers(
      <Marker>[updatedMarkerSameCluster],
    );
    expect(updatedMarkers.length, 1);
    expect(updatedMarkers.first!.options.clusterManagerId, 'cluster_A');
    expect(updatedMarkers.first!.options.alpha, 0.5);
    expect(updatedMarkers.first!.options.infoWindow.title, 'Updated Marker');

    // Update marker to move it to a different cluster
    final Marker updatedMarkerDifferentCluster = updatedMarkerSameCluster
        .copyWith(
          options: updatedMarkerSameCluster.options.copyWith(
            clusterManagerId: 'cluster_B',
          ),
        );

    final List<Marker?> updatedMarkers2 = await viewController.updateMarkers(
      <Marker>[updatedMarkerDifferentCluster],
    );
    expect(updatedMarkers2.length, 1);
    expect(updatedMarkers2.first!.options.clusterManagerId, 'cluster_B');

    // Clean up
    await viewController.clearMarkers();
    await viewController.clearClusterManagers();
  }, variant: mapTypeVariants);

  patrol(
    'Clustering tests - Multiple cluster managers with different markers',
    (PatrolIntegrationTester $) async {
      /// Get viewController for the test type (navigation map or regular map).
      final GoogleMapViewController viewController =
          await getMapViewControllerForTestMapType(
            $,
            testMapType: mapTypeVariants.currentValue!,
            initializeNavigation: false,
            simulateLocation: false,
          );

      // Add multiple cluster managers
      await viewController.addClusterManagers(<String>[
        'cluster_north',
        'cluster_south',
        'cluster_east',
      ]);

      final List<ClusterManager> clusterManagers =
          await viewController.getClusterManagers();
      expect(clusterManagers.length, 3);

      // Add markers to different clusters
      final List<MarkerOptions> markerOptions = <MarkerOptions>[
        // North cluster markers
        const MarkerOptions(
          position: LatLng(latitude: 61.0, longitude: 25.0),
          infoWindow: InfoWindow(title: 'North 1'),
          clusterManagerId: 'cluster_north',
        ),
        const MarkerOptions(
          position: LatLng(latitude: 61.1, longitude: 25.1),
          infoWindow: InfoWindow(title: 'North 2'),
          clusterManagerId: 'cluster_north',
        ),
        // South cluster markers
        const MarkerOptions(
          position: LatLng(latitude: 59.0, longitude: 25.0),
          infoWindow: InfoWindow(title: 'South 1'),
          clusterManagerId: 'cluster_south',
        ),
        const MarkerOptions(
          position: LatLng(latitude: 59.1, longitude: 25.1),
          infoWindow: InfoWindow(title: 'South 2'),
          clusterManagerId: 'cluster_south',
        ),
        // East cluster markers
        const MarkerOptions(
          position: LatLng(latitude: 60.0, longitude: 26.0),
          infoWindow: InfoWindow(title: 'East 1'),
          clusterManagerId: 'cluster_east',
        ),
        // Non-clustered marker
        const MarkerOptions(
          position: LatLng(latitude: 60.0, longitude: 24.0),
          infoWindow: InfoWindow(title: 'Independent'),
        ),
      ];

      final List<Marker?> addedMarkers = await viewController.addMarkers(
        markerOptions,
      );
      expect(addedMarkers.length, 6);

      // Verify markers are assigned to correct clusters
      final List<Marker?> allMarkers = await viewController.getMarkers();
      expect(allMarkers.length, 6);

      final List<Marker?> northMarkers =
          allMarkers
              .where(
                (Marker? m) => m!.options.clusterManagerId == 'cluster_north',
              )
              .toList();
      final List<Marker?> southMarkers =
          allMarkers
              .where(
                (Marker? m) => m!.options.clusterManagerId == 'cluster_south',
              )
              .toList();
      final List<Marker?> eastMarkers =
          allMarkers
              .where(
                (Marker? m) => m!.options.clusterManagerId == 'cluster_east',
              )
              .toList();
      final List<Marker?> independentMarkers =
          allMarkers
              .where((Marker? m) => m!.options.clusterManagerId == null)
              .toList();

      expect(northMarkers.length, 2);
      expect(southMarkers.length, 2);
      expect(eastMarkers.length, 1);
      expect(independentMarkers.length, 1);

      // Remove one cluster manager and verify its markers are removed
      final ClusterManager northCluster = clusterManagers.firstWhere(
        (ClusterManager cm) => cm.clusterManagerId == 'cluster_north',
      );
      await viewController.removeClusterManagers(<ClusterManager>[
        northCluster,
      ]);

      final List<Marker?> afterRemoval = await viewController.getMarkers();
      // Should have 4 markers left (2 south + 1 east + 1 independent)
      expect(afterRemoval.length, 4);

      final List<Marker?> northMarkersAfterRemoval =
          afterRemoval
              .where(
                (Marker? m) => m!.options.clusterManagerId == 'cluster_north',
              )
              .toList();
      expect(northMarkersAfterRemoval.length, 0);

      // Verify other markers still exist
      final List<Marker?> southMarkersAfterRemoval =
          afterRemoval
              .where(
                (Marker? m) => m!.options.clusterManagerId == 'cluster_south',
              )
              .toList();
      expect(southMarkersAfterRemoval.length, 2);

      // Test clear() removes both cluster managers and their markers
      await viewController.clear();

      final List<ClusterManager> afterClear =
          await viewController.getClusterManagers();
      expect(afterClear.length, 0);

      final List<Marker?> markersAfterClear = await viewController.getMarkers();
      expect(markersAfterClear.length, 0);
    },
    variant: mapTypeVariants,
  );

  patrol(
    'Clustering tests - Removing individual clustered markers',
    (PatrolIntegrationTester $) async {
      /// Get viewController for the test type (navigation map or regular map).
      final GoogleMapViewController viewController =
          await getMapViewControllerForTestMapType(
            $,
            testMapType: mapTypeVariants.currentValue!,
            initializeNavigation: false,
            simulateLocation: false,
          );

      // Add a cluster manager
      await viewController.addClusterManagers(<String>['test_cluster']);

      // Add multiple markers to the cluster
      final List<MarkerOptions> markerOptions = <MarkerOptions>[
        const MarkerOptions(
          position: LatLng(latitude: 60.0, longitude: 25.0),
          infoWindow: InfoWindow(title: 'Clustered 1'),
          clusterManagerId: 'test_cluster',
        ),
        const MarkerOptions(
          position: LatLng(latitude: 60.1, longitude: 25.1),
          infoWindow: InfoWindow(title: 'Clustered 2'),
          clusterManagerId: 'test_cluster',
        ),
        const MarkerOptions(
          position: LatLng(latitude: 60.2, longitude: 25.2),
          infoWindow: InfoWindow(title: 'Clustered 3'),
          clusterManagerId: 'test_cluster',
        ),
      ];

      final List<Marker?> addedMarkers = await viewController.addMarkers(
        markerOptions,
      );
      expect(addedMarkers.length, 3);

      // Remove one clustered marker
      await viewController.removeMarkers(<Marker>[addedMarkers[0]!]);

      final List<Marker?> afterRemoval = await viewController.getMarkers();
      expect(afterRemoval.length, 2);
      expect(
        afterRemoval.map((Marker? m) => m!.options.infoWindow.title).toList(),
        containsAll(<String>['Clustered 2', 'Clustered 3']),
      );

      // Remove another clustered marker
      await viewController.removeMarkers(<Marker>[addedMarkers[1]!]);

      final List<Marker?> afterSecondRemoval =
          await viewController.getMarkers();
      expect(afterSecondRemoval.length, 1);
      expect(afterSecondRemoval.first!.options.infoWindow.title, 'Clustered 3');

      // Verify the cluster manager still exists
      final List<ClusterManager> clusterManagers =
          await viewController.getClusterManagers();
      expect(clusterManagers.length, 1);
      expect(clusterManagers.first.clusterManagerId, 'test_cluster');

      // Clean up
      await viewController.clearMarkers();
      await viewController.clearClusterManagers();
    },
    variant: mapTypeVariants,
  );
}
