import 'dart:collection';

import 'package:familiar_faces/api_models/movie_response.dart';
import 'package:familiar_faces/api_models/movie_search_response.dart';
import 'package:familiar_faces/api_models/person_credit_response.dart';
import 'package:familiar_faces/api_models/person_response.dart';
import 'package:familiar_faces/api_models/tv_show_response.dart';
import 'package:familiar_faces/domain/actor.dart';
import 'package:familiar_faces/domain/actor_credit.dart';
import 'package:familiar_faces/domain/cast.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/imports/utils.dart';

// converts raw data from api to consumable contracts for app
class ModelCreator {
  static List<SearchMediaResult> getSearchMediaResponses(List<MediaResponse> mediaResults) {
    return mediaResults
        .map(
          (mediaResult) => new SearchMediaResult(
            mediaResult.id,
            getTitle(mediaResult.title, mediaResult.name, mediaResult.mediaType),
            getMediaType(mediaResult.mediaType),
            getReleaseDate(mediaResult.releaseDate, mediaResult.firstAirDate, mediaResult.mediaType),
            mediaResult.posterPath,
            mediaResult.isVideo,
            mediaResult.isAdult,
          ),
        )
        .toList();
  }

  static Movie getMovieWithCastResponse(MovieResponse movie) {
    var cast = <Cast>[];
    for (var castMember in movie.cast) {
      cast.add(new Cast(castMember.id, castMember.name, getCharacterName(castMember.characterName!.split(",")),
          castMember.profilePath));
    }
    return new Movie(movie.id, movie.title, parseDate(movie.releaseDate), movie.posterImagePath, cast);
  }

  static TvShow getTvShowWithCastResponse(TvShowResponse tvShow) {
    var cast = <Cast>[];
    for (var castMember in tvShow.cast) {
      cast.add(new Cast(castMember.id, castMember.name, getCharacterName(castMember.characterName!.split(",")),
          castMember.profilePath));
    }
    return new TvShow(
        tvShow.id, tvShow.name, parseDate(tvShow.firstAirDate), parseDate(tvShow.lastAirDate), tvShow.posterPath, cast);
  }

  static MediaType getMediaType(String? mediaType) {
    switch (mediaType) {
      case 'movie':
        return MediaType.Movie;
      case 'tv':
        return MediaType.TV;
      default:
        return MediaType.Movie;
    }
  }

  static String? getTitle(String? title, String? name, String? mediaType) {
    var mediaTypeEnum = getMediaType(mediaType);
    switch (mediaTypeEnum) {
      case MediaType.Movie:
        return title;
      case MediaType.TV:
        return name;
      default:
        return title;
    }
  }

  static DateTime? getReleaseDate(String? releaseDate, String? firstAirDate, String? mediaType) {
    var mediaTypeEnum = getMediaType(mediaType);
    switch (mediaTypeEnum) {
      case MediaType.Movie:
        return parseDate(releaseDate);
      case MediaType.TV:
        return parseDate(firstAirDate);
      default:
        return null;
    }
  }

  static Actor getActor(PersonResponse person) {
    return new Actor(person.id, person.name!, person.profileImagePath, parseDate(person.birthday),
        parseDate(person.deathDay), getPersonCreditsResponse(person.credits));
  }

  static List<ActorCredit> getPersonCreditsResponse(List<PersonCreditResponse> personCredits) {
    /*
    	Essentially when there are multiple characters for the same media, more than one 'row' is returned.
    	What I'm doing here is looping through all of the duplicated media ids and combining all the character
    	names into one string, and then putting a singular media back into the return list.
     */

    // first ensure all the media are distinct (by id)
    var mediaIdToDistinctCredit = new HashMap<int, PersonCreditResponse>();
    var mediaIdToCharacterNames = new HashMap<int, List<String?>>();
    for (var credit in personCredits) {
      if (!mediaIdToCharacterNames.containsKey(credit.id)) {
        mediaIdToCharacterNames[credit.id] = <String?>[];
      }

      mediaIdToCharacterNames[credit.id]!.add(credit.characterName);

      if (!mediaIdToDistinctCredit.containsKey(credit.id)) {
        // just take the first match we find for the credit, we just need one reference for the duplicate ones
        mediaIdToDistinctCredit[credit.id] = credit;
      }
    }

    var retVal = <ActorCredit>[];
    for (var credit in mediaIdToDistinctCredit.values) {
      retVal.add(
        new ActorCredit(
          credit.id,
          getTitle(credit.title, credit.name, credit.mediaType),
          getMediaType(credit.mediaType),
          getCharacterName(mediaIdToCharacterNames[credit.id]!),
          getReleaseDate(credit.releaseDate, credit.firstAirDate, credit.mediaType),
          credit.posterPath,
        ),
      );
    }
    return retVal;
  }

  static String getCharacterName(List<String?> characters) {
    var retVal = '';
    var maxShown = 4;
    for (var i = 0; i < characters.length; i++) {
      var charName = characters[i];
      if (isStringNullOrEmpty(charName)) continue;
      if (i == maxShown - 1) {
        var remaining = characters.length - 1 - i;
        retVal += '$charName +$remaining more';
        break;
      }

      retVal += i == characters.length - 1 ? '$charName' : '$charName, ';
    }
    return retVal;
  }
}
