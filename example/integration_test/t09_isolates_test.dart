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

// This test file validates that the Google Maps Navigation plugin works
// correctly with Dart isolates and background execution, including testing
// that multiple GoogleMapsNavigationSessionManager instances can share
// the same Navigator through native implementations.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'shared.dart';

void main() {
  setUpAll(() async {
    // No special setup needed for flutter_background_service in tests
  });

  patrol(
    'Test GoogleMapsNavigator.getNavSDKVersion() in multiple background isolates',
    (PatrolIntegrationTester $) async {
      final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      const int numIsolates = 3;
      final List<ReceivePort> receivePorts = [];

      for (int i = 0; i < numIsolates; i++) {
        final ReceivePort receivePort = ReceivePort();
        receivePorts.add(receivePort);

        await Isolate.spawn(
          _isolateVersionCheckMain,
          _IsolateData(
            rootIsolateToken: rootIsolateToken,
            sendPort: receivePort.sendPort,
          ),
        );
      }

      final List<_IsolateResult> results = [];
      for (final receivePort in receivePorts) {
        final dynamic result = await receivePort.first;
        expect(result, isA<_IsolateResult>());
        results.add(result as _IsolateResult);
      }

      for (int i = 0; i < results.length; i++) {
        expect(
          results[i].error,
          isNull,
          reason: 'Isolate $i should not throw an error',
        );
        expect(results[i].version, isNotNull);
        expect(results[i].version!.length, greaterThan(0));
      }

      final String firstVersion = results[0].version!;
      for (int i = 1; i < results.length; i++) {
        expect(
          results[i].version,
          equals(firstVersion),
          reason: 'All isolates should return the same SDK version',
        );
      }
    },
  );

  patrol('Test background service with navigation updates', (
    PatrolIntegrationTester $,
  ) async {
    if (!Platform.isAndroid) {
      return;
    }

    await checkLocationDialogAndTosAcceptance($);

    // Request notification permission for foreground service
    if (!await Permission.notification.isGranted) {
      final Future<PermissionStatus> notificationGranted =
          Permission.notification.request();

      if (await $.native.isPermissionDialogVisible(
        timeout: const Duration(seconds: 5),
      )) {
        // Tap "Allow" button for notification permission
        await $.native.tap(Selector(text: 'Allow'));
      }

      // Check that the notification permission is granted
      await notificationGranted.then((PermissionStatus status) async {
        expect(status, PermissionStatus.granted);
      });
    }

    final service = FlutterBackgroundService();

    // Stop any existing service
    if (await service.isRunning()) {
      service.invoke('stopService');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final List<Map<String, dynamic>> backgroundServiceUpdates = [];
    final List<Map<String, dynamic>> mainIsolateUpdates = [];
    final Completer<void> backgroundServiceReady = Completer<void>();

    // Listen to data from background service
    service.on('update').listen((event) {
      if (event is Map) {
        final update = Map<String, dynamic>.from(
          event as Map<dynamic, dynamic>,
        );
        backgroundServiceUpdates.add(update);

        // Signal when background service is initialized
        if (update['status'] == 'initialized' &&
            !backgroundServiceReady.isCompleted) {
          backgroundServiceReady.complete();
        }
      }
    });

    // Configure and start the background service
    // Using isForegroundMode: true to show notification with navigation updates
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onBackgroundServiceStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'navigation_test_service',
        initialNotificationTitle: 'Navigation Test Service',
        initialNotificationContent: 'Testing navigation...',
        foregroundServiceNotificationId: 999,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onBackgroundServiceStart,
        onBackground: onIosBackground,
      ),
    );

    final bool serviceStarted = await service.startService();
    expect(serviceStarted, true);

    // Wait for background service to be fully initialized
    await backgroundServiceReady.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException(
          'Background service failed to initialize within 5 seconds',
        );
      },
    );

    // Give the background service a moment to fully set up its listener
    await Future.delayed(const Duration(milliseconds: 500));

    await GoogleMapsNavigator.initializeNavigationSession();

    await GoogleMapsNavigator.simulator.setUserLocation(
      const LatLng(latitude: 37.79136614772824, longitude: -122.41565900473043),
    );
    await Future.delayed(const Duration(seconds: 1));

    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: const LatLng(latitude: 37.791424, longitude: -122.414139),
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);
    expect(status, NavigationRouteStatus.statusOk);

    await GoogleMapsNavigator.startGuidance();
    expect(await GoogleMapsNavigator.isGuidanceRunning(), true);

    final mainIsolateSubscription =
        GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener((
          event,
        ) {
          mainIsolateUpdates.add({
            'source': 'main_isolate',
            'remainingTime': event.remainingTime,
            'remainingDistance': event.remainingDistance,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });

    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(
          SimulationOptions(speedMultiplier: 50),
        );

    final bool? bothReceived = await waitForValueMatchingPredicate<bool>(
      $,
      () async {
        // Filter out status updates - we only want navigation data updates
        final navUpdates =
            backgroundServiceUpdates
                .where(
                  (update) =>
                      update.containsKey('remainingTime') &&
                      update.containsKey('remainingDistance'),
                )
                .toList();
        return mainIsolateUpdates.isNotEmpty && navUpdates.isNotEmpty;
      },
      (bool hasData) => hasData,
      maxTries: 100,
      delayMs: 100,
    );

    expect(
      bothReceived,
      true,
      reason:
          'Should receive updates from both isolates within 10 seconds. '
          'Main isolate updates: ${mainIsolateUpdates.length}, '
          'Background service navigation updates: ${backgroundServiceUpdates.where((u) => u.containsKey('remainingTime')).length}',
    );

    expect(
      mainIsolateUpdates.length,
      greaterThan(0),
      reason: 'Should receive navigation updates on main isolate',
    );

    // Filter background updates to only count navigation data (not status updates)
    final backgroundNavUpdates =
        backgroundServiceUpdates
            .where(
              (update) =>
                  update.containsKey('remainingTime') &&
                  update.containsKey('remainingDistance'),
            )
            .toList();

    expect(
      backgroundNavUpdates.length,
      greaterThan(0),
      reason: 'Should receive navigation updates from background service',
    );

    bool mainIsolateHasValidData = false;
    bool backgroundServiceHasValidData = false;

    for (final update in mainIsolateUpdates) {
      if (update.containsKey('remainingDistance') &&
          update.containsKey('remainingTime')) {
        expect(update['remainingDistance'], isA<num>());
        expect(update['remainingTime'], isA<num>());
        mainIsolateHasValidData = true;
        break;
      }
    }

    for (final update in backgroundNavUpdates) {
      if (update.containsKey('remainingDistance') &&
          update.containsKey('remainingTime')) {
        expect(update['remainingDistance'], isA<num>());
        expect(update['remainingTime'], isA<num>());
        backgroundServiceHasValidData = true;
        break;
      }
    }

    expect(mainIsolateHasValidData, true);
    expect(backgroundServiceHasValidData, true);

    // Stop the background service
    service.invoke('stopService');
    await Future.delayed(const Duration(milliseconds: 500));

    mainIsolateUpdates.clear();

    await GoogleMapsNavigator.simulator
        .simulateLocationsAlongExistingRouteWithOptions(
          SimulationOptions(speedMultiplier: 50),
        );

    final bool? stillReceiving = await waitForValueMatchingPredicate<bool>(
      $,
      () async => mainIsolateUpdates.isNotEmpty,
      (bool hasData) => hasData,
      maxTries: 50,
      delayMs: 100,
    );

    expect(
      stillReceiving,
      true,
      reason:
          'Should receive updates on main isolate after foreground service destroyed within 5 seconds',
    );

    expect(
      mainIsolateUpdates.length,
      greaterThan(0),
      reason:
          'Main isolate should continue receiving navigation updates after foreground service is destroyed',
    );

    bool mainIsolateStillReceivingData = false;
    for (final update in mainIsolateUpdates) {
      if (update.containsKey('remainingDistance') &&
          update.containsKey('remainingTime')) {
        expect(update['remainingDistance'], isA<num>());
        expect(update['remainingTime'], isA<num>());
        mainIsolateStillReceivingData = true;
        break;
      }
    }

    expect(
      mainIsolateStillReceivingData,
      true,
      reason:
          'Main isolate should still receive valid navigation data after background service destroyed',
    );

    await mainIsolateSubscription.cancel();

    await GoogleMapsNavigator.stopGuidance();
    await GoogleMapsNavigator.cleanup();
  });
}

