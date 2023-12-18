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

class GoogleMapsNavigationViewRegistry {
  private var views: [Int64: GoogleMapsNavigationView] = [:]

  func registerView(viewId: Int64, view: GoogleMapsNavigationView) {
    views[viewId] = view
  }

  func unregisterView(viewId: Int64) {
    views.removeValue(forKey: viewId)
  }

  func getView(viewId: Int64) -> GoogleMapsNavigationView? {
    views[viewId]
  }

  func getAllRegisteredViewIds() -> [Int64] {
    Array(views.keys)
  }

  func getAllRegisteredViews() -> [GoogleMapsNavigationView] {
    Array(views.values)
  }
}
