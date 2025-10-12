package com.nielsen.appsdk.flutter.plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.Date

import com.nielsen.app.sdk.AppSdk

class NielsenFlutterPluginPlugin : FlutterPlugin, MethodCallHandler {
    private var applicationContext: Context? = null
    private var methodChannel: MethodChannel? = null
    private val appSdkInstanceMap: MutableMap<String, AppSdk?> = mutableMapOf()

    companion object {

        private const val CREATE_INSTANCE = "createInstance"
        private const val LOAD_METADATA = "loadMetadata"
        private const val PLAY = "play"
        private const val STOP = "stop"
        private const val END = "end"
        private const val SET_PLAYHEAD_POSITION = "setPlayheadPosition"
        private const val FREE = "free"
        private const val GET_DEMOGRAPHIC_ID = "getDemographicId"
        private const val GET_OPTOUT_STATUS = "getOptOutStatus"
        private const val USER_OPTOUT_URL_STRING = "userOptOutURLString"
        private const val GET_METER_VERSION = "getMeterVersion"
        private const val STATIC_END = "staticEnd"
        private const val SEND_ID3 = "sendID3"
        private const val GET_DEVICE_ID = "getDeviceId"
        private const val GET_FPID = "getFpId"
        private const val GET_VENDOR_ID = "getVendorId"
        private const val UPDATE_OTT = "updateOTT"
        private const val USER_OPTOUT = "userOptOut"
        private const val TAG = "NielsenFlutterPlugin"
        private const val CHANNEL_NAME = "nielsen_flutter_plugin_android"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        applicationContext = flutterPluginBinding.applicationContext

        val messenger: BinaryMessenger = flutterPluginBinding.binaryMessenger

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)

        Log.d(TAG, "NielsenFlutterPlugin attached to engine. Channel: $CHANNEL_NAME")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

        Log.d(TAG, "NielsenFlutterPlugin detached from engine.")

        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        closeAllAppSdkInstances() // Close all the sdk instances created so far

