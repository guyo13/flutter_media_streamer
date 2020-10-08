// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'abstraction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MediaStreamerType _$mediaStreamerTypeImage =
    const MediaStreamerType._('image');
const MediaStreamerType _$mediaStreamerTypeVideo =
    const MediaStreamerType._('video');
const MediaStreamerType _$mediaStreamerTypeAudio =
    const MediaStreamerType._('audio');
const MediaStreamerType _$mediaStreamerTypeUnknown =
    const MediaStreamerType._('unknown');

MediaStreamerType _$mstValueOf(String name) {
  switch (name) {
    case 'image':
      return _$mediaStreamerTypeImage;
    case 'video':
      return _$mediaStreamerTypeVideo;
    case 'audio':
      return _$mediaStreamerTypeAudio;
    case 'unknown':
      return _$mediaStreamerTypeUnknown;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<MediaStreamerType> _$mstValues =
    new BuiltSet<MediaStreamerType>(const <MediaStreamerType>[
  _$mediaStreamerTypeImage,
  _$mediaStreamerTypeVideo,
  _$mediaStreamerTypeAudio,
  _$mediaStreamerTypeUnknown,
]);

Serializers _$abstractionSerializers = (new Serializers().toBuilder()
      ..add(AbstractMediaItem.serializer)
      ..add(MediaStreamerType.serializer))
    .build();
Serializer<MediaStreamerType> _$mediaStreamerTypeSerializer =
    new _$MediaStreamerTypeSerializer();
Serializer<AbstractMediaItem> _$abstractMediaItemSerializer =
    new _$AbstractMediaItemSerializer();

class _$MediaStreamerTypeSerializer
    implements PrimitiveSerializer<MediaStreamerType> {
  @override
  final Iterable<Type> types = const <Type>[MediaStreamerType];
  @override
  final String wireName = 'MediaStreamerType';

  @override
  Object serialize(Serializers serializers, MediaStreamerType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  MediaStreamerType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MediaStreamerType.valueOf(serialized as String);
}

class _$AbstractMediaItemSerializer
    implements StructuredSerializer<AbstractMediaItem> {
  @override
  final Iterable<Type> types = const [AbstractMediaItem, _$AbstractMediaItem];
  @override
  final String wireName = 'AbstractMediaItem';

  @override
  Iterable<Object> serialize(Serializers serializers, AbstractMediaItem object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'mediaQueryIdentifier',
      serializers.serialize(object.mediaQueryIdentifier,
          specifiedType: const FullType(String)),
      'mediaType',
      serializers.serialize(object.mediaType,
          specifiedType: const FullType(MediaStreamerType)),
    ];
    if (object.width != null) {
      result
        ..add('width')
        ..add(serializers.serialize(object.width,
            specifiedType: const FullType(int)));
    }
    if (object.height != null) {
      result
        ..add('height')
        ..add(serializers.serialize(object.height,
            specifiedType: const FullType(int)));
    }
    if (object.dateModified != null) {
      result
        ..add('dateModified')
        ..add(serializers.serialize(object.dateModified,
            specifiedType: const FullType(int)));
    }
    if (object.dateTaken != null) {
      result
        ..add('dateTaken')
        ..add(serializers.serialize(object.dateTaken,
            specifiedType: const FullType(int)));
    }
    if (object.duration != null) {
      result
        ..add('duration')
        ..add(serializers.serialize(object.duration,
            specifiedType: const FullType(double)));
    }
    if (object.isFavorite != null) {
      result
        ..add('isFavorite')
        ..add(serializers.serialize(object.isFavorite,
            specifiedType: const FullType(bool)));
    }
    return result;
  }

  @override
  AbstractMediaItem deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new AbstractMediaItemBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'mediaQueryIdentifier':
          result.mediaQueryIdentifier = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'mediaType':
          result.mediaType = serializers.deserialize(value,
                  specifiedType: const FullType(MediaStreamerType))
              as MediaStreamerType;
          break;
        case 'width':
          result.width = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'height':
          result.height = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'dateModified':
          result.dateModified = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'dateTaken':
          result.dateTaken = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int;
          break;
        case 'duration':
          result.duration = serializers.deserialize(value,
              specifiedType: const FullType(double)) as double;
          break;
        case 'isFavorite':
          result.isFavorite = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$AbstractMediaItem extends AbstractMediaItem {
  @override
  final String id;
  @override
  final String mediaQueryIdentifier;
  @override
  final MediaStreamerType mediaType;
  @override
  final int width;
  @override
  final int height;
  @override
  final int dateModified;
  @override
  final int dateTaken;
  @override
  final double duration;
  @override
  final bool isFavorite;

  factory _$AbstractMediaItem(
          [void Function(AbstractMediaItemBuilder) updates]) =>
      (new AbstractMediaItemBuilder()..update(updates)).build();

  _$AbstractMediaItem._(
      {this.id,
      this.mediaQueryIdentifier,
      this.mediaType,
      this.width,
      this.height,
      this.dateModified,
      this.dateTaken,
      this.duration,
      this.isFavorite})
      : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('AbstractMediaItem', 'id');
    }
    if (mediaQueryIdentifier == null) {
      throw new BuiltValueNullFieldError(
          'AbstractMediaItem', 'mediaQueryIdentifier');
    }
    if (mediaType == null) {
      throw new BuiltValueNullFieldError('AbstractMediaItem', 'mediaType');
    }
  }

  @override
  AbstractMediaItem rebuild(void Function(AbstractMediaItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AbstractMediaItemBuilder toBuilder() =>
      new AbstractMediaItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AbstractMediaItem &&
        id == other.id &&
        mediaQueryIdentifier == other.mediaQueryIdentifier &&
        mediaType == other.mediaType &&
        width == other.width &&
        height == other.height &&
        dateModified == other.dateModified &&
        dateTaken == other.dateTaken &&
        duration == other.duration &&
        isFavorite == other.isFavorite;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc($jc(0, id.hashCode),
                                    mediaQueryIdentifier.hashCode),
                                mediaType.hashCode),
                            width.hashCode),
                        height.hashCode),
                    dateModified.hashCode),
                dateTaken.hashCode),
            duration.hashCode),
        isFavorite.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('AbstractMediaItem')
          ..add('id', id)
          ..add('mediaQueryIdentifier', mediaQueryIdentifier)
          ..add('mediaType', mediaType)
          ..add('width', width)
          ..add('height', height)
          ..add('dateModified', dateModified)
          ..add('dateTaken', dateTaken)
          ..add('duration', duration)
          ..add('isFavorite', isFavorite))
        .toString();
  }
}

