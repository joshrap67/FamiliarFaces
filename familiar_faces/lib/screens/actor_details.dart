import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/domain/actor.dart';
import 'package:familiar_faces/domain/actor_credit.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/widgets/actor_media_card.dart';
import 'package:familiar_faces/widgets/sort_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'media_cast_screen.dart';

class ActorDetails extends StatefulWidget {
  const ActorDetails({Key? key, required this.actor}) : super(key: key);

  final Actor actor;

  @override
  _ActorDetailsState createState() => _ActorDetailsState();
}

enum Filters { ShowOnlySeen, IncludeMovies, IncludeTv }

class _ActorDetailsState extends State<ActorDetails> {
  List<ActorCredit> _displayedCredits = [];
  List<ActorCredit> _allCredits = [];
  SortValue _sortValue = SortValue.ReleaseDateDescending;
  bool _showOnlySeen = false;
  bool _includeMovies = true;
  bool _includeTv = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _allCredits = List.from(widget.actor.credits);
    updateDisplayedCredits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey(),
      appBar: AppBar(
        title: const AutoSizeText(
          'Actor Details',
          minFontSize: 10,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                  child: Container(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CachedNetworkImage(
                          imageUrl: getTmdbPicture(widget.actor.profileImagePath),
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
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      if (widget.actor.birthday != null) // ffs
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                          child: AutoSizeText(
                                            '${getAge(widget.actor.birthday!, widget.actor.deathDay)}',
                                            style: const TextStyle(fontSize: 14),
                                            maxLines: 1,
                                            minFontSize: 10,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                                        child: Visibility(
                                          visible: _allCredits.where((element) => element.isSeenByUser).length > 0,
                                          maintainSize: true,
                                          maintainAnimation: true,
                                          maintainSemantics: true,
                                          maintainState: true,
                                          child: AutoSizeText(
                                            'Seen ${_allCredits.where((element) => element.isSeenByUser).length} of their credits',
                                            style: const TextStyle(fontSize: 14),
                                            maxLines: 1,
                                            minFontSize: 10,
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SortDropdown(
                                            sortValue: _sortValue, onSelected: (result) => onSortSelected(result)),
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(15.0),
                                            ),
                                          ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 2.0),
                    child: _displayedCredits.length > 0
                        ? Scrollbar(
                            child: ListView.builder(
                              key: new PageStorageKey<String>('actor_details:list'),
                              itemCount: _displayedCredits.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ActorMediaCard(
                                  media: _displayedCredits[index],
                                  arrowClicked: (credit) => mediaClicked(credit),
                                  setSeenClicked: (credit) => setToSeen(credit),
                                  removeAsSeenClicked: (credit) => removeAsSeen(credit),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: const Text(
                              'No credits',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: _isLoading,
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  Future<void> mediaClicked(ActorCredit creditResponse) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (creditResponse.mediaType == MediaType.Movie) {
        var movie = await MediaService.getMovieWithCast(creditResponse.id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: movie.cast,
              movie: movie,
            ),
          ),
        ).then((value) => updateSeenCredits());
      } else if (creditResponse.mediaType == MediaType.TV) {
        var tvShow = await MediaService.getTvShowWithCast(creditResponse.id);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: tvShow.cast,
              tvShow: tvShow,
            ),
          ),
        ).then((value) => updateSeenCredits());
      }
    } catch (e) {
      showSnackbar('There was a problem loading the media', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void updateSeenCredits() {
    var seenMedia = context.read<SavedMediaProvider>().savedMedia;
    MediaService.applySeenMedia(_allCredits, seenMedia);
    setState(() {
      updateDisplayedCredits();
    });
  }

  Future<void> setToSeen(ActorCredit creditResponse) async {
    await SavedMediaService.add(
        context,
        new SavedMedia(creditResponse.id, creditResponse.mediaType,
            title: creditResponse.title,
            posterPath: creditResponse.posterPath,
            releaseDate: creditResponse.releaseDate));

    setState(() {
      var media = _allCredits.firstWhere((element) => element.id == creditResponse.id);
      media.isSeenByUser = true;
    });
  }

  Future<void> removeAsSeen(ActorCredit credit) async {
    var seenMedia = await SavedMediaService.getByMediaId(credit.id);
    if (seenMedia == null) {
      return;
    }

    await SavedMediaService.remove(context, seenMedia.id!);

    setState(() {
      var media = _allCredits.firstWhere((element) => element.id == credit.id);
      media.isSeenByUser = false;
    });
  }

  void onSortSelected(SortValue result) {
    if (_sortValue != result) {
      _sortValue = result;
      setState(() {
        updateDisplayedCredits();
      });
    }
  }

  void sortCredits(List<ActorCredit> credits) {
    // seen credits are always on top
    switch (_sortValue) {
      case SortValue.AlphaDescending:
        credits.sort((a, b) {
          var sortBySeen = compareToBool(a.isSeenByUser, b.isSeenByUser);
          if (sortBySeen == 0) {
            if (a.title == null || b.title == null) {
              return 1;
            } else {
              return b.title!.toLowerCase().compareTo(a.title!.toLowerCase());
            }
          }
          return sortBySeen;
        });
        break;
      case SortValue.AlphaAscending:
        credits.sort((a, b) {
          var sortBySeen = compareToBool(a.isSeenByUser, b.isSeenByUser);
          if (sortBySeen == 0) {
            if (a.title == null || b.title == null) {
              return 1;
            } else {
              return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
            }
          }
          return sortBySeen;
        });
        break;
      case SortValue.ReleaseDateDescending:
        credits.sort((a, b) {
          var sortBySeen = compareToBool(a.isSeenByUser, b.isSeenByUser);
          if (sortBySeen == 0) {
            if (a.releaseDate == null || b.releaseDate == null) {
              return 1;
            } else {
              return b.releaseDate!.compareTo(a.releaseDate!);
            }
          }
          return sortBySeen;
        });
        break;
      case SortValue.ReleaseDateAscending:
        credits.sort((a, b) {
          var sortBySeen = compareToBool(a.isSeenByUser, b.isSeenByUser);
          if (sortBySeen == 0) {
            if (a.releaseDate == null || b.releaseDate == null) {
              return 1;
            } else {
              return a.releaseDate!.compareTo(b.releaseDate!);
            }
          }
          return sortBySeen;
        });
        break;
    }
  }

  void updateDisplayedCredits() {
    var credits = List<ActorCredit>.from(_allCredits);

    if (_showOnlySeen) {
      credits.removeWhere((element) => !element.isSeenByUser);
    }
    if (!_includeTv) {
      credits.removeWhere((element) => element.mediaType == MediaType.TV);
    }
    if (!_includeMovies) {
      credits.removeWhere((element) => element.mediaType == MediaType.Movie);
    }

    sortCredits(credits);
    _displayedCredits = credits;
  }
}
