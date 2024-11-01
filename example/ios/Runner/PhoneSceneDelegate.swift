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

class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      window = UIWindow(windowScene: windowScene)
      let flutterEngine = FlutterEngine(name: "PhoneSceneDelegateEngine")
      flutterEngine.run()
      GeneratedPluginRegistrant.register(with: flutterEngine)
      let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
      window?.rootViewController = controller
      window?.makeKeyAndVisible()
    }
  }
}
