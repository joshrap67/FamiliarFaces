import 'dart:collection';

import 'package:familiar_faces/api_models/movie.dart';
import 'package:familiar_faces/api_models/movie_search_result.dart';
import 'package:familiar_faces/api_models/person.dart';
import 'package:familiar_faces/api_models/person_credit.dart';
import 'package:familiar_faces/api_models/tv_show.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/imports/utils.dart';

class ModelCreator {
  static List<SearchMediaResponse> getSearchMediaResponses(List<MediaResult> mediaResults) {
    return mediaResults
        .map((mediaResult) => new SearchMediaResponse(
            mediaResult.id,
            getTitle(mediaResult.title, mediaResult.name, mediaResult.mediaType),
            getMediaType(mediaResult.mediaType),
            getReleaseDate(mediaResult.releaseDate, mediaResult.firstAirDate, mediaResult.mediaType),
            mediaResult.posterPath,
            mediaResult.isVideo,
            mediaResult.isAdult))
        .toList();
  }

  static MovieResponse getMovieWithCastResponse(Movie movie) {
    var cast = <CastResponse>[];
    for (var castMember in movie.cast) {
      cast.add(new CastResponse(castMember.id, castMember.name, castMember.characterName, castMember.profilePath));
    }
    return new MovieResponse(movie.id, movie.title, parseDate(movie.releaseDate), movie.posterImagePath, cast);
  }

  static TvResponse getTvShowWithCastResponse(TvShow tvShow) {
    var cast = <CastResponse>[];
    for (var castMember in tvShow.cast) {
      cast.add(new CastResponse(castMember.id, castMember.name, castMember.characterName, castMember.profilePath));
    }
    return new TvResponse(
        tvShow.id, tvShow.name, parseDate(tvShow.firstAirDate), parseDate(tvShow.lastAirDate), tvShow.posterPath, cast);
  }

  static MediaType getMediaType(String? mediaType) {
    switch (mediaType) {
      case "movie":
        return MediaType.Movie;
      case "tv":
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

  static PersonResponse getPersonResponse(Person person) {
    return new PersonResponse(person.id, person.name!, person.profileImagePath, parseDate(person.birthday),
        parseDate(person.deathDay), getPersonCreditResponse(person.credits));
  }

  static List<PersonCreditResponse> getPersonCreditResponse(List<PersonCredit> personCredits) {
    /*
    	Essentially, since this API is pretty trash, some media from the get aggregate credits are duplicated with different
    	character names. What I'm doing here is looping through all of the duplicated ids and combining all the character
    	names into one string, and then putting a singular media back into the return list. So damn stupid.
     */

    // first ensure all the media are distinct (by id)
    var mediaIdToDistinctCredit = new HashMap<int, PersonCredit>();
    var mediaIdToCharacterNames = new HashMap<int, List<String?>>();
    for (var credit in personCredits) {
      if (!mediaIdToCharacterNames.containsKey(credit.id)) {
        mediaIdToCharacterNames[credit.id] = <String?>[];
      }

      mediaIdToCharacterNames[credit.id]!.add(credit.characterName);

      if (!mediaIdToDistinctCredit.containsKey(credit.id)) {
        mediaIdToDistinctCredit[credit.id] = credit;
      }
    }

    for (var uniqueCredit in mediaIdToCharacterNames.keys) {
      if (mediaIdToCharacterNames[uniqueCredit]!.length > 1) {
        var cleanedName = getCharacterName(mediaIdToCharacterNames[uniqueCredit]!);
        mediaIdToDistinctCredit[uniqueCredit]!.characterName = cleanedName;
      }
    }

    var retVal = <PersonCreditResponse>[];
    for (var credit in mediaIdToDistinctCredit.values) {
      retVal.add(new PersonCreditResponse(
          credit.id,
          getTitle(credit.title, credit.name, credit.mediaType),
          getMediaType(credit.mediaType),
          getCharacterName(mediaIdToCharacterNames[credit.id]!),
          getReleaseDate(credit.releaseDate, credit.firstAirDate, credit.mediaType),
          credit.posterPath));
    }
    return retVal;
  }

  static String getCharacterName(List<String?> characters) {
    var retVal = '';
    int maxShown = 4;
    for (int i = 0; i < characters.length; i++) {
      var charName = characters[i];
      if (isStringNullOrEmpty(charName)) continue;
      if (i == maxShown - 1) {
        int remaining = characters.length - 1 - i;
        retVal += '$charName +$remaining more';
        break;
      }

      retVal += i == characters.length - 1 ? '$charName' : '$charName, ';
    }
    return retVal;
  }
}
