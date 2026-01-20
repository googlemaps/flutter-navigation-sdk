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

// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../widgets/widgets.dart';

class ClusteringPage extends ExamplePage {
  const ClusteringPage({super.key})
    : super(leading: const Icon(Icons.workspaces), title: 'Clustering');

  @override
  ExamplePageState<ClusteringPage> createState() => _ClusteringPageState();
}

class _ClusteringPageState extends ExamplePageState<ClusteringPage> {
  /// Starting point from where markers are added.
  static const LatLng center = LatLng(latitude: -33.86, longitude: 151.1547171);

  /// Marker offset factor for randomizing marker placing.
  static const double _markerOffsetFactor = 0.05;

  /// Offset for longitude when placing markers to different cluster managers.
  static const double _clusterManagerLongitudeOffset = 0.1;

  /// Maximum amount of cluster managers.
  static const int _clusterManagerMaxCount = 3;

  /// Amount of markers to be added to the cluster manager at once.
  static const int _markersToAddToClusterManagerCount = 10;

  /// Fully visible alpha value.
  static const double _fullyVisibleAlpha = 1.0;

  /// Half visible alpha value.
  static const double _halfVisibleAlpha = 0.5;

  /// Google navigation view controller.
  GoogleNavigationViewController? _navigationViewController;

  /// Map of clusterManagers with identifier as the key.
  final Map<String, ClusterManager> _clusterManagers =
      <String, ClusterManager>{};

  /// Map of markers with identifier as the key.
  final Map<String, Marker> _markers = <String, Marker>{};

  /// Id of the currently selected marker.
  String? _selectedMarkerId;

  /// Counter for added cluster manager ids.
  int _clusterManagerIdCounter = 1;

  /// Counter for added markers ids.
  int _markerIdCounter = 1;

  /// Cluster that was tapped most recently.
  Cluster? _lastCluster;

  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;

