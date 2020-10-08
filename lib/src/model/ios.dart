// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

part 'ios.g.dart';

/// An [EnumClass] representing the possible Media Types defined by iOS
class IOSMediaType extends EnumClass {
  static Serializer<IOSMediaType> get serializer => _$iOSMediaTypeSerializer;

  static const IOSMediaType unknown = _$mediaTypeUnknown;
  static const IOSMediaType image = _$mediaTypeImage;
  static const IOSMediaType video = _$mediaTypeVideo;
  static const IOSMediaType audio = _$mediaTypeAudio;

  const IOSMediaType._(String name) : super(name);
  static BuiltSet<IOSMediaType> get values => _$iosmtValues;
  static IOSMediaType valueOf(String name) => _$iosmtValueOf(name);
}

/// An [EnumClass] representing the possible Media Subtypes defined by iOS
class IOSMediaSubtype extends EnumClass {
  static Serializer<IOSMediaSubtype> get serializer =>
      _$iOSMediaSubtypeSerializer;

  static const IOSMediaSubtype photoPanorma = _$mediaSubtypePhotoPanorama;
  static const IOSMediaSubtype photoHDR = _$mediaSubtypePhotoHDR;
  static const IOSMediaSubtype photoScreenshot = _$mediaSubtypePhotoScreenshot;
  static const IOSMediaSubtype photoLive = _$mediaSubtypePhotoLive;
  static const IOSMediaSubtype photoDepthEffect =
      _$mediaSubtypePhotoDepthEffect;
  static const IOSMediaSubtype videoStreamed = _$mediaSubtypeVideoStreamed;
  static const IOSMediaSubtype videoHighFrameRate =
      _$mediaSubtypeVideoHighFrameRate;
  static const IOSMediaSubtype videoTimelapse = _$mediaSubtypeVideoTimelapse;

  const IOSMediaSubtype._(String name) : super(name);
  static BuiltSet<IOSMediaSubtype> get values => _$iosmstValues;
  static IOSMediaSubtype valueOf(String name) => _$iosmstValueOf(name);
}

/// An [EnumClass] representing the possible asset Source Types defined by iOS
class IOSAssetSourceType extends EnumClass {
  static Serializer<IOSAssetSourceType> get serializer =>
      _$iOSAssetSourceTypeSerializer;

  static const IOSAssetSourceType cloudShared = _$assetSourceTypeCloudShared;
  static const IOSAssetSourceType userLibrary = _$assetSourceTypeUserLibrary;
  static const IOSAssetSourceType iTunesSynced = _$assetSourceTypeiTunesSynced;

  //FIXME - remove this value
  /// Not a real type - a default value returned by the plugin's Swift serializer
  static const IOSAssetSourceType unknown = _$assetSourceTypeUnknown;

  const IOSAssetSourceType._(String name) : super(name);
  static BuiltSet<IOSAssetSourceType> get values => _$iosastValues;
  static IOSAssetSourceType valueOf(String name) => _$iosastValueOf(name);
}

/// An [EnumClass] representing the possible Playback Styles defined by iOS
class IOSPlaybackStyle extends EnumClass {
  static Serializer<IOSPlaybackStyle> get serializer =>
      _$iOSPlaybackStyleSerializer;

  static const IOSPlaybackStyle image = _$playbackStyleImage;
  static const IOSPlaybackStyle imageAnimated = _$playbackStyleImageAnimated;
  static const IOSPlaybackStyle livePhoto = _$playbackStyleLivePhoto;
  static const IOSPlaybackStyle video = _$playbackStyleVideo;
  static const IOSPlaybackStyle videoLooping = _$playbackStyleVideoLooping;
  static const IOSPlaybackStyle unsupported = _$playbackStyleUnsupported;

  const IOSPlaybackStyle._(String name) : super(name);
  static BuiltSet<IOSPlaybackStyle> get values => _$iospsValues;
  static IOSPlaybackStyle valueOf(String name) => _$iospsValueOf(name);
}

/// An [EnumClass] representing the possible Burst Selection Types defined by iOS
class IOSBurstSelectionType extends EnumClass {
  static Serializer<IOSBurstSelectionType> get serializer =>
      _$iOSBurstSelectionTypeSerializer;

  static const IOSBurstSelectionType autoPick = _$burstSelectionTypeAutoPick;
  static const IOSBurstSelectionType userPick = _$burstSelectionTypeUserPick;

  const IOSBurstSelectionType._(String name) : super(name);
  static BuiltSet<IOSBurstSelectionType> get values => _$iosbstValues;
  static IOSBurstSelectionType valueOf(String name) => _$iosbstValueOf(name);
}

