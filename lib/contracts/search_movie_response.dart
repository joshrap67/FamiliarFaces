import 'media_type.dart';

class SearchMovieResponse {
  List<SearchMediaResponse> results = <SearchMediaResponse>[];
}

class SearchMediaResponse {
  late int id;
  String? title;
  late MediaType mediaType;
  DateTime? releaseDate;
  String? posterPath;

  SearchMediaResponse(this.id, this.title, this.mediaType, this.releaseDate, this.posterPath);
}