        applicationContext = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        try {
            Log.d(TAG, "Method call: ${call.method} with arguments: ${call.arguments}")

            val jsonString = call.arguments as? String
            val jsonStringObject = JSONObject(jsonString)

            var appSdk : AppSdk? = null

            if (jsonStringObject.has("sdkId")) {
                val appSdkId = jsonStringObject.getString("sdkId")
                appSdk = findAppSDKInstanceBySdkId(appSdkId)
            }

            when (call.method) {

                CREATE_INSTANCE -> {
                    if (jsonStringObject != null) {
                        createNielsenInstance(jsonStringObject, result)
                    } else {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Arguments for createInstance must be a JSON string",
                            null
                        )
                    }
                }

                LOAD_METADATA -> {
                    if (jsonStringObject != null) {
                        val metadataJSON = jsonStringObject.getJSONObject("metadata")
                        loadMetadata(appSdk, metadataJSON, result)
                    }
                }

                PLAY -> {
                    if (jsonStringObject != null) {
                        val playInfoJSON = jsonStringObject.getJSONObject("playdata")
                        play(appSdk, playInfoJSON, result)
                    }
                }

                STOP -> {
                    stop(appSdk, result)
                }

                END -> {
                    end(appSdk, result)
                }

                SET_PLAYHEAD_POSITION -> {
                    if (jsonStringObject != null) {
                        val playheadPosition = jsonStringObject.getLong("position")
                        setPlayheadPosition(appSdk, playheadPosition, result)
                    }
                }

                FREE -> freeInstance(appSdk, result)

                GET_DEMOGRAPHIC_ID -> {
                    getDemographicId(appSdk, result)
                }

                GET_OPTOUT_STATUS -> {
                    getNielsenOptOutStatus(appSdk, result)
                }

                USER_OPTOUT_URL_STRING -> {
                    getUserOptOutURLString(appSdk, result)
                }

                GET_METER_VERSION -> getMeterVersion(result)

                STATIC_END -> {
                    staticEnd(appSdk, result)
                }

                SEND_ID3 -> {
                    if (jsonStringObject != null) {
                        val payload = jsonStringObject.getString("sendID3")
                        sendID3(appSdk, payload, result)
                    }
                }

                GET_DEVICE_ID -> {
                    getNielsenDeviceId(appSdk, result)
                }

                GET_FPID -> {
                    getFirstPartyId(appSdk, result)
                }

                GET_VENDOR_ID -> {
                    getVendorId(appSdk, result)
                }

                UPDATE_OTT -> {
                    if (jsonStringObject != null) {
                        val ottDataJSON = jsonStringObject.getJSONObject("ottData")
                        updateOTT(appSdk, ottDataJSON, result)
                    }
                }

                USER_OPTOUT -> {
                    if (jsonStringObject != null) {
                        val userOptOutResponse = jsonStringObject.getString("url")
                        userOptout(appSdk, userOptOutResponse, result)
                    }
                }

                else -> {
                    Log.w(TAG, "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }
        catch (e: Exception) {
            Log.e(TAG, "Error during method call: ${call.method}", e)
            result.error("NATIVE_ERROR", "Exception in onMethodCall: ${e.message}", e.localizedMessage)
        }
    }

    private fun findAppSDKInstanceBySdkId(appsdkId: String?): AppSdk? {

        var appSdk: AppSdk? = null

        if (appsdkId != null && appsdkId.isNotEmpty() && appSdkInstanceMap.containsKey(appsdkId)) {
            appSdk = appSdkInstanceMap.get(appsdkId)
        } else {
            Log.e(TAG, "Unable to find the appropriate AppSDK instance w.r.t sdk id: ($appsdkId)")
        }

        return appSdk
    }

    //region SDK Method Implementations
    private fun createNielsenInstance(appInfo: JSONObject, result: Result) {

        if (applicationContext == null) {
            result.error("CONTEXT_NULL", "Application context is null, cannot create Nielsen AppSDK instance.", null)
            return
        }
        try {
            val appSdkId = Date().time.toString()
            val appSdkConfig = appInfo
            appSdkConfig.put("playerid", appSdkId)
            appSdkConfig.put("intType", "f")
            Log.d(TAG, "Attempting to create Nielsen AppSDK instance with config: $appSdkConfig")
            val appSdk = AppSdk(applicationContext, appSdkConfig, null)

            if (appSdk?.isValid == true) {
                Log.i(TAG, "Nielsen AppSDK instance created successfully with Sdk Id: $appSdkId")
                appSdkInstanceMap.put(appSdkId, appSdk)
                result.success(appSdkId)
            }
            else {
                Log.e(TAG, "Nielsen AppSDK instance creation failed! isValid: ${appSdk?.isValid}")
                // If Nielsen SDK AppSdk class has a method to get error details, use it here.
                // For now, using a generic message or null for details.
                val errorDetails = "Nielsen AppSDK initialization failed; isValid is false." // Corrected line
                //appSdk = null
                result.error("SDK_INIT_FAILED", "Nielsen AppSDK instance creation failed.", errorDetails)
            }
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error during createInstance", e)
            result.error("JSON_ERROR", "Error converting appInfo to JSON: ${e.message}", null)
        } catch (e: Exception) { // Catch potential exceptions from AppSdk constructor
            Log.e(TAG, "Exception during Nielsen AppSDK instance creation", e)
            result.error(
                "INSTANCE_CREATION_ERROR",
                "Failed to create Nielsen AppSDK instance: ${e.message}",
                null
            )
        }
    }

    private fun loadMetadata(sdk: AppSdk?, metadata: JSONObject, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen SDK instance not available for loadMetadata.", null
            )
            return
        }

        try {
            sdk.loadMetadata(metadata)
            Log.d(TAG, "loadMetadata called with: $metadata")
            result.success("load metadata called successfully ")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in loadMetadata", e)
            result.error("JSON_ERROR", "Error converting metadata to JSON: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in loadMetadata", e)
            result.error("NATIVE_ERROR", "Error in loadMetadata: ${e.message}", null)
        }
    }

