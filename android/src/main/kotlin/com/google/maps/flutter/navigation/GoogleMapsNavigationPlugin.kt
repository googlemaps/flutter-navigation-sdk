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

  internal lateinit var viewRegistry: GoogleMapsViewRegistry
  private lateinit var viewMessageHandler: GoogleMapsViewMessageHandler
  private lateinit var imageRegistryMessageHandler: GoogleMapsImageRegistryMessageHandler
  internal lateinit var viewEventApi: ViewEventApi
  private lateinit var _binding: FlutterPlugin.FlutterPluginBinding
  private lateinit var lifecycle: Lifecycle
  internal lateinit var imageRegistry: ImageRegistry
  private lateinit var autoViewMessageHandler: GoogleMapsAutoViewMessageHandler
  internal lateinit var autoViewEventApi: AutoViewEventApi

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    instance = this
    viewRegistry = GoogleMapsViewRegistry()
    imageRegistry = ImageRegistry()
    viewMessageHandler = GoogleMapsViewMessageHandler(viewRegistry)
    MapViewApi.setUp(binding.binaryMessenger, viewMessageHandler)
    imageRegistryMessageHandler = GoogleMapsImageRegistryMessageHandler(imageRegistry)
    ImageRegistryApi.setUp(binding.binaryMessenger, imageRegistryMessageHandler)
    viewEventApi = ViewEventApi(binding.binaryMessenger)
    _binding = binding
    binding.applicationContext.registerComponentCallbacks(viewRegistry)
    autoViewMessageHandler = GoogleMapsAutoViewMessageHandler(viewRegistry)
    AutoMapViewApi.setUp(binding.binaryMessenger, autoViewMessageHandler)
    autoViewEventApi = AutoViewEventApi(binding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    MapViewApi.setUp(binding.binaryMessenger, null) // Cleanup
    ImageRegistryApi.setUp(binding.binaryMessenger, null)
    GoogleMapsNavigationSessionManager.destroyInstance()
    binding.applicationContext.unregisterComponentCallbacks(viewRegistry)
    instance = null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val factory = GoogleMapsViewFactory(viewRegistry, viewEventApi, imageRegistry)
    _binding.platformViewRegistry.registerViewFactory("google_navigation_flutter", factory)
    GoogleMapsNavigationSessionManager.createInstance(_binding.binaryMessenger)
    val inspectorHandler = GoogleMapsNavigationInspectorHandler(viewRegistry)
    NavigationInspector.setUp(_binding.binaryMessenger, inspectorHandler)
    GoogleMapsNavigationSessionManager.getInstance().onActivityCreated(binding.activity)

    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    lifecycle.addObserver(viewRegistry)
    lifecycle.addObserver(GoogleMapsNavigationSessionManager.getInstance())
  }

  override fun onDetachedFromActivityForConfigChanges() {
    GoogleMapsNavigationSessionManager.getInstance().onActivityDestroyed()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    GoogleMapsNavigationSessionManager.getInstance().onActivityCreated(binding.activity)
  }

  override fun onDetachedFromActivity() {
    lifecycle.removeObserver(GoogleMapsNavigationSessionManager.getInstance())
    GoogleMapsNavigationSessionManager.getInstance().onActivityDestroyed()
    lifecycle.removeObserver(viewRegistry)
  }
}
