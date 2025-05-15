import 'dart:convert';

import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

NielsenFlutterPluginPlatform get _platform => NielsenFlutterPluginPlatform.instance;

/// Returns the name of the current platform.
Future<String> getPlatformName() async {
  final platformName = await _platform.getPlatformName();
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}


Future<Map<String, String>> getAppInfo() async {
  final appInfo = await _platform.getAppInfo();
  return appInfo;
}


Future<String> createInstance(Map<String, String> data) async {
  final platformName = await _platform.createInstance(jsonEncode(data));
  if (platformName == null) throw Exception('Unable to get platform name.');
  return platformName;
}


