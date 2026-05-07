// Copyright 2025 Google LLC
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

import 'package:flutter_test/flutter_test.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:google_navigation_flutter/src/google_navigation_flutter_platform_interface.dart';
import 'package:google_navigation_flutter/src/method_channel/method_channel.dart';
import 'package:mockito/mockito.dart';

import '../google_navigation_flutter_test.mocks.dart';
import '../messages_test.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoMapView API Tests', () {
    late MockTestAutoMapViewApi autoViewMockApi;

    final List<GoogleMapsNavigationPlatform> platforms =
        <GoogleMapsNavigationPlatform>[
          GoogleMapsNavigationAndroid(
            AndroidNavigationSessionAPIImpl(),
            MapViewAPIImpl(),
            AutoMapViewAPIImpl(),
            ImageRegistryAPIImpl(),
          ),
          GoogleMapsNavigationIOS(
            NavigationSessionAPIImpl(),
            MapViewAPIImpl(),
            AutoMapViewAPIImpl(),
            ImageRegistryAPIImpl(),
          ),
        ];

    setUp(() {
      autoViewMockApi = MockTestAutoMapViewApi();
      TestAutoMapViewApi.setUp(autoViewMockApi);
    });

    for (final GoogleMapsNavigationPlatform platform in platforms) {
      group(platform.runtimeType, () {
        setUp(() {
          GoogleMapsNavigationPlatform.instance = platform;
        });

        group('Navigation UI features', () {
          test('isNavigationTripProgressBarEnabled returns value', () async {
            when(
              autoViewMockApi.isNavigationTripProgressBarEnabled(),
            ).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isNavigationTripProgressBarEnabled();

            expect(result, true);
            verify(
              autoViewMockApi.isNavigationTripProgressBarEnabled(),
            ).called(1);
          });

          test(
            'setNavigationTripProgressBarEnabled sends correct value',
            () async {
              await GoogleMapsNavigationPlatform.instance.autoAPI
                  .setNavigationTripProgressBarEnabled(enabled: true);

              verify(
                autoViewMockApi.setNavigationTripProgressBarEnabled(true),
              ).called(1);
            },
          );

          test('isSpeedLimitIconEnabled returns value', () async {
            when(autoViewMockApi.isSpeedLimitIconEnabled()).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isSpeedLimitIconEnabled();

            expect(result, true);
            verify(autoViewMockApi.isSpeedLimitIconEnabled()).called(1);
          });

          test('setSpeedLimitIconEnabled sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setSpeedLimitIconEnabled(enabled: true);

            verify(autoViewMockApi.setSpeedLimitIconEnabled(true)).called(1);
          });

          test('isSpeedometerEnabled returns value', () async {
            when(autoViewMockApi.isSpeedometerEnabled()).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isSpeedometerEnabled();

            expect(result, true);
            verify(autoViewMockApi.isSpeedometerEnabled()).called(1);
          });

          test('setSpeedometerEnabled sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setSpeedometerEnabled(enabled: true);

            verify(autoViewMockApi.setSpeedometerEnabled(true)).called(1);
          });

          test('showRouteOverview sends message', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .showRouteOverview();

            verify(autoViewMockApi.showRouteOverview()).called(1);
          });
        });

        group('Traffic UI features', () {
          test('isTrafficPromptsEnabled returns value', () async {
            when(autoViewMockApi.isTrafficPromptsEnabled()).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isTrafficPromptsEnabled();

            expect(result, true);
            verify(autoViewMockApi.isTrafficPromptsEnabled()).called(1);
          });

          test('setTrafficPromptsEnabled sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setTrafficPromptsEnabled(enabled: true);

            verify(autoViewMockApi.setTrafficPromptsEnabled(true)).called(1);
          });

          test('isTrafficIncidentCardsEnabled returns value', () async {
            when(
              autoViewMockApi.isTrafficIncidentCardsEnabled(),
            ).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isTrafficIncidentCardsEnabled();

            expect(result, true);
            verify(autoViewMockApi.isTrafficIncidentCardsEnabled()).called(1);
          });

          test('setTrafficIncidentCardsEnabled sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setTrafficIncidentCardsEnabled(enabled: true);

            verify(
              autoViewMockApi.setTrafficIncidentCardsEnabled(true),
            ).called(1);
          });
        });

        group('Theme and color scheme', () {
          test('getMapColorScheme returns correct value', () async {
            when(
              autoViewMockApi.getMapColorScheme(),
            ).thenReturn(MapColorSchemeDto.dark);

            final MapColorScheme result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .getMapColorScheme();

            expect(result, MapColorScheme.dark);
            verify(autoViewMockApi.getMapColorScheme()).called(1);
          });

          test('setMapColorScheme sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setMapColorScheme(mapColorScheme: MapColorScheme.dark);

            verify(
              autoViewMockApi.setMapColorScheme(MapColorSchemeDto.dark),
            ).called(1);
          });

          test('getForceNightMode returns correct value', () async {
            when(
              autoViewMockApi.getForceNightMode(),
            ).thenReturn(NavigationForceNightModeDto.forceNight);

            final NavigationForceNightMode result =
                await GoogleMapsNavigationPlatform.instance.autoAPI
                    .getForceNightMode();

            expect(result, NavigationForceNightMode.forceNight);
            verify(autoViewMockApi.getForceNightMode()).called(1);
          });

          test('setForceNightMode sends correct value', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .setForceNightMode(
                  forceNightMode: NavigationForceNightMode.forceNight,
                );

            verify(
              autoViewMockApi.setForceNightMode(
                NavigationForceNightModeDto.forceNight,
              ),
            ).called(1);
          });
        });

        group('Auto screen availability', () {
          test('isAutoScreenAvailable returns value', () async {
            when(autoViewMockApi.isAutoScreenAvailable()).thenReturn(true);

            final bool result = await GoogleMapsNavigationPlatform
                .instance
                .autoAPI
                .isAutoScreenAvailable();

            expect(result, true);
            verify(autoViewMockApi.isAutoScreenAvailable()).called(1);
          });
        });

        group('Custom events', () {
          test('sendCustomNavigationAutoEvent sends event and data', () async {
            await GoogleMapsNavigationPlatform.instance.autoAPI
                .sendCustomNavigationAutoEvent(
                  event: 'testEvent',
                  data: 'testData',
                );

            verify(
              autoViewMockApi.sendCustomNavigationAutoEvent(
                'testEvent',
                'testData',
              ),
            ).called(1);
          });
        });
      });
    }
  });
}
