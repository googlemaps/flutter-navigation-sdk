#!/bin/bash
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e

DEVICE_NAME=${TEST_DEVICE:-'iPhone 16 Pro'} # Default to 'iPhone 16 Pro' if no argument is provided
OS_VERSION=${TEST_OS:-'18.1'} # Default to 'iPhone 16 Pro' if no argument is provided

# Navigate to the ios directory and run xcodebuild with the provided device name
cd ios && xcodebuild test \
            -workspace Runner.xcworkspace \
            -scheme Runner \
            -only-testing RunnerTests \
            -configuration Debug \
            -sdk iphoneos -destination "platform=iOS Simulator,name=$DEVICE_NAME,OS=$OS_VERSION" \
            -derivedDataPath ../build/ios_unit
