import 'media_type.dart';

class PersonCreditResponse {
  int id;
  String? title;
  MediaType mediaType;
  String? characterName;
  String? releaseDate;
  String? posterPath;

  PersonCreditResponse(this.id, this.title, this.mediaType, this.characterName, this.releaseDate, this.posterPath);
}
