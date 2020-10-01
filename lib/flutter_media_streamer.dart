import 'dart:async';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/utils/utils.dart';

import 'model/android.dart';

const _empty = <String>[];

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

  Future<Uint8List> getThumbnail(String contentUri,
      {int width = 640, int height = 400}) async {
    return await _channel.invokeMethod('getThumbnail', <String, dynamic>{
      'contentUriString': contentUri ?? '',
      'width': width ?? 640,
      'height': height ?? 400,
    });
  }

  Future<Uint8List> getImage(String contentUri, {int width, int height}) async {
    return await _channel.invokeMethod('getImage', <String, dynamic>{
      'contentUriString': contentUri ?? '',
      'width': width,
      'height': height,
    });
  }

  Stream<AndroidImageMediaData> streamAndroidGalleryImages({
    int limit = 10,
    int offset = 0,
    Iterable<AndroidBaseColumn> baseColumns = const [idColumn],
    Iterable<AndroidMediaColumn> mediaColumns = const [
      AndroidMediaColumn.mime_type,
      AndroidMediaColumn.height,
      AndroidMediaColumn.width
    ],
    Iterable<AndroidImageColumn> imageColumns = const [
      AndroidImageColumn.description
    ],
    JsonCallback jsonDecodeFn = defaultJsonDecode,
  }) async* {
    await for (var item in streamRawAndroidGalleryImages(
        limit: limit,
        offset: offset,
        baseColumns: baseColumns,
        mediaColumns: mediaColumns,
        imageColumns: imageColumns)) {
      final json = await jsonDecodeFn(item);
      yield androidSerializers.deserialize(json, specifiedType: const FullType(AndroidImageMediaData));
    }
  }

  //TODO - make sure that this lock is abuse-proof
  Stream<String> streamRawAndroidGalleryImages(
      {int limit = 10,
      int offset = 0,
      Iterable<AndroidBaseColumn> baseColumns = const [idColumn],
      Iterable<AndroidMediaColumn> mediaColumns = const [
        AndroidMediaColumn.mime_type,
        AndroidMediaColumn.height,
        AndroidMediaColumn.width
      ],
      Iterable<AndroidImageColumn> imageColumns = const [
        AndroidImageColumn.description
      ]}) async* {
    int millis = 400;
    while (_galleryImageStreamLocked) {
      millis = millis < 2000 ? millis + 100 : millis;
      await Future.delayed(Duration(milliseconds: millis));
    }
    yield* streamRawGalleryImages(
        limit: limit,
        offset: offset,
        baseColumns: baseColumns,
        mediaColumns: mediaColumns,
        imageColumns: imageColumns);
  }

  Stream<String> streamRawGalleryImages(
      {int limit = 10,
      int offset = 0,
      Iterable<AndroidBaseColumn> baseColumns = const [idColumn],
      Iterable<AndroidMediaColumn> mediaColumns = const [
        AndroidMediaColumn.mime_type,
        AndroidMediaColumn.height,
        AndroidMediaColumn.width
      ],
      Iterable<AndroidImageColumn> imageColumns = const [
        AndroidImageColumn.description
      ]}) async* {
    if (!_galleryImageStreamLocked) {
      _galleryImageStreamLocked = true;
      if (true || await haveStoragePermission) {
        List<String> columns = [];
        columns.addAll(baseColumns.map((e) => e.name) ?? _empty);
        columns.addAll(mediaColumns.map((e) => e.name) ?? _empty);
        columns.addAll(imageColumns.map((e) => e.name) ?? _empty);

        List<String> results;
        limit = limit ?? 10;
        offset = offset ?? 0;
        try {
          do {
            results = await _channel
                .invokeListMethod('streamGalleryImages', <String, dynamic>{
              'columns': columns,
              'limit': limit,
              'offset': offset,
            });
            offset += results.length;
            for (var item in results) {
              yield item;
            }
          } while (results != null && results.isNotEmpty);
        } catch (e) {
          print(e);
        }
        print('Stream over');
      }
      _galleryImageStreamLocked = false;
    }
  }

  /// On Android check if Read External Storage permissions granted
  /// On iOS check if PHAuthorizationStatus is authorized
  // FIXME - unify method channel method name or check platform and fire with the matching name
  static Future<bool> get haveStoragePermission async {
    return await _channel.invokeMethod('haveStoragePermission');
  }

  /// Request permissions, on Android for reading external storage
  /// TODO on iOS
  /// Returns a boolean value indicating if permissions were granted or not
  /// [timeout] - Timeout is seconds to wait for permissions. Default 10
  /// if 0 or null then returns false
  static Future<bool> requestStoragePermissions({int timeout = 10}) async {
    return await _channel.invokeMethod(
        'requestStoragePermissions', <String, dynamic>{'timeout': timeout});
  }
}
