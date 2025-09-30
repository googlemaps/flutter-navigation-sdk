/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.google.maps.flutter.navigation

import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter

/** GoogleMapsNavigationPlugin */
class GoogleMapsNavigationPlugin : FlutterPlugin, ActivityAware {
  companion object {
    private var instance: GoogleMapsNavigationPlugin? = null

    fun getInstance(): GoogleMapsNavigationPlugin? {
      return instance
    }
  }

  internal var viewRegistry: GoogleMapsViewRegistry? = null
  internal var imageRegistry: ImageRegistry? = null
  internal var autoViewEventApi: AutoViewEventApi? = null
  private var viewEventApi: ViewEventApi? = null

  private var viewMessageHandler: GoogleMapsViewMessageHandler? = null
  private var imageRegistryMessageHandler: GoogleMapsImageRegistryMessageHandler? = null
  private var autoViewMessageHandler: GoogleMapsAutoViewMessageHandler? = null

  private var lifecycle: Lifecycle? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    instance = this

    // Init view registry and its method channel handlers
    viewRegistry = GoogleMapsViewRegistry()
    viewMessageHandler = GoogleMapsViewMessageHandler(viewRegistry!!)
    MapViewApi.setUp(binding.binaryMessenger, viewMessageHandler)
    binding.applicationContext.registerComponentCallbacks(viewRegistry)

    // Init image registry and its method channel handlers
    imageRegistry = ImageRegistry()
    imageRegistryMessageHandler = GoogleMapsImageRegistryMessageHandler(imageRegistry!!)
    ImageRegistryApi.setUp(binding.binaryMessenger, imageRegistryMessageHandler)

    // Setup platform view factory and its method channel handlers
    viewEventApi = ViewEventApi(binding.binaryMessenger)
    val factory = GoogleMapsViewFactory(viewRegistry!!, viewEventApi!!, imageRegistry!!)
    binding.platformViewRegistry.registerViewFactory("google_navigation_flutter", factory)

    // Setup auto map view method channel handlers
    autoViewMessageHandler = GoogleMapsAutoViewMessageHandler(viewRegistry!!)
    AutoMapViewApi.setUp(binding.binaryMessenger, autoViewMessageHandler)
    autoViewEventApi = AutoViewEventApi(binding.binaryMessenger)

    // Setup navigation session manager and its method channel handlers
    GoogleMapsNavigationSessionManager.createInstance(binding.binaryMessenger)
    val inspectorHandler = GoogleMapsNavigationInspectorHandler(viewRegistry!!)
    NavigationInspector.setUp(binding.binaryMessenger, inspectorHandler)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // Cleanup method channel handlers
    MapViewApi.setUp(binding.binaryMessenger, null)
    ImageRegistryApi.setUp(binding.binaryMessenger, null)
    AutoMapViewApi.setUp(binding.binaryMessenger, null)
    NavigationInspector.setUp(binding.binaryMessenger, null)

    GoogleMapsNavigationSessionManager.destroyInstance()
    binding.applicationContext.unregisterComponentCallbacks(viewRegistry)

    // Cleanup references
    viewRegistry = null
    viewMessageHandler = null
    imageRegistryMessageHandler = null
    viewEventApi = null
    imageRegistry = null
    autoViewMessageHandler = null
    autoViewEventApi = null
    instance = null
  }

  private fun attachActivity(binding: ActivityPluginBinding) {
    lifecycle =
      FlutterLifecycleAdapter.getActivityLifecycle(binding).also { lc ->
        viewRegistry?.let(lc::addObserver)
        GoogleMapsNavigationSessionManager.getInstanceOrNull()?.let(lc::addObserver)
      }
    GoogleMapsNavigationSessionManager.getInstanceOrNull()?.onActivityCreated(binding.activity)
  }

  private fun detachActivity(forConfigChange: Boolean) {
    lifecycle?.let { lc ->
      viewRegistry?.let(lc::removeObserver)
      GoogleMapsNavigationSessionManager.getInstanceOrNull()?.let(lc::removeObserver)
    }

    GoogleMapsNavigationSessionManager.getInstanceOrNull()?.onActivityDestroyed(forConfigChange)
    lifecycle = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) = attachActivity(binding)

  override fun onDetachedFromActivityForConfigChanges() = detachActivity(forConfigChange = true)

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
    attachActivity(binding)

  override fun onDetachedFromActivity() = detachActivity(forConfigChange = false)
}
