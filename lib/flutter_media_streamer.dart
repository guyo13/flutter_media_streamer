
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
    final String result = await _channel.invokeMethod('getGalleryImages');
    return result;
  }
}
