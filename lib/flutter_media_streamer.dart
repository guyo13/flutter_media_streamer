
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMediaStreamer {
  static const MethodChannel _channel =
      const MethodChannel('flutter_media_streamer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<String> get galleryImages async {
    if (await haveStoragePermission) {
      final String result = await _channel.invokeMethod('getGalleryImages');
      return result;
    }
    return null;
  }

  static Future<bool> get haveStoragePermission async {
    return await _channel.invokeMethod('haveStoragePermission');
  }

  /// Request permissions, on Android for reading external storage
  /// TODO on iOS
  /// Returns a boolean value indicating if permissions were granted or not
  /// [timeout] - Timeout is seconds to wait for permissions. Default 10
  /// if 0 or null then returns false
  static Future<bool> requestStoragePermissions({int timeout = 10}) async {
    return await _channel.invokeMethod('requestStoragePermissions', <String, dynamic> {
      'timeout': timeout
    } );
  }
}
