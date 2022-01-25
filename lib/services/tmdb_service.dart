import 'dart:convert';

import 'package:familiar_faces/api_models/movie.dart';
import 'package:familiar_faces/api_models/movie_search_result.dart';
import 'package:familiar_faces/api_models/person.dart';
import 'package:familiar_faces/api_models/tvShow.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/gateways/http_action.dart';
import 'package:familiar_faces/gateways/tmdbGateway.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';

import 'model_creator.dart';

class TmdbService {
  // todo rename mediaService
  static Future<List<PersonResponse>> getGroupedMovieResponse(int movieId, {String? characterName}) async {
    var movieWithCast = await getMovieWithCastAsync(movieId);
    List<SavedMedia> savedMedia = await SavedMediaDatabase.instance.getAll();
    if (characterName != null && movieWithCast.cast.any((element) => element.characterName == characterName)) {
      // only get the grouped movies for the character the user specified. the happy path
      var credits = await getPersonCreditsAsync(
          movieWithCast.cast.firstWhere((element) => element.characterName == characterName).id);
      applySeenMedia(credits, savedMedia);
      return ({credits}.toList());
    } else {
      // bad path, loop through every actor in the movie and return their credits grouped together
      List<PersonResponse> allActors = <PersonResponse>[];
      await Future.wait(movieWithCast.cast
          .map((castMember) => TmdbService.getPersonCreditsAsync(castMember.id).then((value) => allActors.add(value))));
      var list = new List<PersonResponse>.from(allActors);
      list.forEach((element) {
        applySeenMedia(element, savedMedia);
      });
      return list;
    }
  }

  static void applySeenMedia(PersonResponse personResponse, List<SavedMedia> savedMedia) {
    for (var credit in personResponse.credits) {
      if (savedMedia.any((element) => element.mediaId == credit.id)) {
        credit.isSeen = true;
      }
    }
  }

  static Future<PersonResponse> getPersonCreditsAsync(int personId) async {
    List<SavedMedia> savedMedia = await SavedMediaDatabase.instance.getAll();
    var queryParams = getCommonQuery();
    queryParams.putIfAbsent('append_to_response', () => 'combined_credits');
    var apiResult = await makeApiRequest(HttpAction.GET, 'person/$personId', queryParams);
    if (!apiResult.success()) {
      throw new Exception('No person found with id=$personId');
    }
    var jsonMap = jsonDecode(apiResult.data!);
    var personCredit = new Person.fromJsonWithCombinedCredits(jsonMap);
    var contract = ModelCreator.getPersonResponse(personCredit);
    applySeenMedia(contract, savedMedia);
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

  static Future<List<SearchMediaResponse>> searchMulti(String query, {List<SavedMedia>? savedMedia}) async {
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
    // drop any records with a null title as that makes no sense for user to click
    contract.removeWhere((element) => element.title == null);
    if (savedMedia != null) {
      // don't show suggestions for ones the user has already saved
      contract.removeWhere((element) => savedMedia.any((savedMedia) => savedMedia.mediaId == element.id));
    }
    return contract;
  }

  static Map<String, String> getCommonQuery() {
    return {'api_key': 'f04e815090e8fadd641ce2984ae66438'};
  }
}
