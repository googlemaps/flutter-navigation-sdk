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

import CarPlay
import Foundation
import GoogleMaps

open class BaseCarSceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate,
  CPMapTemplateDelegate
{
  /// Map options to use for CarPlay views.
  /// Can be set before the CarPlay scene is created to customize map appearance.
  public static var mapOptions: AutoMapViewOptions?

  /// Provides the map options to use when creating the CarPlay map view.
  ///
  /// Override this method in your BaseCarSceneDelegate subclass to provide custom map options
  /// from the native layer. This is useful when you want to set map configuration (like mapId)
  /// directly in native code instead of from Flutter, especially when the CarPlay screen
  /// may already be open.
  ///
  /// The default implementation returns the value from the static property, which can be set
  /// from Flutter via GoogleMapsAutoViewController.setAutoMapOptions().
  ///
  /// - Returns: AutoMapViewOptions containing map configuration, or nil to use defaults
  ///
  /// Example:
  /// ```swift
  /// override func getAutoMapOptions() -> AutoMapViewOptions? {
  ///   return AutoMapViewOptions(
  ///     mapId: "your-map-id",
  ///     mapType: .satellite,
  ///     mapColorScheme: .dark,
  ///     forceNightMode: NavigationView.ForceNightMode.auto.rawValue
  ///   )
  /// }
  /// ```
  open func getAutoMapOptions() -> AutoMapViewOptions? {
    BaseCarSceneDelegate.mapOptions
  }

  private var interfaceController: CPInterfaceController?
  private var carWindow: CPWindow?
  private var mapTemplate: CPMapTemplate?
  private var navView: GoogleMapsNavigationView?
  private var navViewController: UIViewController?
  private var templateApplicationScene: CPTemplateApplicationScene?
  private var autoViewEventApi: AutoViewEventApi?
  private var viewRegistry: GoogleMapsNavigationViewRegistry?

  public func getNavView() -> GoogleMapsNavigationView? {
    navView
  }

  public func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didConnect interfaceController: CPInterfaceController,
    to window: CPWindow
  ) {
    self.interfaceController = interfaceController
    carWindow = window
    mapTemplate = getTemplate()
    self.templateApplicationScene = templateApplicationScene
    mapTemplate?.mapDelegate = self
    createVC()
  }

  open func getTemplate() -> CPMapTemplate {
    let template = CPMapTemplate()
    template.showPanningInterface(animated: true)
    return template
  }

  open func templateApplicationScene(
    _ templateApplicationScene: CPTemplateApplicationScene,
    didDisconnect interfaceController: CPInterfaceController,
    from window: CPWindow
  ) {
    self.interfaceController = nil
    carWindow?.rootViewController = nil
    carWindow = nil
    mapTemplate = nil
    navView?.unregisterView()
    navView = nil
    navViewController = nil
    self.templateApplicationScene = nil
  }

  open func sceneDidBecomeActive(_ scene: UIScene) {}

  func createVC() {
    guard
      let templateApplicationScene,
      navView == nil
    else { return }

    GoogleMapsNavigationPlugin
      .pluginInitializedCallback = { [weak self] viewRegistry, autoViewEventApi, imageRegistry in
        guard let self else { return }
        self.viewRegistry = viewRegistry
        self.autoViewEventApi = autoViewEventApi

        // Get map options from overridable method (can be customized in subclasses)
        let autoMapOptions = self.getAutoMapOptions()

        self.navView = GoogleMapsNavigationView(
          frame: templateApplicationScene.carWindow.screen.bounds,
          viewIdentifier: nil,
          isNavigationView: true,
          viewRegistry: viewRegistry,
          viewEventApi: nil,
          navigationUIEnabledPreference: NavigationUIEnabledPreference.automatic,
          forceNightMode: autoMapOptions?.forceNightMode,
          mapConfiguration: MapConfiguration(
            cameraPosition: autoMapOptions?.cameraPosition,
            mapType: autoMapOptions?.mapType ?? .normal,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabledDuringRotateOrZoom: false,
            cameraTargetBounds: nil,
            minZoomPreference: nil,
            maxZoomPreference: nil,
            padding: nil,
            mapId: autoMapOptions?.mapId,
            mapColorScheme: autoMapOptions?.mapColorScheme ?? .unspecified
          ),
          imageRegistry: imageRegistry,
          isCarPlayView: true
        )

        // Set up prompt visibility callback to allow override
        self.navView?.promptVisibilityCallback = { [weak self] promptVisible in
          self?.onPromptVisibilityChanged(promptVisible: promptVisible)
        }

        self.navView?.setNavigationHeaderEnabled(false)
        self.navView?.setRecenterButtonEnabled(false)
        self.navView?.setNavigationFooterEnabled(false)
        self.navView?.setSpeedometerEnabled(false)
        self.navView?.setReportIncidentButtonEnabled(false)
        self.navViewController = UIViewController()
        self.navViewController?.view = self.navView?.view()
        self.carWindow?.rootViewController = self.navViewController
        self.interfaceController?.setRootTemplate(self.mapTemplate!, animated: true) { _, _ in }

        self.viewRegistry?.onHasCarPlayViewChanged = { isAvalable in
          self.sendAutoScreenAvailabilityChangedEvent(isAvailable: isAvalable)
        }
      }
  }

  // CPMapTemplateDelegate
  open func mapTemplate(
    _ mapTemplate: CPMapTemplate,
    panWith direction: CPMapTemplate.PanDirection
  ) {
    let scrollAmount = scrollAmount(for: direction)
    navView?.animateCameraByScroll(dx: scrollAmount.x, dy: scrollAmount.y)
  }

  func scrollAmount(for direction: CPMapTemplate.PanDirection) -> CGPoint {
    let scrollDistance: CGFloat = 80.0
    var scrollAmount = CGPoint(x: 0.0, y: 0.0)

    if direction.contains(.left) {
      scrollAmount.x = -scrollDistance
    }
    if direction.contains(.right) {
      scrollAmount.x = scrollDistance
    }
    if direction.contains(.up) {
      scrollAmount.y = -scrollDistance
    }
    if direction.contains(.down) {
      scrollAmount.y = scrollDistance
    }

    if scrollAmount.x != 0, scrollAmount.y != 0 {
      let factor = CGFloat(Double(1.0 / sqrt(2.0)))
      scrollAmount.x *= factor
      scrollAmount.y *= factor
    }

    return scrollAmount
  }

  /// Checks if a traffic prompt is currently visible on the CarPlay screen.
  ///
  /// This can be useful to dynamically adjust your UI based on prompt visibility,
  /// such as when deciding whether to show custom buttons or adjust your template.
  ///
  /// - Returns: true if a prompt is currently visible, false otherwise
  ///
  /// Example:
  /// ```swift
  /// override func getTemplate() -> CPMapTemplate {
  ///   let template = CPMapTemplate()
  ///
  ///   // Only show custom buttons if prompt is not visible
  ///   if !isPromptVisible() {
  ///     template.leadingNavigationBarButtons = [customButton]
  ///   }
  ///
  ///   return template
  /// }
  /// ```
  open func isPromptVisible() -> Bool {
    return navView?.isPromptVisible() ?? false
  }

  /// Called when traffic prompt visibility changes on the CarPlay screen.
  ///
  /// Override this method to customize behavior when prompts appear or disappear,
  /// such as hiding custom UI elements or adjusting your template.
  ///
  /// The default implementation sends the event to Flutter via AutoViewEventApi.
  ///
  /// - Parameter promptVisible: true when a prompt becomes visible, false when it disappears
  ///
  /// Example:
  /// ```swift
  /// override func onPromptVisibilityChanged(promptVisible: Bool) {
  ///   super.onPromptVisibilityChanged(promptVisible: promptVisible)
  ///
  ///   if promptVisible {
  ///     // Hide custom UI when prompt appears
  ///     mapTemplate?.leadingNavigationBarButtons = []
  ///   } else {
  ///     // Restore custom UI when prompt disappears
  ///     mapTemplate?.leadingNavigationBarButtons = [customButton]
  ///   }
  /// }
  /// ```
  open func onPromptVisibilityChanged(promptVisible: Bool) {
    // Default implementation: send event to Flutter
    autoViewEventApi?.onPromptVisibilityChanged(
      promptVisible: promptVisible,
      completion: { _ in }
    )
  }

  open func sendCustomNavigationAutoEvent(event: String, data: Any) {
    autoViewEventApi?.onCustomNavigationAutoEvent(event: event, data: data) { _ in }
  }

  // Called when Flutter sends a custom event to native via sendCustomNavigationAutoEvent
  // Override this method in your CarSceneDelegate subclass to handle custom events from Flutter
  open func onCustomNavigationAutoEventFromFlutter(event: String, data: Any) {
    // Default implementation does nothing
    // Subclasses can override to handle custom events
  }

  func sendAutoScreenAvailabilityChangedEvent(isAvailable: Bool) {
    autoViewEventApi?.onAutoScreenAvailabilityChanged(isAvailable: isAvailable) { _ in }
  }
}
