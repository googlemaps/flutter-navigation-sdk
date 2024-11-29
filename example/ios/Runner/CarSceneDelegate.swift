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
import google_navigation_flutter
import GoogleNavigation
import UIKit

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
}
