import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class FlutterMediaStreamer {
  static FlutterMediaStreamer _instance = FlutterMediaStreamer._();
  static FlutterMediaStreamer get instance => _instance;
  bool _galleryImageStreamLocked = false;
  FlutterMediaStreamer._();

  static const MethodChannel _channel =
      const MethodChannel('flutter_media_streamer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<Uint8List> getThumbnail(String contentUri, {int width=640, int height=400}) async {
    return await _channel.invokeMethod('getThumbnail', <String, dynamic> {
      'contentUriString': contentUri ?? '',
      'width':  width ?? 640,
      'height': height ?? 400,
    });
  }

  //FIXME - Still buggy
  Future<Uint8List> getImage(String contentUri, {int width, int height}) async {
    return await _channel.invokeMethod('getImage', <String, dynamic> {
      'contentUriString': contentUri ?? '',
      'width':  width,
      'height': height,
    });
  }

  //TODO - make sure that this lock is abuse-proof
  Stream<String> streamGalleryImages({int limit=10, int offset=0}) async* {
    int millis = 400;
    while (_galleryImageStreamLocked) {
      millis += 100;
      await Future.delayed(Duration(milliseconds: millis));
    }
    yield* _streamGalleryImages(limit: limit, offset: offset);
  }

  Stream<String> _streamGalleryImages({int limit=10, int offset=0}) async* {
    if (!_galleryImageStreamLocked) {
      _galleryImageStreamLocked = true;
      if (await haveStoragePermission) {
        List<String> results;
        limit = limit ?? 10;
        offset = offset ?? 0;
        do {
          results = await _channel.invokeListMethod('streamGalleryImages', <String, dynamic> {
            'limit':  limit,
            'offset': offset,
          });
          offset += results.length;
          for (var item in results) {
            yield item;
          }
        } while (results != null && results.isNotEmpty);
      }
      _galleryImageStreamLocked = false;
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
