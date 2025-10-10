import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// INTERNAL: platform contract implemented by iOS/Android MethodChannel layers.
/// All methods receive a JSON-encoded string, and return a nullable string.
abstract class NielsenFlutterPluginPlatform extends PlatformInterface {
  NielsenFlutterPluginPlatform() : super(token: _token);
  static final Object _token = Object();

  static NielsenFlutterPluginPlatform _instance = _UnimplementedPlatform();
  static NielsenFlutterPluginPlatform get instance => _instance;

  static set instance(NielsenFlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ---------- Instance lifecycle ----------
  Future<String?> createInstance(String json);
  Future<String?> free(String json);

  // ---------- Playback / metadata ----------
  Future<String?> play(String json);
  Future<String?> loadMetadata(String json);
  Future<String?> stop(String json);
  Future<String?> end(String json);
  Future<String?> staticEnd(String json);
  Future<String?> setPlayheadPosition(String json);
  Future<String?> updateOTT(String json);

  // ---------- Timed metadata ----------
  Future<String?> sendID3(String json);

  // ---------- Info / privacy ----------
  Future<String?> getOptOutStatus(String json);
  Future<String?> userOptOutURLString(String json);
  Future<String?> userOptOut(String json);
  Future<String?> getMeterVersion(String json);
  Future<String?> getDemographicId(String json);
  Future<String?> getDeviceId(String json);
  Future<String?> getVendorId(String json);
  Future<String?> getFpId(String json);
}

class _UnimplementedPlatform extends NielsenFlutterPluginPlatform {
  @override
  Future<String?> createInstance(String json) async => null;

  @override
  Future<String?> free(String json) async => null;

  @override
  Future<String?> play(String json) async => null;

  @override
  Future<String?> loadMetadata(String json) async => null;

  @override
  Future<String?> updateOTT(String json) async => null;

  @override
  Future<String?> stop(String json) async => null;

  @override
  Future<String?> end(String json) async => null;

  @override
  Future<String?> staticEnd(String json) async => null;

  @override
  Future<String?> setPlayheadPosition(String json) async => null;

  @override
  Future<String?> sendID3(String json) async => null;

  @override
  Future<String?> getOptOutStatus(String json) async => null;

  @override
  Future<String?> userOptOutURLString(String json) async => null;

  @override
  Future<String?> userOptOut(String json) async => null;

  @override
  Future<String?> getMeterVersion(String json) async => null;

  @override
  Future<String?> getDemographicId(String json) async => null;

  @override
  Future<String?> getDeviceId(String json) async => null;

  @override
  Future<String?> getVendorId(String json) async => null;

  @override
  Future<String?> getFpId(String json) async => null;
}
