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

import GoogleMaps

enum GoogleMapsAutoViewHandlerError: Error {
  case viewNotFound
}

class GoogleMapsAutoViewMessageHandler: AutoMapViewApi {
  private let viewRegistry: GoogleMapsNavigationViewRegistry

  init(viewRegistry: GoogleMapsNavigationViewRegistry) {
    self.viewRegistry = viewRegistry
  }

  private func getView() throws -> GoogleMapsNavigationView {
    guard let view = viewRegistry.getCarPlayView() else {
      throw GoogleMapsNavigationViewHandlerError.viewNotFound
    }
    return view
  }

  func setMapType(mapType: MapTypeDto) throws {
    let gmsMapType = Convert.convertMapType(mapType: mapType)
    try getView().setMapType(mapType: gmsMapType)
  }
}
