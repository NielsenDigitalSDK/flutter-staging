import 'package:flutter_test/flutter_test.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

class NielsenFlutterPluginMock extends NielsenFlutterPluginPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
  
  @override
  Future<String?> callMethodChannels(String type, String data) {
    // TODO: implement callMethodChannels
    throw UnimplementedError();
  }
  
  @override
  Future<String?> createInstance(String data) {
    // TODO: implement createInstance
    throw UnimplementedError();
  }
  
  @override
  Future<String?> end(String data) {
    // TODO: implement end
    throw UnimplementedError();
  }
  
  @override
  Future<String?> free(String data) {
    // TODO: implement free
    throw UnimplementedError();
  }
  
  @override
  Future<Map<String, String>> getAppInfo() {
    // TODO: implement getAppInfo
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getDemographicId(String data) {
    // TODO: implement getDemographicId
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getDeviceId(String data) {
    // TODO: implement getDeviceId
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getFpId(String data) {
    // TODO: implement getFpId
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getMeterVersion(String data) {
    // TODO: implement getMeterVersion
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getOptOutStatus(String data) {
    // TODO: implement getOptOutStatus
    throw UnimplementedError();
  }
  
  @override
  Future<String?> getVendorId(String data) {
    // TODO: implement getVendorId
    throw UnimplementedError();
  }
  
  @override
  Future<String?> loadMetadata(String data) {
    // TODO: implement loadMetadata
    throw UnimplementedError();
  }
  
  @override
  Future<String?> play(String data) {
    // TODO: implement play
    throw UnimplementedError();
  }
  
  @override
  Future<String?> sendID3(String data) {
    // TODO: implement sendID3
    throw UnimplementedError();
  }
  
  @override
  Future<String?> setPlayheadPosition(String data) {
    // TODO: implement setPlayheadPosition
    throw UnimplementedError();
  }
  
  @override
  Future<String?> staticEnd(String data) {
    // TODO: implement staticEnd
    throw UnimplementedError();
  }
  
  @override
  Future<String?> stop(String data) {
    // TODO: implement stop
    throw UnimplementedError();
  }
  
  @override
  Future<String?> userOptOutURLString(String data) {
    // TODO: implement userOptOutURLString
    throw UnimplementedError();
  }
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
