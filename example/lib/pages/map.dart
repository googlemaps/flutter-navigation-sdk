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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_navigation_flutter/google_navigation_flutter.dart';

import '../utils/utils.dart';
import '../widgets/widgets.dart';

class MapPage extends ExamplePage {
  const MapPage({super.key})
      : super(leading: const Icon(Icons.map), title: 'Map');

  @override
  ExamplePageState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ExamplePageState<MapPage> {
  late final GoogleNavigationViewController _navigationViewController;
  late bool isMyLocationEnabled = false;
  late bool isMyLocationButtonEnabled = true;
  late bool consumeMyLocationButtonClickEvent = false;
  late bool isZoomGesturesEnabled = true;
  late bool isZoomControlsEnabled = true;
  late bool isCompassEnabled = true;
  late bool isRotateGesturesEnabled = true;
  late bool isScrollGesturesEnabled = true;
  late bool isScrollGesturesEnabledDuringRotateOrZoom = true;
  late bool isTiltGesturesEnabled = true;
  late bool isTrafficEnabled = false;
  late MapType mapType = MapType.normal;

  Future<void> setMapType(MapType type) async {
    mapType = type;
    await _navigationViewController.setMapType(mapType: type);
    setState(() {});
  }

  Future<void> setMapStyleDefault() async {
    await _navigationViewController.setMapStyle(null);
  }

  Future<void> setMapStyleNight() async {
    final String jsonString =
        await rootBundle.loadString('assets/night_style.json');
    await _navigationViewController.setMapStyle(jsonString);
  }

  Future<void> setMapStyleSepia() async {
    final String jsonString =
        await rootBundle.loadString('assets/sepia_style.json');
    await _navigationViewController.setMapStyle(jsonString);
  }

  // ignore: use_setters_to_change_properties
  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final SnackBar snackBar = SnackBar(
        duration: const Duration(milliseconds: 2000), content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onMyLocationClicked(MyLocationClickedEvent event) {
    _showMessage('My location clicked');
  }

  void _onMyLocationButtonClicked(MyLocationButtonClickedEvent event) {
    _showMessage('My location button clicked');
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle mapTypeStyle = ElevatedButton.styleFrom(
        minimumSize: const Size(80, 36),
        disabledBackgroundColor:
            Theme.of(context).colorScheme.primaryContainer);

    return buildPage(
        context,
        (BuildContext context) => Stack(
              children: <Widget>[
                GoogleMapsNavigationView(
                  onViewCreated: _onViewCreated,
                  onMyLocationClicked: _onMyLocationClicked,
                  onMyLocationButtonClicked: _onMyLocationButtonClicked,
                  initialNavigationUIEnabledPreference:
                      NavigationUIEnabledPreference.disabled,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                          style: mapTypeStyle,
                          onPressed: mapType == MapType.normal
                              ? null
                              : () => setMapType(MapType.normal),
                          child: const Text('Normal')),
                      ElevatedButton(
                          style: mapTypeStyle,
                          onPressed: mapType == MapType.satellite
                              ? null
                              : () => setMapType(MapType.satellite),
                          child: const Text('Satellite')),
                      ElevatedButton(
                          style: mapTypeStyle,
                          onPressed: mapType == MapType.terrain
                              ? null
                              : () => setMapType(MapType.terrain),
                          child: const Text('Terrain')),
                      ElevatedButton(
                          style: mapTypeStyle,
                          onPressed: mapType == MapType.hybrid
                              ? null
                              : () => setMapType(MapType.hybrid),
                          child: const Text('Hybrid')),
                    ],
                  ),
                ),
                if (mapType == MapType.normal)
                  Padding(
                    padding: isMyLocationEnabled && isMyLocationButtonEnabled
                        ? const EdgeInsets.only(top: 50.0, right: 8.0)
                        : const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: <Widget>[
                          ElevatedButton(
                            style: mapTypeStyle,
                            onPressed: () => setMapStyleDefault(),
                            child: const Text('Default style'),
                          ),
                          ElevatedButton(
                            style: mapTypeStyle,
                            onPressed: () => setMapStyleNight(),
                            child: const Text('Night style'),
                          ),
                          ElevatedButton(
                            style: mapTypeStyle,
                            onPressed: () => setMapStyleSepia(),
                            child: const Text('Sepia style'),
                          ),
                        ],
                      ),
                    ),
                  ),
                getOverlayOptionsButton(context,
                    onPressed: () => toggleOverlay())
              ],
            ));
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    return Column(children: <Widget>[
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setCompassEnabled(newValue);
            final bool enabled =
                await _navigationViewController.settings.isCompassEnabled();
            setState(() {
              isCompassEnabled = enabled;
            });
          },
          title: const Text('Enable compass'),
          value: isCompassEnabled),
      SwitchListTile(
          title: const Text('Enable my location'),
          value: isMyLocationEnabled,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool newValue) async {
            await _navigationViewController.setMyLocationEnabled(newValue);
            final bool enabled =
                await _navigationViewController.isMyLocationEnabled();
            setState(() {
              isMyLocationEnabled = enabled;
            });
          },
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          title: const Text('Enable my location button'),
          value: isMyLocationButtonEnabled,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: isMyLocationEnabled
              ? (bool newValue) async {
                  await _navigationViewController.settings
                      .setMyLocationButtonEnabled(newValue);
                  final bool enabled = await _navigationViewController.settings
                      .isMyLocationButtonEnabled();
                  setState(() {
                    isMyLocationButtonEnabled = enabled;
                  });
                }
              : null,
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          title: const Text('Consume my location button click'),
          value: consumeMyLocationButtonClickEvent,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: isMyLocationEnabled && isMyLocationButtonEnabled
              ? (bool newValue) async {
                  await _navigationViewController.settings
                      .setConsumeMyLocationButtonClickEventsEnabled(newValue);
                  final bool enabled = await _navigationViewController.settings
                      .isConsumeMyLocationButtonClickEventsEnabled();
                  setState(() {
                    consumeMyLocationButtonClickEvent = enabled;
                  });
                }
              : null,
          visualDensity: VisualDensity.compact),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setZoomGesturesEnabled(newValue);
            final bool enabled = await _navigationViewController.settings
                .isZoomGesturesEnabled();
            setState(() {
              isZoomGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable zoom gestures'),
          value: isZoomGesturesEnabled),
      if (Platform.isAndroid)
        SwitchListTile(
            onChanged: (bool newValue) async {
              await _navigationViewController.settings
                  .setZoomControlsEnabled(newValue);
              final bool enabled = await _navigationViewController.settings
                  .isZoomControlsEnabled();
              setState(() {
                isZoomControlsEnabled = enabled;
              });
            },
            title: const Text('Enable zoom controls'),
            value: isZoomControlsEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setRotateGesturesEnabled(newValue);
            final bool enabled = await _navigationViewController.settings
                .isRotateGesturesEnabled();
            setState(() {
              isRotateGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable rotate gestures'),
          value: isRotateGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setScrollGesturesEnabled(newValue);
            final bool enabled = await _navigationViewController.settings
                .isScrollGesturesEnabled();
            setState(() {
              isScrollGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable scroll gestures'),
          value: isScrollGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setScrollGesturesDuringRotateOrZoomEnabled(newValue);
            final bool enabled = await _navigationViewController.settings
                .isScrollGesturesEnabledDuringRotateOrZoom();
            setState(() {
              isScrollGesturesEnabledDuringRotateOrZoom = enabled;
            });
          },
          title: const Text('Enable scroll gestures during rotate or zoom'),
          value: isScrollGesturesEnabledDuringRotateOrZoom),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setTiltGesturesEnabled(newValue);
            final bool enabled = await _navigationViewController.settings
                .isTiltGesturesEnabled();
            setState(() {
              isTiltGesturesEnabled = enabled;
            });
          },
          title: const Text('Enable tilt gestures'),
          value: isTiltGesturesEnabled),
      SwitchListTile(
          onChanged: (bool newValue) async {
            await _navigationViewController.settings
                .setTrafficEnabled(newValue);
            final bool enabled =
                await _navigationViewController.settings.isTrafficEnabled();
            setState(() {
              isTrafficEnabled = enabled;
            });
          },
          title: const Text('Enable traffic'),
          value: isTrafficEnabled),
    ]);
  }
}
