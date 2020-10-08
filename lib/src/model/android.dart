// Copyright (c) 2020, Guy Or Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

part 'android.g.dart';

/// An [EnumClass] representing possible values of Android MediaStore Base Columns
class AndroidBaseColumn extends EnumClass {
  static Serializer<AndroidBaseColumn> get serializer =>
      _$androidBaseColumnSerializer;

  static AndroidBaseColumn get id => _id;
  static AndroidBaseColumn get count => _count;
  static const AndroidBaseColumn _id = _$id;
  static const AndroidBaseColumn _count = _$count;

  const AndroidBaseColumn._(String name) : super(name);
  static BuiltSet<AndroidBaseColumn> get values => _$abcValues;
  static AndroidBaseColumn valueOf(String name) => _$abcValueOf(name);
}

/// A workaround for naming the enum value "_ID"
const AndroidBaseColumn idColumn = AndroidBaseColumn._id;

/// A workaround for naming the enum value "_COUNT"
const AndroidBaseColumn countColumn = AndroidBaseColumn._count;

/// An [EnumClass] representing possible values of Android MediaStore Media Columns
/// Not including deprecated fields (_data)
class AndroidMediaColumn extends EnumClass {
  static Serializer<AndroidMediaColumn> get serializer =>
      _$androidMediaColumnSerializer;

  static const AndroidMediaColumn album = _$mediaAlbum;
  static const AndroidMediaColumn album_artist = _$album_artist;
  static const AndroidMediaColumn artist = _$mediaArtist;
  static const AndroidMediaColumn author = _$author;
  static const AndroidMediaColumn bitrate = _$bitrate;
  static const AndroidMediaColumn bucket_display_name = _$bucket_display_name;
  static const AndroidMediaColumn bucket_id = _$bucket_id;
  static const AndroidMediaColumn capture_framerate = _$capture_framerate;
  static const AndroidMediaColumn cd_track_number = _$cd_track_number;
  static const AndroidMediaColumn compilation = _$compilation;
  static const AndroidMediaColumn composer = _$composer;
  static const AndroidMediaColumn date_added = _$mediaDateAdded;
  static const AndroidMediaColumn date_expires = _$mediaDateExpires;
  static const AndroidMediaColumn date_modified = _$mediaDateModified;
  static const AndroidMediaColumn datetaken = _$datetaken;
  static const AndroidMediaColumn disc_number = _$disc_number;
  static AndroidMediaColumn get displayName => _display_name;
  static const AndroidMediaColumn _display_name = _$display_name;
  static const AndroidMediaColumn document_id = _$document_id;
  static const AndroidMediaColumn duration = _$duration;
  static const AndroidMediaColumn generation_added = _$generation_added;
  static const AndroidMediaColumn generation_modified = _$generation_modified;
  static const AndroidMediaColumn genre = _$mediaGenre;
  static const AndroidMediaColumn height = _$height;
  static const AndroidMediaColumn instance_id = _$instance_id;
  static const AndroidMediaColumn is_download = _$is_download;
  static const AndroidMediaColumn is_drm = _$is_drm;
  static const AndroidMediaColumn is_favorite = _$is_favorite;
  static const AndroidMediaColumn is_pending = _$is_pending;
  static const AndroidMediaColumn is_trashed = _$is_trashed;
  static const AndroidMediaColumn mime_type = _$mime_type;
  static const AndroidMediaColumn num_tracks = _$num_tracks;
  static const AndroidMediaColumn orientation = _$orientation;
  static const AndroidMediaColumn original_document_id = _$original_document_id;
  static const AndroidMediaColumn owner_package_name = _$owner_package_name;
  static const AndroidMediaColumn relative_path = _$relative_path;
  static const AndroidMediaColumn resolution = _$resolution;
  static AndroidMediaColumn get size => _size;
  static const AndroidMediaColumn _size = _$size;
  static const AndroidMediaColumn title = _$title;
  static const AndroidMediaColumn volume_name = _$volume_name;
  static const AndroidMediaColumn width = _$width;
  static const AndroidMediaColumn writer = _$writer;
  static const AndroidMediaColumn xmp = _$xmp;
  static const AndroidMediaColumn year = _$mediaYear;

  const AndroidMediaColumn._(String name) : super(name);
  static BuiltSet<AndroidMediaColumn> get values => _$amcValues;
  static AndroidMediaColumn valueOf(String name) => _$amcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Image Columns
/// Not including deprecated fields (latitude, longitude, mini_thumb_magic, picasa_id)
class AndroidImageColumn extends EnumClass {
  static Serializer<AndroidImageColumn> get serializer =>
      _$androidImageColumnSerializer;

