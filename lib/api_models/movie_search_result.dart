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

  @override
  String toString() {
    return 'MovieSearchResult{page: $page, totalResults: $totalResults, totalPages: $totalPages, results: $results}';
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
  bool isVideo = false; // https://www.themoviedb.org/bible/movie/59f3b16d9251414f20000001#59f73b759251416e71000005
  bool isAdult = false;

  MediaResult.fromJson(Map<String, dynamic> rawJson) {
    id = rawJson['id'];
    mediaType = rawJson['media_type'];
    title = rawJson['title'];
    name = rawJson['name'];
    releaseDate = rawJson['release_date'];
    firstAirDate = rawJson['first_air_date'];
    posterPath = rawJson['poster_path'];
    isVideo = rawJson['video'] ?? false;
    isAdult = rawJson['adult'] ?? false;
  }

  @override
  String toString() {
    return 'MediaResult{id: $id, mediaType: $mediaType, title: $title, name: $name, releaseDate: $releaseDate,'
        'firstAirDate: $firstAirDate, posterPath: $posterPath, isVideo: $isVideo, isAdult: $isAdult}';
  }
}
