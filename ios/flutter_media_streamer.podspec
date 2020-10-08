#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_media_streamer.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_media_streamer'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for streaming Media on iOS and Android'
  s.description      = <<-DESC
A Flutter plugin for reading the Gallery on iOS and Android
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Guy Or' => 'guyor.net@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.3'
end