  static const AndroidImageColumn description = _$description;
  static const AndroidImageColumn exposure_time = _$exposure_time;
  static const AndroidImageColumn f_number = _$f_number;
  static const AndroidImageColumn iso = _$iso;
  static const AndroidImageColumn isprivate = _$isprivate;
  static const AndroidImageColumn scene_capture_type = _$scene_capture_type;

  const AndroidImageColumn._(String name) : super(name);
  static BuiltSet<AndroidImageColumn> get values => _$aicValues;
  static AndroidImageColumn valueOf(String name) => _$aicValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Audio Columns
/// Not including deprecated fields (album_key, artist_key, genre_key, title_key)
class AndroidAudioColumn extends EnumClass {
  static Serializer<AndroidAudioColumn> get serializer =>
      _$androidAudioColumnSerializer;

  static const AndroidAudioColumn album_id = _$audioAlbumId;
  static const AndroidAudioColumn artist_id = _$artist_id;
  static const AndroidAudioColumn bookmark = _$bookmark;
  static const AndroidAudioColumn genre = _$audioGenre;
  static const AndroidAudioColumn genre_id = _$genre_id;
  static const AndroidAudioColumn is_alarm = _$is_alarm;
  static const AndroidAudioColumn is_audiobook = _$is_audiobook;
  static const AndroidAudioColumn is_music = _$is_music;
  static const AndroidAudioColumn is_notification = _$is_notification;
  static const AndroidAudioColumn is_podcast = _$is_podcast;
  static const AndroidAudioColumn is_ringtone = _$is_ringtone;
  static const AndroidAudioColumn title_resource_uri = _$title_resource_uri;
  static const AndroidAudioColumn track = _$track;
  static const AndroidAudioColumn year = _$audioYear;

  const AndroidAudioColumn._(String name) : super(name);
  static BuiltSet<AndroidAudioColumn> get values => _$aacValues;
  static AndroidAudioColumn valueOf(String name) => _$aacValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Artist Columns
/// Not including deprecated fields (artist_key)
class AndroidArtistColumn extends EnumClass {
  static Serializer<AndroidArtistColumn> get serializer =>
      _$androidArtistColumnSerializer;

  static const AndroidArtistColumn artist = _$artist;
  static const AndroidArtistColumn number_of_albums = _$number_of_albums;
  static const AndroidArtistColumn number_of_tracks = _$number_of_tracks;

  const AndroidArtistColumn._(String name) : super(name);
  static BuiltSet<AndroidArtistColumn> get values => _$aarcValues;
  static AndroidArtistColumn valueOf(String name) => _$aarcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Album Columns
/// Not including deprecated fields (album_art, album_key, artist_key)
class AndroidAlbumColumn extends EnumClass {
  static Serializer<AndroidAlbumColumn> get serializer =>
      _$androidAlbumColumnSerializer;

  static const AndroidAlbumColumn album = _$album;
  static const AndroidAlbumColumn album_id = _$album_id;
  static const AndroidAlbumColumn artist = _$albumArtist;
  static const AndroidAlbumColumn artist_id = _$albumArtistId;
  static const AndroidAlbumColumn minyear = _$albumMinYear;
  static const AndroidAlbumColumn maxyear = _$albumMaxYear;
  static const AndroidAlbumColumn numsongs = _$albumNumsongs;
  static const AndroidAlbumColumn numsongs_by_artist = _$albumNumSongsByArtist;

  const AndroidAlbumColumn._(String name) : super(name);
  static BuiltSet<AndroidAlbumColumn> get values => _$aalcValues;
  static AndroidAlbumColumn valueOf(String name) => _$aalcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Genre Columns
class AndroidGenreColumn extends EnumClass {
  static Serializer<AndroidGenreColumn> get serializer =>
      _$androidGenreColumnSerializer;

  @BuiltValueEnumConst(wireName: 'name')
  static const AndroidGenreColumn genreName = _$genreName;

  const AndroidGenreColumn._(String name) : super(name);
  static BuiltSet<AndroidGenreColumn> get values => _$agcValues;
  static AndroidGenreColumn valueOf(String name) => _$agcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Playlist Columns
/// Not including deprecated fields (_data)
class AndroidPlaylistColumn extends EnumClass {
  static Serializer<AndroidPlaylistColumn> get serializer =>
      _$androidPlaylistColumnSerializer;

