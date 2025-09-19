package com.example.nielsen_flutter_app

import android.content.Context
import android.util.Log
import androidx.media3.common.MediaItem
import androidx.media3.common.Metadata
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.extractor.metadata.id3.PrivFrame
import com.nielsen.app.sdk.AppSdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class NielsenFlutterPlugin : FlutterPlugin, MethodCallHandler,EventChannel.StreamHandler {
    private var applicationContext: Context? = null
    private var methodChannel: MethodChannel? = null
    private var appSdk: AppSdk? = null // Single instance model
    private var id3EventSink: EventChannel.EventSink? = null
    private var exoPlayer: ExoPlayer? = null
    private var id3EventChannel: EventChannel? = null // Initialize in onAttachedToEngine


    companion object {
        private const val TAG = "NielsenFlutterPlugin"
        private const val CHANNEL_NAME = "NielsenAndroidAppSDK"
        private const val ID3_EVENT_CHANNEL_NAME = "id3_timed_metadata" // Channel for ID3 events
        private const val ID3_LENGTH: Int = 249

    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        val messenger: BinaryMessenger = flutterPluginBinding.binaryMessenger

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        Log.d(TAG, "NielsenFlutterPlugin attached to engine. Channel: $CHANNEL_NAME")

        id3EventChannel = EventChannel(messenger, ID3_EVENT_CHANNEL_NAME)
        id3EventChannel?.setStreamHandler(this) // 'this' will handle ID3 stream events
        Log.d(TAG, "NielsenFlutterPlugin ID3 EventChannel attached. Channel: $ID3_EVENT_CHANNEL_NAME")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "NielsenFlutterPlugin detached from engine.")
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        id3EventChannel?.setStreamHandler(null)
        id3EventChannel = null
        releaseExoPlayer() // Clean up ExoPlayer

        appSdk?.close() // Close the SDK instance if it exists
        appSdk = null
        applicationContext = null
    }

    //region JSON Helper Utilities
    private fun jsonStringToMap(jsonString: String?): Map<String, Any>? {
        if (jsonString == null) return null
        return try {
            val jsonObject = JSONObject(jsonString)
            toMap(jsonObject)
        } catch (e: JSONException) {
            Log.e(TAG, "Error parsing JSON string to Map: $jsonString", e)
            null
        }
    }

    private fun toMap(jsonObj: JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = jsonObj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            var value: Any = jsonObj.get(key)
            if (value is JSONObject) {
                value = toMap(value)
            } else if (value is JSONArray) {
                value = toList(value)
            } else if (value == JSONObject.NULL) {
                // Let JSONObject.NULL be added; consumer must handle or convert if actual null is needed.
            }
            map[key] = value
        }
        return map
    }

    private fun toList(array: JSONArray): List<Any> {
        val list = mutableListOf<Any>()
        for (i in 0 until array.length()) {
            var value: Any = array.get(i)
            if (value is JSONObject) {
                value = toMap(value)
            } else if (value is JSONArray) {
                value = toList(value)
            }
            list.add(value)
        }
        return list
    }

    @Suppress("UNCHECKED_CAST")
    @Throws(JSONException::class)
    private fun convertMapToJSONObject(map: Map<String, Any>): JSONObject {
        val jsonObject = JSONObject()
        for ((key, value) in map) {
            when (value) {
                is Map<*, *> -> jsonObject.put(key, convertMapToJSONObject(value as Map<String, Any>))
                is List<*> -> jsonObject.put(key, convertListToJsonArray(value as List<Any>))
                JSONObject.NULL -> jsonObject.put(key, JSONObject.NULL)
                else -> jsonObject.put(key, value)
            }
        }
        return jsonObject
    }

    @Suppress("UNCHECKED_CAST")
    @Throws(JSONException::class)
    private fun convertListToJsonArray(list: List<Any>): JSONArray {
        val jsonArray = JSONArray()
        for (item in list) {
            when (item) {
                is Map<*, *> -> jsonArray.put(convertMapToJSONObject(item as Map<String, Any>))
                is List<*> -> jsonArray.put(convertListToJsonArray(item as List<Any>))
                JSONObject.NULL -> jsonArray.put(JSONObject.NULL)
                else -> jsonArray.put(item)
            }
        }
        return jsonArray
    }
    //endregion

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            Log.d(TAG, "Method call: ${call.method} with arguments: ${call.arguments}")
            val currentAppSdk = appSdk

            when (call.method) {
                "createInstance" -> {
                    val jsonStringArgs = call.arguments as? String
                    if (jsonStringArgs != null) {
                        val appInfoMap = jsonStringToMap(jsonStringArgs)
                        if (appInfoMap != null) {
                            createNielsenInstance(appInfoMap, result)
                        } else {
                            result.error("INVALID_JSON", "Failed to parse JSON arguments for createInstance", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Arguments for createInstance must be a JSON string", null)
                    }
                }
                "loadMetadata" -> {
                    val jsonStringArgs = call.arguments as? String
                    if (jsonStringArgs != null) {
                        val metadataMap = jsonStringToMap(jsonStringArgs)
                        if (metadataMap != null) {
                            loadMetadata(currentAppSdk, metadataMap, result)
                        } else {
                            result.error("INVALID_JSON", "Failed to parse JSON arguments for loadMetadata", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Arguments for loadMetadata must be a JSON string", null)
                    }
                }
                "play" -> {
                    val jsonStringArgs = call.arguments as? String
                    if (jsonStringArgs != null) {
                        val playParamsMap = jsonStringToMap(jsonStringArgs)
                        if (playParamsMap != null) {
                            play(currentAppSdk, playParamsMap, result)
                        } else {
                            result.error("INVALID_JSON", "Failed to parse JSON arguments for play", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Arguments for play must be a JSON string", null)
                    }
                }
                "stop" -> stop(currentAppSdk, result)
                "end" -> end(currentAppSdk, result)
                "setPlayheadPosition" -> {
                    val playheadPositionStr = call.arguments as? String
                    if (playheadPositionStr != null) {
                        try {
                            val ph = playheadPositionStr.toLong()
                            setPlayheadPosition(currentAppSdk, ph, result)
                        } catch (e: NumberFormatException) {
                            result.error("INVALID_ARGUMENT_FORMAT", "Playhead position must be a string representing a number.", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "Argument for setPlayheadPosition must be a string.", null)
                    }
                }
                "free" -> freeInstance(result)
                "getDemographicId" -> getDemographicId(currentAppSdk, result)
                "getOptOutStatus" -> getNielsenOptOutStatus(currentAppSdk, result)
                "userOptOutURLString" -> getUserOptOutURLString(currentAppSdk, result)
                "getMeterVersion" -> getMeterVersion(result) // No 'sdk' instance needed for static call
                "staticEnd" -> staticEnd(currentAppSdk, result)
                "sendID3" -> {
                    val payload = call.argument<String>("payload")
                    sendID3(currentAppSdk, payload, result)
                }
                "appDisableApi" -> {
                    val disabled = call.argument<Boolean>("disabled")
                    if (disabled != null) {
                        appDisableNielsenApi(currentAppSdk, disabled, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Boolean 'disabled' argument is required for appDisableApi.", null)
                    }
                }
                "getNielsenId" -> getNielsenSDKId(currentAppSdk, result)
                "getAppDisable" -> getNielsenAppDisable(currentAppSdk, result)
                "setDebug" -> {
                    val debugArg = call.arguments<String>()
                    if (debugArg != null && debugArg.isNotEmpty()) {
                        setNielsenDebug(debugArg[0], result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Debug argument (string character) is required for setDebug.", null)
                    }
                }
                "suspend" -> suspendNielsen(currentAppSdk, result)
                "appInBackground" -> nielsenAppInBackground(currentAppSdk, result)
                "appInForeground" -> nielsenAppInForeground(currentAppSdk, result)
                "updateOTT" -> {
                    val jsonStringArgs = call.argument<String>("ottData")
                    if (jsonStringArgs != null) {
                        val ottDataMap = jsonStringToMap(jsonStringArgs)
                        if (ottDataMap != null) {
                            updateOTT(currentAppSdk, ottDataMap, result)
                        } else {
                            result.error("INVALID_JSON", "Failed to parse JSON for ottData.", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENTS", "JSON string 'ottData' argument is required for updateOTT.", null)
                    }
                }
                "extractID3Tags" -> { // This is your existing method, presumably for local files
                    val filePath = call.arguments as? String
                    if (filePath != null) {
                        extractID3Tags(filePath, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "File path for ID3 extraction must be a string", null)
                    }
                }
                else -> {
                    Log.w(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during method call: ${call.method}", e)
            result.error("NATIVE_ERROR", "Exception in onMethodCall: ${e.message}", e.localizedMessage)
        }
    }


    //region SDK Method Implementations
    private fun createNielsenInstance(appInfo: Map<String, Any>, result: Result) {
        val currentContext = applicationContext
        if (currentContext == null) {
            result.error("CONTEXT_NULL", "Application context is null, cannot create Nielsen instance.", null)
            return
        }
        if (appSdk != null) {
            Log.w(TAG, "Nielsen SDK instance already exists. Closing previous one before creating new.")
            appSdk?.close()
        }
        try {
            val appSdkConfig = convertMapToJSONObject(appInfo)
            Log.d(TAG, "Attempting to create Nielsen SDK instance with config: $appSdkConfig")
            appSdk = AppSdk(currentContext, appSdkConfig, null)

            if (appSdk?.isValid == true) {
                Log.i(TAG, "Nielsen SDK instance created successfully.")
                result.success("created app sdk instance ")
            } else {
                Log.e(TAG, "Nielsen SDK instance creation failed. isValid: ${appSdk?.isValid}")
                // If Nielsen SDK AppSdk class has a method to get error details, use it here.
                // For now, using a generic message or null for details.
                val errorDetails = "SDK initialization failed; isValid is false." // Corrected line
                appSdk = null
                result.error("SDK_INIT_FAILED", "Nielsen SDK instance creation failed.", errorDetails)
            }
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error during createInstance", e)
            result.error("JSON_ERROR", "Error converting appInfo to JSON: ${e.message}", null)
        } catch (e: Exception) { // Catch potential exceptions from AppSdk constructor
            Log.e(TAG, "Exception during Nielsen SDK instance creation", e)
            appSdk = null // Ensure appSdk is null if constructor threw
            result.error("INSTANCE_CREATION_ERROR", "Failed to create Nielsen SDK instance: ${e.message}", null)
        }
    }

    private fun loadMetadata(sdk: AppSdk?, metadata: Map<String, Any>, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for loadMetadata.", null)
            return
        }
        try {
            val contentMetadata = convertMapToJSONObject(metadata)
            sdk.loadMetadata(contentMetadata)
            Log.d(TAG, "loadMetadata called with: $contentMetadata")
            result.success("load metadata called successfully ")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in loadMetadata", e)
            result.error("JSON_ERROR", "Error converting metadata to JSON: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in loadMetadata", e)
            result.error("NATIVE_ERROR", "Error in loadMetadata: ${e.message}", null)
        }
    }

    private fun play(sdk: AppSdk?, playParams: Map<String, Any>, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for play.", null)
            return
        }
        try {
            val channelInfo = convertMapToJSONObject(playParams)
            sdk.play(channelInfo)
            Log.d(TAG, "play called with: $channelInfo")
            result.success("play called successfully")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in play", e)
            result.error("JSON_ERROR", "Error converting play parameters to JSON: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in play", e)
            result.error("NATIVE_ERROR", "Error in play: ${e.message}", null)
        }
    }

    private fun stop(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for stop.", null)
            return
        }
        try {
            sdk.stop()
            Log.d(TAG, "stop API called.")
            result.success("Stop API called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in stop", e)
            result.error("NATIVE_ERROR", "Error in stop: ${e.message}", null)
        }
    }

    private fun end(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for end.", null)
            return
        }
        try {
            sdk.end()
            Log.d(TAG, "end API called.")
            result.success("End API called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in end", e)
            result.error("NATIVE_ERROR", "Error in end: ${e.message}", null)
        }
    }

    private fun setPlayheadPosition(sdk: AppSdk?, playheadPos: Long, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for setPlayheadPosition.", null)
            return
        }
        try {
            sdk.setPlayheadPosition(playheadPos)
            Log.d(TAG, "setPlayheadPosition called with: $playheadPos")
            result.success("$playheadPos")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in setPlayheadPosition", e)
            result.error("NATIVE_ERROR", "Error in setPlayheadPosition: ${e.message}", null)
        }
    }

    private fun freeInstance(result: Result) {
        if (appSdk != null) {
            Log.d(TAG, "Freeing Nielsen SDK instance.")
            appSdk?.close()
            appSdk = null
            result.success("free called successfully")
        } else {
            Log.d(TAG, "Free called but no Nielsen SDK instance to free.")
            result.success("No instance to free")
        }
    }

    private fun getDemographicId(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for getDemographicId.", null)
            return
        }
        try {
            val demographicId = sdk.demographicId
            Log.d(TAG, "getDemographicId returning: $demographicId")
            result.success(demographicId)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getDemographicId", e)
            result.error("NATIVE_ERROR", "Error in getDemographicId: ${e.message}", null)
        }
    }

    private fun getNielsenOptOutStatus(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for getOptOutStatus.", null)
            return
        }
        try {
            val optOut = sdk.optOutStatus
            Log.d(TAG, "getOptOutStatus returning: $optOut")
            result.success(if (optOut) "true" else "false")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getOptOutStatus", e)
            result.error("NATIVE_ERROR", "Error in getOptOutStatus: ${e.message}", null)
        }
    }

    private fun getUserOptOutURLString(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for userOptOutURLString.", null)
            return
        }
        try {
            val optOutUrl = sdk.userOptOutURLString()
            Log.d(TAG, "userOptOutURLString returning: $optOutUrl")
            result.success(optOutUrl)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in userOptOutURLString", e)
            result.error("NATIVE_ERROR", "Error in userOptOutURLString: ${e.message}", null)
        }
    }

    private fun getMeterVersion(result: Result) {
        try {
            val version = AppSdk.getMeterVersion() // Corrected: Use static method
            Log.d(TAG, "getMeterVersion (static) returning: $version")
            result.success(version)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getMeterVersion", e)
            result.error("NATIVE_ERROR", "Error in getMeterVersion: ${e.message}", null)
        }
    }

    private fun staticEnd(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for staticEnd.", null)
            return
        }
        try {
            sdk.staticEnd()
            Log.d(TAG, "staticEnd API called.")
            result.success("static end API called succesfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in staticEnd", e)
            result.error("NATIVE_ERROR", "Error in staticEnd: ${e.message}", null)
        }
    }

    private fun sendID3(sdk: AppSdk?, payload: String?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for sendID3.", null)
            return
        }
        if (payload == null) {
            result.error("INVALID_ARGUMENTS", "Payload for sendID3 cannot be null.", null)
            return
        }
        try {
            sdk.sendID3(payload)
            Log.d(TAG, "sendID3 called with payload: $payload")
            result.success("sendID3 called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in sendID3", e)
            result.error("NATIVE_ERROR", "Error in sendID3: ${e.message}", null)
        }
    }

    private fun appDisableNielsenApi(sdk: AppSdk?, disabled: Boolean, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for appDisableApi.", null)
            return
        }
        try {
            sdk.appDisableApi(disabled)
            Log.d(TAG, "appDisableNielsenApi called with disabled: $disabled")
            result.success("appDisableApi called successfully with: $disabled")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in appDisableNielsenApi", e)
            result.error("NATIVE_ERROR", "Error in appDisableNielsenApi: ${e.message}", null)
        }
    }

    private fun getNielsenSDKId(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for getNielsenId.", null)
            return
        }
        try {
            val nielsenId = sdk.nielsenId
            Log.d(TAG, "getNielsenId returning: $nielsenId")
            result.success(nielsenId)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getNielsenId", e)
            result.error("NATIVE_ERROR", "Error in getNielsenId: ${e.message}", null)
        }
    }

    private fun getNielsenAppDisable(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for getAppDisable.", null)
            return
        }
        try {
            val appDisableStatus = sdk.appDisable
            Log.d(TAG, "getAppDisable returning: $appDisableStatus")
            result.success(appDisableStatus)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getAppDisable", e)
            result.error("NATIVE_ERROR", "Error in getAppDisable: ${e.message}", null)
        }
    }

    private fun setNielsenDebug(debugState: Char, result: Result) {
        try {
            AppSdk.setDebug(debugState)
            Log.d(TAG, "setNielsenDebug called with state: $debugState")
            result.success("setDebug called successfully with: $debugState")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in setNielsenDebug", e)
            result.error("NATIVE_ERROR", "Error in setNielsenDebug: ${e.message}", null)
        }
    }

    private fun suspendNielsen(sdk: AppSdk?, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for suspend.", null)
            return
        }
        try {
            sdk.suspend()
            Log.d(TAG, "suspendNielsen called.")
            result.success("suspend called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in suspendNielsen", e)
            result.error("NATIVE_ERROR", "Error in suspendNielsen: ${e.message}", null)
        }
    }

    private fun nielsenAppInBackground(sdk: AppSdk?, result: Result) {
        val currentContext = applicationContext
        if (sdk == null || currentContext == null) {
            result.error(
                if (sdk == null) "SDK_NOT_INITIALIZED" else "CONTEXT_NULL",
                "Nielsen SDK or Context not available for appInBackground.",
                null
            )
            return
        }
        try {
            sdk.appInBackground(currentContext)
            Log.d(TAG, "nielsenAppInBackground called.")
            result.success("appInBackground called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in nielsenAppInBackground", e)
            result.error("NATIVE_ERROR", "Error in nielsenAppInBackground: ${e.message}", null)
        }
    }

    private fun nielsenAppInForeground(sdk: AppSdk?, result: Result) {
        val currentContext = applicationContext
        if (sdk == null || currentContext == null) {
            result.error(
                if (sdk == null) "SDK_NOT_INITIALIZED" else "CONTEXT_NULL",
                "Nielsen SDK or Context not available for appInForeground.",
                null
            )
            return
        }
        try {
            sdk.appInForeground(currentContext)
            Log.d(TAG, "nielsenAppInForeground called.")
            result.success("appInForeground called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in nielsenAppInForeground", e)
            result.error("NATIVE_ERROR", "Error in nielsenAppInForeground: ${e.message}", null)
        }
    }

    private fun updateOTT(sdk: AppSdk?, ottData: Map<String, Any>, result: Result) {
        if (sdk == null) {
            result.error("SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for updateOTT.", null)
            return
        }
        try {
            val ottJSONObject = convertMapToJSONObject(ottData)
            sdk.updateOTT(ottJSONObject)
            Log.d(TAG, "updateOTT called with: $ottJSONObject")
            result.success("updateOTT called successfully")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in updateOTT", e)
            result.error("JSON_ERROR", "Error converting OTT data to JSON: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in updateOTT", e)
            result.error("NATIVE_ERROR", "Error in updateOTT: ${e.message}", null)
        }
    }

    private fun extractID3Tags(filePath: String, result: Result) {
        // Assuming ID3Extractor.extractID3Tags(filePath) exists and works for local files
        try {
            // val id3Tags = ID3Extractor.extractID3Tags(filePath)
            // Log.d(TAG, "Extracted ID3 tags (local file): $id3Tags")
            // result.success(id3Tags) // Return the HashMap to Flutter
            Log.w(TAG, "extractID3Tags for local files might need a separate ID3Extractor implementation.")
            result.notImplemented() // Placeholder if not fully implemented here
        } catch (e: Exception) {
            Log.e(TAG, "Error extracting ID3 tags from local file: $filePath", e)
            result.error("ID3_EXTRACTION_ERROR", "Failed to extract ID3 tags (local file): ${e.message}", e.localizedMessage)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "EventChannel.onListen called for '$ID3_EVENT_CHANNEL_NAME'. Raw arguments: '$arguments'")

        this.id3EventSink = events
        if (arguments is String) {
            val urlString = arguments
            if (urlString.isNotEmpty())
            {
                Log.d(TAG, "EventChannel.onListen: Received URL string: '$urlString'") // <--- LOG 5
                startPlaybackWithTimedMetadata(urlString)
            }
            else
            {
                Log.e(TAG, "EventChannel.onListen: Received an EMPTY URL string.")
                id3EventSink?.error("INVALID_ARGUMENTS", "Received an empty URL string.", null)
            }
        } else {
            Log.e(TAG, "EventChannel.onListen: Arguments are NOT a String or are null. Type: ${arguments?.javaClass?.name}") // <--- LOG 6
            id3EventSink?.error("INVALID_ARGUMENTS", "URL string expected. Received: ${arguments?.javaClass?.name}", null)
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "EventChannel.onCancel called for '$ID3_EVENT_CHANNEL_NAME'. Arguments: '$arguments'") // <--- LOG
        this.id3EventSink = null
        releaseExoPlayer()
    }

    private fun startPlaybackWithTimedMetadata(urlString: String) {
        Log.d(TAG, "startPlaybackWithTimedMetadata called with URL: $urlString")
        val currentContext = applicationContext
        if (currentContext == null) {
            Log.e(TAG, "startPlaybackWithTimedMetadata: Application context is null!")
            id3EventSink?.error("CONTEXT_NULL", "Application context is null, cannot start playback.", null)
            return
        }
        releaseExoPlayer()

        try {
            exoPlayer = ExoPlayer.Builder(currentContext).build()
            val mediaItem = MediaItem.fromUri(urlString)
            exoPlayer?.setMediaItem(mediaItem)
            exoPlayer?.addListener(playerListener)
            exoPlayer?.prepare()
            exoPlayer?.playWhenReady = true // Start playback when ready
            Log.d(TAG, "ExoPlayer (Media3) preparing for URL: $urlString")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting ExoPlayer (Media3): ${e.message}", e)
            id3EventSink?.error("EXOPLAYER_ERROR", "Failed to start ExoPlayer (Media3): ${e.message}", null)
        }
    }


    private val playerListener = @UnstableApi
    object : Player.Listener {
        override fun onMetadata(metadata: Metadata)
        {
            Log.d("METADATA", metadata.toString())

            for (i in 0 until metadata.length())
            {
                val metadataEntry: Metadata.Entry = metadata[i]
                if (metadataEntry is PrivFrame) {
                    val privFrame: PrivFrame = metadataEntry
                    Log.d(TAG, "ID3 Metadata ${privFrame.owner}")

                    if (privFrame.owner.startsWith("www.nielsen.com") &&
                        privFrame.owner.length == ID3_LENGTH && appSdk != null)
                    {
                        Log.d(TAG, "ID3 Metadata final ${privFrame.owner}")
                        appSdk?.sendID3(privFrame.owner);
                        Log.d(TAG, "Successfully called sendID3 API call")
                    }
                } else {
                    Log.e(TAG, "onMetadata() - invalid id3Metadata received (entry was not PrivFrame)")
                }
            }
        }

        override fun onPlaybackStateChanged(playbackState: Int) {
            Log.d(TAG, "Player state changed (Media3): $playbackState")
        }

        override fun onPlayerError(error: androidx.media3.common.PlaybackException) {
            Log.e(TAG, "Player error (Media3): ${error.errorCodeName} - ${error.message}", error)
            id3EventSink?.error("EXOPLAYER_ERROR", "Player error: ${error.errorCodeName}", error.message)
        }
    }


    private fun releaseExoPlayer() {
        exoPlayer?.let { player ->
            Log.d(TAG, "Releasing ExoPlayer (Media3).")
            player.removeListener(playerListener)
            player.stop()
            player.release()
        }
        exoPlayer = null
    }
}
