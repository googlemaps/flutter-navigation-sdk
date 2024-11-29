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

import Dispatch
import Foundation

class GoogleMapsNavigationViewRegistry {
  private var views: [Int64: GoogleMapsNavigationView] = [:]
  private var carPlayView: GoogleMapsNavigationView? {
    didSet {
      onHasCarPlayViewChanged?(carPlayView != nil)
    }
  }

  var onHasCarPlayViewChanged: ((Bool) -> Void)?
  // Using a concurrent queue with a barrier ensures that write operations are serialized,
  // meaning each write completes before another write can access the shared resource.
  // Multiple read operations can still proceed concurrently as long as no write is in progress.
  private let queue = DispatchQueue(
    label: "google_navigation_flutter.thread_safe_view_registry_queue",
    attributes: .concurrent
  )

  func registerView(viewId: Int64, view: GoogleMapsNavigationView) {
    queue.async(flags: .barrier) { [weak self] in
      DispatchQueue.main.async {
        self?.views[viewId] = view
      }
    }
  }

  func unregisterView(viewId: Int64) {
    queue.async(flags: .barrier) { [weak self] in
      DispatchQueue.main.async {
        self?.views.removeValue(forKey: viewId)
      }
    }
  }

  func getView(viewId: Int64) -> GoogleMapsNavigationView? {
    queue.sync {
      views[viewId]
    }
  }

  func getAllRegisteredViewIds() -> [Int64] {
    queue.sync {
      Array(views.keys)
    }
  }

  func getAllRegisteredViews() -> [GoogleMapsNavigationView] {
    queue.sync {
      Array(views.values)
    }
  }

  func getAllRegisteredNavigationViewIds() -> [Int64] {
    // Filter the views dictionary to include only those views that are navigation views
    views.filter { $0.value.isNavigationView() }.map(\.key)
  }

  func registerCarPlayView(view: GoogleMapsNavigationView) {
    queue.async(flags: .barrier) { [weak self] in
      DispatchQueue.main.async {
        self?.carPlayView = view
      }
    }
  }

  func unregisterCarPlayView() {
    queue.async(flags: .barrier) { [weak self] in
      DispatchQueue.main.async {
        self?.carPlayView = nil
      }
    }
  }

  func getCarPlayView() -> GoogleMapsNavigationView? {
    queue.sync {
      self.carPlayView
    }
  }
}
