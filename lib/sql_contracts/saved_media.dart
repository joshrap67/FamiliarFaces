import 'package:familiar_faces/imports/utils.dart';

final String tableSavedMedia = 'saved_media';

class SavedMediaFields {
  static final String id = '_id';
  static final String mediaId = 'mediaId';
  static final String title = 'title';
  static final String posterPath = 'posterPath';
  static final String releaseDate = 'releaseDate';

  static final List<String> values = [id, mediaId, title, posterPath, releaseDate];
}

class SavedMedia {
  int? id;
  late int mediaId;
  String? title;
  String? posterPath;
  DateTime? releaseDate;

  SavedMedia(this.mediaId, {this.id, this.title, this.posterPath, this.releaseDate});

  Map<String, Object?> toJson() => {
        SavedMediaFields.id: id,
        SavedMediaFields.mediaId: mediaId,
        SavedMediaFields.title: title,
        SavedMediaFields.posterPath: posterPath,
        SavedMediaFields.releaseDate: releaseDate != null ? releaseDate!.toIso8601String() : null,
      };

  SavedMedia deepCopy({int? id, int? mediaId, String? title, String? posterPath, DateTime? releaseDate}) {
    return new SavedMedia(mediaId ?? this.mediaId,
        id: id ?? this.id,
        title: title ?? this.title,
        posterPath: posterPath ?? this.posterPath,
        releaseDate: releaseDate ?? this.releaseDate);
  }

  static SavedMedia fromJson(Map<String, Object?> rawJson) {
    var releaseDate = rawJson[SavedMediaFields.releaseDate] as String?;
    return new SavedMedia(
		rawJson[SavedMediaFields.mediaId] as int,
		id: rawJson[SavedMediaFields.id] as int,
        title: rawJson[SavedMediaFields.title] as String?,
        posterPath: rawJson[SavedMediaFields.posterPath] as String?,
        releaseDate: parseDate(releaseDate));
  }
}
