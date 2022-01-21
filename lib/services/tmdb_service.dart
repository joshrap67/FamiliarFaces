import 'dart:convert';

import 'package:familiar_faces/api_models/movie.dart';
import 'package:familiar_faces/api_models/movie_search_result.dart';
import 'package:familiar_faces/api_models/person.dart';
import 'package:familiar_faces/api_models/tvShow.dart';
import 'package:familiar_faces/contracts/grouped_movie_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/gateways/http_action.dart';
import 'package:familiar_faces/gateways/tmdbGateway.dart';
import 'package:familiar_faces/imports/utils.dart';

import 'model_creator.dart';

class TmdbService {
  static Future<GroupedMovieResponse> getGroupedMovieResponse(int movieId, {String? characterName}) async {
    var movieWithCast = await getMovieWithCastAsync(movieId);
    if (characterName != null && movieWithCast.cast.any((element) => element.characterName == characterName)) {
      // only get the grouped movies for the character the user specified. the happy path
      var credits = await getPersonCreditsAsync(
          movieWithCast.cast.firstWhere((element) => element.characterName == characterName).id);
      return new GroupedMovieResponse({credits}.toList());
    } else {
      // bad bath, loop through every actor in the movie and return their credits grouped together
      List<PersonResponse> allActors = <PersonResponse>[];
      await Future.wait(movieWithCast.cast
          .map((castMember) => TmdbService.getPersonCreditsAsync(castMember.id).then((value) => allActors.add(value))));
      return new GroupedMovieResponse(List.from(allActors));
    }
  }

  static Future<PersonResponse> getPersonCreditsAsync(int personId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'combined_credits');
    var apiResult = await makeApiRequest(HttpAction.GET, 'person/$personId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No person found with id=$personId');
    }
    var jsonMap = jsonDecode(apiResult.data!);
    var personCredit = new Person.fromJsonWithCombinedCredits(jsonMap);
    var contract = ModelCreator.getPersonResponse(personCredit);
    return contract;
  }

  static Future<MovieResponse> getMovieWithCastAsync(int movieId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'credits');

    var apiResult = await makeApiRequest(HttpAction.GET, 'movie/$movieId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No movie found with id=$movieId. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var movieWithCast = new Movie.fromJsonWithCast(jsonMap);
    var contract = ModelCreator.getMovieWithCastResponse(movieWithCast);
    return contract;
  }

  static Future<TvResponse> getTvShowWithCastAsync(int tvId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'aggregated_credits');

    var apiResult = await makeApiRequest(HttpAction.GET, 'tv/$tvId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No tv show found with id=$tvId. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var tvShowWithCast = new TvShow.fromJsonWithCast(jsonMap);
    var contract = ModelCreator.getTvShowWithCastResponse(tvShowWithCast);
    return contract;
  }

  static Future<List<SearchMediaResponse>> searchMulti(String query) async {
    if (isStringNullOrEmpty(query)) {
      return <SearchMediaResponse>[];
    }

    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('query', () => query);

    var apiResult = await makeApiRequest(HttpAction.GET, 'search/multi', queryParams);

    if (!apiResult.success()) {
      throw new Exception('Can\'t complete query=$query. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var searchResult = new MovieSearchResult.fromJson(jsonMap);
    var contract = ModelCreator.getSearchMediaResponses(searchResult.results);
    return contract;
  }

  static Map<String, String> getCommonQuery() {
    return {'api_key': 'f04e815090e8fadd641ce2984ae66438'};
  }
}
