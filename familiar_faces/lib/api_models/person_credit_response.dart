class PersonCreditResponse {
  late int id;
  String? title;
  String? name;
  String? mediaType;
  String? characterName;
  String? releaseDate;
  String? firstAirDate;
  String? posterPath; // of the movie

  PersonCreditResponse.fromJson(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    title = rawJson['title'];
    name = rawJson['name'];
    mediaType = rawJson['media_type'];
    characterName = rawJson['character'];
    releaseDate = rawJson['release_date'];
    firstAirDate = rawJson['first_air_date'];
    posterPath = rawJson['poster_path'];
  }

  @override
  String toString() {
    return 'PersonCreditResponse{id: $id, title: $title, name: $name, mediaType: $mediaType, characterName: $characterName, '
        'releaseDate: $releaseDate, firstAirDate: $firstAirDate, posterPath: $posterPath}';
  }
}
