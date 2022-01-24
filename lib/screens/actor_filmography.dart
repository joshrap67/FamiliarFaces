import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/screens/actor_movie_row.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActorFilmography extends StatefulWidget {
  const ActorFilmography({Key? key, required this.actor}) : super(key: key);

  final PersonResponse actor;

  @override
  _ActorFilmographyState createState() => _ActorFilmographyState();
}

enum Filters { ShowOnlySeen, IncludeMovies, IncludeTv }
enum SortingValues { AlphaDescending, AlphaAscending, ReleaseDateDescending, ReleaseDateAscending }

class _ActorFilmographyState extends State<ActorFilmography> {
  late List<PersonCreditResponse> _displayedCredits;
  late List<PersonCreditResponse> _allCredits;
  late List<PersonCreditResponse> _seenCredits = <PersonCreditResponse>[];
  late String _url;
  late bool _showImage;
  SortingValues _sortValue = SortingValues.ReleaseDateDescending;
  bool _groupSeenAtTop = true;
  bool _showOnlySeen = false;
  bool _includeMovies = true;
  bool _includeTv = true;
  static const String placeholderUrl = 'https://picsum.photos/500';
  final _scrollController = new ScrollController();

  // todo on return re query all saved media in case somewhere down the stack they added a media to their seen list and its on this original page

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
      body: Column(
        children: [
          Container(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.network(
                  _showImage ? _url : placeholderUrl,
                  fit: BoxFit.scaleDown,
                  width: 100,
                  height: 140,
                ),
                Expanded(
                  child: Container(
                    // color: Colors.red,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              '${widget.actor.name}',
                              style: TextStyle(fontSize: 20),
                              minFontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PopupMenuButton(
                        icon: Icon(Icons.sort_rounded),
                        itemBuilder: (context) => <PopupMenuEntry<SortingValues>>[
                          PopupMenuItem<SortingValues>(
                            value: SortingValues.AlphaAscending,
                            child: Container(
                              child: Text('Alpha Ascending'),
                            ),
                          ),
                          PopupMenuItem<SortingValues>(
                            value: SortingValues.AlphaDescending,
                            child: Text('Alpha Descending'),
                          ),
                          PopupMenuItem<SortingValues>(
                            value: SortingValues.ReleaseDateAscending,
                            child: Text('Release Date Ascending'),
                          ),
                          PopupMenuItem<SortingValues>(
                            value: SortingValues.ReleaseDateDescending,
                            child: Text('Release Date Descending'),
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
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 10.0, 2.0, 2.0),
              child: Scrollbar(
                child: ListView.separated(
                  key: new PageStorageKey<String>('actor_details:list'),
                  controller: _scrollController,
                  separatorBuilder: (BuildContext context, int index) => Divider(height: 15),
                  itemCount: _displayedCredits.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ActorMovieRow(
                      movie: _displayedCredits[index],
                      rowClicked: (movie) => mediaClicked(movie),
                      addToSeenClicked: (movie) => addToSeen(movie),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void mediaClicked(PersonCreditResponse creditResponse) async {
    final snackBar = SnackBar(
      duration: Duration(seconds: 1),
      content: const LinearProgressIndicator(
        color: Colors.redAccent,
      ),
    );

    // route .then((value) => {print('todo refresh seen media list')});

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void addToSeen(PersonCreditResponse creditResponse) async {
    await SavedMediaDatabase.instance.create(new SavedMedia(creditResponse.id,
        title: creditResponse.title, posterPath: creditResponse.posterPath, releaseDate: creditResponse.releaseDate));

    setState(() {
      var media = _allCredits.firstWhere((element) => element.id == creditResponse.id);
      media.isSeen = true;
    });
  }

  void sortCredits(List<PersonCreditResponse> credits) {
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
    _seenCredits = <PersonCreditResponse>[];
    _seenCredits.addAll(_allCredits.where((element) => element.isSeen));

    if (_showOnlySeen) {
      _displayedCredits.removeWhere((element) => !element.isSeen);
    }

    if (!_includeTv) {
      _displayedCredits.removeWhere((element) => element.mediaType == MediaType.TV);
    }

    if (!_includeMovies) {
      _displayedCredits.removeWhere((element) => element.mediaType == MediaType.Movie);
    }

    if (_groupSeenAtTop) {
      // todo idk if its worth making this a toggle
      _displayedCredits.removeWhere((element) => element.isSeen);
    }

    sortCredits(_seenCredits);
    sortCredits(_displayedCredits);

    _displayedCredits.insertAll(0, _seenCredits);
  }
}
