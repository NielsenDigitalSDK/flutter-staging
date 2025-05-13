import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nielsen_flutter_plugin_ios/nielsen_flutter_plugin_ios.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NielsenFlutterPluginIOS', () {
    const kPlatformName = 'iOS';
    late NielsenFlutterPluginIOS nielsenFlutterPlugin;
    late List<MethodCall> log;

    setUp(() async {
      nielsenFlutterPlugin = NielsenFlutterPluginIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nielsenFlutterPlugin.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      NielsenFlutterPluginIOS.registerWith();
      expect(NielsenFlutterPluginPlatform.instance, isA<NielsenFlutterPluginIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await nielsenFlutterPlugin.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
