import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nielsen_flutter_plugin_android/constants.dart' as constants;
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

/// The Android implementation of [NielsenFlutterPluginPlatform].
class NielsenFlutterPluginAndroid extends NielsenFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(constants.androidMethodChannel);

  /// Registers this class as the default instance of [NielsenFlutterPluginPlatform]
  static void registerWith() {
    NielsenFlutterPluginPlatform.instance = NielsenFlutterPluginAndroid();
  }

  @override
  Future<String?> createInstance(String data) {
    return methodChannel.invokeMethod<String>(constants.createInstance, data);
  }

  @override
  Future<String?> end(String data) {
    return methodChannel.invokeMethod<String>(constants.end, data);
  }

  @override
  Future<String?> free(String data) {
    return methodChannel.invokeMethod<String>(constants.free, data);
  }

  @override
  Future<String?> getMeterVersion(String data) {
    return methodChannel.invokeMethod<String>(constants.getMeterVersion, data);
  }

  @override
  Future<String?> getOptOutStatus(String data) {
    return methodChannel.invokeMethod<String>(constants.getOptOutStatus, data);
  }

  @override
  Future<String?> loadMetadata(String data) {
    return methodChannel.invokeMethod<String>(constants.loadMetadata, data);
  }

  @override
  Future<String?> updateOTT(String data) {
    return methodChannel.invokeMethod<String>(constants.updateOTT, data);
  }

  @override
  Future<String?> play(String data) {
    return methodChannel.invokeMethod<String>(constants.play, data);
  }

  @override
  Future<String?> setPlayheadPosition(String data) {
    return methodChannel.invokeMethod<String>(
        constants.setPlayheadPosition, data);
  }

  @override
  Future<String?> staticEnd(String data) {
    return methodChannel.invokeMethod<String>(constants.staticEnd, data);
  }

  @override
  Future<String?> stop(String data) {
    return methodChannel.invokeMethod<String>(constants.stop, data);
  }

  @override
  Future<String?> userOptOutURLString(String data) {
    return methodChannel.invokeMethod<String>(
        constants.userOptOutURLString, data);
  }

  @override
  Future<String?> sendID3(String data) {
    return methodChannel.invokeMethod<String>(constants.sendID3, data);
  }

  @override
  Future<String?> getDemographicId(String data) {
    return methodChannel.invokeMethod<String>(constants.getDemographicId, data);
  }

  @override
  Future<String?> getDeviceId(String data) {
    return methodChannel.invokeMethod<String>(constants.getDeviceId, data);
  }

  @override
  Future<String?> getFpId(String data) {
    return methodChannel.invokeMethod<String>(constants.getFpId, data);
  }

  @override
  Future<String?> getVendorId(String data) {
    return methodChannel.invokeMethod<String>(constants.getVendorId, data);
  }
}
