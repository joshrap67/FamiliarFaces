import 'dart:convert';

import 'package:familiar_faces/api_models/movie.dart';
import 'package:familiar_faces/api_models/movie_search_result.dart';
import 'package:familiar_faces/api_models/person.dart';
import 'package:familiar_faces/api_models/tv_show.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/gateways/http_action.dart';
import 'package:familiar_faces/gateways/tmdb_gateway.dart';

import 'model_creator.dart';

class TmdbService {
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

    // if it hasn't been released don't show it todo move this to outer business logic layer?
    var now = DateTime.now();
    contract.credits.removeWhere((element) => element.releaseDate != null && element.releaseDate!.isAfter(now));

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
    queryParams.putIfAbsent('append_to_response', () => 'aggregate_credits');

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
