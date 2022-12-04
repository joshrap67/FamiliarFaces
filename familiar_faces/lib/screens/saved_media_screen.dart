import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';
import 'package:familiar_faces/widgets/sort_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'media_cast_screen.dart';

class SavedMediaScreen extends StatefulWidget {
  const SavedMediaScreen({Key? key}) : super(key: key);

  @override
  _SavedMediaScreenState createState() => _SavedMediaScreenState();
}

class _SavedMediaScreenState extends State<SavedMediaScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _mediaAddController = TextEditingController();
  final TextEditingController _mediaSearchController = TextEditingController();

  List<SavedMedia> _allSavedMedia = <SavedMedia>[];
  List<SavedMedia> _displayedSavedMedia = <SavedMedia>[];
  SortingValues _sortValue = SortingValues.ReleaseDateDescending;
  FocusNode _searchFocusNode = new FocusNode();
  FocusNode _addMediaFocusNode = new FocusNode();
  bool _showMovies = true;
  bool _showTV = true;

  @override
  void initState() {
    super.initState();
    updateSavedMedia();
  }

  @override
  void dispose() {
    _mediaAddController.dispose();
    _mediaSearchController.dispose();
    _searchFocusNode.dispose();
    _addMediaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Column(
          children: [
            if (_allSavedMedia.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            controller: _mediaSearchController,
                            onChanged: (input) => searchSavedMedia(input),
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(),
                                suffixIcon: _mediaSearchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _mediaSearchController.clear();
                                            hideKeyboard(context);
                                            searchSavedMedia(_mediaSearchController.text);
                                          });
                                        },
                                        icon: Icon(Icons.clear),
                                      )
                                    : null,
                                labelText: 'Search My Media',
                                hintText: 'Search Movie or TV Show'),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            if (_allSavedMedia.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        movieCount(),
                        Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0)),
                        tvCount(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SortDropdown(sortValue: _sortValue, onSelected: (result) => onSortSelected(result)),
                    )
                  ],
                ),
              ),
            Expanded(
              child: _displayedSavedMedia.isNotEmpty
                  ? Scrollbar(
                      interactive: true,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                        // list has to be wrapped in a material... https://github.com/flutter/flutter/issues/86584
                        child: Material(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: ListView.separated(
                            separatorBuilder: (BuildContext context, int index) => Divider(
                              height: 10,
                              color: Colors.transparent,
                            ),
                            key: new PageStorageKey<String>('saved_media_screen:list'),
                            itemCount: _displayedSavedMedia.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () => rowClicked(index),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  title: AutoSizeText(
                                    _displayedSavedMedia[index].title!,
                                    minFontSize: 12,
                                  ),
                                  subtitle: AutoSizeText(
                                    formatDateYearOnly(_displayedSavedMedia[index].releaseDate),
                                    minFontSize: 12,
                                  ),
                                  tileColor: Globals.TILE_COLOR,
                                  leading: Container(
                                    height: 160,
                                    width: 50,
                                    child: Image.network(
                                      getTmdbPicture(_displayedSavedMedia[index].posterPath),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: const Text(
                        'No saved media',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                addPopup();
              },
              child: Icon(Icons.add),
            ),
          ),
        )
      ],
    );
  }

  Widget movieCount() {
    return FilterChip(
      label: Text(
        '${_allSavedMedia.where((element) => element.mediaType == MediaType.Movie).length} movies',
        style: TextStyle(color: Colors.white),
      ),
      selectedColor: Theme.of(context).colorScheme.secondary,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.black54,
      selected: _showMovies,
      onSelected: (bool value) {
        setState(() {
          _showMovies = value;
          filterMedia();
        });
      },
    );
  }

  Widget tvCount() {
    return FilterChip(
      label: Text(
        '${_allSavedMedia.where((element) => element.mediaType == MediaType.TV).length} TV shows',
        style: TextStyle(color: Colors.white),
      ),
      selectedColor: Theme.of(context).colorScheme.secondary,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.black54,
      selected: _showTV,
      onSelected: (bool value) {
        setState(() {
          _showTV = value;
          filterMedia();
        });
      },
    );
  }

  String formattedMovieTitle(SavedMedia savedMedia) {
    return '${savedMedia.title} (${formatDateYearOnly(savedMedia.releaseDate)})';
  }

  void onSortSelected(SortingValues result) {
    if (_sortValue != result) {
      _sortValue = result;
      setState(() {
        sortDisplayedMedia();
      });
    }
  }

  void sortDisplayedMedia() {
    switch (_sortValue) {
      case SortingValues.AlphaDescending:
        _displayedSavedMedia.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return b.title!.toLowerCase().compareTo(a.title!.toLowerCase());
          }
        });
        break;
      case SortingValues.AlphaAscending:
        _displayedSavedMedia.sort((a, b) {
          if (a.title == null || b.title == null) {
            return 1;
          } else {
            return a.title!.toLowerCase().compareTo(b.title!.toLowerCase());
          }
        });
        break;
      case SortingValues.ReleaseDateDescending:
        _displayedSavedMedia.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return b.releaseDate!.compareTo(a.releaseDate!);
          }
        });
        break;
      case SortingValues.ReleaseDateAscending:
        _displayedSavedMedia.sort((a, b) {
          if (a.releaseDate == null || b.releaseDate == null) {
            return 1;
          } else {
            return a.releaseDate!.compareTo(b.releaseDate!);
          }
        });
        break;
    }
  }

  void filterMedia() {
    setState(() {
      // easier to just clear search input when changing the filters
      hideKeyboard(context);
      _mediaSearchController.text = '';

      _displayedSavedMedia = List.from(_allSavedMedia.where((element) => mediaFilter(element)));
      sortDisplayedMedia();
    });
  }

  bool mediaFilter(SavedMedia media) {
    if (media.mediaType == MediaType.Movie && _showMovies) {
      return true;
    }
    if (media.mediaType == MediaType.TV && _showTV) {
      return true;
    }
    return false;
  }

  void addPopup() {
    hideKeyboard(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('DONE'),
            )
          ],
          insetPadding: EdgeInsets.all(8.0),
          title: const Text('Add Media'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TypeAheadField<SearchMediaResult>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _mediaAddController,
                    onChanged: (_) {
                      // so x button can properly be hidden
                      setState(() {});
                    },
                    focusNode: _addMediaFocusNode,
                    decoration: const InputDecoration(
                        prefixIcon: const Icon(Icons.add),
                        border: const OutlineInputBorder(),
                        labelText: 'Add Media',
                        hintText: 'Add Movie or TV Show'),
                  ),
                  hideOnLoading: true,
                  hideOnEmpty: true,
                  hideOnError: true,
                  hideSuggestionsOnKeyboardHide: false,
                  debounceDuration: Duration(milliseconds: 300),
                  keepSuggestionsOnSuggestionSelected: true,
                  onSuggestionSelected: (media) => onMediaSelected(media),
                  suggestionsCallback: (query) => MediaService.searchMulti(query, showSavedMedia: false),
                  itemBuilder: (context, SearchMediaResult result) {
                    return ListTile(
                      title: Text('${result.title} (${formatDateYearOnly(result.releaseDate)})'),
                      leading: Container(
                        height: 50,
                        width: 50,
                        child: Image.network(
                          getTmdbPicture(result.posterPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                if (!isStringNullOrEmpty(_mediaAddController.text))
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear media',
                    onPressed: () => onMediaInputCleared(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onMediaInputCleared() {
    setState(() {
      _mediaAddController.text = '';
      hideKeyboard(context);
    });
  }

  void searchSavedMedia(String searchText) {
    setState(() {
      _displayedSavedMedia = List.from(_allSavedMedia.where((element) {
        if (element.title == null) {
          return false;
        }
        return element.title!.toLowerCase().contains(searchText.toLowerCase()) && mediaFilter(element);
      }));
      sortDisplayedMedia();
    });
  }

  bool modalShowing() {
    return ModalRoute.of(context)?.isCurrent != true;
  }

  void rowClicked(int index) {
    var media = _displayedSavedMedia[index];
    var loading = false;
    hideKeyboard(context);

    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext buildContext) {
        return StatefulBuilder(builder: (BuildContext statefulContext, StateSetter myState) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                  child: ListTile(
                    title: AutoSizeText(
                      formattedMovieTitle(media),
                      minFontSize: 12,
                    ),
                    subtitle: AutoSizeText(
                      media.mediaType == MediaType.Movie ? 'Movie' : 'TV Show',
                      minFontSize: 12,
                    ),
                    leading: Container(
                      child: Image.network(
                        getTmdbPicture(media.posterPath),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: loading,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: LinearProgressIndicator(),
                ),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    myState(() {
                      loading = true;
                    });
                    mediaClicked(media);
                  },
                  child: ListTile(
                    title: const Text('Show Cast'),
                    trailing: IconButton(
                      onPressed: () {
                        myState(() {
                          loading = true;
                        });
                        mediaClicked(media);
                      },
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: InkWell(
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      Navigator.pop(buildContext);
                      deleteSavedMedia(media);
                    },
                    child: ListTile(
                      title: const Text('Remove Media'),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.pop(buildContext);
                          deleteSavedMedia(media);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> mediaClicked(SavedMedia media) async {
    try {
      if (media.mediaType == MediaType.Movie) {
        var movie = await MediaService.getMovieWithCast(media.mediaId);

        if (modalShowing()) {
          closePopup(context);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: movie.cast,
              movie: movie,
            ),
          ),
        ).then((value) => updateSavedMedia());
      } else if (media.mediaType == MediaType.TV) {
        var tvShow = await MediaService.getTvShowWithCast(media.mediaId);

        if (modalShowing()) {
          closePopup(context);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: tvShow.cast,
              tvShow: tvShow,
            ),
          ),
        ).then((value) => updateSavedMedia());
      }
    } catch (e) {
      showSnackbar('There was a problem loading the media', context);
      if (modalShowing()) {
        closePopup(context);
      }
    }
  }

  Future<void> updateSavedMedia() async {
    _allSavedMedia = await SavedMediaService.getAll();
    filterMedia();
  }

  Future<void> onMediaSelected(SearchMediaResult selected) async {
    if (_allSavedMedia.any((element) => element.mediaId == selected.id && element.mediaType == selected.mediaType)) {
      showSnackbar('You already have added this media to your list.', context);
    } else {
      var savedMedia = new SavedMedia(selected.id, selected.mediaType,
          title: selected.title, posterPath: selected.posterPath, releaseDate: selected.releaseDate);
      var created = await SavedMediaService.add(savedMedia);
      showSnackbar('${selected.mediaType == MediaType.Movie ? 'Movie' : 'TV Show'} Added', context);
      setState(() {
        _allSavedMedia.add(created);
        _mediaAddController.text = '';
        _addMediaFocusNode.requestFocus();
        _displayedSavedMedia.add(created);
        sortDisplayedMedia();
      });
    }
  }

  Future<void> deleteSavedMedia(SavedMedia mediaToDelete) async {
    showDialog<void>(
      context: context,
      builder: (builderContext) {
        return AlertDialog(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(builderContext),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(builderContext);
                var success = await SavedMediaService.remove(mediaToDelete.id!);
                if (success) {
                  setState(() {
                    _allSavedMedia.removeWhere((element) => mediaToDelete.id == element.id!);
                    _displayedSavedMedia.removeWhere((element) => mediaToDelete.id == element.id!);
                    sortDisplayedMedia();
                  });
                } else {
                  showSnackbar('Error deleting media', context);
                }
              },
              child: const Text('YES'),
            ),
          ],
          title: const Text('Delete Media'),
          content: const Text('Are you sure you want to permanently delete this media from your list?'),
        );
      },
    );
  }

  // to keep state when page view scrolls to another page
  @override
  bool get wantKeepAlive => true;
}
