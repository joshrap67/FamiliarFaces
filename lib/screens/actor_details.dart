import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie.dart';
import 'package:familiar_faces/contracts/actor_credit.dart';
import 'package:familiar_faces/contracts/actor.dart';
import 'package:familiar_faces/contracts/tv_show.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/actor_media_row.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'media_cast_screen.dart';

class ActorDetails extends StatefulWidget {
  const ActorDetails({Key? key, required this.actor}) : super(key: key);

  final Actor actor;

  @override
  _ActorDetailsState createState() => _ActorDetailsState();
}

enum Filters { ShowOnlySeen, IncludeMovies, IncludeTv }

class _ActorDetailsState extends State<ActorDetails> {
  late List<ActorCredit> _displayedCredits;
  late List<ActorCredit> _allCredits;
  late List<ActorCredit> _seenCredits = <ActorCredit>[];
  late String _url;
  late bool _showImage;
  SortingValues _sortValue = SortingValues.ReleaseDateDescending;
  bool _showOnlySeen = false;
  bool _includeMovies = true;
  bool _includeTv = true;
  static const String placeholderUrl = 'https://picsum.photos/500'; // todo remove
  final _scrollController = new ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    _url = 'https://image.tmdb.org/t/p/w500/${widget.actor.profileImagePath}';
    _allCredits = List.from(widget.actor.credits);
    _allCredits.removeWhere((element) => element.releaseDate == null);
    _showImage = widget.actor.profileImagePath != null;