  //FIXME - find a workaround because this value will be serialized as 'playlistName'
  @BuiltValueEnumConst(wireName: 'name')
  static const AndroidPlaylistColumn playlistName = _$playlistName;
  static const AndroidPlaylistColumn date_added = _$playlistDateAdded;
  static const AndroidPlaylistColumn date_modified = _$playlisyDateModified;

  const AndroidPlaylistColumn._(String name) : super(name);
  static BuiltSet<AndroidPlaylistColumn> get values => _$apcValues;
  static AndroidPlaylistColumn valueOf(String name) => _$apcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore Download Columns
class AndroidDownloadColumn extends EnumClass {
  static Serializer<AndroidDownloadColumn> get serializer =>
      _$androidDownloadColumnSerializer;

  static const AndroidDownloadColumn download_uri = _$download_uri;
  static const AndroidDownloadColumn referer_uri = _$referer_uri;

  const AndroidDownloadColumn._(String name) : super(name);
  static BuiltSet<AndroidDownloadColumn> get values => _$adcValues;
  static AndroidDownloadColumn valueOf(String name) => _$adcValueOf(name);
}

/// An [EnumClass] representing possible values of Android MediaStore File Columns
class AndroidFileColumn extends EnumClass {
  static Serializer<AndroidFileColumn> get serializer =>
      _$androidFileColumnSerializer;

  static const AndroidFileColumn media_type = _$fileMediaType;
  static const AndroidFileColumn mime_type = _$fileMimeType;
  static const AndroidFileColumn parent = _$fileParent;

  const AndroidFileColumn._(String name) : super(name);
  static BuiltSet<AndroidFileColumn> get values => _$afcValues;
  static AndroidFileColumn valueOf(String name) => _$afcValueOf(name);
}

/// Defines the possible File Media Types in Android MediaStore API
enum FileMediaTypes {
  MEDIA_TYPE_NONE,
  MEDIA_TYPE_IMAGE,
  MEDIA_TYPE_AUDIO,
  MEDIA_TYPE_VIDEO,
  MEDIA_TYPE_PLAYLIST,
  MEDIA_TYPE_SUBTITLE,
  MEDIA_TYPE_DOCUMENT
}

/// An [EnumClass] representing possible values of Android MediaStore Video Columns
/// Not including deprecated fields (latitude, longitude, mini_thumb_magic)
class AndroidVideoColumn extends EnumClass {
  static Serializer<AndroidVideoColumn> get serializer =>
      _$androidVideoColumnSerializer;

  static const AndroidVideoColumn bookmark = _$videoBookmark;
  static const AndroidVideoColumn category = _$category;
  static const AndroidVideoColumn color_range = _$color_range;
  static const AndroidVideoColumn color_standard = _$color_standard;
  static const AndroidVideoColumn color_transfer = _$color_transfer;
  static const AndroidVideoColumn description = _$videoDescription;
  static const AndroidVideoColumn isprivate = _$videoIsPrivate;
  static const AndroidVideoColumn mini_thumb_magic = _$videoMiniThumbMagic;
  static const AndroidVideoColumn tags = _$videoTags;

