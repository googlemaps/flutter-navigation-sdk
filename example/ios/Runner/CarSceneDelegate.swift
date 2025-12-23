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
import GoogleNavigation
import UIKit
import google_navigation_flutter

class CarSceneDelegate: BaseCarSceneDelegate {
  override func getTemplate() -> CPMapTemplate {
    let template = CPMapTemplate()
    template.showPanningInterface(animated: true)

    let customEventButton = CPBarButton(title: "Custom Event") { [weak self] _ in
      let data = ["sampleDataKey": "sampleDataContent"]
      self?.sendCustomNavigationAutoEvent(event: "CustomCarPlayEvent", data: data)
    }
    let recenterButton = CPBarButton(title: "Re-center") { [weak self] _ in
      self?.getNavView()?.followMyLocation(
        perspective: GMSNavigationCameraPerspective.tilted,
        zoomLevel: nil
      )
    }
    template.leadingNavigationBarButtons = [customEventButton, recenterButton]
    return template
  }

  // Example of handling custom events from Flutter
  override func onCustomNavigationAutoEventFromFlutter(event: String, data: Any) {
    NSLog("CarSceneDelegate: Received custom event from Flutter: event=\(event), data=\(data)")
  }

  // Example of providing custom map options from native code
  // Override this method to provide custom map configuration
  override func getAutoMapOptions() -> AutoMapViewOptions? {
    // Call super to use Flutter-provided options
    return super.getAutoMapOptions()

    // Or provide your own custom options:
    // let cameraPosition = GMSCameraPosition(latitude: 37.7749, longitude: -122.4194, zoom: 14)
    // return AutoMapViewOptions(
    //   cameraPosition: cameraPosition,
    //   mapId: "your-custom-map-id",
    //   mapType: .satellite,
    //   mapColorScheme: .dark,
    //   forceNightMode: .lowLight
    // )
  }

  // Example of handling prompt visibility changes
  override func onPromptVisibilityChanged(promptVisible: Bool) {
    // Call super to ensure Flutter receives the event
    super.onPromptVisibilityChanged(promptVisible: promptVisible)

    NSLog("CarSceneDelegate: onPromptVisibilityChanged called with promptVisible=\(promptVisible)")

    // Example: Hide custom UI when prompt appears, show it when prompt disappears
    // Uncomment to enable this behavior:
    // if promptVisible {
    //   mapTemplate?.leadingNavigationBarButtons = []
    // } else {
    //   // Restore your custom buttons
    //   let customEventButton = CPBarButton(title: "Custom Event") { [weak self] _ in
    //     let data = ["sampleDataKey": "sampleDataContent"]
    //     self?.sendCustomNavigationAutoEvent(event: "CustomCarPlayEvent", data: data)
    //   }
    //   let recenterButton = CPBarButton(title: "Re-center") { [weak self] _ in
    //     self?.getNavView()?.followMyLocation(
    //       perspective: GMSNavigationCameraPerspective.tilted,
    //       zoomLevel: nil
    //     )
    //   }
    //   mapTemplate?.leadingNavigationBarButtons = [customEventButton, recenterButton]
    // }
  }
}