    private fun play(sdk: AppSdk?, playInfo: JSONObject, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for play.", null
            )
            return
        }
        try {
            sdk.play(playInfo)
            Log.d(TAG, "play called with: $playInfo")
            result.success("play called successfully")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in play", e)
            result.error(
                "JSON_ERROR", "Error converting play parameters to JSON: ${e.message}", null
            )
        } catch (e: Exception) {
            Log.e(TAG, "Exception in play", e)
            result.error("NATIVE_ERROR", "Error in play: ${e.message}", null)
        }
    }
    private fun stop(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for stop.", null
            )
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
            result.error("SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for end.", null)
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

    private fun setPlayheadPosition(sdk: AppSdk?, playheadPosition: Long, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for setPlayheadPosition.",
                null
            )
            return
        }

        try {
            sdk.setPlayheadPosition(playheadPosition)
            Log.d(TAG, "setPlayheadPosition called with: $playheadPosition")
            result.success("$playheadPosition")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in setPlayheadPosition", e)
            result.error("NATIVE_ERROR", "Error in setPlayheadPosition: ${e.message}", null)
        }
    }

    private fun freeInstance(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "No Nielsen AppSDK instance available to free.",
                null
            )
            return
        }

        Log.d(TAG, "Freeing Nielsen SDK instance.")
        sdk.close()
        result.success("free called successfully")
    }

    private fun getDemographicId(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for getDemographicId.",
                null
            )
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
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for getOptOutStatus.",
                null
            )
            return
        }
        try {
            // Handle the method call on a background thread
            Thread {
                val optOut = sdk.optOutStatus
                Log.d(TAG, "getOptOutStatus returning: $optOut")
                result.success(if (optOut) "true" else "false")
            }.start()
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getOptOutStatus", e)
            result.error("NATIVE_ERROR", "Error in getOptOutStatus: ${e.message}", null)
        }
    }

    private fun getUserOptOutURLString(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for userOptOutURLString.",
                null
            )
            return
        }
        try {
            // Handle the method call on a background thread
            Thread {
                val optOutUrl = sdk.userOptOutURLString()
                Log.d(TAG, "userOptOutURLString returning: $optOutUrl")
                result.success(optOutUrl)
            }.start()
        } catch (e: Exception) {
            Log.e(TAG, "Exception in userOptOutURLString", e)
            result.error("NATIVE_ERROR", "Error in userOptOutURLString: ${e.message}", null)
        }
    }

    private fun getMeterVersion(result: Result) {

        try {
            val version = AppSdk.getMeterVersion()
            Log.d(TAG, "getMeterVersion (static) returning: $version")
            result.success(version)
        }
        catch (e: Exception) {
            Log.e(TAG, "Exception in getMeterVersion", e)
            result.error("NATIVE_ERROR", "Error in getMeterVersion: ${e.message}", null)
        }
    }

    private fun staticEnd(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for staticEnd.", null
            )
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
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for sendID3.", null
            )
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

    private fun getNielsenDeviceId(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for getDeviceId.", null
            )
            return
        }

        try {
            // Handle the method call on a background thread
            Thread {
                val deviceId = sdk.deviceId
                Log.d(TAG, "getDeviceId returning: $deviceId")
                result.success(deviceId)
            }.start()
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getDeviceId", e)
            result.error("NATIVE_ERROR", "Error in getDeviceId: ${e.message}", null)
        }
    }

    private fun getFirstPartyId(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for getFirstPartyId.",
                null
            )
            return
        }
        try {
            val firstPartyId = sdk.firstPartyId
            Log.d(TAG, "getFirstPartyId returning: $firstPartyId")
            result.success(firstPartyId)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getFirstPartyId", e)
            result.error("NATIVE_ERROR", "Error in getFirstPartyId: ${e.message}", null)
        }
    }

    private fun getVendorId(sdk: AppSdk?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED",
                "Nielsen AppSDK instance not available for getVendorId.",
                null
            )
            return
        }
        try {
            val vendorId = sdk.vendorId
            Log.d(TAG, "getVendorId returning: $vendorId")
            result.success(vendorId)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getVendorId", e)
            result.error("NATIVE_ERROR", "Error in getVendorId: ${e.message}", null)
        }
    }

    private fun updateOTT(sdk: AppSdk?, ottData: JSONObject, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for updateOTT.", null
            )
            return
        }

        try {
            sdk.updateOTT(ottData)
            Log.d(TAG, "updateOTT called with: $ottData")
            result.success("updateOTT called successfully")
        } catch (e: JSONException) {
            Log.e(TAG, "JSON conversion error in updateOTT", e)
            result.error("JSON_ERROR", "Error converting OTT data to JSON: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Exception in updateOTT", e)
            result.error("NATIVE_ERROR", "Error in updateOTT: ${e.message}", null)
        }
    }

    private fun userOptout(sdk: AppSdk?, userOptoutResponse: String?, result: Result) {

        if (sdk == null) {
            result.error(
                "SDK_NOT_INITIALIZED", "Nielsen AppSDK instance not available for userOptout.", null
            )
            return
        }
        if (userOptoutResponse == null) {
            result.error("INVALID_ARGUMENTS", "Payload for userOptout cannot be null.", null)
            return
        }
        try {
            sdk.userOptOut(userOptoutResponse)
            Log.d(TAG, "userOptout called with response: $userOptoutResponse")
            result.success("userOptout called successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Exception in userOptout", e)
            result.error("NATIVE_ERROR", "Error in userOptout: ${e.message}", null)
        }
    }

    private fun closeAllAppSdkInstances() {
        if (appSdkInstanceMap != null) {
                Log.d(TAG, "Found ${appSdkInstanceMap.size} AppSDK instance(s).")
                appSdkInstanceMap.forEach { (key, value) ->
                    Log.d(TAG, "Closing AppSDK instance with instance id ${key}.")
                    value?.close()
            }
            Log.d(TAG, "Removing ${appSdkInstanceMap.size} AppSDK instance(s) from internal AppSDK instance map.")
            appSdkInstanceMap.clear()
        }
    }
}