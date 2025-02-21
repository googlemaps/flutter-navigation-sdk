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

// ignore_for_file: public_member_api_docs

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../widgets/widgets.dart';

class MarkersPage extends ExamplePage {
  const MarkersPage({super.key})
      : super(leading: const Icon(Icons.pin_drop), title: 'Markers');

  @override
  ExamplePageState<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends ExamplePageState<MarkersPage> {
  late final GoogleNavigationViewController _navigationViewController;
  ImageDescriptor? _registeredCustomIcon;
  List<Marker> _markers = <Marker>[];
  Marker? _selectedMarker;

  late bool _isMapToolbarEnabled = true;
  late bool _displayMarkerUpdates = false;
  final List<double> _zIndexes = <double>[-1, 0, 1];
  final List<double> _alphas = <double>[1.0, 0.3];

  // ignore: use_setters_to_change_properties
  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
  }

  Future<void> addMarkerToMap() async {
    // Add a marker to the current camera position.

    try {
      final CameraPosition position =
          await _navigationViewController.getCameraPosition();

      final MarkerOptions options = MarkerOptions(
        position: position.target,
        infoWindow: const InfoWindow(title: 'Name', snippet: 'Snippet here'),
      );

      final List<Marker?> addedMarkers =
          await _navigationViewController.addMarkers(<MarkerOptions>[options]);

      if (addedMarkers.isEmpty || addedMarkers.first == null) {
        showMessage('Failed to add marker');
        return;
      }

      setState(() {
        final Marker marker = addedMarkers.first!;
        _markers.add(marker);
        _selectedMarker = marker;
      });
    } catch (e) {
      showMessage('Error adding marker: ${e.toString()}');
    }
  }

  Future<void> _removeMarker() async {
    if (_selectedMarker == null) return;

    try {
      await _navigationViewController.removeMarkers(<Marker>[_selectedMarker!]);
      setState(() {
        _markers.remove(_selectedMarker);
        _selectedMarker = null;
      });
    } catch (e) {
      showMessage('Error removing marker: ${e.toString()}');
    }
  }

  Future<void> clearMarkers() async {
    try {
      await _navigationViewController.clearMarkers();
      setState(() {
        _markers.clear();
        _selectedMarker = null;
      });
    } catch (e) {
      showMessage('Error clearing markers: ${e.toString()}');
    }
  }

  Future<void> _updateSelectedMarkerWithOptions(MarkerOptions options) async {
    if (_selectedMarker == null) return;

    try {
      final Marker newMarker = _selectedMarker!.copyWith(options: options);
      final List<Marker?> markers =
          await _navigationViewController.updateMarkers(<Marker>[newMarker]);

      final Marker? updatedMarker = markers.firstOrNull;
      if (updatedMarker == null) {
        showMessage('Failed to update marker');
        return;
      }

      setState(() {
        _markers = _markers
            .where((Marker element) => element != _selectedMarker)
            .toList()
          ..add(updatedMarker);
        _selectedMarker = updatedMarker;
      });
    } catch (e) {
      showMessage('Error updating marker: ${e.toString()}');
    }
  }

  // Helper methods for marker property updates
  Future<void> _updateMarkerProperty({
    bool? visible,
    bool? draggable,
    bool? flat,
    double? alpha,
    double? zIndex,
  }) async {
    if (_selectedMarker == null) return;

    final MarkerOptions currentOptions = _selectedMarker!.options;
    final MarkerOptions newOptions = currentOptions.copyWith(
      visible: visible,
      draggable: draggable,
      flat: flat,
      alpha: alpha,
      zIndex: zIndex,
    );

    await _updateSelectedMarkerWithOptions(newOptions);
  }

  Future<void> _toggleVisibility() async {
    await _updateMarkerProperty(
      visible: !_selectedMarker!.options.visible,
    );
  }

  Future<void> _toggleDraggable() async {
    await _updateMarkerProperty(
      draggable: !_selectedMarker!.options.draggable,
    );
  }

