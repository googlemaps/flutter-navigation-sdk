#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_navigation_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_navigation_flutter'
  s.version          = '0.0.1'
  s.summary          = 'A Google Maps Navigation Flutter plugin.'
  s.description      = <<-DESC
A Google Maps Navigation Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Google Maps' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'google_navigation_flutter/Sources/google_navigation_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'GoogleNavigation', '9.3.0'
  s.platform = :ios, '15.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {'google_navigation_flutter_privacy_info' => ['google_navigation_flutter/Sources/google_navigation_flutter/PrivacyInfo.xcprivacy']}
end