  const AndroidVideoColumn._(String name) : super(name);
  static BuiltSet<AndroidVideoColumn> get values => _$avcValues;
  static AndroidVideoColumn valueOf(String name) => _$avcValueOf(name);
}

/// A data class which represents an Image Media as passed by FlutterMediaStreamer Android Plugin.
/// It can contain values of any of the columns defined by [AndroidBaseColumn], [AndroidMediaColumn]
/// and [AndroidImageColumn], depending on availability, the API level of the device and the requested columns
abstract class AndroidImageMediaData
    implements Built<AndroidImageMediaData, AndroidImageMediaDataBuilder> {
  static Serializer<AndroidImageMediaData> get serializer =>
      _$androidImageMediaDataSerializer;

  String get contentUri;

  /// The unique id assigned by MediaStore
  int get id;
  @nullable
  int get count;

  @nullable
  String get description;
  @nullable
  String get exposureTime;
  @nullable
  String get fNumber;
  @nullable
  int get iso;
  @nullable
  int get isPrivate;
  @nullable
  int get sceneCaptureType;

  @nullable
  String get album;
  @nullable
  String get albumArtist;
  @nullable
  String get artist;
  @nullable
  String get author;
  @nullable
  int get bitrate;
  @nullable
  String get bucketDisplayName;
  @nullable
  int get bucketId;
  @nullable
  double get captureFramerate;
  @nullable
  String get cdTrackNumber;
  @nullable
  String get compilation;
  @nullable
  String get composer;

  /// The time at which the media was added by MediaStore in Milliseconds since Unix epoch
  @nullable
  int get dateAdded;

  /// The time at which the media will expire in Milliseconds since Unix epoch
  @nullable
  int get dateExpires;

  /// The time at which the media was last modified in Milliseconds since Unix epoch
  @nullable
  int get dateModified;

  /// The time at which the media was taken (Exif) in Milliseconds since Unix epoch
  @nullable
  int get dateTaken;
  @nullable
  String get discNumber;
  @nullable
  String get displayName;
  @nullable
  String get documentId;

  /// The duration of the media in Milliseconds
  @nullable
  int get duration;
  @nullable
  int get generationAdded;
  @nullable
  int get generationModified;
  @nullable
  String get genre;
  @nullable
  int get height;
  @nullable
  String get instanceId;
  @nullable
  int get isDownload;
  @nullable
  int get isDrm;
  @nullable
  int get isFavorite;
  @nullable
  int get isPending;
  @nullable
  int get isTrashed;
  @nullable
  int get orientation;
  @nullable
  String get originalDocumentId;
  @nullable
  String get ownerPackageName;
  @nullable
  String get relativePath;
  @nullable
  String get resolution;
  @nullable
  int get size;
  @nullable
  String get title;
  @nullable
  String get volumeName;
  @nullable
  int get width;
  @nullable
  String get writer;
  @nullable
  String get xmpBase64;
  @nullable
  int get year;

  AndroidImageMediaData._();

  /// Factory constructor that initializes the underlying [Built]
  factory AndroidImageMediaData({
    String contentUri,
    int id,
    int count,
    String description,
    String exposureTime,
    String fNumber,
    int iso,
    int isPrivate,
    int sceneCaptureType,
    String album,
    String albumArtist,
    String artist,
    String author,
    int bitrate,
    String bucketDisplayName,
    int bucketId,
    double captureFramerate,
    String cdTrackNumber,
    String compilation,
    String composer,
    int dateAdded,
    int dateExpires,
    int dateModified,
    int dateTaken,
    String discNumber,
    String displayName,
    String documentId,
    int duration,
    int generationAdded,
    int generationModified,
    String genre,
    int height,
    String instanceId,
    int isDownload,
    int isDrm,
    int isFavorite,
    int isPending,
    int isTrashed,
    int orientation,
    String originalDocumentId,
    String ownerPackageName,
    String relativePath,
    String resolution,
    int size,
    String title,
    String volumeName,
    int width,
    String writer,
    String xmpBase64,
    int year,
  }) =>
      _$AndroidImageMediaData._(
        id: id,
        count: count,
        description: description,
        exposureTime: exposureTime,
        fNumber: fNumber,
        iso: iso,
        isPrivate: isPrivate,
        sceneCaptureType: sceneCaptureType,
        album: album,
        albumArtist: albumArtist,
        artist: artist,
        author: author,
        bitrate: bitrate,
        bucketDisplayName: bucketDisplayName,
        bucketId: bucketId,
        captureFramerate: captureFramerate,
        cdTrackNumber: cdTrackNumber,
        compilation: compilation,
        composer: composer,
        dateAdded: dateAdded,
        dateExpires: dateExpires,
        dateModified: dateModified,
        dateTaken: dateTaken,
        discNumber: discNumber,
        displayName: displayName,
        documentId: documentId,
        duration: duration,
        generationAdded: generationAdded,
        generationModified: generationModified,
        genre: genre,
        height: height,
        instanceId: instanceId,
        isDownload: isDownload,
        isDrm: isDrm,
        isFavorite: isFavorite,
        isPending: isPending,
        isTrashed: isTrashed,
        orientation: orientation,
        originalDocumentId: originalDocumentId,
        ownerPackageName: ownerPackageName,
        relativePath: relativePath,
        resolution: resolution,
        size: size,
        title: title,
        volumeName: volumeName,
        width: width,
        writer: writer,
        xmpBase64: xmpBase64,
        year: year,
      );
}

@SerializersFor([
  AndroidBaseColumn,
  AndroidMediaColumn,
  AndroidImageColumn,
  AndroidAudioColumn,
  AndroidArtistColumn,
  AndroidAlbumColumn,
  AndroidGenreColumn,
  AndroidPlaylistColumn,
  AndroidDownloadColumn,
  AndroidFileColumn,
  AndroidVideoColumn,
  AndroidImageMediaData,
])

/// A collection of [Serializers] responsible of handling (de)serialization of the Android model classes
final Serializers androidSerializers = (_$androidSerializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
