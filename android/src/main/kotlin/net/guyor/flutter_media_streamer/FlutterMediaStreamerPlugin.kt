package net.guyor.flutter_media_streamer

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.MediaStore.Images.Thumbnails.MINI_KIND
import android.util.Log
import android.util.Size
import android.webkit.URLUtil
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.PermissionChecker.PERMISSION_GRANTED
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.*
import java.io.ByteArrayOutputStream

private const val READ_EXTERNAL_STORAGE_REQUEST_CODE = 0xF17357
/** FlutterMediaStreamerPlugin */
class FlutterMediaStreamerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel : MethodChannel
  private var galleryImageCursor: ImageCursorContainer? = null
  private var binding : FlutterPlugin.FlutterPluginBinding? = null
  private var activityBinding : ActivityPluginBinding? = null
  private val mainScope = CoroutineScope(Dispatchers.Main)
  private val serializer = Gson()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_media_streamer")
    binding = flutterPluginBinding
    channel.setMethodCallHandler(this)
  }

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
    val INVALID_URI = "INVALID_URI"
    @JvmStatic
    val ERR_URI_OPEN = "ERR_OPEN_URI"
    @JvmStatic
    val ERR_NULL_CURSOR = "ERR_NULL_CURSOR"
    @JvmStatic
    val ERR_PERMISSIONS = "ERR_PERMISSIONS"
    @JvmStatic
    val ERR_EXCEPTION = "ERR_EXCEPTION"
    @JvmStatic
    val ERR_RESOURCE = "ERR_RESOURCE"
    private const val TAG = "FlutterMediaStreamer"
    @JvmStatic
    private val READ_PERMISSIONS = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
    )
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "imageMetadataStream" -> streamImageMetadata(
              result,
              call.argument<List<String>>("columns") as List<String>,
              limit = call.argument<Int>("limit") as Int,
              offset = call.argument<Int>("offset") as Int,
      )
      "getThumbnail" -> getThumbnail(
              result,
              call.argument<String?>("imageIdentifier") ?: "",
              width = call.argument<Int?>("width") ?: 640,
              height = call.argument<Int?>("height") ?: 400)
      "getImage" -> getImage(
              result,
              call.argument<String?>("imageIdentifier") ?: "",
              width = call.argument<Int?>("width") ?: -1,
              height = call.argument<Int?>("height") ?: -1 )
      "havePermissions" -> result.success(havePermissions())
      "requestPermissions" -> requestPermissions(result)
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
    activityBinding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "FlutterMediaStreamerPlugin onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    Log.d(TAG, "FlutterMediaStreamerPlugin onReattachedToActivityForConfigChanges")
    activityBinding = binding
  }

  override fun onDetachedFromActivity() {
    Log.d(TAG, "FlutterMediaStreamerPlugin onDetachedFromActivity")
    activityBinding = null
  }
  /** Main Functionality */

  private fun streamImageMetadata(@NonNull result: Result, columns: List<String>, limit: Int = 10, offset: Int = 0) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "streamImageMetadata"))
    mainScope.launch {
      //If cursor already available, continue serving results through it
      if (galleryImageCursor != null) {
        val res = resumeImageStream(limit = limit, offset = offset)
        result.success(res)
      } else {
        // Execute with permissions
        val handler: (Boolean) -> Unit = { isAuthorized: Boolean ->
          mainScope.launch {
          if (isAuthorized) {
            // Execute query only if permissions were authorized
              galleryImageCursor = getGalleryImageCursor(appContext, columns)
              if (galleryImageCursor == null) {
                onError(result, ERR_NULL_CURSOR, "Received null cursor from android")
              } else {
                val res = resumeImageStream(limit = limit, offset = offset)
                result.success(res)
              }
          } else {
            // Return error ro flutter if permissions denied
            onError(result, ERR_PERMISSIONS, "Photo Gallery Permissions denied")
          }
         } // Main thread coroutine for result
        } // End of handler
        executeWithPermissions(handler)
      }
    }
  }

  private suspend fun resumeImageStream(limit: Int = 10, offset: Int = 0) : List<String> {
    val res = mutableListOf<String>()
    withContext(Dispatchers.IO) {
        /** Based on https://github.com/android/storage-samples/tree/master/MediaStore */
      galleryImageCursor?.cursor?.let { cursor: Cursor ->
        val cursorPos = cursor.position
        var hasNext = false
        if (cursorPos != offset  && cursor.count > offset) {
          Log.d(TAG, "Moving cursor at pos $cursorPos to pos $offset")
          cursor.moveToPosition(offset)
          hasNext = true
        } else if (cursorPos == offset)
            hasNext = offset < cursor.count
        while (hasNext && res.size < limit) {
          val image = galleryImageCursor!!.getImageMediaData()
          Log.v(TAG, "Adding image to result set: id - ${image.id}")
          res.add(serializer.toJson(image))
          hasNext = cursor.moveToNext()
        }
        if (!hasNext) {
          galleryImageCursor?.cursor?.close()
          galleryImageCursor = null
        }
      }
    }
    return res
  }

  private suspend fun getGalleryImageCursor(appContext: Context, @NonNull columns: List<String>) : ImageCursorContainer? {
    var cursorContainer: ImageCursorContainer? = null
    withContext(Dispatchers.IO) {
      val projection = ImageCursorContainer.getValidProjection(columns)
      //TODO - take from method call
      val selection = "${MediaStore.Images.Media.DATE_ADDED} >= ?"
      val selectionArgs = arrayOf("0")
      val sortOrder = "${MediaStore.Images.Media.DATE_ADDED} DESC"

      val cursor: Cursor? = appContext.contentResolver.query(
              MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
              projection.toTypedArray(),
              selection,
              selectionArgs,
              sortOrder
      )
      if (cursor != null) {
        Log.v(TAG, "Found ${cursor.count} images")
        cursorContainer = ImageCursorContainer(cursor)
        /** Get indices for the same columns as we are projecting */
        cursorContainer!!.addColumns(projection)
      }
    }
    return cursorContainer
  }


  //TODO - Execute with permissions
  private fun getThumbnail(@NonNull result: Result, @NonNull uriString: String, width: Int = 640, height: Int = 480) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "getThumbnail"))
    var res : ByteArray? = null
    val uri: Uri = Uri.parse(uriString)
    if (URLUtil.isValidUrl(uriString)) {
      mainScope.launch {
        withContext(Dispatchers.IO) {
          val thumbnail : Bitmap? =
                  when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                      appContext.contentResolver.loadThumbnail(uri, Size(width, height), null)
                    }
                    else -> {
//                      Log.v(TAG, "API < 29 Using MediaStore Thumbnails")
                      uri.lastPathSegment?.let path@{ lastPath ->
                        val id = lastPath.toLongOrNull()
                        id?.let {
                          return@path MediaStore.Images.Thumbnails.getThumbnail(
                                  appContext.contentResolver,
                                  id,
                                  MINI_KIND,
                                  null
                          )
                        }
                      }
                    }
                  }
          val stream = ByteArrayOutputStream()
          thumbnail?.let {
            it.compress(Bitmap.CompressFormat.PNG, 100, stream)
            res = stream.toByteArray()
            it.recycle()
          }
        }
        if (res != null)
          result.success(res)
        else
          result.error(ERR_RESOURCE, "Couldn't get thumbnail for uri $uriString", null)
      }
    } else {
      result.error(INVALID_URI, "Invalid URI $uriString", null)
    }
  }

  //TODO - see if speed and memory usage can be further improved
  //TODO - Execute with permissions
  //TODO - Choose either scaledBitmap algo or sampledBitmap
  private fun getImage(@NonNull result: Result, @NonNull uriString: String, width: Int = -1, height: Int = -1) {
    val appContext = binding?.applicationContext ?: return onError(result, ERR_CONTEXT, String.format(ERR_CONTEXT_MSG, "getImage"))
    var res : ByteArray? = null
    var error: Throwable? = null
    val uri: Uri = Uri.parse(uriString)
    if (URLUtil.isValidUrl(uriString)) {
      mainScope.launch {
        withContext(Dispatchers.IO) {
          var bitmap: Bitmap?

          val pfd = appContext.contentResolver.openFileDescriptor(uri, "r") ?: return@withContext
          pfd.use {
            try {
              bitmap = createScaledBitmap(pfd.fileDescriptor, width, height)
              Log.d(TAG, "Got image with size ${bitmap?.width} X ${bitmap?.height}")
              val stream = ByteArrayOutputStream()
              bitmap?.compress(Bitmap.CompressFormat.PNG, 100, stream)
              res = stream.toByteArray()
              bitmap?.recycle()
            } catch (t: Throwable) {
              error = t
              Log.e(TAG, "Error while generating bitmap for URI $uriString")
              Log.e(TAG, t.message!!)
              Log.e(TAG, Log.getStackTraceString(t))
            }
          }
        }
        when {
            res != null -> result.success(res)
            error == null -> result.error(ERR_URI_OPEN, "Error opening URI $uriString", "Received null input stream")
            else -> result.error(ERR_EXCEPTION, "Exception occurred while generating image for URI $uriString", Log.getStackTraceString(error))
        }
      }
    } else {
      result.error(INVALID_URI, "Invalid URI $uriString", null)
    }
  }
  /** Other Methods */

  private fun executeWithPermissions(handler: (isAuthorized: Boolean) -> Unit) {
    if (havePermissions()) {
      handler(true)
    } else {
      var permissionsHandler: PluginRegistry.RequestPermissionsResultListener? = null
      permissionsHandler = PluginRegistry.RequestPermissionsResultListener { requestCode, permissions, grantResults ->
        if (requestCode == READ_EXTERNAL_STORAGE_REQUEST_CODE) {
          val authorized = permissions.contains(Manifest.permission.READ_EXTERNAL_STORAGE) &&
                  grantResults[permissions.indexOf(Manifest.permission.READ_EXTERNAL_STORAGE)] == PERMISSION_GRANTED
          Log.d(TAG, "permission handler request ${if (!authorized) "not " else ""}authorized")
          handler(authorized)
        }
        mainScope.launch {
          activityBinding?.removeRequestPermissionsResultListener(permissionsHandler!!)
        }
        return@RequestPermissionsResultListener true
      }

      activityBinding?.addRequestPermissionsResultListener(permissionsHandler)
      requestAndroidPermissions()
    }
  }

  private fun requestPermissions(@NonNull result: Result) {
    mainScope.launch {
      if (havePermissions()) {
        result.success(true)
      } else {
        executeWithPermissions { isAuthorized: Boolean ->
          result.success(isAuthorized)
        }
      }
    }
  }

  private fun onError(@NonNull result: Result, errorCode: String, errorMessage: String? = null, errorDetails: String? = null) {
    result.error(errorCode, errorMessage, errorDetails)
    return
  }

  private fun havePermissions() =
          ContextCompat.checkSelfPermission(
                  binding?.applicationContext!!,
                  Manifest.permission.READ_EXTERNAL_STORAGE
          ) == PackageManager.PERMISSION_GRANTED

  private fun requestAndroidPermissions(requestCode: Int = READ_EXTERNAL_STORAGE_REQUEST_CODE, permissions: Array<String> = READ_PERMISSIONS) {
    ActivityCompat.requestPermissions(activityBinding?.activity!!, permissions, requestCode)
  }
}
