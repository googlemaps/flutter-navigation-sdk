// Copyright 2026 Google LLC
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

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
        // Only needed to resolve ktfmt below (development/CI-only, gated by -Pktfmt).
        if (providers.gradleProperty("ktfmt").isPresent) {
            maven { url = uri("https://plugins.gradle.org/m2/") }
        }
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.3")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        // ktfmt (Kotlin formatter) is a development/CI-only tool. Pulling it onto the classpath
        // (and applying it below) is gated behind -Pktfmt so it is never forced on apps that
        // depend on this plugin. Enabled by `melos run format:android`.
        if (providers.gradleProperty("ktfmt").isPresent) {
            classpath("com.ncorti.ktfmt.gradle:plugin:0.21.0")
        }
    }
}

plugins {
    id("com.android.library")
}

group = "com.google.maps.flutter.navigation"
version = "1.0-SNAPSHOT"

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    configurations.configureEach {
        if (name == "implementation") {
            exclude(group = "com.google.android.gms", module = "play-services-maps")
        }
    }
}

// Apply the Kotlin Gradle Plugin (KGP) only when consumed by AGP < 9. AGP 9+ ships built-in Kotlin,
// so applying KGP there is unnecessary and triggers a Flutter deprecation warning. Keeping it
// conditional preserves compatibility for apps still on AGP 8.
// https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors#supporting-flutter-versions-earlier-than-3-44
val agpMajor = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.substringBefore('.').toInt()
if (agpMajor < 9) {
    apply(plugin = "org.jetbrains.kotlin.android")
}

// ktfmt is applied only for development/CI formatting (-Pktfmt), so it is never forced on apps
// that depend on this plugin. Run via `melos run format:android` (which passes -Pktfmt).
if (providers.gradleProperty("ktfmt").isPresent) {
    apply(plugin = "com.ncorti.ktfmt.gradle")
    // Configured dynamically (no compile-time type reference) so this script still compiles when
    // ktfmt is absent from the classpath, i.e. for apps that depend on this plugin.
    extensions.getByName("ktfmt").withGroovyBuilder { "googleStyle"() }
}

android {
    namespace = "com.google.maps.flutter.navigation"

    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
        consumerProguardFiles("proguard.txt")
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
                it.outputs.upToDateWhen { false }
            }
        }
    }
}

// Configure the Kotlin JVM target via the compilerOptions DSL (replaces the deprecated
// android.kotlinOptions block). Configured through the extension so it works whether the Kotlin
// plugin is applied conditionally (AGP < 9) or provided by AGP's built-in Kotlin (AGP 9+). The
// static `kotlin { }` accessor is not generated for imperatively-applied plugins.
project.extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java) {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    implementation("androidx.car.app:app:1.7.0")
    implementation("androidx.car.app:app-projected:1.7.0")
    implementation("androidx.startup:startup-runtime:1.2.0")
    implementation("com.google.android.libraries.navigation:navigation:7.6.1")
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.robolectric:robolectric:4.14.1")
}
