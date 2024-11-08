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

import UIKit
import Flutter
import GoogleMaps
import GoogleNavigation

@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. Try to find the Maps API key from the environment variables.
    // 2. Try to find the Maps API key from the Dart defines.
    // 3. Use the default Maps API key "YOUR_API_KEY".
    var mapsApiKey = ProcessInfo.processInfo.environment["MAPS_API_KEY"] ?? findMapApiKeyFromDartDefines("MAPS_API_KEY") ?? ""
    if (mapsApiKey.isEmpty) {
      mapsApiKey = "YOUR_API_KEY"
    }
    GMSServices.provideAPIKey(mapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Helper function to find the Maps API key from the Dart defines
  private func findMapApiKeyFromDartDefines(_ defineKey: String) -> String? {
    if (Bundle.main.infoDictionary!["DART_DEFINES"] == nil) {
      return nil
    }

    let dartDefinesString = Bundle.main.infoDictionary!["DART_DEFINES"] as! String
    let base64EncodedDartDefines = dartDefinesString.components(separatedBy: ",")
    for base64EncodedDartDefine in base64EncodedDartDefines {
      let decoded = String(data: Data(base64Encoded: base64EncodedDartDefine)!, encoding: .utf8)!
      let values = decoded.components(separatedBy: "=")
      if (values[0] == defineKey && values.count == 2) {
        return values[1]
      }
    }
    return nil
  }
}
