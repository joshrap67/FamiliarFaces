import 'package:familiar_faces/imports/utils.dart';

import 'cast_response.dart';

class TvShowResponse {
  late int id;
  String? name;
  String? firstAirDate;
  String? lastAirDate;
  String? posterPath;
  List<CastResponse> cast = <CastResponse>[];

  TvShowResponse.fromJsonWithCast(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    name = rawJson['name'];
    firstAirDate = rawJson['first_air_date'];
    lastAirDate = rawJson['last_air_date'];
    posterPath = rawJson['poster_path'];
    var rawCast = rawJson['aggregate_credits']['cast'] as List<dynamic>;
    for (var castMember in rawCast) {
      // have to do it this way because same actor can have multiple roles in this API
      var characterNamesRaw = castMember['roles'] as List<dynamic>;
      var characterName = '';
      var characterNames = <String>[];
      for (var role in characterNamesRaw) {
        characterNames.add(role['character'] as String);
      }
      if (characterNames.length >= 2) {
        for (var i = 0; i < characterNames.length; i++) {
          var charName = characterNames[i].trim();
          if (isStringNullOrEmpty(charName)) {
            continue;
          }

          // if actor has multiple characters, comma separate them
          characterName += i == characterNames.length - 1 ? '$charName' : '$charName,';
        }
      } else if (characterNames.length == 1) {
        characterName = characterNames[0].trim();
      }
      cast.add(new CastResponse(castMember['id'], castMember['name'], characterName, castMember['profile_path']));
    }
  }

  @override
  String toString() {
    return 'TvShowResponse{id: $id, name:$name, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, posterPath: $posterPath, '
        'cast: $cast}';
  }
}
