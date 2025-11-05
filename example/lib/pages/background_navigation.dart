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

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/utils.dart';
import '../widgets/widgets.dart';

/// Background navigation example demonstrating foreground service
/// with turn-by-turn notifications.
const AndroidNotificationChannel _notificationSettingsAndroid =
    AndroidNotificationChannel(
      'navigation_service',
      'Navigation Service',
      description: 'Shows navigation updates and distance information',
      playSound: false,
      enableVibration: false,
      importance: Importance.high,
    );

const DarwinInitializationSettings _notificationSettingsiOS =
    DarwinInitializationSettings(requestSoundPermission: false);

const int _notificationId = 888;

class BackgroundNavigationPage extends ExamplePage {
  const BackgroundNavigationPage({super.key})
    : super(
        leading: const Icon(Icons.cloud_queue),
        title: 'Background Navigation',
      );

  @override
  ExamplePageState<BackgroundNavigationPage> createState() =>
      _BackgroundNavigationPageState();
}

class _BackgroundNavigationPageState
    extends ExamplePageState<BackgroundNavigationPage> {
  GoogleNavigationViewController? _navigationViewController;
  final FlutterBackgroundService _service = FlutterBackgroundService();
  StreamSubscription<dynamic>? _serviceUpdateSubscription;

  bool _termsAndConditionsAccepted = false;
  bool _locationPermissionsAccepted = false;
  bool _notificationPermissionAccepted = false;
  bool _navigatorInitialized = false;
  bool _guidanceRunning = false;
  bool _backgroundServiceRunning = false;
  bool _backgroundServiceConfigured = false;
  bool _cleanupOnExit = false;

  String _serviceStatus = 'Not started';
  int _remainingTime = 0;
  int _remainingDistance = 0;
  String _currentInstruction = '';

  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final bool isRunning = await _service.isRunning();
    if (isRunning) {
      setState(() {
        _backgroundServiceRunning = true;
        _backgroundServiceConfigured = true;
        _serviceStatus = 'Reconnected';
      });
    }

    await _showTermsAndConditionsDialogIfNeeded();
    await _askLocationPermissionsIfNeeded();
    await _requestNotificationPermission();

    if (_notificationPermissionAccepted) {
      await _initializeNotificationChannel();
    }

    if (_backgroundServiceRunning) {
      _setupServiceUpdateListener();
      _service.invoke('requestState');
    }

    if (_termsAndConditionsAccepted && _locationPermissionsAccepted) {
      await _initializeNavigator();
    }
  }

  void _setupServiceUpdateListener() {
    _serviceUpdateSubscription?.cancel();

    _serviceUpdateSubscription = _service.on('update').listen((event) {
      if (event is Map) {
        final update = Map<String, dynamic>.from(
          event as Map<dynamic, dynamic>,
        );
        _handleServiceUpdate(update);
      }
    });
  }

  @override
  void dispose() {
    _serviceUpdateSubscription?.cancel();
    if (_cleanupOnExit) {
      if (_backgroundServiceRunning) {
        _service.invoke('stopService');
      }
      try {
        GoogleMapsNavigator.cleanup();
      } catch (e) {
        debugPrint('Cleanup error: $e');
      }
    }
    super.dispose();
  }

  Future<void> _showTermsAndConditionsDialogIfNeeded() async {
    _termsAndConditionsAccepted = await requestTermsAndConditionsAcceptance();
    setState(() {});
  }

  Future<void> _askLocationPermissionsIfNeeded() async {
    _locationPermissionsAccepted = await requestLocationDialogAcceptance();
    setState(() {});
  }

  Future<void> _requestNotificationPermission() async {
    final PermissionStatus status = await Permission.notification.request();
    _notificationPermissionAccepted = status.isGranted;
    setState(() {});
  }

  Future<void> _initializeNotificationChannel() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_notificationSettingsAndroid);
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(iOS: _notificationSettingsiOS),
      );
    }
  }

  Future<void> _initializeNavigator() async {
    if (!_navigatorInitialized) {
      await GoogleMapsNavigator.initializeNavigationSession();
      _navigatorInitialized = await GoogleMapsNavigator.isInitialized();
      _userLocation =
          await _navigationViewController?.getMyLocation() ??
          const LatLng(latitude: 37.7749, longitude: -122.4194);
      setState(() {});
    }
  }

  Future<void> _onViewCreated(GoogleNavigationViewController controller) async {
    _navigationViewController = controller;
    await controller.setMyLocationEnabled(true);
    setState(() {});
  }

  Future<void> _startBackgroundService() async {
    if (_backgroundServiceRunning) {
      return;
    }

    if (!_notificationPermissionAccepted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission is required for background service',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (!_backgroundServiceConfigured) {
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onServiceStart,
          autoStart: false,
          autoStartOnBoot: false,
          isForegroundMode: true,
          notificationChannelId: _notificationSettingsAndroid.id,
          initialNotificationTitle: _notificationSettingsAndroid.name,
          initialNotificationContent: 'Initializing navigation tracking...',
          foregroundServiceNotificationId: _notificationId,
          foregroundServiceTypes: <AndroidForegroundType>[
            AndroidForegroundType.location,
          ],
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: onServiceStart,
          onBackground: _onBackgroundServiceIOS,
        ),
      );

      _backgroundServiceConfigured = true;
    }

    _setupServiceUpdateListener();

    setState(() {
      _serviceStatus = 'Starting...';
    });

    final bool serviceStarted = await _service.startService();

    if (serviceStarted) {
      setState(() {
        _backgroundServiceRunning = true;
      });
    } else {
      setState(() {
        _serviceStatus = 'Failed to start';
      });
    }
  }

  Future<void> _stopBackgroundService() async {
    if (_backgroundServiceRunning) {
      _service.invoke('stopService');
      _serviceUpdateSubscription?.cancel();
      _serviceUpdateSubscription = null;
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _backgroundServiceRunning = false;
        _serviceStatus = 'Stopped';
        _remainingTime = 0;
        _remainingDistance = 0;
        _currentInstruction = '';
      });
    }
  }

  void _handleServiceUpdate(Map<String, dynamic> update) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (update.containsKey('status')) {
        _serviceStatus = update['status'] as String;
        if (_serviceStatus == 'Navigating' && !_guidanceRunning) {
          _guidanceRunning = true;
          _navigationViewController?.followMyLocation(CameraPerspective.tilted);
        } else if (_serviceStatus.startsWith('Arrived')) {
          _guidanceRunning = false;
        }
      }
      if (update.containsKey('remainingTime')) {
        _remainingTime = (update['remainingTime'] as num).toInt();
      }
      if (update.containsKey('remainingDistance')) {
        _remainingDistance = (update['remainingDistance'] as num).toInt();
      }
      if (update.containsKey('currentInstruction')) {
        _currentInstruction = update['currentInstruction'] as String;
      }
    });
  }

  Future<void> _setSimpleDestination() async {
    if (!_navigatorInitialized) {
      await _initializeNavigator();
    }

    final LatLng destination = const LatLng(
      latitude: 37.791424,
      longitude: -122.414139,
    );

    final Destinations destinations = Destinations(
      waypoints: <NavigationWaypoint>[
        NavigationWaypoint.withLatLngTarget(
          title: 'California St & Jones St',
          target: destination,
        ),
      ],
      displayOptions: NavigationDisplayOptions(showDestinationMarkers: false),
    );

    if (_userLocation != null) {
      await GoogleMapsNavigator.simulator.setUserLocation(_userLocation!);
    }

    final NavigationRouteStatus status =
        await GoogleMapsNavigator.setDestinations(destinations);

    if (status == NavigationRouteStatus.statusOk) {
      await GoogleMapsNavigator.startGuidance();
      _guidanceRunning = true;

      await GoogleMapsNavigator.simulator
          .simulateLocationsAlongExistingRouteWithOptions(
            SimulationOptions(speedMultiplier: 5),
          );

      if (!_backgroundServiceRunning) {
        await _startBackgroundService();
      }

      await _navigationViewController?.setNavigationUIEnabled(true);
      await _navigationViewController?.followMyLocation(
        CameraPerspective.tilted,
      );

      setState(() {});
    }
  }

  Future<void> _stopNavigation() async {
    await GoogleMapsNavigator.simulator.removeUserLocation();
    await GoogleMapsNavigator.stopGuidance();
    await _navigationViewController?.setNavigationUIEnabled(false);
    setState(() {
      _guidanceRunning = false;
      _remainingTime = 0;
      _remainingDistance = 0;
    });
  }

  @override
  Widget buildPage(BuildContext context, WidgetBuilder builder) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: builder(context),
    );
  }

  @override
  Widget build(BuildContext context) => buildPage(
    context,
    (BuildContext context) => Column(
      children: <Widget>[
        Expanded(
          child:
              _navigatorInitialized && _userLocation != null
                  ? GoogleMapsNavigationView(
                    onViewCreated: _onViewCreated,
                    initialCameraPosition: CameraPosition(
                      target: _userLocation!,
                      zoom: 15,
                    ),
                    initialNavigationUIEnabledPreference:
                        NavigationUIEnabledPreference.disabled,
                  )
                  : const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Initializing...'),
                        SizedBox(height: 10),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
        ),
        _buildStatusPanel(),
        _buildControls(),
      ],
    ),
  );

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Background Navigation Status',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          _buildStatusRow('Service', _serviceStatus),
          if (_remainingTime > 0 || _remainingDistance > 0) ...<Widget>[
            _buildStatusRow(
              'Time',
              formatRemainingDuration(Duration(seconds: _remainingTime)),
            ),
            _buildStatusRow(
              'Distance',
              formatRemainingDistance(_remainingDistance),
            ),
          ],
          if (_currentInstruction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _currentInstruction,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.green : Colors.white,
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (!_termsAndConditionsAccepted || !_locationPermissionsAccepted) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const Text(
              'Terms and conditions and location permissions must be accepted.',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Accept Terms & Permissions'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          if (!_guidanceRunning)
            ElevatedButton(
              onPressed: _setSimpleDestination,
              child: const Text('Start Navigation'),
            ),
          if (_guidanceRunning)
            ElevatedButton(
              onPressed: _stopNavigation,
              child: const Text('Stop Navigation'),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!_backgroundServiceRunning)
                ElevatedButton(
                  onPressed: _startBackgroundService,
                  child: const Text('Start Background Service'),
                ),
              if (_backgroundServiceRunning)
                ElevatedButton(
                  onPressed: _stopBackgroundService,
                  child: const Text('Stop Background Service'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                value: _cleanupOnExit,
                onChanged: (bool? value) {
                  setState(() {
                    _cleanupOnExit = value ?? true;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _cleanupOnExit = !_cleanupOnExit;
                  });
                },
                child: const Text('Stop service on exit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildOverlayContent(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Navigation state container.
class _NavigationState {
  String status;
  int remainingTime;
  int remainingDistance;
  String currentInstruction;

  _NavigationState({
    this.status = 'Not started',
    this.remainingTime = 0,
    this.remainingDistance = 0,
    this.currentInstruction = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'remainingTime': remainingTime,
      'remainingDistance': remainingDistance,
      'currentInstruction': currentInstruction,
    };
  }
}

/// Updates service state and notification.
void _updateNavigationState(
  _NavigationState state,
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notificationPlugin,
) {
  service.invoke('update', state.toMap());

  if (Platform.isAndroid && state.currentInstruction.isNotEmpty) {
    final String distanceText = formatRemainingDistance(
      state.remainingDistance,
    );
    final String timeText = formatRemainingDuration(
      Duration(seconds: state.remainingTime),
    );

    final bool isArrival = state.currentInstruction.startsWith('Arrived');

    notificationPlugin.show(
      _notificationId,
      state.currentInstruction,
      isArrival ? 'Arrived' : '$distanceText • $timeText remaining',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationSettingsAndroid.id,
          _notificationSettingsAndroid.name,
          channelDescription: _notificationSettingsAndroid.description,
          icon: '@mipmap/ic_launcher',
          ongoing: !isArrival,
          autoCancel: isArrival,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
          priority: Priority.high,
          importance: Importance.high,
        ),
      ),
    );
  }
}

/// Background service entry point. Runs in a separate isolate.
@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final navigationState = _NavigationState();

  StreamSubscription<RemainingTimeOrDistanceChangedEvent>?
  remainingTimeSubscription;
  StreamSubscription<NavInfoEvent>? navInfoSubscription;
  StreamSubscription<OnArrivalEvent>? arrivalSubscription;

  service.on('stopService').listen((event) async {
    await remainingTimeSubscription?.cancel();
    await navInfoSubscription?.cancel();
    await arrivalSubscription?.cancel();
    await GoogleMapsNavigator.cleanup(resetSession: false);
    service.stopSelf();
  });

  service.on('requestState').listen((event) {
    _updateNavigationState(
      navigationState,
      service,
      flutterLocalNotificationsPlugin,
    );
  });

  try {
    service.invoke('update', {'status': 'Initializing...'});

    await GoogleMapsNavigator.initializeNavigationSession();

    remainingTimeSubscription =
        GoogleMapsNavigator.setOnRemainingTimeOrDistanceChangedListener(
          (event) {
            navigationState.remainingTime = event.remainingTime.toInt();
            navigationState.remainingDistance = event.remainingDistance.toInt();
            navigationState.status = 'Navigating';

            _updateNavigationState(
              navigationState,
              service,
              flutterLocalNotificationsPlugin,
            );
          },
          remainingTimeThresholdSeconds: 10,
          remainingDistanceThresholdMeters: 50,
        );

    navInfoSubscription = GoogleMapsNavigator.setNavInfoListener((
      NavInfoEvent event,
    ) {
      final navInfo = event.navInfo;

      if (navInfo.currentStep != null) {
        final step = navInfo.currentStep!;

        final distanceToStep = navInfo.distanceToCurrentStepMeters;
        navigationState.currentInstruction =
            distanceToStep != null
                ? '${formatRemainingDistance(distanceToStep)} - ${step.fullInstructions}'
                : step.fullInstructions;
        navigationState.status = 'Navigating';

        _updateNavigationState(
          navigationState,
          service,
          flutterLocalNotificationsPlugin,
        );
      }
    }, numNextStepsToPreview: 3);

    arrivalSubscription = GoogleMapsNavigator.setOnArrivalListener((event) {
      navigationState.currentInstruction = 'Arrived at ${event.waypoint.title}';
      navigationState.status = 'Arrived at ${event.waypoint.title}';
      navigationState.remainingTime = 0;
      navigationState.remainingDistance = 0;

      _updateNavigationState(
        navigationState,
        service,
        flutterLocalNotificationsPlugin,
      );
    });

    service.invoke('update', {'status': 'Ready'});
  } catch (e, stackTrace) {
    service.invoke('update', {'status': 'Error: ${e.toString()}'});
    debugPrint('Background service error: $e\n$stackTrace');
  }
}

@pragma('vm:entry-point')
Future<bool> _onBackgroundServiceIOS(ServiceInstance service) async {
  return true;
}