    updateDisplayedCredits();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey(),
      appBar: AppBar(
        title: AutoSizeText(
          'Actor Details',
          minFontSize: 10,
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        opacity: 0.4,
        child: Column(
          children: [
            Container(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CachedNetworkImage(
                    imageUrl: _showImage ? _url : placeholderUrl,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        child: const CircularProgressIndicator(),
                        height: 50,
                        width: 50,
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  '${widget.actor.name}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  minFontSize: 10,
                                  style: TextStyle(fontSize: 24),
                                ),
                                if (widget.actor.birthday != null) // ffs
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                    child: AutoSizeText(
                                      '${getAge(widget.actor.birthday!, widget.actor.deathDay)}',
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 1,
                                      minFontSize: 10,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                // todo show seen count
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              PopupMenuButton(
                                icon: Icon(Icons.sort_rounded),
                                itemBuilder: (context) => <PopupMenuEntry<SortingValues>>[
                                  PopupMenuItem<SortingValues>(
                                    value: SortingValues.AlphaAscending,
                                    child: Container(
                                      child: Text(
                                        'Alpha Ascending',
                                        style: TextStyle(
                                            decoration: _sortValue == SortingValues.AlphaAscending
                                                ? TextDecoration.underline
                                                : null),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<SortingValues>(
                                    value: SortingValues.AlphaDescending,
                                    child: Text(
                                      'Alpha Descending',
                                      style: TextStyle(
                                          decoration: _sortValue == SortingValues.AlphaDescending
                                              ? TextDecoration.underline
                                              : null),
                                    ),
                                  ),
                                  PopupMenuItem<SortingValues>(
                                    value: SortingValues.ReleaseDateAscending,
                                    child: Text(
                                      'Release Date Ascending',
                                      style: TextStyle(
                                          decoration: _sortValue == SortingValues.ReleaseDateAscending
                                              ? TextDecoration.underline
                                              : null),
                                    ),
                                  ),
                                  PopupMenuItem<SortingValues>(
                                    value: SortingValues.ReleaseDateDescending,
                                    child: Text(
                                      'Release Date Descending',
                                      style: TextStyle(
                                          decoration: _sortValue == SortingValues.ReleaseDateDescending
                                              ? TextDecoration.underline
                                              : null),
                                    ),
                                  ),
                                ],
                                onSelected: (SortingValues result) {
                                  if (_sortValue != result) {
                                    _sortValue = result;
                                    setState(() {
                                      updateDisplayedCredits();
                                    });
                                  }
                                },
                              ),
                              PopupMenuButton<Filters>(
                                onSelected: (Filters result) {
                                  switch (result) {
                                    case Filters.ShowOnlySeen:
                                      setState(() {
                                        _showOnlySeen = !_showOnlySeen;
                                        updateDisplayedCredits();
                                      });
                                      break;
                                    case Filters.IncludeMovies:
                                      setState(() {
                                        _includeMovies = !_includeMovies;
                                        updateDisplayedCredits();
                                      });
                                      break;
                                    case Filters.IncludeTv:
                                      setState(() {
                                        _includeTv = !_includeTv;
                                        updateDisplayedCredits();
                                      });
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<Filters>>[
                                  CheckedPopupMenuItem<Filters>(
                                    checked: _showOnlySeen,
                                    value: Filters.ShowOnlySeen,
                                    child: const Text('Include Seen Media Only'),
                                  ),
                                  const PopupMenuDivider(),
                                  CheckedPopupMenuItem<Filters>(
                                    value: Filters.IncludeMovies,
                                    checked: _includeMovies,
                                    child: Text('Include Movies'),
                                  ),
                                  const PopupMenuDivider(),
                                  CheckedPopupMenuItem<Filters>(
                                    value: Filters.IncludeTv,
                                    checked: _includeTv,
                                    child: Text('Include TV Shows'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 2.0),
                child: _displayedCredits.length > 0
                    ? Scrollbar(
                        child: ListView.separated(
                          key: new PageStorageKey<String>('actor_details:list'),
                          controller: _scrollController,
                          separatorBuilder: (BuildContext context, int index) => Divider(height: 15),
                          itemCount: _displayedCredits.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ActorMediaRow(
                              movie: _displayedCredits[index],
                              rowClicked: (movie) => mediaClickedAsync(movie),
                              addToSeenClicked: (movie) => addToSeenSync(movie),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          'No credits',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateSeenAsync() async {
    List<SavedMedia> seenMedia = await SavedMediaService.getAll();
    MediaService.applySeenMedia(_allCredits, seenMedia);
    setState(() {
      updateDisplayedCredits();
    });
  }

  void updateSeenCredits() {
    _seenCredits = <ActorCredit>[];
    _seenCredits.addAll(_allCredits.where((element) => element.isSeen));
  }

  Future<void> mediaClickedAsync(ActorCredit creditResponse) async {
    // showLoadingDialog(context, dismissible: true); todo this breaks everything
    setState(() {
      _isLoading = true;
    });
    try {
      if (creditResponse.mediaType == MediaType.Movie) {
        var actorsOfMovie = await MediaService.getActorsFromMovie(creditResponse.id);

        Movie movie = await MediaService.getMovieWithCast(creditResponse.id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: movie.cast,
              actors: actorsOfMovie,
              movie: movie,
            ),
          ),
        ).then((value) => updateSeenAsync());
      } else if (creditResponse.mediaType == MediaType.TV) {
        var actorsOfTvShow = await MediaService.getActorsFromTv(creditResponse.id);

        TvShow tvShow = await MediaService.getTvShowWithCast(creditResponse.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: tvShow.cast,
              actors: actorsOfTvShow,
              tvShow: tvShow,
            ),
          ),
        ).then((value) => updateSeenAsync()).onError((error, stackTrace) => print(error));
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addToSeenSync(ActorCredit creditResponse) async {
    await SavedMediaDatabase.instance.create(new SavedMedia(creditResponse.id, creditResponse.mediaType,
        title: creditResponse.title, posterPath: creditResponse.posterPath, releaseDate: creditResponse.releaseDate));

    setState(() {
      var media = _allCredits.firstWhere((element) => element.id == creditResponse.id);
      media.isSeen = true;
    });
  }

  void sortCredits(List<ActorCredit> credits) {
    switch (_sortValue) {
      case SortingValues.AlphaDescending:
        credits.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return b.title!.toLowerCase().compareTo(a.title!.toLowerCase());
          }
        });
        break;
      case SortingValues.AlphaAscending:
        credits.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
          }
        });
        break;
      case SortingValues.ReleaseDateDescending:
        credits.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return b.releaseDate!.compareTo(a.releaseDate!);
          }
        });
        break;
      case SortingValues.ReleaseDateAscending:
        credits.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return a.releaseDate!.compareTo(b.releaseDate!);
          }
        });
        break;
    }
  }

  void updateDisplayedCredits() {
    _displayedCredits = List.from(_allCredits);
    updateSeenCredits();

    if (_showOnlySeen) {
      _displayedCredits.removeWhere((element) => !element.isSeen);
    }

    if (!_includeTv) {
      _displayedCredits.removeWhere((element) => element.mediaType == MediaType.TV);
      _seenCredits.removeWhere((element) => element.mediaType == MediaType.TV);
    }

    if (!_includeMovies) {
      _displayedCredits.removeWhere((element) => element.mediaType == MediaType.Movie);
      _seenCredits.removeWhere((element) => element.mediaType == MediaType.Movie);
    }

    _displayedCredits.removeWhere((element) => element.isSeen); // so seen media isn't shown twice in same list

    sortCredits(_seenCredits);
    sortCredits(_displayedCredits);

    _displayedCredits.insertAll(0, _seenCredits);
  }
}
