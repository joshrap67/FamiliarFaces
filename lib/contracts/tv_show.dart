import 'cast.dart';

class TvShow {
  late int id;
  String? title;
  DateTime? firstAirDate;
  DateTime? lastAirDate;
  String? posterPath;
  List<Cast> cast = <Cast>[];

  TvShow(this.id, this.title, this.firstAirDate, this.lastAirDate, this.posterPath, this.cast);

  @override
  String toString() {
    return 'TvShow{id: $id, title: $title, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, posterPath: $posterPath, cast: $cast}';
  }
}
