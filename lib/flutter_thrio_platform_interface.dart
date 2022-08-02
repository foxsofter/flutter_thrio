import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_thrio_method_channel.dart';

abstract class FlutterThrioPlatform extends PlatformInterface {
  /// Constructs a FlutterThrioPlatform.
  FlutterThrioPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterThrioPlatform _instance = MethodChannelFlutterThrio();

  /// The default instance of [FlutterThrioPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterThrio].
  static FlutterThrioPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterThrioPlatform] when
  /// they register themselves.
  static set instance(FlutterThrioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
