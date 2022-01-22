import 'media_type.dart';

class PersonCreditResponse {
  int id;
  bool isSeen;
  String? title;
  MediaType mediaType;
  String? characterName;
  DateTime? releaseDate;
  String? posterPath;

  PersonCreditResponse(this.id, this.title, this.mediaType, this.characterName, this.releaseDate, this.posterPath,
      {this.isSeen = false});
}
