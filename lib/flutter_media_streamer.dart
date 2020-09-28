
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMediaStreamer {
  static const MethodChannel _channel =
      const MethodChannel('flutter_media_streamer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Stream<List<String>> streamGalleryImages({int limit=10, int offset=0}) async* {
    if (await haveStoragePermission) {
      List<String> results;
      limit = limit ?? 10;
      offset = offset ?? 0;
      do {
          results = await _channel.invokeMethod('streamGalleryImages', <String, dynamic> {
          'limit':  limit,
          'offset': offset,
        });
          offset += results.length;
          yield results;
      } while (results != null && results.isNotEmpty);
    }
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
