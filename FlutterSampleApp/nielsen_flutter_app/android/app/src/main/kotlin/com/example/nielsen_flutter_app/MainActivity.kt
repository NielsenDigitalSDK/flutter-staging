package com.example.nielsen_flutter_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        // You'll need to ensure NielsenFlutterPlugin() is accessible here.
        // If it's a custom plugin, make sure the import statement is correct.
        flutterEngine.plugins.add(NielsenFlutterPlugin())
    }
}