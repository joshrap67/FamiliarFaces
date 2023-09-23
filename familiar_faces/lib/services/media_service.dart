import 'package:familiar_faces/domain/actor.dart';
import 'package:familiar_faces/domain/actor_credit.dart';
import 'package:familiar_faces/domain/cast.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MediaService {
  static Future<Actor> getActor(BuildContext buildContext, int id) async {
    var actor = await TmdbService.getPersonCreditsAsync(id);
    cleanActorCredits(actor.credits);

    return actor;
  }

  static Future<Movie> getMovieWithCast(int movieId) async {
    var movie = await TmdbService.getMovieWithCastAsync(movieId);
    cleanCast(movie.cast);

    return movie;
  }

  static Future<TvShow> getTvShowWithCast(int tvId) async {
    var tvShow = await TmdbService.getTvShowWithCastAsync(tvId);
    cleanCast(tvShow.cast);

    return tvShow;
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
  static Future<List<SearchMediaResult>> searchMulti(BuildContext buildContext, String query,
      {bool showSavedMedia = true}) async {
    if (isStringNullOrEmpty(query)) {
      return <SearchMediaResult>[];
    }
    var search = await TmdbService.searchMulti(query);
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
      var savedMedia = buildContext.read<SavedMediaProvider>().savedMedia;
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
