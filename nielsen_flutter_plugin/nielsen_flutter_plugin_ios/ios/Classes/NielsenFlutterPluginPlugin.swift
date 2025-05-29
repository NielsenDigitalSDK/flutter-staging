import Flutter
import UIKit
import NielsenAppApi
public class NielsenFlutterPluginPlugin: NSObject, FlutterPlugin {
//    var sdk: NielsenAppApi?
    var eventSink: FlutterEventSink?

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var asset: AVAsset?
    private var metadataOutput: AVPlayerItemMetadataOutput?
    
    private var nlsSDKs: [String:NielsenAppApi]? = [:]
    private var sdkIdForSendID3: String? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nielsen_flutter_plugin_ios", binaryMessenger: registrar.messenger())
    let instance = NielsenFlutterPluginPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
        
        // setup event channel
      let metadataChannel = FlutterEventChannel(name: "id3_timed_metadata", binaryMessenger: registrar.messenger())
      metadataChannel.setStreamHandler(instance)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "createInstance":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              var bridgedInfo = convertedObject
              let sdk_id: String = String(format: "%lli", CUnsignedLongLong(Date().timeIntervalSince1970 * 1000))
              print("sdk instances before sdk init \(self.nlsSDKs)")
              bridgedInfo["nol_playerid"] = sdk_id
              let sdk = NielsenAppApi(appInfo:bridgedInfo, delegate:nil)
              if sdk != nil {
                  self.nlsSDKs?[sdk_id] = sdk
              }
              print("sdk instances \(self.nlsSDKs)")
              if let result = result as FlutterResult? {
                  result(sdk_id)
              }
          }
          
      case "loadMetadata":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              if let sdkId = convertedObject["sdkId"] as? String, let metadata = convertedObject["metadata"] as? [String: Any] {
                  if let sdk = self.nlsSDKs, sdk[sdkId] != nil {
                      sdk[sdkId]?.loadMetadata(metadata)
                  }
              }
                            
              if let result = result as FlutterResult? {
                  result("load metadata called successfully ")
              }
          }
          
      case "play":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              if let sdkId = convertedObject["sdkId"] as? String, let playData = convertedObject["playdata"] as? [String: Any] {
                  if let sdk = self.nlsSDKs, sdk[sdkId] != nil {
                      sdk[sdkId]?.play(playData)
                  }
              }
              if let result = result as FlutterResult? {
                  result("play called successfully")
                  
              }
          }
          
      case "stop":
          player?.pause()
          if let args = call.arguments as? String,let convertedObject = self.jsonStringToDictionary(jsonString: args), let sdkId = convertedObject["sdkId"] as? String {
              if let sdk = self.nlsSDKs, sdk[sdkId] != nil {
                  sdk[sdkId]?.stop()
              }
          }
                    
          if let result = result as FlutterResult? {
              result("Stop API called successfully")
          }
          
      case "end":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args), let sdkId = convertedObject["sdkId"] as? String {
              if let sdk = self.nlsSDKs, sdk[sdkId] != nil {
                  sdk[sdkId]?.end()
              }
          }

          if let result = result as FlutterResult? {
              result("End API called successfully")
          }
          
      case "setPlayheadPosition":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, let playhead = convertedObject["position"] as? String {
              if let sdk = self.nlsSDKs, sdk[sdkId] != nil, let ph = Int64(playhead) {
                  sdk[sdkId]?.playheadPosition(ph)
                  if let result = result as FlutterResult? {
                      result("\(ph)")
                  }
              }
              
          }
          
      case "getDemographicId":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String {
              if let sdk = self.nlsSDKs, sdk[sdkId] != nil{
                  let demographicId = sdk[sdkId]?.demographicId as String?
                  if let result = result as FlutterResult?, let demoId = demographicId {
                      result("\(demoId)")
                  }
              }
              
          }

          
      case "getOptOutStatus":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil {
              if let optoutStatus = sdk[sdkId]?.optOutStatus {
                    if let result = result as FlutterResult? {
                        result(optoutStatus ? "true" : "false")
                    }
              }
          }
                    
      case "userOptOutURLString":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil, let optOutURL = sdk[sdkId]?.optOutURL {
                    if let result = result as FlutterResult? {
                        result(optOutURL)
                    }
          }
          
      case "getMeterVersion":
          print("call. args \(call.arguments)")
          print("all sdks \(nlsSDKs)")
          guard let args = call.arguments as? String,
                let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return result("data not available")}
          if let sdkId = convertedObject["sdkId"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil, let meterVersion = sdk[sdkId]?.meterVersion {
            if let result = result as FlutterResult? {
                result(meterVersion)
            }
          }

          
      case "getDeviceId":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil, let deviceId = sdk[sdkId]?.deviceId {
                if let result = result as FlutterResult? {
                    result(deviceId)
                }
          }


          
      case "staticEnd":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return result("N/A") }
          if let sdkId = convertedObject["sdkId"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil {
              sdk[sdkId]?.staticEnd()
                if let result = result as FlutterResult? {
                    result("static end API called succesfully")
                }
          }

      case "free":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, var sdk = self.nlsSDKs, sdk[sdkId] != nil {
              sdk[sdkId] = nil
                
          }
          
      case "sendID3":
          guard let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) else { return }
          if let sdkId = convertedObject["sdkId"] as? String, let id3 = convertedObject["sendID3"] as? String, let sdk = self.nlsSDKs, sdk[sdkId] != nil {
              sdk[sdkId]?.sendID3(id3)
                if let result = result as FlutterResult? {
                    result("sendID3 metadata called successfully")
                }
          }

      default:
          result("iOS")
      }
      
      
  }
    
    func jsonStringToDictionary(jsonString: String) -> [String: Any]? {
// 1. Convert the JSON string to Data.
    guard let data = jsonString.data(using: .utf8) else {
        print("Error: Invalid JSON string")
        return nil
    }

    // 2. Use JSONSerialization to convert the Data to a JSON object.
    //    The JSON object can be a Dictionary or an Array.
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        // 3. Cast the JSON object to a Dictionary.
        //    If the JSON string represents an array, this cast will fail.
        guard let dictionary = jsonObject as? [String: Any] else {
            print("Error: JSON is not a Dictionary")
            return nil
        }
        
        return dictionary
    } catch {
        // 4. Handle any errors that occur during the serialization process.
        print("Error: \(error.localizedDescription)")
        return nil
    }
}
    
}

