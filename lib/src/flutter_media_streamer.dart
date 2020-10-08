// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_streamer/src/model/abstraction.dart';
import 'package:flutter_media_streamer/src/model/ios.dart';
import 'package:flutter_media_streamer/src/model/android.dart';
import 'package:flutter_media_streamer/src/utils/utils.dart';

const _empty = <String>[];

class FlutterMediaStreamer {
  static FlutterMediaStreamer _instance = FlutterMediaStreamer._();
  static FlutterMediaStreamer get instance => _instance;
  bool _galleryImageMetadataStreamLocked = false;
  FlutterMediaStreamer._();

  static const MethodChannel _channel =
      const MethodChannel('flutter_media_streamer');

  /// Static transformation methods

  /// Converts an object represented by [raw] into object [T]
  /// using [objectSerializer] from [serializers]
  /// processing the String into Map with [jsonDecodeFn]
  static Future<T> convertSingle<T>(
      String raw, Serializers serializers, Serializer objectSerializer,
      {JsonCallback jsonDecodeFn = defaultJsonDecode}) async {
    final json = await jsonDecodeFn(raw);
    return serializers.deserializeWith(objectSerializer, json);
  }

  /// Converts a iterable of objects represented by [rawItems] into objects [T]
  /// using [objectSerializer] from [serializers]
  /// processing the Strings into Maps as a batch with [batchJsonDecodeFn]
  static Stream<T> convertBatch<T>(Iterable<String> rawItems,
      Serializers serializers, Serializer objectSerializer,
      {BatchJsonCallback batchJsonDecodeFn = defaultBatchJsonDecode}) async* {
    final maps = await batchJsonDecodeFn(rawItems);
    for (var item in maps) {
      yield serializers.deserializeWith(objectSerializer, item);
    }
  }