  Future<void> _toggleFlat() async {
    await _updateMarkerProperty(
      flat: !_selectedMarker!.options.flat,
    );
  }

  Future<void> _setAlpha() async {
    final double oldAlpha = _selectedMarker!.options.alpha;
    final double newAlpha = _getNextValue(_alphas, oldAlpha);
    await _updateMarkerProperty(alpha: newAlpha);
  }

  Future<void> _setZIndex() async {
    final double oldZIndex = _selectedMarker!.options.zIndex;
    final double newZIndex = _getNextValue(_zIndexes, oldZIndex);
    await _updateMarkerProperty(zIndex: newZIndex);
  }

  T _getNextValue<T>(List<T> values, T currentValue) {
    final int currentIndex = values.indexOf(currentValue);
    return values.elementAtOrNull(currentIndex + 1) ?? values.first;
  }

  Future<ImageDescriptor> _getOrCreateCustomImageFromAsset() async {
    try {
      if (_registeredCustomIcon != null) {
        return _registeredCustomIcon!;
      }

      const AssetImage assetImage = AssetImage('assets/marker1.png');
      final ImageConfiguration configuration =
          createLocalImageConfiguration(context);

      final AssetBundleImageKey assetBundleImageKey =
          await assetImage.obtainKey(configuration);

      final ByteData imageBytes =
          await rootBundle.load(assetBundleImageKey.name);

      _registeredCustomIcon = await registerBitmapImage(
        bitmap: imageBytes,
        imagePixelRatio: assetBundleImageKey.scale,
      );

      return _registeredCustomIcon!;
    } catch (e) {
      showMessage('Error loading custom marker icon: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _unRegisterUnusedCustomImage() async {
    try {
      if (_registeredCustomIcon == null) return;

      // Check if image is still in use
      final bool isImageInUse = _markers.any((Marker marker) =>
          marker.options.icon.registeredImageId ==
          _registeredCustomIcon!.registeredImageId);

      if (!isImageInUse) {
        await unregisterImage(_registeredCustomIcon!);
        _registeredCustomIcon = null;
      }
    } catch (e) {
      showMessage('Error unregistering custom icon: ${e.toString()}');
    }
  }

  Future<void> _toggleCustomIcon() async {
    if (_selectedMarker == null) return;

    try {
      if (_selectedMarker!.options.icon.registeredImageId == null) {
        final ImageDescriptor customMarkerIcon =
            await _getOrCreateCustomImageFromAsset();
        await _updateSelectedMarkerWithOptions(
          _selectedMarker!.options.copyWith(icon: customMarkerIcon),
        );
      } else {
        await _updateSelectedMarkerWithOptions(
          _selectedMarker!.options.copyWith(icon: ImageDescriptor.defaultImage),
        );
        await _unRegisterUnusedCustomImage();
      }
    } catch (e) {
      showMessage('Error toggling custom icon: ${e.toString()}');
    }
  }

  void _onMarkerClicked(String markerId) {
    final Marker marker =
        _markers.firstWhere((Marker marker) => marker.markerId == markerId);
    setState(() {
      _selectedMarker = marker;
    });
  }

  void _onMarkerDrag(String markerId, LatLng position) {
    showMessage('Marker drag, position: $position markerId: $markerId');
  }

  void _onMarkerDragStart(String markerId, LatLng position) {
    showMessage('Marker drag, position: $position markerId: $markerId');
  }

  void _onMarkerDragEnd(String markerId, LatLng position) {
    showMessage('Marker drag, position: $position markerId: $markerId');
    final Marker marker =
        _markers.firstWhere((Marker marker) => marker.markerId == markerId);
    _updateSelectedMarkerWithOptions(
        marker.options.copyWith(position: position));
  }

  void _onMarkerInfoWindowClicked(String markerId) {
    showMessage('Marker info window clicked. markerId: $markerId');
  }

  void _onMarkerInfoWindowClosed(String markerId) {
    showMessage('Marker info window closed. markerId: $markerId');
  }

  void _onMarkerInfoWindowLongClicked(String markerId) {
    showMessage('Marker info window long clicked. markerId: $markerId');
  }

  @override
  Widget build(BuildContext context) => buildPage(
      context,
      (BuildContext context) => Padding(
            padding: EdgeInsets.zero,
            child: Column(children: <Widget>[
              Expanded(
                child: GoogleMapsNavigationView(
                  onViewCreated: _onViewCreated,
                  initialNavigationUIEnabledPreference:
                      NavigationUIEnabledPreference.disabled,
                  onMarkerClicked: _onMarkerClicked,
                  onMarkerDrag: _onMarkerDrag,
                  onMarkerDragStart: _onMarkerDragStart,
                  onMarkerDragEnd: _onMarkerDragEnd,
                  onMarkerInfoWindowClicked: _onMarkerInfoWindowClicked,
                  onMarkerInfoWindowClosed: _onMarkerInfoWindowClosed,
                  onMarkerInfoWindowLongClicked: _onMarkerInfoWindowLongClicked,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _markers.isEmpty
                    ? 'No markers added'
                    : _selectedMarker == null
                        ? 'Click to select marker'
                        : 'Selected marker ${_selectedMarker!.markerId}',
                style: const TextStyle(fontSize: 15),
              ),
              bottomControls
            ]),
          ));

  Widget get bottomControls {
    final ButtonStyle style =
        ElevatedButton.styleFrom(minimumSize: const Size(150, 36));

    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: <Widget>[
                  ElevatedButton(
                    style: style,
                    onPressed: () => addMarkerToMap(),
                    child: const Text('Add marker'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed:
                        _selectedMarker == null ? null : () => _removeMarker(),
                    child: const Text('Remove marker'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed: _selectedMarker == null
                        ? null
                        : () => _toggleVisibility(),
                    child:
                        Text('Visibility: ${_selectedMarker?.options.visible}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed: _selectedMarker == null
                        ? null
                        : () => _toggleDraggable(),
                    child: Text(
                        'Draggable: ${_selectedMarker?.options.draggable}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed:
                        _selectedMarker == null ? null : () => _toggleFlat(),
                    child: Text('Flat: ${_selectedMarker?.options.flat}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed:
                        _selectedMarker == null ? null : () => _setAlpha(),
                    child: Text('Alpha: ${_selectedMarker?.options.alpha}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed:
                        _selectedMarker == null ? null : () => _setZIndex(),
                    child: Text('Z-index: ${_selectedMarker?.options.zIndex}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed: _selectedMarker == null
                        ? null
                        : _selectedMarker == null
                            ? null
                            : () => _toggleCustomIcon(),
                    child: Text(
                        'Icon: ${_selectedMarker?.options.icon.registeredImageId != null ? 'Custom' : 'Default'}'),
                  ),
                  ElevatedButton(
                    style: style,
                    onPressed: _markers.isNotEmpty
                        ? () {
                            setState(() {
                              _navigationViewController.clearMarkers();
                              _markers.clear();
                              _selectedMarker = null;
                            });
                          }
                        : null,
                    child: const Text('Clear all'),
                  ),
                ]),
            if (Platform.isAndroid)
              SwitchListTile(
                  onChanged: (bool newValue) async {
                    await _navigationViewController.settings
                        .setMapToolbarEnabled(newValue);
                    _isMapToolbarEnabled = await _navigationViewController
                        .settings
                        .isMapToolbarEnabled();
                    setState(() {});
                  },
                  title: const Text('Enable map toolbar'),
                  value: _isMapToolbarEnabled),
            SwitchListTile(
                onChanged: (bool newValue) async {
                  _displayMarkerUpdates = newValue;
                  setState(() {});
                },
                title: const Text('Display marker updates'),
                value: _displayMarkerUpdates),
          ],
        ));
  }

  void showMessage(String message) {
    if (_displayMarkerUpdates) {
      final SnackBar snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    try {
      _unRegisterUnusedCustomImage();
    } catch (e) {
      debugPrint('Error during disposal: ${e.toString()}');
    }
    super.dispose();
  }
}
