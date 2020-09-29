package net.guyor.flutter_media_streamer

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.util.Size
import android.webkit.URLUtil
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
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
import java.io.ByteArrayOutputStream

private const val READ_EXTERNAL_STORAGE_REQUEST = 0x1045
/** FlutterMediaStreamerPlugin */
public class FlutterMediaStreamerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var galleryImageCursor: ImageCursorContainer? = null
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
    @JvmStatic
    val ERR_VERSION = "ANDROID_VER_TOO_LOW"
    @JvmStatic
    val INVALID_URI = "INVALID_URI"
    @JvmStatic
    val ERR_URI_OPEN = "ERR_OPEN_URI"
    @JvmStatic
    val ERR_MISSING_ARG = "ERR_MISSING_ARG"
    private const val TAG = "FlutterMediaStreamer"
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "streamGalleryImages" -> streamGalleryImages(
              result,
              call.argument<List<String>>("columns") as List<String>,
              limit = call.argument<Int>("limit") as Int,
              offset = call.argument<Int>("offset") as Int,
      )
      "requestStoragePermissions" -> requestStoragePermissions(
              result,
              timeout = call.argument<Int?>("timeout") as Int?
      )
      "getThumbnail" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) getThumbnail(
              result,
              call.argument<String?>("contentUriString") ?: "",
              width = call.argument<Int?>("width") ?: 640,
              height = call.argument<Int?>("height") ?: 400)
      else getImage(
              result,
              call.argument<String?>("contentUriString") ?: "",
              width = call.argument<Int?>("width") ?: 640,
              height = call.argument<Int?>("height") ?: 400)
      "getImage" -> getImage(
              result,
              call.argument<String?>("contentUriString") ?: "",
              width = call.argument<Int?>("width"),
              height = call.argument<Int?>("height"))
      "haveStoragePermission" -> result.success(haveStoragePermission())
      "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    this.binding = null
    channel.setMethodCallHandler(null)
    Log.d(TAG, "FlutterMediaStreamerPlugin onDetachedFromEngine")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    Log.d(TAG, "FlutterMediaStreamerPlugin onAttachedToActivity")
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "FlutterMediaStreamerPlugin onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(TAG, "FlutterMediaStreamerPlugin onReattachedToActivityForConfigChanges")
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    Log.d(TAG, "FlutterMediaStreamerPlugin onDetachedFromActivity")
    activity = null
  }
  /** Main Functionality */

  private fun streamGalleryImages(@NonNull result: Result, columns: List<String>, limit: Int = 0, offset: Int = 0) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "streamGalleryImages"))
    mainScope.launch {
      if (galleryImageCursor == null) {
        startImageStream(appContext, columns)
//        Log.d(TAG, "Cursor Loaded")
//        Log.v(TAG, ImageCursorContainer.ColumnIndex.imageColumnNames.toString())
      }
      val res = resumeImageStream(limit = limit, offset = offset)
      result.success(res)
    }
  }

  private suspend fun resumeImageStream(limit: Int = 0, offset: Int = 0) : List<String> {
    val res = mutableListOf<String>()
    withContext(Dispatchers.IO) {
        /** Based on https://github.com/android/storage-samples/tree/master/MediaStore */
      galleryImageCursor?.cursor?.let { cursor: Cursor ->
        val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID)
        val dateModifiedColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATE_ADDED)
        val displayNameColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DISPLAY_NAME)
        val mimTypeCol = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.MIME_TYPE)

        var hasNext = cursor.moveToNext()
        while (hasNext && res.size < limit) {

          // Here we'll use the column indexs that we found above.
          val id = cursor.getLong(idColumn)
          val dateModified = cursor.getLong(dateModifiedColumn)
          val displayName = cursor.getString(displayNameColumn)
          val mimeType = cursor.getString(mimTypeCol)


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
          val image = ImageMediaData(contentUri, id, displayName = displayName, dateModified = dateModified, mimeType = mimeType)
          //images += image
          //TODO
          Log.v(TAG, "Added image: $image")
          res.add(serializer.toJson(image))
        }
        if (!hasNext) {
          galleryImageCursor?.cursor?.close()
          galleryImageCursor = null
        }
      }
    }
    return res
  }

  private suspend fun startImageStream(appContext: Context, @NonNull columns: List<String>) {
    withContext(Dispatchers.IO) {
      val projection = arrayOf(
              MediaStore.Images.Media._ID,
              MediaStore.Images.Media.DISPLAY_NAME,
              MediaStore.Images.Media.DATE_ADDED,
              MediaStore.Images.Media.MIME_TYPE,
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
      Log.i(TAG, "Found ${cursor?.count} images")
      if (cursor != null) {
        galleryImageCursor = ImageCursorContainer(cursor)
      }
    }
  }


  @RequiresApi(Build.VERSION_CODES.Q)
  private fun getThumbnail(@NonNull result: Result, @NonNull uriString: String, width: Int = 640, height: Int = 480) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "getThumbnail"))
    var res : ByteArray
    val uri: Uri = Uri.parse(uriString)
