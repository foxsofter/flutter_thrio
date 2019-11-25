import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thrio_router/thrio_router.dart';

void main() {
  const MethodChannel channel = MethodChannel('thrio_router');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ThrioRouter.platformVersion, '42');
  });
}
