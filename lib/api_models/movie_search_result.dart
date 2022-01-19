class MovieSearchResult {
  late int page;
  late int totalResults;
  late int totalPages;
  List<MediaResult> results = <MediaResult>[];

  MovieSearchResult.fromJson(Map<String, dynamic> rawJson) {
    page = rawJson['page'];
    totalResults = rawJson['total_results'];
    totalPages = rawJson['total_pages'];
    var rawResults = rawJson['results'] as List<dynamic>;
    for (var result in rawResults) {
      results.add(new MediaResult.fromJson(result));
    }
  }
}

class MediaResult {
  late int id;
  String? mediaType;
  String? title;
  String? name;
  String? releaseDate;
  String? firstAirDate;
  String? posterPath;

  MediaResult.fromJson(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    mediaType = rawJson['media_type'];
    title = rawJson['title'];
    name = rawJson['name'];
    releaseDate = rawJson['release_date'];
    firstAirDate = rawJson['first_air_date'];
    posterPath = rawJson['poster_path'];
  }
}