// ID3 extraction from timedmetadata
extension NielsenFlutterPluginPlugin: AVPlayerItemMetadataOutputPushDelegate {
    public func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                        didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                        from track: AVPlayerItemTrack?) {
        for group in groups {
            for item in group.items {
                if let identifier = item.identifier?.rawValue, let value = item.value(forKey: "value") {
                    if let id3Data = item.extraAttributes?[AVMetadataExtraAttributeKey.info] as? String {
                        if let sdkId = self.sdkIdForSendID3, let sdk = self.nlsSDKs?[sdkId] {
                            print("[NielsenFlutterPlugin] SendID3: \(id3Data)")
                            sdk.sendID3(id3Data)
                        }
                    }
                }
            }
        }
    }
}

extension NielsenFlutterPluginPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let arguments = arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: arguments) else { return nil }
        self.eventSink = events
        sdkIdForSendID3 = convertedObject["sdkId"] as? String
        if let urlString = convertedObject["url"] as? String {
            startPlaybackWithTimedMetadata(url: urlString)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    private func startPlaybackWithTimedMetadata(url: String) {
        guard let url = URL(string: url) else { return }

        asset = AVAsset(url: url)
        playerItem = AVPlayerItem(asset: asset!)
        player = AVPlayer(playerItem: playerItem)
        metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil) // Specify identifiers if needed
        metadataOutput?.setDelegate(self, queue: DispatchQueue.main)
        playerItem?.add(metadataOutput!) // Add the metadata output

        player?.play()
        
    }
    
}