//    Log.d(TAG, "uriString $uriString is ${if (URLUtil.isValidUrl(uriString)) "valid" else "invalid"}")
    if (URLUtil.isValidUrl(uriString)) {
      mainScope.launch {
        withContext(Dispatchers.IO) {
          var thumbnail : Bitmap = appContext.contentResolver.loadThumbnail(uri, Size(width, height), null)
          val stream = ByteArrayOutputStream()
          thumbnail.compress(Bitmap.CompressFormat.PNG, 100, stream)
          res = stream.toByteArray()
          thumbnail.recycle()
        }
        result.success(res)
      }
    } else {
      result.error(INVALID_URI, "Invalid URI $uriString", null)
    }
  }

  //TODO - see if speed and memory usage can be further improved
  private fun getImage(@NonNull result: Result, @NonNull uriString: String, width: Int?, height: Int?) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "getImage"))
    var res : ByteArray? = null
    val uri: Uri = Uri.parse(uriString)
    if (URLUtil.isValidUrl(uriString)) {
      mainScope.launch {
        withContext(Dispatchers.IO) {
          var bitmap : Bitmap?

          val pfd = appContext.contentResolver.openFileDescriptor(uri, "r") ?: return@withContext
          pfd.use { istream ->
              if (width != null && width> 0 && height != null && height > 0) {
                Log.d(TAG, "Getting image with size $width X $height")
                bitmap = decodeSampledBitmapFromDescriptor(pfd.fileDescriptor, width, height)
              } else {
                bitmap = BitmapFactory.decodeFileDescriptor(pfd.fileDescriptor, null, null)
              }
              val stream = ByteArrayOutputStream()
              bitmap?.compress(Bitmap.CompressFormat.PNG, 100, stream)
              res = stream.toByteArray()
              bitmap?.recycle()
          }
        }
        if (res != null)
          result.success(res)
        else
          result.error(ERR_URI_OPEN, "Error opening URI $uriString", "Received null input stream")
      }
    } else {
      result.error(INVALID_URI, "Invalid URI $uriString", null)
    }
  }
  /** Other Methods */

  private fun requestStoragePermissions(@NonNull result: Result, timeout: Int? = 10) {
    if (haveStoragePermission()) {
      result.success(true)
      return
    } else {
      requestPermission()
    }
    //FIXME - use {@link ActivityPluginBinding#addRequestPermissionsResultListener}
    var granted = false
    mainScope.launch {
      if (timeout != null && timeout > 0) {
        val timeoutMillis = timeout * 1000
        var count = 0
        withContext(Dispatchers.Default) {
          while (!granted && count < timeoutMillis) {
            Log.d(TAG, "Checking permissions... ($count)")
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
}
