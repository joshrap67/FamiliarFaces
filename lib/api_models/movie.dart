import 'cast.dart';

class Movie {
  late int id;
  String? title;
  String? releaseDate;
  String? posterImagePath;

  // double? revenue; todo can i get this here?
  // String? status; todo can i get this here?
  List<Cast> cast = <Cast>[];

  Movie.fromJsonWithCast(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    title = rawJson['title'];
    releaseDate = rawJson['release_date'];
    posterImagePath = rawJson['poster_path'];
    var rawCast = rawJson['credits']['cast'] as List<dynamic>;
    for (var castMember in rawCast) {
      cast.add(new Cast.fromJson(castMember));
    }
  }
}
