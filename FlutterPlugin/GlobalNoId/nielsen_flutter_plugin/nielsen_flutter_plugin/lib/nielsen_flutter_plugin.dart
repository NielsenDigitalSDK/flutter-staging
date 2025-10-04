import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

/// Nielsen App SDK – Flutter Public APIs.
class NielsenFlutterPlugin {
  NielsenFlutterPlugin._();
  static final NielsenFlutterPlugin instance = NielsenFlutterPlugin._();

  NielsenFlutterPluginPlatform get _p => NielsenFlutterPluginPlatform.instance;

  bool _debugLogging = false;

  /// Enable/disable debug logging of raw native responses.
  void enableDebugLogs(bool enable) {
    _debugLogging = enable;
  }

  void _logDebug(String api, String? res) {
    if (_debugLogging) {
      debugPrint('[NielsenFlutterPlugin] $api → $res');
    }
  }

  // ----------------------------------------------------------------------
  // Instance lifecycle
  // ----------------------------------------------------------------------

  /// Creates a Nielsen SDK instance with the provided app info.
  /// Returns the generated sdkId string.
  Future<String?> createInstance(Map<String, dynamic> appInfo) async {
    final res = await _p.createInstance(jsonEncode(appInfo));
    _logDebug('createInstance', res);
    return res;
  }

  /// Releases a previously created Nielsen SDK instance.
  Future<void> free(String sdkId) async {
    final res = await _p.free(jsonEncode({'sdkId': sdkId}));
    _logDebug('free', res);
  }

  // ----------------------------------------------------------------------
  // Playback lifecycle and metadata
  // ----------------------------------------------------------------------

  /// Signals playback start and passes play metadata.
  Future<void> play(String sdkId, Map<String, dynamic> playData) async {
    final res =
        await _p.play(jsonEncode({'sdkId': sdkId, 'playdata': playData}));
    _logDebug('play', res);
  }

  /// Loads content/ad/static metadata into the active measurement session.
  Future<void> loadMetadata(String sdkId, Map<String, dynamic> metadata) async {
    final res = await _p
        .loadMetadata(jsonEncode({'sdkId': sdkId, 'metadata': metadata}));
    _logDebug('loadMetadata', res);
  }

  /// Notifies a temporary stop/pause/interruption in playback.
  Future<void> stop(String sdkId) async {
    final res = await _p.stop(jsonEncode({'sdkId': sdkId}));
    _logDebug('stop', res);
  }

  /// Ends the playback measurement session.
  Future<void> end(String sdkId) async {
    final res = await _p.end(jsonEncode({'sdkId': sdkId}));
    _logDebug('end', res);
  }

  /// Ends a static content session (if used in your workflow).
  Future<void> staticEnd(String sdkId) async {
    final res = await _p.staticEnd(jsonEncode({'sdkId': sdkId}));
    _logDebug('staticEnd', res);
  }

  /// Updates the playhead position (in seconds).
  Future<void> setPlayheadPosition(String sdkId, int positionSeconds) async {
    final res = await _p.setPlayheadPosition(
      jsonEncode({'sdkId': sdkId, 'position': '$positionSeconds'}),
    );
    _logDebug('setPlayheadPosition', res);
  }

  /// Reporting OTT update event to the SDK.
  Future<void> updateOTT(String sdkId, Map<String, dynamic> ottData) async {
    final res =
        await _p.updateOTT(jsonEncode({'sdkId': sdkId, 'ottData': ottData}));
    _logDebug('updateOTT', res);
  }

  // ----------------------------------------------------------------------
  // Timed metadata (ID3)
  // ----------------------------------------------------------------------

  /// Sends ID3 timed metadata to the SDK.
  Future<void> sendID3(String sdkId, String id3) async {
    final res = await _p.sendID3(jsonEncode({'sdkId': sdkId, 'sendID3': id3}));
    _logDebug('sendID3', res);
  }

  // ----------------------------------------------------------------------
  // Information / getters
  // ----------------------------------------------------------------------

  /// Returns opt-out status as a string ("true"/"false").
  Future<String?> getOptOutStatus(String sdkId) async {
    final res = await _p.getOptOutStatus(jsonEncode({'sdkId': sdkId}));
    _logDebug('getOptOutStatus', res);
    return res;
  }

  /// Returns the user opt-out URL string.
  Future<String?> userOptOutURLString(String sdkId) async {
    final res = await _p.userOptOutURLString(jsonEncode({'sdkId': sdkId}));
    _logDebug('userOptOutURLString', res);
    return res;
  }

  /// Returns the meter version string.
  Future<String?> getMeterVersion(String sdkId) async {
    final res = await _p.getMeterVersion(jsonEncode({'sdkId': sdkId}));
    _logDebug('getMeterVersion', res);
    return res;
  }

  /// Returns the demographicId string.
  Future<String?> getDemographicId(String sdkId) async {
    final res = await _p.getDemographicId(jsonEncode({'sdkId': sdkId}));
    _logDebug('getDemographicId', res);
    return res;
  }

  /// Returns the deviceId string.
  Future<String?> getDeviceId(String sdkId) async {
    final res = await _p.getDeviceId(jsonEncode({'sdkId': sdkId}));
    _logDebug('getDeviceId', res);
    return res;
  }

  /// Returns the vendorId string (if implemented natively).
  Future<String?> getVendorId(String sdkId) async {
    final res = await _p.getVendorId(jsonEncode({'sdkId': sdkId}));
    _logDebug('getVendorId', res);
    return res;
  }

  /// Returns the FPID string (if implemented natively).
  Future<String?> getFpId(String sdkId) async {
    final res = await _p.getFpId(jsonEncode({'sdkId': sdkId}));
    _logDebug('getFpid', res);
    return res;
  }
}
