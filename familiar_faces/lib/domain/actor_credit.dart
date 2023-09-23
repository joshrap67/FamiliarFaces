import 'media_type.dart';

class ActorCredit {
  int id;
  bool isSeenByUser;
  String? title;
  MediaType mediaType;
  String? characterName;
  DateTime? releaseDate;
  String? posterPath;

  ActorCredit(this.id, this.title, this.mediaType, this.characterName, this.releaseDate, this.posterPath,
      {this.isSeenByUser = false});

  @override
  String toString() {
    return 'ActorCredit{id: $id, isSeenByUser: $isSeenByUser, title: $title, mediaType: $mediaType, '
        'characterName: $characterName, releaseDate: $releaseDate}, posterPath: $posterPath}';
  }
}
