import 'cast_member.dart';

class Movie {
  late int id;
  String? title;
  DateTime? releaseDate;
  String? posterImagePath;
  List<CastMember> cast = <CastMember>[];

  Movie(this.id, this.title, this.releaseDate, this.posterImagePath, this.cast);

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, releaseDate: $releaseDate, posterImagePath: $posterImagePath, cast: $cast}';
  }
}
