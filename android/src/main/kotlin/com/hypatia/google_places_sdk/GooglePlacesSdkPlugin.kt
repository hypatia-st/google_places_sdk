package com.hypatia.google_places_sdk

import android.app.Activity
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.net.FetchPlaceRequest
import com.google.android.libraries.places.api.net.PlacesClient

/** GooglePlacesSdkPlugin */
public class GooglePlacesSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  lateinit var mActivity: Activity
  lateinit var mPlacesClient: PlacesClient
  private var mResult: Result? = null
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "google_places_sdk")
    channel.setMethodCallHandler(this);
  }

  constructor() {
  }

  override fun onAttachedToActivity(@NonNull activityPluginBinding: ActivityPluginBinding) {
    mActivity = activityPluginBinding.activity;
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(@NonNull activityPluginBinding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "google_places_sdk")
      channel.setMethodCallHandler(GooglePlacesSdkPlugin().apply {
        mActivity = registrar.activity()
      })
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    mResult = result
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method.equals("initialize")) {
      initialize(call.argument("androidApiKey"))
    } else if (call.method.equals("getPlaceById")) {
      getPlaceById(call.argument("placeId"))
    } else {
      result.notImplemented()
    }
  }

  fun getPlaceById(placeId: String?) {
    if (placeId.isNullOrEmpty()) {
      mResult?.error("PLACE_ID_ERROR", "Invalid Place ID", null)
      return
    }
    try {
      val request = FetchPlaceRequest.builder(placeId!!, listOf(Place.Field.ID, Place.Field.NAME, Place.Field.ADDRESS, Place.Field.LAT_LNG)).build()
      mPlacesClient.fetchPlace(request).addOnSuccessListener { response ->
        val place = response.place;
        val placeMap = mutableMapOf<String, Any>()
        placeMap.put("latitude", place.latLng?.latitude ?: 0.0)
        placeMap.put("longitude", place.latLng?.longitude ?: 0.0)
        placeMap.put("id", place.id ?: "")
        placeMap.put("name", place.name ?: "")
        placeMap.put("address", place.address ?: "")
        mResult?.success(placeMap)
      }.addOnFailureListener {e: Exception ->
        mResult?.error("API_KEY_ERROR", e.localizedMessage, null)
      }
    } catch (e: Exception) {
      mResult?.error("API_KEY_ERROR", e.localizedMessage, null)
    }
  }

  fun initialize(apiKey: String?) {
      if (apiKey.isNullOrEmpty()) {
          mResult?.error("API_KEY_ERROR", "Invalid Android API Key", null)
          return
      }
      try {
          if (!Places.isInitialized()) {
              Places.initialize(mActivity.applicationContext, apiKey!!);
              mPlacesClient = Places.createClient(mActivity);
          }
          mResult?.success(null)
      } catch (e: Exception) {
          mResult?.error("API_KEY_ERROR", e.localizedMessage, null)
      }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
