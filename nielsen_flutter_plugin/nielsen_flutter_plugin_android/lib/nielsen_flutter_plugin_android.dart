import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
}
