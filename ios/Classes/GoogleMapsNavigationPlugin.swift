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

import Flutter
import UIKit

extension FlutterError: Error {}

public class GoogleMapsNavigationPlugin: NSObject, FlutterPlugin {
  private static var viewRegistry: GoogleMapsNavigationViewRegistry?
  private static var viewMessageHandler: GoogleMapsNavigationViewMessageHandler?
  private static var navigationViewEventApi: NavigationViewEventApi?
  private static var navigationInspector: NavigationInspector?

  private static var sessionMessageHandler: GoogleMapsNavigationSessionMessageHandler?
  private static var navigationSessionEventApi: NavigationSessionEventApi?
  private static var navigationSessionManager: GoogleMapsNavigationSessionManager?
  private static var navigationInspectorHandler: GoogleMapsNavigationInspectorHandler?

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Navigation View handling
    viewRegistry = GoogleMapsNavigationViewRegistry()
    guard viewRegistry != nil else {
      return
    }
    viewMessageHandler = GoogleMapsNavigationViewMessageHandler(viewRegistry: viewRegistry!)
    NavigationViewApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: viewMessageHandler
    )
    navigationViewEventApi = NavigationViewEventApi(binaryMessenger: registrar.messenger())
    guard navigationViewEventApi != nil else {
      return
    }
    let factory = GoogleMapsNavigationViewFactory(
      viewRegistry: viewRegistry!,
      navigationViewEventApi: navigationViewEventApi!
    )
    registrar.register(factory, withId: "google_maps_navigation")

    navigationSessionEventApi = NavigationSessionEventApi(
      binaryMessenger: registrar.messenger()
    )
    guard let navigationSessionEventApi else {
      return
    }
    sessionMessageHandler = GoogleMapsNavigationSessionMessageHandler(
      navigationSessionEventApi: navigationSessionEventApi,
      viewRegistry: viewRegistry!
    )
    // Navigation Session manager handling
    NavigationSessionApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: sessionMessageHandler
    )

    navigationInspector = GoogleMapsNavigationInspectorHandler(
      viewRegistry: viewRegistry!
    )
    NavigationInspectorSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: navigationInspector
    )
  }
}
