import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/imports/utils.dart';

final String tableSavedMedia = 'saved_media';

class SavedMediaFields {
  static final String id = '_id';
  static final String mediaId = 'mediaId';
  static final String mediaType = 'mediaType';
  static final String title = 'title';
  static final String posterPath = 'posterPath';
  static final String releaseDate = 'releaseDate';

  static final List<String> columnNames = [id, mediaId, mediaType, title, posterPath, releaseDate];
}

class SavedMedia {
  int? id;
  late int mediaId;
  late MediaType mediaType;
  String? title;
  String? posterPath;
  DateTime? releaseDate;

  SavedMedia(this.mediaId, this.mediaType, {this.id, this.title, this.posterPath, this.releaseDate});

  Map<String, Object?> toJson() => {
        SavedMediaFields.id: id,
        SavedMediaFields.mediaId: mediaId,
        SavedMediaFields.mediaType: mediaType.index,
        SavedMediaFields.title: title,
        SavedMediaFields.posterPath: posterPath,
        SavedMediaFields.releaseDate: releaseDate != null ? releaseDate!.toIso8601String() : null,
      };

  static SavedMedia fromJson(Map<String, Object?> rawJson) {
    var releaseDate = rawJson[SavedMediaFields.releaseDate] as String?;
    var rawMediaType = rawJson[SavedMediaFields.mediaType] as int;
    return new SavedMedia(
      rawJson[SavedMediaFields.mediaId] as int,
      MediaType.values[rawMediaType],
      id: rawJson[SavedMediaFields.id] as int,
      title: rawJson[SavedMediaFields.title] as String?,
      posterPath: rawJson[SavedMediaFields.posterPath] as String?,
      releaseDate: parseDate(releaseDate),
    );
  }

  @override
  String toString() {
    return 'SavedMedia{id: $id, mediaId: $mediaId, mediaType: $mediaType, title: $title, '
        'releaseDate: $releaseDate, posterPath: $posterPath}';
  }
}
