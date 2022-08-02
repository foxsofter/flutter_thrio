import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_thrio_platform_interface.dart';

/// An implementation of [FlutterThrioPlatform] that uses method channels.
class MethodChannelFlutterThrio extends FlutterThrioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_thrio');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
