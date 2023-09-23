import 'media_type.dart';

class SearchMediaResult {
  late int id;
  String? title;
  late MediaType mediaType;
  DateTime? releaseDate;
  String? posterPath;
  late bool isVideo;
  late bool isAdult;

  SearchMediaResult(this.id, this.title, this.mediaType, this.releaseDate, this.posterPath, this.isVideo, this.isAdult);

  @override
  String toString() {
    return 'SearchMediaResult{id: $id, title: $title, mediaType: $mediaType, releaseDate: $releaseDate, '
        'posterPath: $posterPath, isVideo: $isVideo, isAdult: $isAdult}';
  }
}
