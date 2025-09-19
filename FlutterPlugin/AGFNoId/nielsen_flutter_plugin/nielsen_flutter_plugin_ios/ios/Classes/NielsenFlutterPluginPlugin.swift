import Flutter
import UIKit
import AVFoundation
import NielsenAppApi

    /// Flutter plugin bridging Dart <-> Nielsen iOS SDK.
public class NielsenFlutterPluginPlugin: NSObject, FlutterPlugin {
    
        // MARK: - Channels / State
    
    private var eventSink: FlutterEventSink?
    private var nlsSDKs: [String: NielsenAppApi] = [:]
    
        // AVFoundation
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var asset: AVAsset?
    private var metadataOutput: AVPlayerItemMetadataOutput?
    
    private var sdkIdForSendID3: String?
    
        // MARK: - Threading
    
    private let sdkQueue = DispatchQueue(label: "com.nielsen.flutterplugin.sdkQueue")
    
    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
    private func onSDK(_ block: @escaping () -> Void) {
        sdkQueue.async(execute: block)
    }
    
        // MARK: - Nielsen error codes
    
    private enum NlsErr {
        static let jsonInvalid       = "NLS_JSON_INVALID"
        static let argsMissing       = "NLS_ARGS_MISSING"
        static let sdkNotFound       = "NLS_SDK_NOT_FOUND"
        static let initFailed        = "NLS_INIT_FAILED"
        static let methodUnsupported = "NLS_METHOD_UNSUPPORTED"
        static let playheadInvalid   = "NLS_PLAYHEAD_INVALID"
    }
    
    private func okMain(_ result: @escaping FlutterResult, _ value: Any? = "ok") {
        onMain { result(value) }
    }
    private func failMain(_ result: @escaping FlutterResult, _ code: String, _ msg: String, _ details: Any? = nil) {
        onMain { result(FlutterError(code: code, message: msg, details: details)) }
    }
    
