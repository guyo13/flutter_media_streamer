// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:flutter_media_streamer/model/android.dart';
import 'package:flutter_media_streamer/model/ios.dart';

part 'abstraction.g.dart';

/// Enums
class MediaStreamerType extends EnumClass {
  static Serializer<MediaStreamerType> get serializer =>
      _$mediaStreamerTypeSerializer;

  static const MediaStreamerType image = _$mediaStreamerTypeImage;
  static const MediaStreamerType video = _$mediaStreamerTypeVideo;
  static const MediaStreamerType audio = _$mediaStreamerTypeAudio;
  static const MediaStreamerType unknown = _$mediaStreamerTypeUnknown;
  //TODO - figure out what other types

  const MediaStreamerType._(String name) : super(name);
  static BuiltSet<MediaStreamerType> get values => _$mstValues;
  static MediaStreamerType valueOf(String name) => _$mstValueOf(name);
  static MediaStreamerType valueOfPlatform(dynamic object) {
    if (object is IOSMediaType) {
      // iOS maps directly by name
      return valueOf(object.name);
    } else if (object is AndroidImageMediaData) {
      return image;
    }
    // TODO - other Android types when ready
    else return unknown;
  }
}
/// Data Classes

abstract class AbstractMediaItem implements Built<AbstractMediaItem, AbstractMediaItemBuilder> {
  static Serializer<AbstractMediaItem> get serializer => _$abstractMediaItemSerializer;

  String get id;
  String get mediaQueryIdentifier;
  MediaStreamerType get mediaType;
  @nullable
  int get width;
  @nullable
  int get height;
  /// In Milliseconds
  @nullable
  int get dateModified;
  @nullable
  int get dateTaken;
  /// In Seconds
  @nullable
  double get duration;
  @nullable
  bool get isFavorite;


  AbstractMediaItem._();
  factory AbstractMediaItem({
    String id,
    String mediaQueryIdentifier,
    MediaStreamerType mediaType,
    int width,
    int height,
    int dateModified,
    int dateTaken,
    double duration,
    bool isFavorite,
}) => _$AbstractMediaItem._(
    id: id,
    mediaQueryIdentifier: mediaQueryIdentifier,
    mediaType: mediaType,
    width: width,
    height: height,
    dateModified: dateModified,
    dateTaken: dateTaken,
    duration: duration,
    isFavorite: isFavorite,
  );
  factory AbstractMediaItem.fromIOSPHAsset(IOSPHAsset asset) {
    return AbstractMediaItem(
      id: asset.localIdentifier,
      mediaQueryIdentifier: asset.localIdentifier,
      mediaType: MediaStreamerType.valueOfPlatform(asset.mediaType),
      width: asset.pixelWidth,
      height: asset.pixelHeight,
      dateModified: (asset.modificationDate*1000).toInt(),
      dateTaken: (asset.creationDate*1000).toInt(),
      duration: asset.duration,
      isFavorite: asset.isFavorite,
    );
  }

  factory AbstractMediaItem.fromAndroidImageMediaData(AndroidImageMediaData mediaData) {
   return AbstractMediaItem(
     id: mediaData.id.toString(),
     mediaQueryIdentifier: mediaData.contentUri,
     mediaType: MediaStreamerType.valueOfPlatform(mediaData),
     width: mediaData.width,
     height: mediaData.height,
     dateModified: mediaData.dateModified,
     dateTaken: mediaData.dateTaken,
     duration: mediaData.duration != null ? mediaData.duration.toDouble()/1000.0 : null,
     isFavorite: mediaData.isFavorite != null ? mediaData.isFavorite > 0 : null,
   );
  }
}

@SerializersFor([
  MediaStreamerType,
  AbstractMediaItem,
])
final Serializers abstractionSerializers = (_$abstractionSerializers.toBuilder()
  ..add(Iso8601DateTimeSerializer())
  ..addPlugin(StandardJsonPlugin()))
    .build();