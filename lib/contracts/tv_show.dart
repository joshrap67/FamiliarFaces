import 'cast.dart';

class TvShow {
  late int id;
  String? name;
  DateTime? firstAirDate;
  DateTime? lastAirDate;
  String? posterPath;
  List<Cast> cast = <Cast>[];

  TvShow(this.id, this.name, this.firstAirDate, this.lastAirDate, this.posterPath, this.cast);

  @override
  String toString() {
    return 'TvShow{id: $id, name: $name, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, posterPath: $posterPath, cast: $cast}';
  }
}
