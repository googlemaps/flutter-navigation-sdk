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

package com.google.maps.flutter.navigation

class GoogleMapsNavigationInspectorHandler(private val viewRegistry: GoogleMapsViewRegistry) :
  NavigationInspector {
  private fun manager(): GoogleMapsNavigationSessionManager {
    return GoogleMapsNavigationSessionManager.getInstance()
  }

  override fun isViewAttachedToSession(viewId: Long): Boolean {
    /// Is session exists, it's automatically attached to any existing view.
    if (viewRegistry.getNavigationView(viewId.toInt()) != null) {
      return manager().isInitialized()
    }
    return false
  }
}
