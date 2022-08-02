import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_thrio/flutter_thrio.dart';
import 'package:flutter_thrio/flutter_thrio_method_channel.dart';
import 'package:flutter_thrio/flutter_thrio_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterThrioPlatform with MockPlatformInterfaceMixin implements FlutterThrioPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterThrioPlatform initialPlatform = FlutterThrioPlatform.instance;

  test('$MethodChannelFlutterThrio is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterThrio>());
  });

  test('getPlatformVersion', () async {
    FlutterThrio flutterThrioPlugin = FlutterThrio();
    MockFlutterThrioPlatform fakePlatform = MockFlutterThrioPlatform();
    FlutterThrioPlatform.instance = fakePlatform;

    expect(await flutterThrioPlugin.getPlatformVersion(), '42');
  });
}
