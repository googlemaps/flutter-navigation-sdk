// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2024 Google LLC
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

import PackageDescription

let package = Package(
  name: "google_navigation_flutter",
  platforms: [
    .iOS("15.0"),
  ],
  products: [
    .library(name: "google-navigation-flutter", targets: ["google_navigation_flutter"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/googlemaps/ios-navigation-sdk",
      exact: "9.1.2"
    ),
    .package(
      url: "https://github.com/googlemaps/ios-maps-sdk",
      exact: "9.1.1"
    ),
  ],
  targets: [
    .target(
      name: "google_navigation_flutter",
      dependencies: [
        .product(
          name: "GoogleNavigation",
          package: "ios-navigation-sdk"
        ),
        .product(
          name: "GoogleMaps",
          package: "ios-maps-sdk"
        ),
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy"),
      ]
    ),
  ]
)