  /// Asks the underlying platform to generate a thumbnail representation
  /// of the image and Returns it's bytes.
  ///
  /// [imageIdentifier] - The platform identifier used to load the image
  /// on Android this is a Content URI, and on iOS this is a localIdentifier
  ///
  /// [width] - The requested width of the image. Default is 640
  /// [height] - The requested height of the image. Default is 400
  /// Both of these parameters are used as a gauge by the platform,
  /// the resulting thumbnail will keep the original aspect ratio
  ///
  /// On Android with SDK level < 29, thumbnail will be generated with
  /// kind = android.provider.MediaStore.Images.Thumbnails.MINI_KIND
  /// and [height], [width] will NOT be taken into account
  ///
  /// TODO - iOS control the different PHImageRequestOptions and contentMode params
  /// TODO - format, quality
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
  Future<Uint8List> getImage(String imageIdentifier,
      {int width = -1, int height = -1}) async {
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

  /// On Android consumes an [androidImagesMetadata] stream
  /// On iOS consumes an [iOSImagesMetadata] stream
  /// and returns a stream of [AbstractMediaItem] objects
  ///
  /// Currently on any other platforms throws an exception.
  ///
  /// On Android takes iterables representing [AndroidBaseColumn],
  /// [AndroidMediaColumn] and [AndroidImageColumn] strings
  /// used in the query projection and which will appear in the
  /// resulting objects if available
  ///
  /// On iOS all available information of the underlying PHAsset will
  /// be included in the result
  ///
  /// Arguments:
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
  /// Can use a method based on Flutter [compute]
  /// (https://api.flutter.dev/flutter/foundation/compute.html)
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
  ///
  /// Batch Processing Arguments:
  ///
  /// [batchConvert] - Control raw data conversion algorithm.
  /// if true, converts data strings from method channel into proper
  /// Json Maps in batches of [batchLimit] and then streams the results,
  /// sequentially converting each Map to [AbstractMediaItem].
  /// Default is false
  ///
  /// [batchLimit] - If [batchConvert] enabled controls the size of
  /// the Iterable passed to [convertBatch]. Defaults to 20
  ///
  /// [batchJsonDecodeFn] - A [BatchJsonCallback] used to convert
  /// an Iterable of Json String representations - passed by the
  /// platform over the method channel - into an Iterable of Maps
  /// Used when [batchConvert] is enabled and Defaults to [defaultBatchJsonDecode]
  ///
  /// Batch Processing Use case and example:
  ///
  /// In real Flutter applications it is sometimes desirable to
  /// process information on an Isolate to prevent the UI thread
  /// from doing to much non-UI work.
  /// Batch processing allows you to do the heavy lifting of
  /// JSON parsing by executing it on an Isolate in batches.
  /// After each batch finishes it's JSON processing, resulting Maps
  /// are transformed into model objects back on the main thread.
  /// TODO - convert Maps to model objects on the Isolate as well
  /// Define the following functions on the global scope of your app:
  ///
  /// import 'dart:convert';
  /// List<Map<String, dynamic>> decodeBatch(Iterable<String> rawItems) {
  ///   final results = <Map<String, dynamic>>[];
  ///   for (var item in rawItems) {
  ///     results.add(jsonDecode(item) as Map<String, dynamic>);
  ///   }
  ///   return results;
  /// }
  ///
  /// Future<List<Map<String, dynamic>>> computeBatchJson(
  ///     Iterable<String> rawItems) async {
  ///   return await compute(decodeBatch, rawItems);
  /// }
  /// pass computeBatchJson function to [batchJsonDecodeFn]
  Stream<AbstractMediaItem> streamImageMetadata({
    int limit = 10,
    int offset = 0,
    JsonCallback jsonDecodeFn = defaultJsonDecode,
    bool batchConvert = false,
    int batchLimit = 20,
    BatchJsonCallback batchJsonDecodeFn = defaultBatchJsonDecode,
    Iterable<AndroidBaseColumn> baseColumns = const [idColumn],
    Iterable<AndroidMediaColumn> mediaColumns = const [
      AndroidMediaColumn.mime_type,
      AndroidMediaColumn.height,
      AndroidMediaColumn.width
    ],
    Iterable<AndroidImageColumn> imageColumns = const [
      AndroidImageColumn.description
    ],
  }) async* {
    assert(limit != null && offset != null && offset > -1);
    assert(jsonDecodeFn != null);
    assert(batchConvert == false ||
        (batchLimit != null && batchLimit > 0 && batchJsonDecodeFn != null));

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await for (var asset in iOSImagesMetadata(
          limit: limit,
          offset: offset,
          jsonDecodeFn: jsonDecodeFn,
          batchConvert: batchConvert,
          batchLimit: batchLimit,
          batchJsonDecodeFn: batchJsonDecodeFn)) {
        yield AbstractMediaItem.fromIOSPHAsset(asset);
      }
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await for (var mediaData in androidImagesMetadata(
          limit: limit,
          offset: offset,
          jsonDecodeFn: jsonDecodeFn,
          batchConvert: batchConvert,
          batchLimit: batchLimit,
          batchJsonDecodeFn: batchJsonDecodeFn,
          baseColumns: baseColumns,
          mediaColumns: mediaColumns,
          imageColumns: imageColumns)) {
        yield AbstractMediaItem.fromAndroidImageMediaData(mediaData);
      }
    } else {
      throw Exception('Invalid platform. Flutter Media Streamer'
          ' currently supports only iOS and Android');
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
  /// [jsonDecodeFn] - See [streamImageMetadata]
  ///
  /// Batch Processing Arguments:
  /// See use case and example at [streamImageMetadata]
  /// [batchConvert] - Control raw data conversion algorithm.
  /// if true, converts data strings from method channel into proper
  /// Json Maps in batches of [batchLimit] and then streams the results,
  /// sequentially converting each Map to [IOSPHAsset].
  /// Default is false
  ///
  /// [batchLimit] - If [batchConvert] enabled controls the size of
  /// the Iterable passed to [convertBatch]. Defaults to 20
  ///
  /// [batchJsonDecodeFn] - See [streamImageMetadata]
  Stream<IOSPHAsset> iOSImagesMetadata({
    int limit = 10,
    int offset = 0,
    JsonCallback jsonDecodeFn = defaultJsonDecode,
    bool batchConvert = false,
    int batchLimit = 20,
    BatchJsonCallback batchJsonDecodeFn = defaultBatchJsonDecode,
  }) async* {
    final stream =
        rawImageMetadata(limit: limit, offset: offset, columns: _empty);

    if (batchConvert) {
      List<String> currentBatch = [];
      await for (var item in stream) {
        if (currentBatch.length == batchLimit) {
          /// Batch limit reached - convert, yield results and clear current batch
          yield* convertBatch(
              currentBatch, iosSerializers, IOSPHAsset.serializer,
              batchJsonDecodeFn: batchJsonDecodeFn);
          currentBatch.clear();
        }

        /// Accumulate into batch
        currentBatch.add(item);
      }
      if (currentBatch.isNotEmpty) {
        /// Current batch is not empty because num results % batchLimit != 0
        /// Convert and yield remaining items
        yield* convertBatch(currentBatch, iosSerializers, IOSPHAsset.serializer,
            batchJsonDecodeFn: batchJsonDecodeFn);
      }
    } else {
      await for (var item in stream) {
        yield await convertSingle(item, iosSerializers, IOSPHAsset.serializer,
            jsonDecodeFn: jsonDecodeFn);
      }
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
  /// [jsonDecodeFn] - See [streamImageMetadata]
  ///
  /// Batch Processing Arguments:
  /// See use case and example at [streamImageMetadata]
  /// [batchConvert] - Control raw data conversion algorithm.
  /// if true, converts data strings from method channel into proper
  /// Json Maps in batches of [batchLimit] and then streams the results,
  /// sequentially converting each Map to [AndroidImageMediaData].
  /// Default is false
  ///
  /// [batchLimit] - If [batchConvert] enabled controls the size of
  /// the Iterable passed to [convertBatch]. Defaults to 20
  ///
  /// [batchJsonDecodeFn] - See [streamImageMetadata]
  ///
  /// Android Related Arguments:
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
  Stream<AndroidImageMediaData> androidImagesMetadata({
    int limit = 10,
    int offset = 0,
    JsonCallback jsonDecodeFn = defaultJsonDecode,
    bool batchConvert = false,
    int batchLimit = 20,
    BatchJsonCallback batchJsonDecodeFn = defaultBatchJsonDecode,
    Iterable<AndroidBaseColumn> baseColumns = const [idColumn],
    Iterable<AndroidMediaColumn> mediaColumns = const [
      AndroidMediaColumn.mime_type,
      AndroidMediaColumn.height,
      AndroidMediaColumn.width
    ],
    Iterable<AndroidImageColumn> imageColumns = const [
      AndroidImageColumn.description
    ],
  }) async* {
    List<String> columns = [];
    columns.addAll(baseColumns.map((e) => e.name) ?? _empty);
    columns.addAll(mediaColumns.map((e) => e.name) ?? _empty);
    columns.addAll(imageColumns.map((e) => e.name) ?? _empty);

    final stream = rawImageMetadata(
      limit: limit,
      offset: offset,
      columns: columns,
    );

    if (batchConvert) {
      List<String> currentBatch = [];
      await for (var item in stream) {
        if (currentBatch.length == batchLimit) {
          /// Batch limit reached - convert, yield results and clear current batch
          yield* convertBatch(currentBatch, androidSerializers,
              AndroidImageMediaData.serializer,
              batchJsonDecodeFn: batchJsonDecodeFn);
          currentBatch.clear();
        }

        /// Accumulate into batch
        currentBatch.add(item);
      }
      if (currentBatch.isNotEmpty) {
        /// Current batch is not empty because num results % batchLimit != 0
        /// Convert and yield remaining items
        yield* convertBatch(
            currentBatch, androidSerializers, AndroidImageMediaData.serializer,
            batchJsonDecodeFn: batchJsonDecodeFn);
      }
    } else {
      await for (var item in stream) {
        yield await convertSingle(
            item, androidSerializers, AndroidImageMediaData.serializer,
            jsonDecodeFn: jsonDecodeFn);
      }
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
  //TODO - design better mechanism for stream cancellation and support more than one open cursor
  Stream<String> rawImageMetadata({
    int limit = 10,
    int offset = 0,
    Iterable<String> columns = _empty,
  }) async* {
    int millis = 400;
    while (_galleryImageMetadataStreamLocked) {
      millis = millis < 2000 ? millis + 100 : millis;
      await Future.delayed(Duration(milliseconds: millis));
    }

    /// Using a broadcast stream so that underlying stream will exhaust
    /// itself when applying modifiers such as take(x)
    /// FIXME - Address this issue so that we don't have to use a broadcast stream
    yield* _rawImageMetadata(
      limit: limit,
      offset: offset,
      columns: columns,
    ).asBroadcastStream();
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
  Stream<String> _rawImageMetadata({
    int limit = 10,
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
          columns = _empty;
        } while (results != null && results.isNotEmpty);
      } catch (e) {
        print(e);
      }
      print('Stream over');
      _galleryImageMetadataStreamLocked = false;
    }
  }
}
