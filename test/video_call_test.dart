import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_call/video_call.dart';

void main() {
  const MethodChannel channel = MethodChannel('video_call');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await VideoCall.platformVersion, '42');
  });
}
