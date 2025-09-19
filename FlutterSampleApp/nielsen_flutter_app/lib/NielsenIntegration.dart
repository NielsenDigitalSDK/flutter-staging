import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NielsenIntegration extends StatefulWidget {
  const NielsenIntegration({super.key});

  @override
  State<NielsenIntegration> createState() => _NielsenIntegrationState();
}

class _NielsenIntegrationState extends State<NielsenIntegration> {
  static const MethodChannel _nielsenChannel =
  MethodChannel('com.example.nielsen/AppSdk');

  // State variables to hold results and status messages
  String _instanceId = '';
  String _optOutUrl = '';
  String _meterVersion = '';
  bool _appDisableStatus = false;
  String _optOutStatus = '';
  String _demographicId = '';
  String _nielsenId = '';
  String _debugMessage = '';
  String _suspendMessage = '';
  String _backgroundMessage = '';
  String _foregroundMessage = '';
  String _freeMessage = '';
  String _appDisableApiResult = '';
  String _staticEndResult = '';
  String _updateOTTResult = '';
  String _endResult = '';
  String _stopResult = '';
  String _setPlayheadPositionResult = '';
  String _sendID3Result = '';
  String _loadMetadataResult = '';
  String _playResult = '';

  // --- Nielsen SDK Instance Management ---

