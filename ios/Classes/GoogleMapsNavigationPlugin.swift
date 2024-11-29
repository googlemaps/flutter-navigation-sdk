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
  private static var viewEventApi: ViewEventApi?
  private static var navigationInspector: NavigationInspector?

  private static var sessionMessageHandler: GoogleMapsNavigationSessionMessageHandler?
  private static var navigationSessionEventApi: NavigationSessionEventApi?
  private static var navigationSessionManager: GoogleMapsNavigationSessionManager?
  private static var navigationInspectorHandler: GoogleMapsNavigationInspectorHandler?
  private static var autoViewMessageHandler: GoogleMapsAutoViewMessageHandler?
  private static var autoViewEventApi: AutoViewEventApi?

  private static var imageRegistryMessageHandler: GoogleMapsImageRegistryMessageHandler?
  static var imageRegistry: ImageRegistry?
  private static var isPluginInitialized: Bool = false {
    didSet {
      if isPluginInitialized {
        pluginInitializedCallback?(viewRegistry!, autoViewEventApi!, imageRegistry!)
      }
    }
  }

  static var pluginInitializedCallback: ((GoogleMapsNavigationViewRegistry, AutoViewEventApi,
                                          ImageRegistry) -> Void)? {
    didSet {
      if isPluginInitialized {
        pluginInitializedCallback?(viewRegistry!, autoViewEventApi!, imageRegistry!)
      }
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    // Navigation View handling
    viewRegistry = GoogleMapsNavigationViewRegistry()
    guard viewRegistry != nil else {
      return
    }
    viewMessageHandler = GoogleMapsNavigationViewMessageHandler(viewRegistry: viewRegistry!)
    MapViewApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: viewMessageHandler
    )
    viewEventApi = ViewEventApi(binaryMessenger: registrar.messenger())
    guard viewEventApi != nil else {
      return
    }
    imageRegistry = ImageRegistry()
    let factory = GoogleMapsNavigationViewFactory(
      viewRegistry: viewRegistry!,
      viewEventApi: viewEventApi!,
      imageRegistry: imageRegistry!
    )
    registrar.register(factory, withId: "google_navigation_flutter")

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

    // CarPlay map view message handling
    autoViewMessageHandler = GoogleMapsAutoViewMessageHandler(viewRegistry: viewRegistry!)
    AutoMapViewApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: autoViewMessageHandler
    )
    autoViewEventApi = AutoViewEventApi(binaryMessenger: registrar.messenger())

    navigationInspector = GoogleMapsNavigationInspectorHandler(
      viewRegistry: viewRegistry!
    )
    NavigationInspectorSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: navigationInspector
    )

    imageRegistryMessageHandler =
      GoogleMapsImageRegistryMessageHandler(imageRegistry: imageRegistry!)
    ImageRegistryApiSetup.setUp(
      binaryMessenger: registrar.messenger(),
      api: imageRegistryMessageHandler
    )
    isPluginInitialized = true
  }
}
