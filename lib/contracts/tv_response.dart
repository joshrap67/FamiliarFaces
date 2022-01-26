import 'cast_response.dart';

class TvResponse {
  late int id;
  String? name;
  DateTime? firstAirDate;
  DateTime? lastAirDate;
  String? posterPath;
  List<CastResponse> cast = <CastResponse>[];

  TvResponse(this.id, this.name, this.firstAirDate, this.lastAirDate, this.posterPath, this.cast);

  @override
  String toString() {
    return 'TvResponse{id: $id, name: $name, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, posterPath: $posterPath, cast: $cast}';
  }
}