  Future<void> _createInstance() async {
    try {
      const Map<String, dynamic> config = {
        'appid': 'TF2D48D99-9B58-B05C-E040-070AAB3176DB',
        'nol_devDebug': 'DEBUG',
        'uid2' : 'MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=',
        'uid2_token' : 'AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==',
        'hem_sha256' : '0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea',
        'hem_sha1' : 'FA92088EB2E94C2B71B98C423DA3C0B1F10AA211',
        'hem_md5' : 'D5F252F907B95001D7BAB577AE1A514C',
        'hem_unknown' : 'unknown'
      // Add other necessary configuration parameters
      };
      final Map<dynamic, dynamic>? result =
      await _nielsenChannel.invokeMethod('createInstance', config);
      if (mounted) {
        setState(() {
          _instanceId = result?['id'] ?? 'Failed to create instance.';
        });
      }
      debugPrint('Nielsen Instance ID: $_instanceId');
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _instanceId = 'Error creating instance: ${e.message}';
        });
      }
      debugPrint('Error creating Nielsen instance: ${e.message}');
    }
  }

  Future<void> _removeInstance() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('removeInstance', _instanceId);
        if (mounted) {
          setState(() {
            _instanceId = 'Instance removed.';
          });
        }
        debugPrint('Nielsen Instance removed: $_instanceId');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _instanceId = 'Error removing instance: ${e.message}';
          });
        }
        debugPrint('Error removing Nielsen instance: ${e.message}');
      }
    } else {
      debugPrint('No valid Nielsen instance to remove.');
    }
  }

  bool _isValidInstanceId() {
    return _instanceId.isNotEmpty &&
        _instanceId != 'Failed to create instance.' &&
        _instanceId != 'Instance removed.';
  }


  // --- Nielsen SDK Configuration ---

  Future<void> _appDisableApi(bool disabled) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('appDisableApi', {
          'id': _instanceId,
          'disabled': disabled,
        });
        if (mounted) {
          setState(() {
            _appDisableApiResult =
            'App disable API call successful (disabled: $disabled).';
          });
        }
        debugPrint('App disable API call successful (disabled: $disabled).');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _appDisableApiResult = 'Error calling appDisableApi: ${e.message}';
          });
        }
        debugPrint('Error calling appDisableApi: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _appDisableApiResult = 'No valid Nielsen instance for appDisableApi.';
        });
      }
      debugPrint('No valid Nielsen instance for appDisableApi.');
    }
  }

  Future<void> _userOptOutURLString() async {
    if (_isValidInstanceId()) {
      try {
        final String? url =
        await _nielsenChannel.invokeMethod('userOptOutURLString', _instanceId);
        if (mounted) {
          setState(() {
            _optOutUrl = url ?? 'Could not retrieve opt-out URL.';
          });
        }
        debugPrint('Opt-out URL: $_optOutUrl');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _optOutUrl = 'Error retrieving opt-out URL: ${e.message}';
          });
        }
        debugPrint('Error retrieving opt-out URL: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _optOutUrl = 'No valid Nielsen instance to get opt-out URL.';
        });
      }
      debugPrint('No valid Nielsen instance to get opt-out URL.');
    }
  }

  Future<void> _getOptOutStatus() async {
    if (_isValidInstanceId()) {
      try {
        final String? status =
        await _nielsenChannel.invokeMethod('getOptOutStatus', _instanceId);
        if (mounted) {
          setState(() {
            _optOutStatus = status ?? 'Could not retrieve opt-out status.';
          });
        }
        debugPrint('Opt-out Status: $_optOutStatus');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _optOutStatus = 'Error retrieving opt-out status: ${e.message}';
          });
        }
        debugPrint('Error retrieving opt-out status: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _optOutStatus = 'No valid Nielsen instance to get opt-out status.';
        });
      }
      debugPrint('No valid Nielsen instance to get opt-out status.');
    }
  }

  Future<void> _getNielsenId() async {
    if (_isValidInstanceId()) {
      try {
        final String? nielsenId =
        await _nielsenChannel.invokeMethod('getNielsenId', _instanceId);
        if (mounted) {
          setState(() {
            _nielsenId = nielsenId ?? 'Could not retrieve Nielsen ID.';
          });
        }
        debugPrint('Nielsen ID: $_nielsenId');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _nielsenId = 'Error retrieving Nielsen ID: ${e.message}';
          });
        }
        debugPrint('Error retrieving Nielsen ID: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _nielsenId = 'No valid Nielsen instance to get Nielsen ID.';
        });
      }
      debugPrint('No valid Nielsen instance to get Nielsen ID.');
    }
  }

  Future<void> _getDemographicId() async {
    if (_isValidInstanceId()) {
      try {
        final String? demographicId =
        await _nielsenChannel.invokeMethod('getDemographicId', _instanceId);
        if (mounted) {
          setState(() {
            _demographicId =
                demographicId ?? 'Could not retrieve Demographic ID.';
          });
        }
        debugPrint('Demographic ID: $_demographicId');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _demographicId = 'Error retrieving Demographic ID: ${e.message}';
          });
        }
        debugPrint('Error retrieving Demographic ID: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _demographicId = 'No valid Nielsen instance to get Demographic ID.';
        });
      }
      debugPrint('No valid Nielsen instance to get Demographic ID.');
    }
  }

  Future<void> _getMeterVersion() async {
    try {
      final String? version =
      await _nielsenChannel.invokeMethod('getMeterVersion');
      if (mounted) {
        setState(() {
          _meterVersion = version ?? 'Could not retrieve Meter Version.';
        });
      }
      debugPrint('Meter Version: $_meterVersion');
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _meterVersion = 'Error retrieving Meter Version: ${e.message}';
        });
      }
      debugPrint('Error retrieving Meter Version: ${e.message}');
    }
  }

  Future<void> _getAppDisable() async {
    if (_isValidInstanceId()) {
      try {
        final bool? disabled =
        await _nielsenChannel.invokeMethod('getAppDisable', _instanceId);
        if (mounted) {
          setState(() {
            _appDisableStatus = disabled ?? false;
          });
        }
        debugPrint('App Disable Status: $_appDisableStatus');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _appDisableStatus = false;
            debugPrint('Error retrieving App Disable status: ${e.message}');
          });
        }
        debugPrint('Error retrieving App Disable status: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _appDisableStatus = false;
        });
      }
      debugPrint('No valid Nielsen instance to get App Disable status.');
    }
  }

  Future<void> _setDebug(String debugState) async {
    try {
      await _nielsenChannel.invokeMethod('setDebug', debugState);
      if (mounted) {
        setState(() {
          _debugMessage = 'Debug mode set to: $debugState';
        });
      }
      debugPrint('Debug mode set to: $debugState');
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _debugMessage = 'Error setting debug mode: ${e.message}';
        });
      }
      debugPrint('Error setting debug mode: ${e.message}');
    }
  }

  // --- Nielsen SDK Lifecycle Management ---

  Future<void> _suspend() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('suspend', _instanceId);
        if (mounted) {
          setState(() {
            _suspendMessage = 'Nielsen SDK suspended.';
          });
        }
        debugPrint('Nielsen SDK suspended.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _suspendMessage = 'Error suspending Nielsen SDK: ${e.message}';
          });
        }
        debugPrint('Error suspending Nielsen SDK: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _suspendMessage = 'No valid Nielsen instance to suspend.';
        });
      }
      debugPrint('No valid Nielsen instance to suspend.');
    }
  }

  Future<void> _appInBackground() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('appInBackground', _instanceId);
        if (mounted) {
          setState(() {
            _backgroundMessage = 'App went to background (Nielsen notified).';
          });
        }
        debugPrint('App went to background (Nielsen notified).');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _backgroundMessage =
            'Error notifying Nielsen about background: ${e.message}';
          });
        }
        debugPrint('Error notifying Nielsen about background: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _backgroundMessage =
          'No valid Nielsen instance to notify background.';
        });
      }
      debugPrint('No valid Nielsen instance to notify background.');
    }
  }

  Future<void> _appInForeground() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('appInForeground', _instanceId);
        if (mounted) {
          setState(() {
            _foregroundMessage = 'App went to foreground (Nielsen notified).';
          });
        }
        debugPrint('App went to foreground (Nielsen notified).');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _foregroundMessage =
            'Error notifying Nielsen about foreground: ${e.message}';
          });
        }
        debugPrint('Error notifying Nielsen about foreground: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _foregroundMessage =
          'No valid Nielsen instance to notify foreground.';
        });
      }
      debugPrint('No valid Nielsen instance to notify foreground.');
    }
  }

  Future<void> _free() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('free', _instanceId);
        if (mounted) {
          setState(() {
            _instanceId = '';
            _freeMessage = 'Nielsen SDK instance freed.';
          });
        }
        debugPrint('Nielsen SDK instance freed.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _freeMessage = 'Error freeing Nielsen SDK instance: ${e.message}';
          });
        }
        debugPrint('Error freeing Nielsen SDK instance: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _freeMessage = 'No valid Nielsen instance to free.';
        });
      }
      debugPrint('No valid Nielsen instance to free.');
    }
  }

  Future<void> _staticEnd() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('staticEnd', _instanceId);
        if (mounted) {
          setState(() {
            _staticEndResult = 'Static end call successful.';
          });
        }
        debugPrint('Static end call successful.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _staticEndResult = 'Error calling staticEnd: ${e.message}';
          });
        }
        debugPrint('Error calling staticEnd: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _staticEndResult = 'No valid instance to call staticEnd';
        });
      }
      debugPrint('No valid instance to call staticEnd');
    }
  }

  Future<void> _updateOTT(Map<String, dynamic> ottData) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('updateOTT', {
          'id': _instanceId,
          'ottData': ottData,
        });
        if (mounted) {
          setState(() {
            _updateOTTResult = 'Update OTT call successful.';
          });
        }
        debugPrint('Update OTT call successful.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _updateOTTResult = 'Error calling updateOTT: ${e.message}';
          });
        }
        debugPrint('Error calling updateOTT: ${e.message}');
      }
    } else {
      if (mounted) {
        setState(() {
          _updateOTTResult = 'No valid instance to call updateOTT';
        });
      }
      debugPrint('No valid instance to call updateOTT');
    }
  }

  Future<void> _end() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('end', _instanceId);
        if (mounted) {
          setState(() {
            _endResult = 'End call successful';
          });
        }
        debugPrint('End call successful');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _endResult = 'Error on end call: ${e.message}';
          });
        }
        debugPrint('Error on end call: ${e.message}');
      }
    } else {
      setState(() {
        _endResult = 'No valid instance to call end';
      });
      debugPrint('No valid instance to call end');
    }
  }

  Future<void> _stop() async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('stop', _instanceId);
        if (mounted) {
          setState(() {
            _stopResult = 'Stop call successful';
          });
        }
        debugPrint('Stop call successful');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _stopResult = 'Error on stop call: ${e.message}';
          });
        }
        debugPrint('Error on stop call: ${e.message}');
      }
    } else {
      setState(() {
        _stopResult = 'No valid instance to call stop';
      });
      debugPrint('No valid instance to call stop');
    }
  }

  Future<void> _setPlayheadPosition(int playheadPosition) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('setPlayheadPosition', {
          'id': _instanceId,
          'playheadPosition': playheadPosition,
        });
        if (mounted) {
          setState(() {
            _setPlayheadPositionResult =
            'Set playhead position successful: $playheadPosition';
          });
        }
        debugPrint('Set playhead position successful: $playheadPosition');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _setPlayheadPositionResult =
            'Error calling setPlayheadPosition: ${e.message}';
          });
        }
        debugPrint('Error calling setPlayheadPosition: ${e.message}');
      }
    } else {
      setState(() {
        _setPlayheadPositionResult =
        'No valid instance to call setPlayheadPosition';
      });
      debugPrint('No valid instance to call setPlayheadPosition');
    }
  }

  Future<void> _sendID3(String payload) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('sendID3', {
          'id': _instanceId,
          'payload': payload,
        });
        if (mounted) {
          setState(() {
            _sendID3Result = 'Send ID3 call successful.';
          });
        }
        debugPrint('Send ID3 call successful.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _sendID3Result = 'Error calling sendID3: ${e.message}';
          });
        }
        debugPrint('Error calling sendID3: ${e.message}');
      }
    } else {
      setState(() {
        _sendID3Result = 'No valid instance to call sendID3';
      });
      debugPrint('No valid instance to call sendID3');
    }
  }

  Future<void> _loadMetadata(Map<String, dynamic> metadata) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('loadMetadata', {
          'id': _instanceId,
          'metadata': metadata,
        });
        if (mounted) {
          setState(() {
            _loadMetadataResult = 'Load metadata call successful.';
          });
        }
        debugPrint('Load metadata call successful.');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _loadMetadataResult = 'Error calling loadMetadata: ${e.message}';
          });
        }
        debugPrint('Error calling loadMetadata: ${e.message}');
      }
    } else {
      setState(() {
        _loadMetadataResult = 'No valid instance to call loadMetadata';
      });
      debugPrint('No valid instance to call loadMetadata');
    }
  }

  Future<void> _play(Map<String, dynamic> metadata) async {
    if (_isValidInstanceId()) {
      try {
        await _nielsenChannel.invokeMethod('play', {
          'id': _instanceId,
          'metadata': metadata
        });
        if (mounted) {
          setState(() {
            _playResult = 'Play call successful';
          });
        }
        debugPrint('Play call successful');
      } on PlatformException catch (e) {
        if (mounted) {
          setState(() {
            _playResult = 'Error on play call: ${e.message}';
          });
        }
        debugPrint('Error on play call: ${e.message}');
      }
    } else {
      setState(() {
        _playResult = 'No valid instance to call play';
      });
      debugPrint('No valid instance to call play');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nielsen SDK Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Instance ID: $_instanceId'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createInstance,
              child: const Text('Create Nielsen Instance'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _removeInstance,
              child: const Text('Remove Nielsen Instance'),
            ),
            const SizedBox(height: 20),
            const Text('App Disable API:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_appDisableApiResult),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _appDisableApi(true),
                  child: const Text('Disable App'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _appDisableApi(false),
                  child: const Text('Enable App'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Opt-out URL: $_optOutUrl'),
            ElevatedButton(
              onPressed: _userOptOutURLString,
              child: const Text('Get Opt-out URL'),
            ),
            const SizedBox(height: 10),
            Text('Opt-out Status: $_optOutStatus'),
            ElevatedButton(
              onPressed: _getOptOutStatus,
              child: const Text('Get Opt-out Status'),
            ),
            const SizedBox(height: 10),
            Text('Nielsen ID: $_nielsenId'),
            ElevatedButton(
              onPressed: _getNielsenId,
              child: const Text('Get Nielsen ID'),
            ),
            const SizedBox(height: 10),
            Text('Demographic ID: $_demographicId'),
            ElevatedButton(
              onPressed: _getDemographicId,
              child: const Text('Get Demographic ID'),
            ),
            const SizedBox(height: 10),
            Text('Meter Version: $_meterVersion'),
            ElevatedButton(
              onPressed: _getMeterVersion,
              child: const Text('Get Meter Version'),
            ),
            const SizedBox(height: 10),
            Text('App Disable Status: $_appDisableStatus'),
            ElevatedButton(
              onPressed: _getAppDisable,
              child: const Text('Get App Disable Status'),
            ),
            const SizedBox(height: 10),
            Text('Debug Status: $_debugMessage'),
            ElevatedButton(
              onPressed: () => _setDebug('1'),
              child: const Text('Set Debug On'),
            ),
            ElevatedButton(
              onPressed: () => _setDebug('0'),
              child: const Text('Set Debug Off'),
            ),
            const SizedBox(height: 10),
            Text('Suspend Status: $_suspendMessage'),
            ElevatedButton(
              onPressed: _suspend,
              child: const Text('Suspend Nielsen SDK'),
            ),
            const SizedBox(height: 10),
            Text('Background Status: $_backgroundMessage'),
            ElevatedButton(
              onPressed: _appInBackground,
              child: const Text('App In Background'),
            ),
            const SizedBox(height: 10),
            Text('Foreground Status: $_foregroundMessage'),
            ElevatedButton(
              onPressed: _appInForeground,
              child: const Text('App In Foreground'),
            ),
            const SizedBox(height: 10),
            Text('Free Status: $_freeMessage'),
            ElevatedButton(
              onPressed: _free,
              child: const Text('Free Nielsen Instance'),
            ),
            const SizedBox(height: 20),
            Text('Static End: $_staticEndResult'),
            ElevatedButton(
              onPressed: _staticEnd,
              child: const Text('Invoke Static End'),
            ),
            const SizedBox(height: 20),
            Text('Update OTT: $_updateOTTResult'),
            ElevatedButton(
              onPressed: () {
                // Example OTT data
                const Map<String, dynamic> ottData = {
                  'provider': 'Sample Provider',
                  'program': 'Sample Program',
                  'channel': 'Sample Channel',
                };
                _updateOTT(ottData);
              },
              child: const Text('Update OTT'),
            ),
            const SizedBox(height: 20),
            Text('End: $_endResult'),
            ElevatedButton(
              onPressed: _end,
              child: const Text('End'),
            ),
            const SizedBox(height: 20),
            Text('Stop: $_stopResult'),
            ElevatedButton(
              onPressed: _stop,
              child: const Text('Stop'),
            ),
            const SizedBox(height: 20),
            Text('Set Playhead Position: $_setPlayheadPositionResult'),
            ElevatedButton(
              onPressed: () {
                _setPlayheadPosition(120); // Example position
              },
              child: const Text('Set Playhead Position'),
            ),
            const SizedBox(height: 20),
            Text('Send ID3: $_sendID3Result'),
            ElevatedButton(
              onPressed: () {
                _sendID3('Sample ID3 Payload');
              },
              child: const Text('Send ID3'),
            ),
            const SizedBox(height: 20),
            Text('Load Metadata: $_loadMetadataResult'),
            ElevatedButton(
              onPressed: () {
                // Example metadata
                const Map<String, dynamic> metadata = {
                  'title': 'Sample Title',
                  'episode': 'Sample Episode',
                  'season': 1,
                };
                _loadMetadata(metadata);
              },
              child: const Text('Load Metadata'),
            ),
            const SizedBox(height: 20),
            Text('Play: $_playResult'),
            ElevatedButton(
              onPressed: () {
                // Example metadata
                const Map<String, dynamic> metadata = {
                  'title': 'Sample Title',
                  'episode': 'Sample Episode',
                  'season': 1,
                };
                _play(metadata);
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}