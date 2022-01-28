import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';

class MediaService {
  static Future<PersonResponse> getSingleActorCredits(int id) async {
    PersonResponse contract = await TmdbService.getPersonCreditsAsync(id);
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();
	// todo if credit after current date don't return it
    applySeenMedia(contract.credits, savedMedia);
    return contract;
  }

  static Future<MovieResponse> getMovieWithCastAsync(int movieId) async {
    var movie = await TmdbService.getMovieWithCastAsync(movieId);
    movie.cast.removeWhere((element) => element.profilePath == null); // if no profile image probably a random extra
    return movie;
  }

  // bad path, loop through every actor in the movie and return their credits grouped together
  static Future<List<PersonResponse>> getGroupedMovieResponse(int movieId, {String? characterName}) async {
    List<PersonResponse> allActors = <PersonResponse>[];
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();

    var movieWithCast = await TmdbService.getMovieWithCastAsync(movieId);
    movieWithCast.cast.removeWhere((element) =>
        element.profilePath == null); // if there is no profile image, probably some random background character

    await Future.wait(movieWithCast.cast
        .map((castMember) => TmdbService.getPersonCreditsAsync(castMember.id).then((value) => allActors.add(value))));

    var list = new List<PersonResponse>.from(allActors);
    list.forEach((element) {
      applySeenMedia(element.credits, savedMedia);
    });
    return list;
  }

  static Future<TvResponse> getTvShowWithCastAsync(int tvId) async {
    var tv = await TmdbService.getTvShowWithCastAsync(tvId);
    tv.cast.removeWhere((element) => element.profilePath == null); // if no profile image probably a random extra
    return tv;
  }

  // bad path, loop through every actor in the movie and return their credits grouped together
  static Future<List<PersonResponse>> getGroupedTvResponse(int tvId, {String? characterName}) async {
    List<PersonResponse> allActors = <PersonResponse>[];
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();

    var tvWithCast = await TmdbService.getTvShowWithCastAsync(tvId);
    tvWithCast.cast.removeWhere((element) =>
        element.profilePath == null); // if there is no profile image, probably some random background character

    await Future.wait(tvWithCast.cast.map((castMember) async {
      // todo handle if somehow id is bad (because this api is trash and this has happened to me before)
      return TmdbService.getPersonCreditsAsync(castMember.id).then((value) => allActors.add(value));
    }));
    var list = new List<PersonResponse>.from(allActors);
    list.forEach((element) {
      applySeenMedia(element.credits, savedMedia);
    });
    return list;
  }

  static void applySeenMedia(List<PersonCreditResponse> credits, List<SavedMedia> savedMedia) {
    for (var credit in credits) {
      if (savedMedia.any((element) => element.mediaId == credit.id)) {
        credit.isSeen = true;
      }
    }
  }

  static Future<List<SearchMediaResponse>> searchMulti(String query, {bool showSavedMedia = true}) async {
    if (isStringNullOrEmpty(query)) {
      return <SearchMediaResponse>[];
    }
    List<SearchMediaResponse> search = await TmdbService.searchMulti(query);
    // drop any records with a null title as that makes no sense for user to click
    search.removeWhere((element) => element.title == null);
    // if it has a null poster it likely is not very popular and might not be released yet either
    search.removeWhere((element) => element.posterPath == null);
    // lmao don't want porn
    search.removeWhere((element) => element.isAdult);
    // according to TMDB docs, this field is set on things like BTS or short films
    search.removeWhere((element) => element.isVideo);
    if (!showSavedMedia) {
      List<SavedMedia> savedMedia = await SavedMediaService.getAll();
      // don't show suggestions for ones the user has already saved
      search.removeWhere((element) => savedMedia.any((savedMedia) => savedMedia.mediaId == element.id));
    }
    // todo if after current date don't return it
    return search;
  }
}
