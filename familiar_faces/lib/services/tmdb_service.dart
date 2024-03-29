import 'dart:convert';

import 'package:familiar_faces/api_models/movie_response.dart';
import 'package:familiar_faces/api_models/movie_search_response.dart';
import 'package:familiar_faces/api_models/person_response.dart';
import 'package:familiar_faces/api_models/tv_show_response.dart';
import 'package:familiar_faces/domain/actor.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/gateways/http_action.dart';
import 'package:familiar_faces/gateways/tmdb_gateway.dart';

import 'model_creator.dart';

class TmdbService {
  static Future<Actor> getPersonCreditsAsync(int personId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'combined_credits');
    var apiResult = await makeApiRequest(HttpAction.GET, 'person/$personId', queryParams);

    if (!apiResult.success()) {
      throw new Exception('No person found with id=$personId');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var personCredit = new PersonResponse.fromJsonWithCombinedCredits(jsonMap);
    var contract = ModelCreator.getActor(personCredit);

    return contract;
  }

  static Future<Movie> getMovieWithCastAsync(int movieId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'credits');

    var apiResult = await makeApiRequest(HttpAction.GET, 'movie/$movieId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No movie found with id=$movieId. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var movieWithCast = new MovieResponse.fromJsonWithCast(jsonMap);
    var contract = ModelCreator.getMovieWithCastResponse(movieWithCast);

    return contract;
  }

  static Future<TvShow> getTvShowWithCastAsync(int tvId) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'aggregate_credits');

    var apiResult = await makeApiRequest(HttpAction.GET, 'tv/$tvId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No tv show found with id=$tvId. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var tvShowWithCast = new TvShowResponse.fromJsonWithCast(jsonMap);
    var contract = ModelCreator.getTvShowWithCastResponse(tvShowWithCast);

    return contract;
  }

  static Future<List<SearchMediaResult>> searchMulti(String query) async {
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('query', () => query);

    var apiResult = await makeApiRequest(HttpAction.GET, 'search/multi', queryParams);
    if (!apiResult.success()) {
      throw new Exception('Can\'t complete query=$query. ${apiResult.errorMessage}');
    }
    var jsonMap = jsonDecode(apiResult.data!);

    var searchResult = new MediaSearchResponse.fromJson(jsonMap);
    var contract = ModelCreator.getSearchMediaResponses(searchResult.results);

    return contract;
  }

  static Map<String, String> getCommonQuery() {
    return {'api_key': 'f04e815090e8fadd641ce2984ae66438'};
  }
}
