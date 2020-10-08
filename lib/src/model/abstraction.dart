// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:flutter_media_streamer/src/model/android.dart';
import 'package:flutter_media_streamer/src/model/ios.dart';

part 'abstraction.g.dart';

/// An [EnumClass] Representing an abstraction of the possible media types found
/// on each platform
class MediaStreamerType extends EnumClass {
  /// The [Serializer] object responsible for (de)serialization of this class' instances
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
    else
      return unknown;
  }
}

/// A data class representing an abstraction of information shared by both iOS and Android
abstract class AbstractMediaItem
    implements Built<AbstractMediaItem, AbstractMediaItemBuilder> {
  /// The [Serializer] object responsible for (de)serialization of this class' instances
  static Serializer<AbstractMediaItem> get serializer =>
      _$abstractMediaItemSerializer;

  /// The unique ID assigned by the platform to this media
  /// Android - _ID column on the MediaStore API
  /// iOS - The localIdentifier of this PHAsset
  String get id;

  /// The identifier used to request the actual media from the underlying platform
  /// On Android corresponds to the Content URI string and on iOS to PHAsset.localIdentifier
  String get mediaQueryIdentifier;

  /// The type of this media
  MediaStreamerType get mediaType;

  /// The width in Pixels of this media
  @nullable
  int get width;

  /// The height in Pixels of this media
  @nullable
  int get height;

  /// The date at which the media was modified in Milliseconds since Unix epoch
  @nullable
  int get dateModified;

  /// The date at which the media was created in Milliseconds since Unix epoch
  @nullable
  int get dateTaken;

  /// The duration in Seconds of this media (when this is a video)
  @nullable
  double get duration;

  /// Whether the user marked this media as favorite
  @nullable
  bool get isFavorite;

  AbstractMediaItem._();

  /// Factory constructor that initializes the underlying [Built]
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
  }) =>
      _$AbstractMediaItem._(
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

  /// Creates an [AbstractMediaItem] from an [IOSPHAsset]
  factory AbstractMediaItem.fromIOSPHAsset(IOSPHAsset asset) {
    return AbstractMediaItem(
      id: asset.localIdentifier,
      mediaQueryIdentifier: asset.localIdentifier,
      mediaType: MediaStreamerType.valueOfPlatform(asset.mediaType),
      width: asset.pixelWidth,
      height: asset.pixelHeight,
      dateModified: (asset.modificationDate * 1000).toInt(),
      dateTaken: (asset.creationDate * 1000).toInt(),
      duration: asset.duration,
      isFavorite: asset.isFavorite,
    );
  }

  /// Creates an [AbstractMediaItem] from an [AndroidImageMediaData]
  factory AbstractMediaItem.fromAndroidImageMediaData(
      AndroidImageMediaData mediaData) {
    return AbstractMediaItem(
      id: mediaData.id.toString(),
      mediaQueryIdentifier: mediaData.contentUri,
      mediaType: MediaStreamerType.valueOfPlatform(mediaData),
      width: mediaData.width,
      height: mediaData.height,
      dateModified: mediaData.dateModified,
      dateTaken: mediaData.dateTaken,
      duration: mediaData.duration != null
          ? mediaData.duration.toDouble() / 1000.0
          : null,
      isFavorite:
          mediaData.isFavorite != null ? mediaData.isFavorite > 0 : null,
    );
  }
}

@SerializersFor([
  MediaStreamerType,
  AbstractMediaItem,
])

/// A collection of [Serializers] responsible of handling (de)serialization of the Abstraction model classes
final Serializers abstractionSerializers = (_$abstractionSerializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
