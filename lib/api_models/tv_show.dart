import 'cast.dart';

class TvShow {
  late int id;
  String? name;
  String? firstAirDate;
  String? lastAirDate;
  String? posterPath;
  List<Cast> cast = <Cast>[];

  TvShow.fromJsonWithCast(Map<String, dynamic> rawJson) {
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
      if (characterNames.length > 2) {
        for (int i = 0; i < characterNames.length; i++) {
          // if actor has multiple characters, comma separate them
          var charName = characterNames[i];
          characterName += i == characterNames.length - 1 ? '$charName' : '$charName, ';
        }
      } else if (characterNames.length == 1) {
        characterName = characterNames[0];
      }
      cast.add(new Cast(castMember['id'], castMember['name'], characterName, castMember['profile_path']));
    }
  }

  @override
  String toString() {
    return 'TvShow{id: $id, name:$name, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, posterPath: $posterPath, '
        'cast: $cast}';
  }
}
