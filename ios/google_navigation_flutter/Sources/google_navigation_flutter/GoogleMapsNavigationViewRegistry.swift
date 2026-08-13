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

/// Weak wrapper so the registry does not own the views it tracks.
///
/// A `GoogleMapsNavigationView` removes itself from the registry only in its
/// `deinit` (`unregisterView()`). If the registry held views strongly, that
/// strong entry would keep the view's reference count above zero after Flutter
/// tears down the platform view, so `deinit` would never run, the view would
/// never be unregistered, and its underlying `GMSMapView` would be retained for
/// the lifetime of the process. Because Flutter assigns a new view id for each
/// platform view, nothing overwrites the stale entry either, so one view leaks
/// per view creation. Holding views weakly lets a released view deallocate,
/// which triggers `deinit` and prunes the (now-empty) entry.
private class WeakViewRef {
  weak var view: GoogleMapsNavigationView?
  init(_ view: GoogleMapsNavigationView) { self.view = view }
}

class GoogleMapsNavigationViewRegistry {
  private var views: [Int64: WeakViewRef] = [:]
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
      self?.views[viewId] = WeakViewRef(view)
    }
  }

  func unregisterView(viewId: Int64, viewInstanceIdToUnregister: ObjectIdentifier) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self else { return }
      // Remove the entry when it matches the unregistering instance, or when the
      // weakly-held view has already been reclaimed, so stale keys never linger.
      if let registeredView = self.views[viewId]?.view {
        if ObjectIdentifier(registeredView) == viewInstanceIdToUnregister {
          self.views.removeValue(forKey: viewId)
        }
      } else {
        self.views.removeValue(forKey: viewId)
      }
    }
  }

  func getView(viewId: Int64) -> GoogleMapsNavigationView? {
    queue.sync {
      views[viewId]?.view
    }
  }

  func getAllRegisteredViewIds() -> [Int64] {
    queue.sync {
      views.compactMap { $0.value.view != nil ? $0.key : nil }
    }
  }

  func getAllRegisteredViews() -> [GoogleMapsNavigationView] {
    queue.sync {
      views.values.compactMap { $0.view }
    }
  }

  func getAllRegisteredNavigationViewIds() -> [Int64] {
    // Filter the views dictionary to include only those views that are navigation views
    views.compactMap { $0.value.view?.isNavigationView() == true ? $0.key : nil }
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
      for view in views.values.compactMap({ $0.view }) {
        view.sendPromptVisibilityChangedEvent(promptVisible: promptVisible)
      }
      // Also send to CarPlay view if it exists
      carPlayView?.sendPromptVisibilityChangedEvent(promptVisible: promptVisible)
    }
  }
}
