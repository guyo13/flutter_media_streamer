import 'dart:async';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/model/ios.dart';
import 'package:flutter_media_streamer/utils/utils.dart';

import 'model/android.dart';

const _empty = <String>[];

class FlutterMediaStreamer {
  static FlutterMediaStreamer _instance = FlutterMediaStreamer._();
  static FlutterMediaStreamer get instance => _instance;
  bool _galleryImageMetadataStreamLocked = false;
  FlutterMediaStreamer._();

  static const MethodChannel _channel =
      const MethodChannel('flutter_media_streamer');

  Future<Uint8List> getThumbnail(String imageIdentifier,
      {int width = 640, int height = 400}) async {
    try {
      return await _channel.invokeMethod('getThumbnail', <String, dynamic>{
        'imageIdentifier': imageIdentifier ?? '',
        'width': width ?? 640,
        'height': height ?? 400,
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Returns image bytes of an image asset represented by [imageIdentifier]
  /// Returned image data is in PNG format
  /// [imageIdentifier] - The platform identifier used to load the image
  /// on Android this is a Content URI, and on iOS this is a localIdentifier
  ///
  /// [width] - The requested width of the image.
  /// [height] - The requested height of the image
  /// In either [width] or [height], a value of -1 means the original
  /// dimension. Be careful loading multiple images in full size as it is a
  /// memory hog!
  ///
  /// TODO - format, quality, subsample, and ios features
  Future<Uint8List> getImage(String imageIdentifier, {int width = -1, int height = -1}) async {
    try {
      return await _channel.invokeMethod('getImage', <String, dynamic>{
        'imageIdentifier': imageIdentifier ?? '',
        'width': width ?? -1,
        'height': height ?? -1,
      });
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// This stream consumes [rawImageMetadata] stream
  /// and transforms the results into model objects
  /// of type [IOSPHAsset]
  /// [limit] - the max number of results per "page"
  /// the platform will send back to flutter
  ///
  /// [offset] - The position from where to start fetching results
  ///
  /// [jsonDecodeFn] - A [JsonCallback] used to convert the String
  /// representations into objects of [Map<String, dynamic>]. by default -
  /// [defaultJsonDecode]
  /// When working on real Flutter applications prefer to use
  /// a method based on [compute] (https://api.flutter.dev/flutter/foundation/compute.html)
  /// For example, define these functions at the global scope of your app:
  ///
  /// import 'dart:convert';
  /// Map<String, dynamic> decode(String raw) {
  ///   return jsonDecode(raw);
  /// }
  ///
  /// Future<Map<String, dynamic>> computeJson(String raw) async {
  ///   return await compute(decode, raw);
  /// }
  /// pass computeJson to [jsonDecodeFn]
  Stream<IOSPHAsset> iOSImagesMetadata({
    int limit = 10,
    int offset = 0,
    JsonCallback jsonDecodeFn = defaultJsonDecode,
  }) async* {
    await for (var item in rawImageMetadata(
      limit: limit,
      offset: offset,
      columns: _empty,)) {
      final json = await jsonDecodeFn(item);
      yield iosSerializers.deserialize(json,
          specifiedType: const FullType(IOSPHAsset));
    }
  }


  /// This stream consumes [rawImageMetadata] stream
  /// and transforms the results into model objects
  /// of type [AndroidImageMediaData]
  /// [limit] - the max number of results per "page"
  /// the platform will send back to flutter
  ///
  /// [offset] - The position from where to start fetching results
  ///
  /// [baseColumns] - The requested Android base columns. by default -
  /// [AndroidBaseColumn.id]
  ///
  /// [mediaColumns] - The request Android media columns. by default -
  /// ([AndroidMediaColumn.mime_type], [AndroidMediaColumn.height],
  /// [AndroidMediaColumn.width])
  ///
  /// [imageColumns] - The requested Android image columns. by default -
  /// [AndroidImageColumn.description]
  ///
  /// [jsonDecodeFn] - A [JsonCallback] used to convert the String
  /// representations into objects of [Map<String, dynamic>]. by default -
  /// [defaultJsonDecode]
  /// When working on real Flutter applications prefer to use
  /// a method based on [compute] (https://api.flutter.dev/flutter/foundation/compute.html)
  /// For example, define these functions at the global scope of your app:
  ///
  /// import 'dart:convert';
  /// Map<String, dynamic> decode(String raw) {
  ///   return jsonDecode(raw);
  /// }
  ///
  /// Future<Map<String, dynamic>> computeJson(String raw) async {
  ///   return await compute(decode, raw);
  /// }
  /// pass computeJson to [jsonDecodeFn]
  Stream<AndroidImageMediaData> androidImagesMetadata({
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
    List<String> columns = [];
    columns.addAll(baseColumns.map((e) => e.name) ?? _empty);
    columns.addAll(mediaColumns.map((e) => e.name) ?? _empty);
    columns.addAll(imageColumns.map((e) => e.name) ?? _empty);
    await for (var item in rawImageMetadata(
        limit: limit,
        offset: offset,
        columns: columns,)) {
      final json = await jsonDecodeFn(item);
      yield androidSerializers.deserialize(json,
          specifiedType: const FullType(AndroidImageMediaData));
    }
  }

  /// Opens a stream which yields a single image metadata
  /// at a time, the data is returned as a JSON String
  /// representing the metadata
  /// on Android this corresponds to [AndroidImageMediaData]
  /// on iOS it is an [IOSPHAsset]
  /// [limit] - the max number of results per "page"
  /// the platform will send back to flutter
  /// [offset] - The position from where to start fetching results
  /// [columns] - An iterable of Strings containing the
  /// requested columns on Android (see [AndroidMediaColumn],
  /// [AndroidImageColumn], [AndroidBaseColumn])
  /// on iOS all data columns available are returned
  //TODO - make sure that this lock is abuse-proof
  Stream<String> rawImageMetadata(
      {int limit = 10,
      int offset = 0,
      Iterable<String> columns = _empty,
      }) async* {
    int millis = 400;
    while (_galleryImageMetadataStreamLocked) {
      millis = millis < 2000 ? millis + 100 : millis;
      await Future.delayed(Duration(milliseconds: millis));
    }
    yield* _rawImageMetadata(
        limit: limit,
        offset: offset,
        columns: columns,);
  }

  /// On Android check if Read External Storage permissions granted
  /// On iOS check if PHAuthorizationStatus is authorized
  static Future<bool> get havePermissions async {
    return await _channel.invokeMethod('havePermissions');
  }

  /// Requests permissions and returns a boolean value
  /// indicating if permissions were granted or not
  /// on Android for reading external storage
  /// on iOS for reading the user's Photo Library
  /// [timeout] - Timeout is seconds to wait for permissions. Default 10
  /// if 0 or null then returns false
  static Future<bool> requestPermissions() async {
    return await _channel.invokeMethod('requestPermissions');
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Use [rawImageMetadata] or [androidImagesMetadata] to read
  /// images' metadata
  ///
  /// Private function that implements the platform method call
  /// Currently only one such stream can exist at the same time
  /// and it is protected by locking and backoff mechanism
  /// so that additional streams opened with the public
  /// functions are still valid
  Stream<String> _rawImageMetadata(
      {int limit = 10,
        int offset = 0,
        Iterable<String> columns = _empty,
      }) async* {
    if (!_galleryImageMetadataStreamLocked) {
      _galleryImageMetadataStreamLocked = true;
      List<String> results;
      limit = limit ?? 10;
      offset = offset ?? 0;
      try {
        do {
          results = await _channel
              .invokeListMethod('imageMetadataStream', <String, dynamic>{
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
      _galleryImageMetadataStreamLocked = false;
    }
  }
}
