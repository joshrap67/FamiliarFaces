import 'media_type.dart';

class ActorCredit {
  int id;
  String? title;
  MediaType mediaType;
  String? characterName;
  DateTime? releaseDate;
  String? posterPath;

  ActorCredit(this.id, this.title, this.mediaType, this.characterName, this.releaseDate, this.posterPath);

  @override
  String toString() {
    return 'ActorCredit{id: $id, title: $title, mediaType: $mediaType, '
        'characterName: $characterName, releaseDate: $releaseDate}, posterPath: $posterPath}';
  }
}
