#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thrio.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'thrio'
  s.version          = '0.2.2'
  s.summary          = 'Thrio makes it easy and fast to add flutter to existing mobile applications, and provide a simple and consistent navigator API.'
  s.description      = <<-DESC
A flutter plugin which enables hybrid integration of flutter for existing ios or android apps.
                       DESC
  s.homepage         = 'https://github.com/hellobike/thrio'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'hellobike' => 'foxsofter@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = ['Classes/*.h',
                           'Classes/Category/*.h',
                           'Classes/Channel/*.h',
                           'Classes/Logger/*.h',
                           'Classes/Module/*.h',
                           'Classes/Registry/*.h',
                           'Classes/Navigator/NavigatorRouteSettings.h',
                           'Classes/Navigator/NavigatorPageRoute.h',
                           'Classes/Navigator/NavigatorPageNotifyProtocol.h',
                           'Classes/Navigator/NavigatorPageObserverProtocol.h',
                           'Classes/Navigator/NavigatorRouteObserverProtocol.h',
                           'Classes/Navigator/NavigatorFlutterViewController.h',
                           'Classes/Navigator/ThrioNavigator.h',
                           'Classes/Navigator/UINavigationController+Navigator.h',
                           'Classes/Navigator/UIViewController+Navigator.h',
                           'Classes/Navigator/UIViewController+WillPopCallback.h',
                           'Classes/Navigator/UIViewController+HidesNavigationBar.h',]
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
