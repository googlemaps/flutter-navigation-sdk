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
  CPMapTemplateDelegate {
  private var interfaceController: CPInterfaceController?
  private var carWindow: CPWindow?
  private var mapTemplate: CPMapTemplate?
  private var navView: GoogleMapsNavigationView?
  private var navViewController: UIViewController?
  private var sessionAttached: Bool = false
  private var viewControllerRegistered: Bool = false
  private var templateApplicationScene: CPTemplateApplicationScene?

  public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                       didConnect interfaceController: CPInterfaceController,
                                       to window: CPWindow) {
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

  open func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                     didDisconnect interfaceController: CPInterfaceController,
                                     from window: CPWindow) {
    unRegisterViewController()
    self.interfaceController = nil
    carWindow = nil
    mapTemplate = nil
    navView = nil
    navViewController = nil
    viewControllerRegistered = false
    sessionAttached = false
  }

  open func sceneDidBecomeActive(_ scene: UIScene) {
    registerViewController()
  }

  func createVC() {
    guard
      let templateApplicationScene,
      navView == nil
    else { return }

    GoogleMapsNavigationPlugin
      .pluginInitializedCallback = { [weak self] viewRegistry, imageRegistry in
        guard let self else { return }
        self.navView = GoogleMapsNavigationView(
          frame: templateApplicationScene.carWindow.screen.bounds,
          isNavigationView: true,
          viewRegistry: viewRegistry,
          navigationUIEnabledPreference: NavigationUIEnabledPreference.automatic,
          mapConfiguration: MapConfiguration(
            cameraPosition: GMSCameraPosition(latitude: 51.51, longitude: 0.12, zoom: 5),
            mapType: .normal,
            compassEnabled: true,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabledDuringRotateOrZoom: false
          ),
          imageRegistry: imageRegistry
        )
        self.navView?.setNavigationHeaderEnabled(false)
        self.navView?.setRecenterButtonEnabled(false)
        self.navView?.setNavigationFooterEnabled(false)
        self.navView?.setSpeedometerEnabled(false)
        self.navViewController = UIViewController()
        self.navViewController?.view = self.navView?.view()
        self.carWindow?.rootViewController = self.navViewController
        self.interfaceController?.setRootTemplate(self.mapTemplate!, animated: true) { _, _ in }
      }
  }

  func registerViewController() {}

  func unRegisterViewController() {}

  // CPMapTemplateDelegate

  open func mapTemplate(_ mapTemplate: CPMapTemplate,
                        panWith direction: CPMapTemplate.PanDirection) {
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

  open func sendCustomNavigationAutoEvent(event: String, data: Any) {
    GoogleMapsNavigationPlugin.sendCustomNavigationAutoEvent(event: event, data: data)
  }
}
