import 'dart:io';

import 'package:nielsen_flutter_plugin_platform_interface/src/method_channel_nielsen_flutter_plugin.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:nielsen_flutter_plugin_platform_interface/src/constants.dart';

/// The interface that implementations of nielsen_flutter_plugin must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `NielsenFlutterPlugin`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [NielsenFlutterPluginPlatform] methods.
abstract class NielsenFlutterPluginPlatform extends PlatformInterface {
  /// Constructs a NielsenFlutterPluginPlatform.
  NielsenFlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NielsenFlutterPluginPlatform _instance = MethodChannelNielsenFlutterPlugin();

  /// The default instance of [NielsenFlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNielsenFlutterPlugin].
  static NielsenFlutterPluginPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [NielsenFlutterPluginPlatform] when they register themselves.
  static set instance(NielsenFlutterPluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }


  Future<Map<String, String>> getAppInfo();
  /// Return the current platform name.
  Future<String?> getPlatformName();

  Future<String?> callMethodChannels(String type, String data);

  Future<String?> createInstance(String data);
  Future<String?> loadMetadata(String data);
  Future<String?> play(String data);
  Future<String?> stop();
  Future<String?> end();
  Future<String?> setPlayheadPosition(String data);
  Future<String?> getOptOutStatus();
  Future<String?> userOptOutURLString();
  Future<String?> getMeterVersion();
  Future<String?> staticEnd();
  Future<String?> free();
  Future<String?> getDemographicId(String data);
  Future<String?> getFpId(String data);
  Future<String?> getVendorId(String data);
  Future<String?> getDeviceId(String data);

  Future<String?> sendID3(String data);

}
