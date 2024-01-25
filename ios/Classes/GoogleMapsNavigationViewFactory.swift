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
  private var navigationViewEventApi: NavigationViewEventApi
  private var imageRegistry: ImageRegistry

  init(viewRegistry: GoogleMapsNavigationViewRegistry,
       navigationViewEventApi: NavigationViewEventApi, imageRegistry: ImageRegistry) {
    self.viewRegistry = viewRegistry
    self.navigationViewEventApi = navigationViewEventApi
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
          let params = NavigationViewCreationOptionsDto.fromList(argsList) else {
      fatalError("Failed to decode NavigationViewCreationOptionsDto")
    }

    let mapConfiguration = Convert.convertMapOptions(params.mapOptions)

    return GoogleMapsNavigationView(
      frame: frame,
      viewIdentifier: viewId,
      viewRegistry: viewRegistry,
      navigationViewEventApi: navigationViewEventApi,
      navigationUIEnabledPreference: Convert
        .convertNavigationUIEnabledPreference(preference: params.navigationViewOptions
          .navigationUIEnabledPreference),
      mapConfiguration: mapConfiguration,
      imageRegistry: imageRegistry
    )
  }
}
