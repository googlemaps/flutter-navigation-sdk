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

class GoogleMapsNavigationViewFactory: NSObject, FlutterPlatformViewFactory {
  private var viewRegistry: GoogleMapsNavigationViewRegistry
  private var viewEventApi: ViewEventApi
  private var imageRegistry: ImageRegistry

  init(viewRegistry: GoogleMapsNavigationViewRegistry,
       viewEventApi: ViewEventApi, imageRegistry: ImageRegistry) {
    self.viewRegistry = viewRegistry
    self.viewEventApi = viewEventApi
    self.imageRegistry = imageRegistry
    super.init()
  }

  public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect,
              viewIdentifier viewId: Int64,
              arguments args: Any?) -> FlutterPlatformView {
    guard let argsList = args as? [Any?],
          let params = ViewCreationOptionsDto.fromList(argsList) else {
      fatalError("Failed to decode ViewCreationOptionsDto")
    }

    let mapConfiguration = Convert.convertMapOptions(params.mapOptions)

    let isNavigationView = params.mapViewType == MapViewTypeDto.navigation

    return GoogleMapsNavigationView(
      frame: frame,
      viewIdentifier: viewId,
      isNavigationView: isNavigationView,
      viewRegistry: viewRegistry,
      viewEventApi: viewEventApi,
      navigationUIEnabledPreference: Convert
        .convertNavigationUIEnabledPreference(preference: params.navigationViewOptions?
          .navigationUIEnabledPreference),
      mapConfiguration: mapConfiguration,
      imageRegistry: imageRegistry,
      isCarPlayView: false
    )
  }
}
