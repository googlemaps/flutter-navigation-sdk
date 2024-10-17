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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/circles.dart';
import 'pages/pages.dart';
import 'widgets/widgets.dart';

/// The list of pages to show in the Google Maps Navigation demo.
final List<ExamplePage> _allPages = <ExamplePage>[
  const NavigationPage(),
  const BasicMapPage(),
  const CameraPage(),
  const MarkersPage(),
  const PolygonsPage(),
  const PolylinesPage(),
  const CirclesPage(),
  const TurnByTurnPage(),
  const WidgetInitializationPage(),
  const NavigationWithoutMapPage(),
  const MultipleMapViewsPage(),
];

/// The main Google Maps Navigation demo screen.
class NavigationDemo extends StatelessWidget {
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavigationBody();
  }
}

class NavigationBody extends StatefulWidget {
  const NavigationBody({super.key});
  @override
  State<StatefulWidget> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationBody> {
  _NavigationDemoState();

  bool _locationPermitted = false;
  bool _notificationsPermitted = false;
  String _navSDKVersion = '';

  @override
  void initState() {
    _requestPermissions();
    super.initState();
    unawaited(_checkSDKVersion());
  }

  Future<void> _checkSDKVersion() async {
    // Get the Navigation SDK version.
    _navSDKVersion = await GoogleMapsNavigator.getNavSDKVersion();
  }

  Future<void> _pushPage(BuildContext context, ExamplePage page) async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// Request permission for accessing the device's location and notifications.
  ///
  /// Android: Fine and Coarse Location
  /// iOS: CoreLocation (Always and WhenInUse), Notification
  Future<void> _requestPermissions() async {
    final PermissionStatus locationPermission =
        await Permission.location.request();

    PermissionStatus notificationPermission = PermissionStatus.denied;
    if (Platform.isIOS) {
      notificationPermission = await Permission.notification.request();
    }
    setState(() {
      _locationPermitted = locationPermission == PermissionStatus.granted;
      _notificationsPermitted =
          notificationPermission == PermissionStatus.granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Navigation Flutter examples')),
      body: SafeArea(
          top: false,
          minimum: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: _allPages.length + 1,
            itemBuilder: (_, int index) {
              if (index == 0) {
                return Card(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Text(Platform.isIOS
                            ? 'Location ${_locationPermitted ? 'granted' : 'denied'} • Notifications ${_notificationsPermitted ? 'granted' : 'denied'}'
                            : 'Location ${_locationPermitted ? 'granted' : 'denied'} '),
                        Text('Navigation SDK version: $_navSDKVersion'),
                      ],
                    ),
                  ),
                );
              }
              return ListTile(
                leading: _allPages[index - 1].leading,
                title: Text(_allPages[index - 1].title),
                onTap: () => _pushPage(context, _allPages[index - 1]),
              );
            },
          )),
    );
  }
}

void main() {
  final ElevatedButtonThemeData exampleButtonDefaultTheme =
      ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 36)));

  runApp(MaterialApp(
    home: const NavigationDemo(),
    theme: ThemeData.light()
        .copyWith(elevatedButtonTheme: exampleButtonDefaultTheme),
    darkTheme: ThemeData.dark()
        .copyWith(elevatedButtonTheme: exampleButtonDefaultTheme),
  ));
}
