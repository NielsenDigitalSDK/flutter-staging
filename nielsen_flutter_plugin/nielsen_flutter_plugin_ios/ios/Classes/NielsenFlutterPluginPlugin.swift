import Flutter
import UIKit
import NielsenAppApi
public class NielsenFlutterPluginPlugin: NSObject, FlutterPlugin {
    var sdk: NielsenAppApi?
    var eventSink: FlutterEventSink?

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var asset: AVAsset?
    private var metadataOutput: AVPlayerItemMetadataOutput?
    
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
              self.sdk = NielsenAppApi(appInfo:convertedObject, delegate:nil)
              if let result = result as FlutterResult? {
                  result("created app sdk instance")
              }
          }
          
      case "loadMetadata":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              self.sdk?.loadMetadata(convertedObject)
              if let result = result as FlutterResult? {
                  result("load metadata called successfully ")
              }
          }
          
      case "play":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              self.sdk?.play(convertedObject)
              if let result = result as FlutterResult? {
                  result("play called successfully")
                  
              }
          }
          
      case "stop":
          self.sdk?.stop()
          if let result = result as FlutterResult? {
              result("Stop API called successfully")
          }
          
      case "end":
          self.sdk?.end()
          if let result = result as FlutterResult? {
              result("End API called successfully")
          }
          
      case "setPlayheadPosition":
          guard let args = call.arguments as? String else { return }
          if let ph = Int(args) {
              self.sdk?.playheadPosition(Int64(ph))
              if let result = result as FlutterResult? {
                  result("\(ph)")
              }
          }
          
      case "getDemographicId":
          let demographicId = self.sdk?.demographicId as String?
          if let result = result as FlutterResult?, let demoId = demographicId {
              result(demoId)
              
          }
          
      case "getOptOutStatus":
          guard let sdk = self.sdk else { return }
          let optoutStatus = sdk.optOutStatus ? "true" : "false"
          if let result = result as FlutterResult? {
              result(optoutStatus)
          }
          
      case "userOptOutURLString":
          let userOptOutURLString = self.sdk?.optOutURL as String?
          if let result = result as FlutterResult? {
              result(userOptOutURLString)
              
          }
          
      case "getMeterVersion":
          let meterVersion = self.sdk?.meterVersion as String?
          if let result = result as FlutterResult? {
              result(meterVersion)
              
          }
          
      case "staticEnd":
          self.sdk?.staticEnd()
          if let result = result as FlutterResult? {
              result("static end API called succesfully")
              
          }
          
      case "free":
          if self.sdk != nil {
              self.sdk = nil
          }
          
      case "sendID3":
          if let args = call.arguments as? String, let convertedObject = self.jsonStringToDictionary(jsonString: args) {
              self.sdk?.sendID3(args)
              if let result = result as FlutterResult? {
                  result("sendID3 metadata called successfully ")
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
                        print("[SDK] SendID3: \(id3Data)")
                        self.sdk?.sendID3(id3Data)
                    }
                }
            }
        }
    }
}

extension NielsenFlutterPluginPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        let urlString = arguments as! String
        startPlaybackWithTimedMetadata(url: urlString)
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

//        player?.play()
        
    }
    
}
