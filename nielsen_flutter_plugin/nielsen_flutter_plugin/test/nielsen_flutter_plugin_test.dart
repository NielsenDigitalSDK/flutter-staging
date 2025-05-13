import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nielsen_flutter_plugin/nielsen_flutter_plugin.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNielsenFlutterPluginPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements NielsenFlutterPluginPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NielsenFlutterPlugin', () {
    late NielsenFlutterPluginPlatform nielsenFlutterPluginPlatform;

    setUp(() {
      nielsenFlutterPluginPlatform = MockNielsenFlutterPluginPlatform();
      NielsenFlutterPluginPlatform.instance = nielsenFlutterPluginPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => nielsenFlutterPluginPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => nielsenFlutterPluginPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
