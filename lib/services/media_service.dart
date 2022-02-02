import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/contracts/movie.dart';
import 'package:familiar_faces/contracts/actor_credit.dart';
import 'package:familiar_faces/contracts/actor.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/contracts/tv_show.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';

class MediaService {
  static Future<Actor> getActor(int id) async {
    Actor actor = await TmdbService.getPersonCreditsAsync(id);
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();

    applySeenMedia(actor.credits, savedMedia);
    cleanActorCredits(actor.credits);

    return actor;
  }

  static Future<Movie> getMovieWithCast(int movieId) async {
    var movie = await TmdbService.getMovieWithCastAsync(movieId);
    cleanCast(movie.cast);

    return movie;
  }

  // bad path, loop through every actor in the movie and return their credits
  static Future<List<Actor>> getActorsFromMovie(int movieId, {String? characterName}) async {
    List<Actor> movieActors = <Actor>[];
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();

    var movieWithCast = await TmdbService.getMovieWithCastAsync(movieId);
    cleanCast(movieWithCast.cast);

    await Future.wait(movieWithCast.cast
        .map((castMember) => TmdbService.getPersonCreditsAsync(castMember.id).then((value) => movieActors.add(value))));

    var actors = new List<Actor>.from(movieActors);
    actors.forEach((element) {
      applySeenMedia(element.credits, savedMedia);
      cleanActorCredits(element.credits);
    });

    return actors;
  }

  static Future<TvShow> getTvShowWithCast(int tvId) async {
    var tvShow = await TmdbService.getTvShowWithCastAsync(tvId);
    cleanCast(tvShow.cast);

    return tvShow;
  }

  // bad path, loop through every actor in the movie and return their credits
  static Future<List<Actor>> getActorsFromTv(int tvId, {String? characterName}) async {
    List<Actor> tvShowActors = <Actor>[];
    List<SavedMedia> savedMedia = await SavedMediaService.getAll();

    var tvWithCast = await TmdbService.getTvShowWithCastAsync(tvId);
    cleanCast(tvWithCast.cast);

    await Future.wait(tvWithCast.cast.map((castMember) async {
      return TmdbService.getPersonCreditsAsync(castMember.id).then((value) => tvShowActors.add(value));
    }));

    var actors = new List<Actor>.from(tvShowActors);
    actors.forEach((element) {
      applySeenMedia(element.credits, savedMedia);
      cleanActorCredits(element.credits);
    });

    return actors;
  }

  static void applySeenMedia(List<ActorCredit> credits, List<SavedMedia> savedMedia) {
    for (var credit in credits) {
      if (savedMedia.any((element) => element.mediaId == credit.id && element.mediaType == credit.mediaType)) {
        credit.isSeen = true;
      }
    }
  }

  static void cleanActorCredits(List<ActorCredit> credits) {
    var now = DateTime.now();
    credits.removeWhere((element) => element.releaseDate == null);
    credits.removeWhere((element) => element.releaseDate!.isAfter(now));
    credits.removeWhere((element) => element.posterPath == null);
    credits.removeWhere((element) => element.title == null);
  }

  static void cleanCast(List<Cast> cast) {
    cast.removeWhere((element) => element.profilePath == null);
    cast.removeWhere((element) => element.name == null);
  }

  // this method is the main source of data cleaning since this is the only way in the app to actually get media ids to query
  static Future<List<SearchMediaResult>> searchMulti(String query, {bool showSavedMedia = true}) async {
    if (isStringNullOrEmpty(query)) {
      return <SearchMediaResult>[];
    }
    List<SearchMediaResult> search = await TmdbService.searchMulti(query);
    // drop any records with a null title as that makes no sense for user to click
    search.removeWhere((element) => element.title == null);
    search.removeWhere((element) => element.releaseDate == null);
    // if it has a null poster it likely is not very popular and might not be released yet either
    search.removeWhere((element) => element.posterPath == null);
    // lmao don't want porn though this worries me since the data is user entered and someone might not flag it properly...
    search.removeWhere((element) => element.isAdult);
    // according to TMDB docs, this field is set on things like BTS or short films but doesn't actually seem to matter
    search.removeWhere((element) => element.isVideo);
    if (!showSavedMedia) {
      List<SavedMedia> savedMedia = await SavedMediaService.getAll();
      // don't show suggestions for ones the user has already saved
      search.removeWhere((element) => savedMedia
          .any((savedMedia) => savedMedia.mediaId == element.id && savedMedia.mediaType == element.mediaType));
    }

    // if it hasn't been released don't show it
    var now = DateTime.now();
    search.removeWhere((element) => element.releaseDate!.isAfter(now));

    return search;
  }
}