    // Set the initial camera position
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        const LatLng(latitude: -33.852, longitude: 151.25),
        11.0,
      ),
    );
  }

  void _onMarkerTapped(String markerId) {
    final Marker? tappedMarker = _markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final String? previousMarkerId = _selectedMarkerId;
        if (previousMarkerId != null &&
            _markers.containsKey(previousMarkerId)) {
          final Marker resetOld = _markers[previousMarkerId]!.copyWith(
            options: _markers[previousMarkerId]!.options.copyWith(
              icon: ImageDescriptor.defaultImage,
            ),
          );
          _markers[previousMarkerId] = resetOld;
          _navigationViewController?.updateMarkers(<Marker>[resetOld]);
        }
        _selectedMarkerId = markerId;
      });
    }
  }

  void _onClusterClicked(Cluster cluster) {
    setState(() {
      _lastCluster = cluster;
    });
  }

  Future<void> _addClusterManager() async {
    if (_clusterManagers.length >= _clusterManagerMaxCount) {
      return;
    }

    final clusterManagerId = 'cluster_manager_id_$_clusterManagerIdCounter';
    _clusterManagerIdCounter++;

    final List<ClusterManager> addedClusterManagers =
        await _navigationViewController!.addClusterManagers(<String>[
          clusterManagerId,
        ]);

    if (addedClusterManagers.isNotEmpty) {
      final clusterManager = addedClusterManagers.first;
      setState(() {
        _clusterManagers[clusterManagerId] = clusterManager;
      });
      await _addMarkersToCluster(clusterManager);
    }
  }

  Future<void> _removeClusterManager(ClusterManager clusterManager) async {
    // Remove cluster manager.
    await _navigationViewController!.removeClusterManagers(<ClusterManager>[
      clusterManager,
    ]);

    setState(() {
      // Remove markers from local state that were managed by removed cluster manager.
      _markers.removeWhere(
        (String markerId, Marker marker) =>
            marker.options.clusterManagerId == clusterManager.clusterManagerId,
      );
      _clusterManagers.remove(clusterManager.clusterManagerId);
    });
  }

  Future<void> _addMarkersToCluster(ClusterManager clusterManager) async {
    final List<MarkerOptions> markerOptions = <MarkerOptions>[];

    for (int i = 0; i < _markersToAddToClusterManagerCount; i++) {
      final markerIdVal =
          '${clusterManager.clusterManagerId}_marker_id_$_markerIdCounter';
      _markerIdCounter++;

      final int clusterManagerIndex = _clusterManagers.values.toList().indexOf(
        clusterManager,
      );

      // Add additional offset to longitude for each cluster manager to space
      // out markers in different cluster managers.
      final double clusterManagerLongitudeOffset =
          clusterManagerIndex * _clusterManagerLongitudeOffset;

      markerOptions.add(
        MarkerOptions(
          position: LatLng(
            latitude: center.latitude + _getRandomOffset(),
            longitude:
                center.longitude +
                _getRandomOffset() +
                clusterManagerLongitudeOffset,
          ),
          infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
          consumeTapEvents: true,
          clusterManagerId: clusterManager.clusterManagerId,
        ),
      );
    }

    final List<Marker?> addedMarkers = await _navigationViewController!
        .addMarkers(markerOptions);

    setState(() {
      for (final marker in addedMarkers) {
        if (marker != null) {
          _markers[marker.markerId] = marker;
        }
      }
    });
  }

  double _getRandomOffset() {
    return (Random().nextDouble() - 0.5) * _markerOffsetFactor;
  }

  Future<void> _removeSelectedMarker() async {
    if (_selectedMarkerId == null) {
      return;
    }

    final Marker? marker = _markers[_selectedMarkerId];
    if (marker != null) {
      await _navigationViewController!.removeMarkers(<Marker>[marker]);
      setState(() {
        _markers.remove(_selectedMarkerId);
        _selectedMarkerId = null;
      });
    }
  }

  Future<void> _changeMarkersAlpha() async {
    final List<Marker> updatedMarkers = <Marker>[];

    for (final String markerId in _markers.keys) {
      final Marker marker = _markers[markerId]!;
      final double current = marker.options.alpha;
      final Marker updatedMarker = marker.copyWith(
        options: marker.options.copyWith(
          alpha:
              current == _fullyVisibleAlpha
                  ? _halfVisibleAlpha
                  : _fullyVisibleAlpha,
        ),
      );
      updatedMarkers.add(updatedMarker);
      _markers[markerId] = updatedMarker;
    }

    await _navigationViewController!.updateMarkers(updatedMarkers);
    setState(() {});
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _clusterManagers.length >= _clusterManagerMaxCount
                              ? null
                              : _addClusterManager,
                      child: const Text('Add cluster manager'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _clusterManagers.isEmpty
                              ? null
                              : () => _removeClusterManager(
                                _clusterManagers.values.last,
                              ),
                      child: const Text('Remove cluster manager'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final MapEntry<String, ClusterManager> clusterEntry
                      in _clusterManagers.entries)
                    ElevatedButton(
                      onPressed: () => _addMarkersToCluster(clusterEntry.value),
                      child: Text('Add markers to ${clusterEntry.key}'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _selectedMarkerId == null
                              ? null
                              : _removeSelectedMarker,
                      child: const Text('Remove selected marker'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _markers.isEmpty ? null : _changeMarkersAlpha,
                      child: const Text('Change all markers alpha'),
                    ),
                  ),
                ],
              ),
              if (_lastCluster != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Last cluster clicked:\n'
                    '${_lastCluster!.count} markers at ${_lastCluster!.position}',
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMapsNavigationView(
              onViewCreated: _onViewCreated,
              initialNavigationUIEnabledPreference:
                  NavigationUIEnabledPreference.disabled,
              initialCameraPosition: const CameraPosition(
                target: center,
                zoom: 11.0,
              ),
              onMarkerClicked: (String markerId) {
                _onMarkerTapped(markerId);
              },
              onClusterClicked: _onClusterClicked,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: buildControlsContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlsContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _clusterManagers.length >= _clusterManagerMaxCount
                        ? null
                        : _addClusterManager,
                child: const Text('Add cluster manager'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _clusterManagers.isEmpty
                        ? null
                        : () =>
                            _removeClusterManager(_clusterManagers.values.last),
                child: const Text('Remove cluster manager'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final MapEntry<String, ClusterManager> clusterEntry
                in _clusterManagers.entries)
              ElevatedButton(
                onPressed: () => _addMarkersToCluster(clusterEntry.value),
                child: Text('Add markers to ${clusterEntry.key}'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _selectedMarkerId == null ? null : _removeSelectedMarker,
                child: const Text('Remove selected marker'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _markers.isEmpty ? null : _changeMarkersAlpha,
                child: const Text('Change all markers alpha'),
              ),
            ),
          ],
        ),
        if (_lastCluster != null)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Last cluster clicked:\n'
              '${_lastCluster!.count} markers at ${_lastCluster!.position}',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