        // MARK: - Registration
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "nielsen_flutter_plugin_ios",
            binaryMessenger: registrar.messenger()
        )
        let instance = NielsenFlutterPluginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let metadataChannel = FlutterEventChannel(
            name: "id3_timed_metadata",
            binaryMessenger: registrar.messenger()
        )
        metadataChannel.setStreamHandler(instance)
    }
    
        // MARK: - Method channel entry
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        case "createInstance":
            onSDK { [weak self] in
                guard let self = self else { return }
                guard
                    let json = call.arguments as? String,
                    var info = self.jsonStringToDictionary(jsonString: json)
                else { return self.failMain(result, NlsErr.jsonInvalid, "Invalid JSON") }
                
                let sdkId = String(format: "%lli", CUnsignedLongLong(Date().timeIntervalSince1970 * 1000))
                info["nol_playerid"] = sdkId
                info["inttype"] = "f"
                
                if let sdk = NielsenAppApi(appInfo: info, delegate: nil) {
                    self.nlsSDKs[sdkId] = sdk
                    self.okMain(result, sdkId)
                } else {
                    self.failMain(result, NlsErr.initFailed, "NielsenAppApi init returned nil")
                }
            }
            
        case "loadMetadata":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdkAndArgs(call: call, result: result) { sdk, obj in
                    guard let metadata = obj["metadata"] as? [String: Any] else {
                        return self.failMain(result, NlsErr.argsMissing, "Missing 'metadata'")
                    }
                    sdk.loadMetadata(metadata)
                    self.okMain(result, "Load metadata called successfully")
                }
            }
            
        case "play":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdkAndArgs(call: call, result: result) { sdk, obj in
                    guard let playData = obj["playdata"] as? [String: Any] else {
                        return self.failMain(result, NlsErr.argsMissing, "Missing 'playdata'")
                    }
                    sdk.play(playData)
                    self.okMain(result, "Play called successfully")
                }
            }
            
        case "stop":
            onMain { [weak self] in self?.player?.pause() }
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    sdk.stop()
                    self.okMain(result, "Stop API called successfully")
                }
            }
            
        case "end":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    sdk.end()
                    self.okMain(result, "End API called successfully")
                }
            }
            
        case "setPlayheadPosition":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdkAndArgs(call: call, result: result) { sdk, obj in
                    guard let posStr = obj["position"] as? String, let ph = Int64(posStr) else {
                        return self.failMain(result, NlsErr.playheadInvalid, "Missing/invalid 'position'")
                    }
                    sdk.playheadPosition(ph)
                    self.okMain(result, "\(ph)")
                }
            }
            
        case "getDemographicId":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    self.okMain(result, sdk.demographicId)
                }
            }
            
        case "getOptOutStatus":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    self.okMain(result, sdk.optOutStatus ? "true" : "false")
                }
            }
            
        case "userOptOutURLString":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    self.okMain(result, sdk.optOutURL)
                }
            }
            
        case "getMeterVersion":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    self.okMain(result, sdk.meterVersion)
                }
            }
            
        case "getDeviceId":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    self.okMain(result, sdk.deviceId)
                }
            }
            
        case "staticEnd":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdk(call: call, result: result) { sdk in
                    sdk.staticEnd()
                    self.okMain(result, "Static end API called successfully")
                }
            }
            
        case "sendID3":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdkAndArgs(call: call, result: result) { sdk, obj in
                    guard let id3 = obj["sendID3"] as? String else {
                        return self.failMain(result, NlsErr.argsMissing, "Missing 'sendID3'")
                    }
                    sdk.sendID3(id3)
                    self.okMain(result, "SendID3 metadata called successfully")
                }
            }
            
        case "free":
            onSDK { [weak self] in
                guard let self = self else { return }
                self.withSdkAndArgs(call: call, result: result) { _, obj in
                    guard let sdkId = obj["sdkId"] as? String else {
                        return self.failMain(result, NlsErr.argsMissing, "Missing 'sdkId'")
                    }
                    self.nlsSDKs[sdkId] = nil
                    self.okMain(result, "Freed")
                }
            }
            
        default:
            failMain(result, NlsErr.methodUnsupported, "Method '\(call.method)' not implemented")
        }
    }
    
        // MARK: - JSON helper
    
    private func jsonStringToDictionary(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            return obj as? [String: Any]
        } catch {
            print("[NielsenFlutterPlugin] JSON error: \(error.localizedDescription)")
            return nil
        }
    }
    
        // MARK: - Argument helpers
    
    private func withSdk(
        call: FlutterMethodCall,
        result: @escaping FlutterResult,
        _ block: (NielsenAppApi) -> Void
    ) {
        guard
            let json = call.arguments as? String,
            let obj = self.jsonStringToDictionary(jsonString: json)
        else { return failMain(result, NlsErr.jsonInvalid, "Invalid JSON") }
        
        guard let sdkId = obj["sdkId"] as? String else {
            return failMain(result, NlsErr.argsMissing, "Missing 'sdkId'")
        }
        guard let sdk = self.nlsSDKs[sdkId] else {
            return failMain(result, NlsErr.sdkNotFound, "Unknown sdkId: \(sdkId)")
        }
        block(sdk)
    }
    
    private func withSdkAndArgs(
        call: FlutterMethodCall,
        result: @escaping FlutterResult,
        _ block: (_ sdk: NielsenAppApi, _ obj: [String: Any]) -> Void
    ) {
        guard
            let json = call.arguments as? String,
            let obj = self.jsonStringToDictionary(jsonString: json)
        else { return failMain(result, NlsErr.jsonInvalid, "Invalid JSON") }
        
        guard let sdkId = obj["sdkId"] as? String else {
            return failMain(result, NlsErr.argsMissing, "Missing 'sdkId'")
        }
        guard let sdk = self.nlsSDKs[sdkId] else {
            return failMain(result, NlsErr.sdkNotFound, "Unknown sdkId: \(sdkId)")
        }
        block(sdk, obj)
    }
}

    // MARK: - Timed metadata forwarding

extension NielsenFlutterPluginPlugin: AVPlayerItemMetadataOutputPushDelegate {
    public func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                               didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                               from track: AVPlayerItemTrack?) {
        for group in groups {
            for item in group.items {
                if let id3Data = item.extraAttributes?[AVMetadataExtraAttributeKey.info] as? String,
                   let sdkId = self.sdkIdForSendID3 {
                    onSDK { [weak self] in
                        guard let self = self, let sdk = self.nlsSDKs[sdkId] else { return }
                        print("[NielsenFlutterPlugin] SendID3: \(id3Data)")
                        sdk.sendID3(id3Data)
                    }
                }
            }
        }
    }
}

    // MARK: - Event stream & AV setup

extension NielsenFlutterPluginPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        onMain { [weak self] in self?.eventSink = events }
        guard
            let argStr = arguments as? String,
            let obj = self.jsonStringToDictionary(jsonString: argStr)
        else { return nil }
        sdkIdForSendID3 = obj["sdkId"] as? String
        if let urlString = obj["url"] as? String {
            startPlaybackWithTimedMetadata(url: urlString)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        onMain { [weak self] in self?.eventSink = nil }
        return nil
    }
    
    private func startPlaybackWithTimedMetadata(url: String) {
        onMain { [weak self] in
            guard let self = self, let u = URL(string: url) else { return }
            self.asset = AVAsset(url: u)
            self.playerItem = AVPlayerItem(asset: self.asset!)
            self.player = AVPlayer(playerItem: self.playerItem)
            let output = AVPlayerItemMetadataOutput(identifiers: nil)
            output.setDelegate(self, queue: DispatchQueue.main)
            self.metadataOutput = output
            self.playerItem?.add(output)
            self.player?.play()
        }
    }
}
