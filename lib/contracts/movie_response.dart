import 'cast_response.dart';

class MovieResponse {
  late int id;
  String? title;
  DateTime? releaseDate;
  String? posterImagePath;
  List<CastResponse> cast = <CastResponse>[];

  MovieResponse(this.id, this.title, this.releaseDate, this.posterImagePath, this.cast);
}
