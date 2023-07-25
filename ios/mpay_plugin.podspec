#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mpay_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mpay_plugin'
  s.version          = '1.0.3'
  s.summary          = 'A new Flutter plugin project.'
  s.static_framework = true
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'


   s.vendored_frameworks = 'Libraries/AlipaySDK/AlipaySDK.framework'
   s.vendored_frameworks = 'Libraries/OpenSDK.framework'
   s.vendored_libraries  = 'Libraries/WeChatSDK/libWeChatSDK.a'
   s.resource_bundles = { 'Resources' => 'Libraries/AlipaySDK/*.framework/*.bundle' }
   s.frameworks = 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'CoreMotion', 'WebKit'
#    s.libraries = 'c++', 'z'
#     s.frameworks = 'CoreGraphics', 'Security', 'WebKit' ,'WebKit'
   s.libraries = 'c++', 'z', 'sqlite3.0'
#     s.pod_target_xcconfig = {
#     'OTHER_LDFLAGS' => '$(inherited) -ObjC -all_load',
#     }
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
