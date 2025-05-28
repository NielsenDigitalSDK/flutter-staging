import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nielsen_flutter_plugin_android/constants.dart' as constants;
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

/// The Android implementation of [NielsenFlutterPluginPlatform].
class NielsenFlutterPluginAndroid extends NielsenFlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nielsen_flutter_plugin_android');

  /// Registers this class as the default instance of [NielsenFlutterPluginPlatform]
  static void registerWith() {
    NielsenFlutterPluginPlatform.instance = NielsenFlutterPluginAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
  
  @override
  Future<Map<String, String>> getAppInfo() async {
    return {'appid': 'TF2D48D99-9B58-B05C-E040-070AAB3176DB', 'nol_devDebug': 'DEBUG', 'uid2': 'MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=', 'uid2_token': 'AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==', 'hem_sha256': '0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea', 'hem_sha1': 'FA92088EB2E94C2B71B98C423DA3C0B1F10AA211', 'hem_md5': 'D5F252F907B95001D7BAB577AE1A514C', 'hem_unknown': 'unknown'};
  }
  
  @override
  Future<String?> callMethodChannels(String type, String data) {
    return methodChannel.invokeMethod<String>(type, jsonEncode(data));
  }
  
  @override
  Future<String?> createInstance(String data) {
    return methodChannel.invokeMethod<String>(constants.createInstance, data);
  }
  
  @override
  Future<String?> end(String data) {
    return methodChannel.invokeMethod<String>(constants.end);
  }
  
  @override
  Future<String?> free(String data) {
    return methodChannel.invokeMethod<String>(constants.free);
  }
  
  @override
  Future<String?> getMeterVersion(String data) {
    return methodChannel.invokeMethod<String>(constants.getMeterVersion);
  }
  
  @override
  Future<String?> getOptOutStatus(String data) {
    return methodChannel.invokeMethod<String>(constants.getOptOutStatus);
  }
  
  @override
  Future<String?> loadMetadata(String data) {
    return methodChannel.invokeMethod<String>(constants.loadMetadata, data);
  }
  
  @override
  Future<String?> play(String data) {
    return methodChannel.invokeMethod<String>(constants.play, data);
  }
  
  @override
  Future<String?> setPlayheadPosition(String data) {
    return methodChannel.invokeMethod<String>(constants.setPlayheadPosition, data);
  }
  
  @override
  Future<String?> staticEnd(String data) {
    return methodChannel.invokeMethod<String>(constants.staticEnd);
  }
  
  @override
  Future<String?> stop(String data) {
    return methodChannel.invokeMethod<String>(constants.stop);
  }
  
  @override
  Future<String?> userOptOutURLString(String data) {
    return methodChannel.invokeMethod<String>(constants.userOptOutURLString);
  }
  
  @override
  Future<String?> sendID3(String data) {
    return methodChannel.invokeMethod<String>(constants.sendID3, data);
  }
  
  @override
  Future<String?> getDemographicId(String data) {
    return methodChannel.invokeMethod<String>(constants.getDemographicId);
  }
  
  @override
  Future<String?> getDeviceId(String data) {
    return methodChannel.invokeMethod<String>(constants.getDeviceId);
  }
  
  @override
  Future<String?> getFpId(String data) {
    return methodChannel.invokeMethod<String>(constants.getFpId);
  }
  
  @override
  Future<String?> getVendorId(String data) {
    return methodChannel.invokeMethod<String>(constants.getVendorId);
  }
}
