import 'cast_response.dart';

class MovieResponse {
  late int id;
  String? title;
  String? releaseDate;
  String? posterImagePath;
  List<CastResponse> cast = <CastResponse>[];

  MovieResponse.fromJsonWithCast(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    title = rawJson['title'];
    releaseDate = rawJson['release_date'];
    posterImagePath = rawJson['poster_path'];
    var rawCast = rawJson['credits']['cast'] as List<dynamic>;
    for (var castMember in rawCast) {
      cast.add(new CastResponse.fromJson(castMember));
    }
  }

  @override
  String toString() {
    return 'MovieResponse{id: $id, title: $title, releaseDate: $releaseDate, posterImagePath: $posterImagePath}';
  }
}
