import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';

part 'android.g.dart';

/// Enums
class AndroidBaseColumn extends EnumClass {
  static Serializer<AndroidBaseColumn> get serializer => _$androidBaseColumnSerializer;

  /// BaseColumns constants as defined in BaseColumns class

  @BuiltValueEnumConst(wireName: '_id')
  static const AndroidBaseColumn ID = _$ID;
  @BuiltValueEnumConst(wireName: '_count')
  static const AndroidBaseColumn COUNT = _$COUNT;

  const AndroidBaseColumn._(String name) : super(name);
  static BuiltSet<AndroidBaseColumn> get values => _$abcValues;
  static AndroidBaseColumn valueOf(String name)  => _$abcValueOf(name);
}

class AndroidMediaColumn extends EnumClass {
  static Serializer<AndroidMediaColumn> get serializer => _$androidMediaColumnSerializer;

  /// MediaColumns constants as defined in MediaStore class
  /// Not including deprecated fields (_data)

  static const AndroidMediaColumn album = _$album;
  static const AndroidMediaColumn album_artist = _$album_artist;
  static const AndroidMediaColumn artist = _$artist;
  static const AndroidMediaColumn author = _$author;
  static const AndroidMediaColumn bitrate = _$bitrate;
  static const AndroidMediaColumn bucket_display_name = _$bucket_display_name;
  static const AndroidMediaColumn bucket_id = _$bucket_id;
  static const AndroidMediaColumn capture_framerate = _$capture_framerate;
  static const AndroidMediaColumn cd_track_number = _$cd_track_number;
  static const AndroidMediaColumn compilation = _$compilation;
  static const AndroidMediaColumn composer = _$composer;
  static const AndroidMediaColumn date_added = _$date_added;
  static const AndroidMediaColumn date_expires = _$date_expires;
  static const AndroidMediaColumn date_modified = _$date_modified;
  static const AndroidMediaColumn datetaken = _$datetaken;
  static const AndroidMediaColumn disc_number = _$disc_number;
  @BuiltValueEnumConst(wireName: '_display_name')
  static const AndroidMediaColumn display_name = _$display_name;
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
  @BuiltValueEnumConst(wireName: '_size')
  static const AndroidMediaColumn size = _$size;
  static const AndroidMediaColumn title = _$title;
  static const AndroidMediaColumn volume_name = _$volume_name;
  static const AndroidMediaColumn width = _$width;
  static const AndroidMediaColumn writer = _$writer;
  static const AndroidMediaColumn xmp = _$xmp;
  static const AndroidMediaColumn year = _$mediaYear;

  const AndroidMediaColumn._(String name) : super(name);
  static BuiltSet<AndroidMediaColumn> get values => _$amcValues;
  static AndroidMediaColumn valueOf(String name)  => _$amcValueOf(name);
}

class AndroidImageColumn extends EnumClass {
  static Serializer<AndroidImageColumn> get serializer => _$androidImageColumnSerializer;

  /// ImageColumns constants as defined in MediaStore class
  /// Not including deprecated fields (latitude, longitude, mini_thumb_magic, picasa_id)

  static const AndroidImageColumn description = _$description;
  static const AndroidImageColumn exposure_time = _$exposure_time;
  static const AndroidImageColumn f_number = _$f_number;
  static const AndroidImageColumn iso = _$iso;
  static const AndroidImageColumn isprivate = _$isprivate;
  static const AndroidImageColumn scene_capture_type = _$scene_capture_type;


  const AndroidImageColumn._(String name) : super(name);
  static BuiltSet<AndroidImageColumn> get values => _$aicValues;
  static AndroidImageColumn valueOf(String name)  => _$aicValueOf(name);
}

class AndroidAudioColumn extends EnumClass {
  static Serializer<AndroidAudioColumn> get serializer => _$androidAudioColumnSerializer;

  /// AudioColumns constants as defined in MediaStore class
  /// Not including deprecated fields (album_key, artist_key, genre_key, title_key)

  static const AndroidAudioColumn album_id = _$album_id;
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
  static AndroidAudioColumn valueOf(String name)  => _$aacValueOf(name);
}

@SerializersFor([AndroidBaseColumn, AndroidMediaColumn, AndroidImageColumn, AndroidAudioColumn])
final Serializers androidSerializers = (_$androidSerializers.toBuilder()
  ..add(Iso8601DateTimeSerializer())
  ..addPlugin(StandardJsonPlugin()))
    .build();