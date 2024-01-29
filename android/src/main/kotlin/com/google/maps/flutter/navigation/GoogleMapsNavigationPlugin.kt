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
  private lateinit var viewRegistry: GoogleMapsNavigationViewRegistry
  private lateinit var viewMessageHandler: GoogleMapsNavigationViewMessageHandler
  private lateinit var imageRegistryMessageHandler: GoogleMapsImageRegistryMessageHandler
  private lateinit var navigationViewEventApi: NavigationViewEventApi
  private lateinit var _binding: FlutterPlugin.FlutterPluginBinding
  private lateinit var lifecycle: Lifecycle
  private lateinit var imageRegistry: ImageRegistry

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    viewRegistry = GoogleMapsNavigationViewRegistry()
    imageRegistry = ImageRegistry()
    viewMessageHandler = GoogleMapsNavigationViewMessageHandler(viewRegistry)
    NavigationViewApi.setUp(binding.binaryMessenger, viewMessageHandler)
    imageRegistryMessageHandler = GoogleMapsImageRegistryMessageHandler(imageRegistry)
    ImageRegistryApi.setUp(binding.binaryMessenger, imageRegistryMessageHandler)
    navigationViewEventApi = NavigationViewEventApi(binding.binaryMessenger)
    _binding = binding
    binding.applicationContext.registerComponentCallbacks(viewRegistry)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    NavigationViewApi.setUp(binding.binaryMessenger, null) // Cleanup
    ImageRegistryApi.setUp(binding.binaryMessenger, null)
    GoogleMapsNavigationSessionManager.destroyInstance()
    binding.applicationContext.unregisterComponentCallbacks(viewRegistry)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val factory =
      GoogleMapsNavigationViewFactory(viewRegistry, navigationViewEventApi, imageRegistry)
    _binding.platformViewRegistry.registerViewFactory("google_maps_navigation", factory)
    GoogleMapsNavigationSessionManager.createInstance(_binding.binaryMessenger)
    val inspectorHandler = GoogleMapsNavigationInspectorHandler(viewRegistry)
    NavigationInspector.setUp(_binding.binaryMessenger, inspectorHandler)
    GoogleMapsNavigationSessionManager.getInstance().onActivityCreated(binding.activity)

    lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    lifecycle.addObserver(viewRegistry)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    GoogleMapsNavigationSessionManager.getInstance().onActivityDestroyed()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    GoogleMapsNavigationSessionManager.getInstance().onActivityCreated(binding.activity)
  }

  override fun onDetachedFromActivity() {
    GoogleMapsNavigationSessionManager.getInstance().onActivityDestroyed()
    lifecycle.removeObserver(viewRegistry)
  }
}
