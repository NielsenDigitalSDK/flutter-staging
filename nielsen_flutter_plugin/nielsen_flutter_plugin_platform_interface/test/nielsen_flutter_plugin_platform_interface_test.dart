import 'package:flutter_test/flutter_test.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

class NielsenFlutterPluginMock extends NielsenFlutterPluginPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('NielsenFlutterPluginPlatformInterface', () {
    late NielsenFlutterPluginPlatform nielsenFlutterPluginPlatform;

    setUp(() {
      nielsenFlutterPluginPlatform = NielsenFlutterPluginMock();
      NielsenFlutterPluginPlatform.instance = nielsenFlutterPluginPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await NielsenFlutterPluginPlatform.instance.getPlatformName(),
          equals(NielsenFlutterPluginMock.mockPlatformName),
        );
      });
    });
  });
}
