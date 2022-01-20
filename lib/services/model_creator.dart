import 'package:familiar_faces/api_models/movie.dart';
import 'package:familiar_faces/api_models/movie_search_result.dart';
import 'package:familiar_faces/api_models/person.dart';
import 'package:familiar_faces/api_models/person_credit.dart';
import 'package:familiar_faces/api_models/tvShow.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/grouped_movie_response.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_movie_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';

class ModelCreator {
  static SearchMovieResponse getSearchResult(MovieSearchResult movieSearchResult) {
    var returnResult = new SearchMovieResponse();
    for (var result in movieSearchResult.results) {
      returnResult.results.add(new SearchMediaResponse(
          result.id,
          getTitle(result.title, result.name, result.mediaType),
          getMediaType(result.mediaType),
          getReleaseDate(result.releaseDate, result.firstAirDate, result.mediaType),
          result.posterPath));
    }
    return returnResult;
  }

  static MovieResponse getMovieWithCastResponse(Movie movie) {
    var cast = <CastResponse>[];
    for (var castMember in movie.cast) {
      cast.add(new CastResponse(castMember.id, castMember.name, castMember.characterName, castMember.profilePath));
    }
    return new MovieResponse(movie.id, movie.title, movie.releaseDate, movie.posterImagePath, cast);
  }

  static TvResponse getTvShowWithCastResponse(TvShow tvShow) {
    var cast = <CastResponse>[];
    for (var castMember in tvShow.cast) {
      cast.add(new CastResponse(castMember.id, castMember.name, castMember.characterName, castMember.profilePath));
    }
    return new TvResponse(tvShow.id, tvShow.name, tvShow.firstAirDate, tvShow.lastAirDate, tvShow.posterPath, cast);
  }

  static GroupedMovieResponse getGroupedMovieResponse(List<Person> people) {
    var returnValue = new GroupedMovieResponse(<PersonResponse>[]);
    for (var person in people) {
      returnValue.people.add(getPersonResponse(person));
    }
    return returnValue;
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

  static String? getReleaseDate(String? releaseDate, String? firstAirDate, String? mediaType) {
// todo datetime
    var mediaTypeEnum = getMediaType(mediaType);
    switch (mediaTypeEnum) {
      case MediaType.Movie:
        return releaseDate;
      case MediaType.TV:
        return firstAirDate;
      default:
        return releaseDate;
    }
  }

  static PersonResponse getPersonResponse(Person person) {
    return new PersonResponse(
        person.id, person.name!, person.profileImagePath, getPersonCreditResponse(person.credits));
  }

  static List<PersonCreditResponse> getPersonCreditResponse(List<PersonCredit> personCredits) {
    return personCredits
        .map((personCredit) => PersonCreditResponse(
            personCredit.id,
            getTitle(personCredit.title, personCredit.name, personCredit.mediaType),
            getMediaType(personCredit.mediaType),
            personCredit.characterName,
            getReleaseDate(personCredit.releaseDate, personCredit.firstAirDate, personCredit.mediaType),
            personCredit.posterPath))
        .toList();
  }
}