class _IsolateData {
  _IsolateData({required this.rootIsolateToken, required this.sendPort});

  final RootIsolateToken rootIsolateToken;
  final SendPort sendPort;
}

class _IsolateResult {
  _IsolateResult({this.version, this.error});

  final String? version;
  final String? error;
}

Future<void> _isolateVersionCheckMain(_IsolateData data) async {
  try {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.rootIsolateToken);
    final String version = await GoogleMapsNavigator.getNavSDKVersion();
    data.sendPort.send(_IsolateResult(version: version));
  } catch (e) {
    data.sendPort.send(_IsolateResult(error: e.toString()));
  }
}

/// Background service callback that listens to navigation events.
/// Tests that multiple GoogleMapsNavigationSessionManager instances can
/// listen to the same Navigator without each one initializing its own session.
/// The navigation session is initialized in the main isolate.
@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  StreamSubscription<RemainingTimeOrDistanceChangedEvent>? subscription;

  service.on('stopService').listen((event) async {
    await subscription?.cancel();
    await GoogleMapsNavigator.cleanup(resetSession: false);
    service.stopSelf();
  });

  try {
    // Call createNavigationSession to register this isolate's listeners.
    // Since the Navigator is already initialized by the main isolate,
    // this will just register listeners without creating a new Navigator.
    await GoogleMapsNavigator.initializeNavigationSession();

    subscription =
        GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener((
          event,
        ) {
          service.invoke('update', {
            'source': 'background_service',
            'remainingTime': event.remainingTime,
            'remainingDistance': event.remainingDistance,
            'timestamp': DateTime.now().toIso8601String(),
          });

          // Update the foreground notification with navigation data
          if (service is AndroidServiceInstance) {
            final double distanceKm = event.remainingDistance / 1000;
            final String distanceText =
                distanceKm >= 1
                    ? '${distanceKm.toStringAsFixed(1)} km'
                    : '${event.remainingDistance.toInt()} m';

            service.setForegroundNotificationInfo(
              title: 'Navigation Test Active',
              content: 'Distance: $distanceText',
            );
          }
        });

    // Signal that the background service is ready and listening
    service.invoke('update', {
      'status': 'initialized',
      'timestamp': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    service.invoke('update', {
      'status': 'error',
      'error': e.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}
