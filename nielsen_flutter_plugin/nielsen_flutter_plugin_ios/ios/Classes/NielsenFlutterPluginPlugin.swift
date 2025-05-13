import Flutter
import UIKit

public class NielsenFlutterPluginPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nielsen_flutter_plugin_ios", binaryMessenger: registrar.messenger())
    let instance = NielsenFlutterPluginPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS")
  }
}
