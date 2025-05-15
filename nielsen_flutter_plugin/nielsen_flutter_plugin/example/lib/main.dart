import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nielsen_flutter_plugin/nielsen_flutter_plugin.dart';
import 'package:nielsen_flutter_plugin_platform_interface/nielsen_flutter_plugin_platform_interface.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platformName;

  NielsenFlutterPluginPlatform? platform;

 var appInfo = (Platform.isAndroid) ? {"appid": "TF2D48D99-9B58-B05C-E040-070AAB3176DB", "nol_devDebug": "DEBUG", "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=", "uid2_token": "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==", "hem_sha256": "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea", "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211", "hem_md5": "D5F252F907B95001D7BAB577AE1A514C", "hem_unknown": "unknown"} :
      {"appid": "TFC984EC1-E044-B465-E040-070AAD3173A1", "nol_devDebug": "DEBUG", "uid2": "MTKVpUAzwYAPnHrtfE0wlINOMzhU7UUEjjVdCdRu63k=", "uid2_token": "AgAAAAPFR0zA5ogv/yaAPiUsAdZPsfqS8QlDSGxAB+rr8yekFs3AjLYVk5qqqiyV2XHbSuwzHmxSlLeQeKQI1mp015jsNnpX5/xGgXldcgVz+gFnyh3T8/3agMwRmyrhCxG4oH2C7fc48AQk2eotE7FW0ZDEYM8fD9ZxDaxFUC/OV3OuZA==", "hem_sha256": "0d27635fc9ca53b6aec32fbfb67d84c0c148857a74399f2ba0a21d8413db74ea", "hem_sha1": "FA92088EB2E94C2B71B98C423DA3C0B1F10AA211", "hem_md5": "D5F252F907B95001D7BAB577AE1A514C", "hem_unknown": "unknown"};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NielsenFlutterPlugin Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_platformName == null)
              const SizedBox.shrink()
            else
              Text(
                'Platform Name: $_platformName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                try {
                  final appInfoData = await NielsenFlutterPluginPlatform.instance.getAppInfo();
                  final result = await platform?.createInstance(appInfoData);
                  setState(() => _platformName = result);
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Get Platform Name'),
            ),
          ],
        ),
      ),
    );
  }
}
