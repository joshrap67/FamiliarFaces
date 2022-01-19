import 'media_type.dart';

class SearchMovieResponse {
  List<SearchMediaResponse> results = <SearchMediaResponse>[];
}

class SearchMediaResponse {
  late int id;
  String? title;
  late MediaType mediaType;
  String? releaseDate;
  String? posterPath;

  SearchMediaResponse(int id, String? title, MediaType mediaType, String? releaseDate, String? posterPath) {
    id = id;
    title = title;
    mediaType = mediaType;
    releaseDate = releaseDate;
    posterPath = posterPath;
  }
}
