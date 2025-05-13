import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nielsen_flutter_plugin_platform_interface/src/method_channel_nielsen_flutter_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelNielsenFlutterPlugin', () {
    late MethodChannelNielsenFlutterPlugin methodChannelNielsenFlutterPlugin;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelNielsenFlutterPlugin = MethodChannelNielsenFlutterPlugin();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelNielsenFlutterPlugin.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName = await methodChannelNielsenFlutterPlugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
  });
}
