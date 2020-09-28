package net.guyor.flutter_media_streamer

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.MediaStore
import android.util.Log
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.*

private const val READ_EXTERNAL_STORAGE_REQUEST = 0x1045
/** FlutterMediaStreamerPlugin */
public class FlutterMediaStreamerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var binding : FlutterPlugin.FlutterPluginBinding? = null
  private var activity : Activity? = null
  private val mainScope = CoroutineScope(Dispatchers.Main)
  private val serializer = Gson()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_media_streamer")
    binding = flutterPluginBinding
    channel.setMethodCallHandler(this)
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
      val channel = MethodChannel(registrar.messenger(), "flutter_media_streamer")
      channel.setMethodCallHandler(FlutterMediaStreamerPlugin())
    }
    @JvmStatic
    val ERR_CONTEXT = "CONTEXT_NOT_AVAIL"
    @JvmStatic
    val ERR_CONTEXT_MSG = "Application context is not available while calling method %s"
    private const val TAG = "FlutterMediaStreamer"
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getGalleryImages" -> getGalleryImages(result)
      "haveStoragePermission" -> result.success(haveStoragePermission())
      "requestStoragePermissions" -> requestStoragePermissions(result, timeout = call.argument<Int?>("timeout") as Int?)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    this.binding = null
    channel.setMethodCallHandler(null)
    print("FlutterMediaStreamerPlugin onDetachedFromEngine")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    print("FlutterMediaStreamerPlugin onAttachedToActivity")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    print("FlutterMediaStreamerPlugin onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    print("FlutterMediaStreamerPlugin onReattachedToActivityForConfigChanges")
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    print("FlutterMediaStreamerPlugin onDetachedFromActivity")
    activity = null
  }

  private fun requestStoragePermissions(@NonNull result: Result, timeout: Int? = 10) {
    if (haveStoragePermission()) {
      result.success(true)
      return
    } else {
      requestPermission()
    }
    var granted = false
    mainScope.launch {
    if (timeout != null && timeout > 0) {
        val timeoutMillis = timeout * 1000
        var count = 0
        withContext(Dispatchers.Default) {
          while (!granted && count < timeoutMillis) {
            Log.d(TAG,"Checking permissions... ($count)")
            count += 1000
            granted = haveStoragePermission()
            delay(1000)
          }
        }
      }
      Log.d(TAG, "Read Storage permissions granted ? $granted")
      result.success(granted)
    }
  }

  private fun getGalleryImages(@NonNull result: Result) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "getGalleryImages"))
    requestPermission()
    mainScope.launch {
      val res = queryImages(appContext)
      result.success(res)
    }
  }
  private fun onError(@NonNull result: Result, errorCode: String, errorMessage: String? = null, errorDetails: String? = null) {
    result.error(errorCode, errorMessage, errorDetails)
    return
  }

  private fun haveStoragePermission() =
          ContextCompat.checkSelfPermission(
                  binding?.applicationContext!!,
                  Manifest.permission.READ_EXTERNAL_STORAGE
          ) == PackageManager.PERMISSION_GRANTED

  private fun requestPermission() {
    if (!haveStoragePermission()) {
      val permissions = arrayOf(
              Manifest.permission.READ_EXTERNAL_STORAGE,
//              Manifest.permission.WRITE_EXTERNAL_STORAGE
      )
      ActivityCompat.requestPermissions(activity!!, permissions, READ_EXTERNAL_STORAGE_REQUEST)
    }
  }

  private suspend fun queryImages(appContext: Context) : String {
    var res : String = ""
    withContext(Dispatchers.IO) {
      val projection = arrayOf(
              MediaStore.Images.Media._ID,
              MediaStore.Images.Media.DISPLAY_NAME,
              MediaStore.Images.Media.DATE_ADDED
      )
      val selection = "${MediaStore.Images.Media.DATE_ADDED} >= ?"
      val selectionArgs = arrayOf("1577881609")
      val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

      val cursor: Cursor? = appContext.contentResolver.query(
              MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
              projection,
              selection,
              selectionArgs,
              sortOrder
      )
      cursor?.use { cursor ->
        val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
        val dateModifiedColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
        val displayNameColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)

        Log.i(TAG, "Found ${cursor.count} images")
        while (cursor.moveToNext()) {

          // Here we'll use the column indexs that we found above.
          val id = cursor.getLong(idColumn)
          val dateModified = cursor.getLong(dateModifiedColumn)
          val displayName = cursor.getString(displayNameColumn)


          /**
           * This is one of the trickiest parts:
           *
           * Since we're accessing images (using
           * [MediaStore.Images.Media.EXTERNAL_CONTENT_URI], we'll use that
           * as the base URI and append the ID of the image to it.
           *
           * This is the exact same way to do it when working with [MediaStore.Video] and
           * [MediaStore.Audio] as well. Whatever `Media.EXTERNAL_CONTENT_URI` you
           * query to get the items is the base, and the ID is the document to
           * request there.
           */
          val contentUri = ContentUris.withAppendedId(
                  MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                  id
          ).toString()
          val image = ImageMediaData(id, displayName, dateModified, contentUri)
          //images += image
          //TODO
          Log.v(TAG, "Added image: $image")
          res = serializer.toJson(image)
          return@use
        }
     }
    }
    return res
  }

}
