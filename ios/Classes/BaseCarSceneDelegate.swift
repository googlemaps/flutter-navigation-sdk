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

import Foundation
import CarPlay
import GoogleMaps

open class BaseCarSceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPMapTemplateDelegate {
  private var interfaceController: CPInterfaceController?
  private var carWindow: CPWindow?
  private var mapTemplate: CPMapTemplate?
  private var navView: GoogleMapsNavigationView?
  private var navViewController: UIViewController?
  private var sessionAttached: Bool = false
  private var viewControllerRegistered: Bool = false

  public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
    self.interfaceController = interfaceController
    self.carWindow = window
    self.mapTemplate = getTemplate()
    self.mapTemplate?.mapDelegate = self

    guard 
      let viewRegistry = GoogleMapsNavigationPlugin.viewRegistry,
      let navigationViewEventApi = GoogleMapsNavigationPlugin.navigationViewEventApi,
      let imageRegistry = GoogleMapsNavigationPlugin.imageRegistry
    else { return }

    self.navView = GoogleMapsNavigationView(
      frame: templateApplicationScene.carWindow.screen.bounds,
      viewIdentifier: 9999,
      viewRegistry: viewRegistry,
      navigationViewEventApi: navigationViewEventApi,
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
    self.navViewController = UIViewController()
    self.navViewController?.view = self.navView?.view()
    self.carWindow?.rootViewController = navViewController
    self.interfaceController?.setRootTemplate(self.mapTemplate!, animated: true) { _, _ in }
  }

  open func getTemplate() -> CPMapTemplate {
    let template = CPMapTemplate()
    template.showPanningInterface(animated: true)
    return template
  }

  open func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow) {
    unRegisterViewController()
    self.interfaceController = nil
    self.carWindow = nil
    self.mapTemplate = nil
    self.navView = nil
    self.navViewController = nil
    self.viewControllerRegistered = false
    self.sessionAttached = false
  }

  open func sceneDidBecomeActive(_ scene: UIScene) {
    attachSession()
    registerViewController()
  }

  func attachSession() {

  }

  func registerViewController() {

  }

  func unRegisterViewController() {

  }

  // CPMapTemplateDelegate

  open func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
    let scrollAmount = scrollAmount(for: direction)
    self.navView?.animateCameraByScroll(dx: scrollAmount.x, dy: scrollAmount.y)
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

    if scrollAmount.x != 0 && scrollAmount.y != 0 {
      let factor: CGFloat = CGFloat(Double(1.0 / sqrt(2.0)))
      scrollAmount.x *= factor
      scrollAmount.y *= factor
    }

    return scrollAmount
  }
}