/// A data class representing an iOS CLLocation object
abstract class IOSLocation implements Built<IOSLocation, IOSLocationBuilder> {
  static Serializer<IOSLocation> get serializer => _$iOSLocationSerializer;

  double get latitude;
  double get longitude;
  @nullable
  double get altitude;
  @nullable
  int get floor;
  @nullable
  double get horizontalAccuracy;
  @nullable
  double get verticalAccuracy;
  @nullable
  double get speedAccuracy;
  @nullable
  double get courseAccuracy;
  double get timestamp;
  @nullable
  double get speed;
  @nullable
  double get course;

  IOSLocation._();
  factory IOSLocation({
    double latitude,
    double longitude,
    double altitude,
    int floor,
    double horizontalAccuracy,
    double verticalAccuracy,
    double speedAccuracy,
    double courseAccuracy,
    double timestamp,
    double speed,
    double course,
  }) =>
      _$IOSLocation._(
        latitude: latitude,
        longitude: longitude,
        altitude: altitude,
        floor: floor,
        horizontalAccuracy: horizontalAccuracy,
        verticalAccuracy: verticalAccuracy,
        speedAccuracy: speedAccuracy,
        courseAccuracy: courseAccuracy,
        timestamp: timestamp,
        speed: speed,
        course: course,
      );
}

/// Data class representing an iOS PHAsset
abstract class IOSPHAsset implements Built<IOSPHAsset, IOSPHAssetBuilder> {
  static Serializer<IOSPHAsset> get serializer => _$iOSPHAssetSerializer;

  /// The PHObject's localIdentifier
  String get localIdentifier;

  /// The PHAsset's Media Type
  IOSMediaType get mediaType;

  /// A list of all Media Subtypes this asset is considered to be
  BuiltSet<IOSMediaSubtype> get mediaSubtypes;

  /// The source of this asset
  IOSAssetSourceType get sourceType;

  /// The width in Pixels of this media
  int get pixelWidth;

  /// The height in Pixels of this media
  int get pixelHeight;

  /// The date at which the media was created in seconds since Unix epoch, can be multiplied to get milliseconds
  @nullable
  double get creationDate;

  /// The date at which the media was last modified in seconds since Unix epoch, can be multiplied to get milliseconds
  @nullable
  double get modificationDate;

  /// The location information attached to this media
  @nullable
  IOSLocation get location;

  /// The duration of this media in seconds (if video)
  double get duration;

  /// Whether the user marked this media as favorite
  bool get isFavorite;

  /// Whether the user marked this media as hidden
  bool get isHidden;
  @nullable
  IOSPlaybackStyle get playbackStyle;

  /// Whether the this asset represents a collection of burst images
  bool get representsBurst;

  /// The Burst Identifier of this asset if it is part of a burst
  @nullable
  String get burstIdentifier;

  /// The Burst Selection type if this asset was selected from a collection of burst images
  @nullable
  BuiltSet<IOSBurstSelectionType> get burstSelectionTypes;

  IOSPHAsset._();
  factory IOSPHAsset({
    String localIdentifier,
    IOSMediaType mediaType,
    BuiltSet<IOSMediaSubtype> mediaSubtypes,
    IOSAssetSourceType sourceType,
    int pixelWidth,
    int pixelHeight,
    double creationDate,
    double modificationDate,
    IOSLocation location,
    double duration,
    bool isFavorite,
    bool isHidden,
    IOSPlaybackStyle playbackStyle,
    bool representsBurst,
    String burstIdentifier,
    BuiltSet<IOSBurstSelectionType> burstSelectionTypes,
  }) =>
      _$IOSPHAsset._(
        localIdentifier: localIdentifier,
        mediaType: mediaType,
        mediaSubtypes: mediaSubtypes,
        sourceType: sourceType,
        pixelWidth: pixelWidth,
        pixelHeight: pixelHeight,
        creationDate: creationDate,
        modificationDate: modificationDate,
        location: location,
        duration: duration,
        isFavorite: isFavorite,
        isHidden: isHidden,
        playbackStyle: playbackStyle,
        representsBurst: representsBurst,
        burstIdentifier: burstIdentifier,
        burstSelectionTypes: burstSelectionTypes,
      );
}

@SerializersFor([
  IOSMediaType,
  IOSMediaSubtype,
  IOSAssetSourceType,
  IOSPlaybackStyle,
  IOSBurstSelectionType,
  IOSLocation,
  IOSPHAsset,
])
final Serializers iosSerializers = (_$iosSerializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
