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

import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.android.libraries.mapsplatform.secrets-gradle-plugin")
}

// Helper function to extract specific Dart define value
fun findDartDefineValue(key: String): String? {
    val encodedDartDefines = project.properties["dart-defines"] as? String ?: ""
    val defines = encodedDartDefines.split(",").mapNotNull {
        try {
            val decoded = String(Base64.getDecoder().decode(it), Charsets.UTF_8).split("=")
            if (decoded.size == 2) decoded[0] to decoded[1] else null
        } catch (e: IllegalArgumentException) {
            null
        }
    }.toMap()
    return defines[key]
}

android {
    namespace = "com.google.maps.flutter.navigation_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {        
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // Set this to the languages you actually use, otherwise you'll include resource strings
    // for all languages supported by the Navigation SDK.
    androidResources {
        localeFilters.add("en")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.google.maps.flutter.navigation_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true

        testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"

        // TODO(jokerttu): Upgrade integration tests to initialize the application state for each
        // test case and uncomment the following line to clear the package data before running tests.
        // testInstrumentationRunnerArguments["clearPackageData"] = "true"

        // Extract MAPS_API_KEY from Dart defines or environment variables
        // and use it as manifest placeholder.
        val mapsApiKey = System.getenv("MAPS_API_KEY") ?: findDartDefineValue("MAPS_API_KEY") ?: ""
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    testOptions {
        execution = "ANDROIDX_TEST_ORCHESTRATOR"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.car.app:app:1.4.0")
    implementation("androidx.car.app:app-projected:1.4.0")
    implementation("com.google.android.libraries.navigation:navigation:7.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    androidTestUtil("androidx.test:orchestrator:1.5.1")
}

secrets {
    // This example application employs the Gradle plugin
    // com.google.android.libraries.mapsplatform.secrets-gradle-plugin
    // to securely manage the Google Maps API key.
    // For more information on the plugin, visit:
    // https://developers.google.com/maps/documentation/android-sdk/secrets-gradle-plugin

    // To add your Maps API key to this project:
    // 1. Open the root project's local.properties file
    // 2. Add this line, where YOUR_API_KEY is your API key:
    //        MAPS_API_KEY=YOUR_API_KEY
    defaultPropertiesFileName = "local.properties"

    // Ignore all keys matching the regexp "sdk.*"
    ignoreList.add("sdk.*")
    // Ignore all keys matching the regexp "flutter.*"
    ignoreList.add("flutter.*")
}
