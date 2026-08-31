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
  private var viewRefs: [Int64: WeakRef<GoogleMapsNavigationView>] = [:]
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
    queue.sync(flags: .barrier) { [weak self] in
      self?.viewRefs[viewId] = WeakRef(view)
    }
  }

  func unregisterView(viewId: Int64, viewInstanceIdToUnregister: ObjectIdentifier) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else { return }
      if let registeredView = self.viewRefs[viewId]?.value {
        if ObjectIdentifier(registeredView) == viewInstanceIdToUnregister {
          self.viewRefs.removeValue(forKey: viewId)
        }
      } else {
        self.viewRefs.removeValue(forKey: viewId)
      }
    }
  }

  func getView(viewId: Int64) -> GoogleMapsNavigationView? {
    queue.sync {
      viewRefs[viewId]?.value
    }
  }

  func getAllRegisteredViewIds() -> [Int64] {
    queue.sync {
      viewRefs.compactMap { id, ref in ref.value != nil ? id : nil }
    }
  }

  func getAllRegisteredViews() -> [GoogleMapsNavigationView] {
    queue.sync {
      viewRefs.values.compactMap { $0.value }
    }
  }

  func getAllRegisteredNavigationViewIds() -> [Int64] {
    // Filter the views dictionary to include only those views that are navigation views
    viewRefs.compactMap { id, ref in ref.value?.isNavigationView() == true ? id : nil }
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

  func sendPromptVisibilityChangedToAllViews(promptVisible: Bool) {
    queue.sync {
      for view in viewRefs.values.compactMap({ $0.value }) {
        view.sendPromptVisibilityChangedEvent(promptVisible: promptVisible)
      }
      // Also send to CarPlay view if it exists
      carPlayView?.sendPromptVisibilityChangedEvent(promptVisible: promptVisible)
    }
  }
}
