import 'cast_response.dart';

class TvResponse {
  late int id;
  String? name;
  String? firstAirDate;
  String? lastAirDate;
  String? posterPath;
  List<CastResponse> cast = <CastResponse>[];

  TvResponse(this.id, this.name, this.firstAirDate, this.lastAirDate, this.posterPath, this.cast);
}