class AbstractMediaItemBuilder
    implements Builder<AbstractMediaItem, AbstractMediaItemBuilder> {
  _$AbstractMediaItem _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _mediaQueryIdentifier;
  String get mediaQueryIdentifier => _$this._mediaQueryIdentifier;
  set mediaQueryIdentifier(String mediaQueryIdentifier) =>
      _$this._mediaQueryIdentifier = mediaQueryIdentifier;

  MediaStreamerType _mediaType;
  MediaStreamerType get mediaType => _$this._mediaType;
  set mediaType(MediaStreamerType mediaType) => _$this._mediaType = mediaType;

  int _width;
  int get width => _$this._width;
  set width(int width) => _$this._width = width;

  int _height;
  int get height => _$this._height;
  set height(int height) => _$this._height = height;

  int _dateModified;
  int get dateModified => _$this._dateModified;
  set dateModified(int dateModified) => _$this._dateModified = dateModified;

  int _dateTaken;
  int get dateTaken => _$this._dateTaken;
  set dateTaken(int dateTaken) => _$this._dateTaken = dateTaken;

  double _duration;
  double get duration => _$this._duration;
  set duration(double duration) => _$this._duration = duration;

  bool _isFavorite;
  bool get isFavorite => _$this._isFavorite;
  set isFavorite(bool isFavorite) => _$this._isFavorite = isFavorite;

  AbstractMediaItemBuilder();

  AbstractMediaItemBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _mediaQueryIdentifier = _$v.mediaQueryIdentifier;
      _mediaType = _$v.mediaType;
      _width = _$v.width;
      _height = _$v.height;
      _dateModified = _$v.dateModified;
      _dateTaken = _$v.dateTaken;
      _duration = _$v.duration;
      _isFavorite = _$v.isFavorite;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AbstractMediaItem other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$AbstractMediaItem;
  }

  @override
  void update(void Function(AbstractMediaItemBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$AbstractMediaItem build() {
    final _$result = _$v ??
        new _$AbstractMediaItem._(
            id: id,
            mediaQueryIdentifier: mediaQueryIdentifier,
            mediaType: mediaType,
            width: width,
            height: height,
            dateModified: dateModified,
            dateTaken: dateTaken,
            duration: duration,
            isFavorite: isFavorite);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
