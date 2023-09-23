import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/widgets/sort_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import 'media_cast_screen.dart';

class SavedMediaScreen extends StatefulWidget {
  const SavedMediaScreen({Key? key}) : super(key: key);

  @override
  _SavedMediaScreenState createState() => _SavedMediaScreenState();
}

class _SavedMediaScreenState extends State<SavedMediaScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _mediaAddController = TextEditingController();
  final TextEditingController _mediaSearchController = TextEditingController();

  // List<SavedMedia> _allSavedMedia = <SavedMedia>[];
  SortValue _sortValue = SortValue.ReleaseDateDescending;
  FocusNode _searchFocusNode = new FocusNode();
  FocusNode _addMediaFocusNode = new FocusNode();
  bool _showMovies = true;
  bool _showTV = true;

  @override
  void initState() {
    super.initState();
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
    var savedMedia = getSavedMedia();
    return Stack(
      children: [
        Column(
          children: [
            if (context.read<SavedMediaProvider>().savedMedia.isNotEmpty)
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
                            onChanged: (_) {
                              setState(() {});
                            },
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(),
                                suffixIcon: _mediaSearchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _mediaSearchController.clear();
                                            hideKeyboard();
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
            if (context.read<SavedMediaProvider>().savedMedia.isNotEmpty)
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
              child: savedMedia.isNotEmpty
                  ? Scrollbar(
                      interactive: true,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                        // list has to be wrapped in a material... https://github.com/flutter/flutter/issues/86584
                        child: Material(
                          child: ListView.builder(
                            key: new PageStorageKey<String>('saved_media_screen:list'),
                            itemCount: savedMedia.length,
                            itemBuilder: (context, index) {
                              var media = savedMedia[index];
                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () => rowClicked(media),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    title: AutoSizeText(
                                      media.title!,
                                      minFontSize: 12,
                                    ),
                                    subtitle: AutoSizeText(
                                      formatDateYearOnly(media.releaseDate),
                                      minFontSize: 12,
                                    ),
                                    leading: Container(
                                      height: 160,
                                      width: 50,
                                      child: Image.network(
                                        getTmdbPicture(media.posterPath),
                                        fit: BoxFit.fitHeight,
                                      ),
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
                        'No seen media',
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
            child: FloatingActionButton.extended(
              onPressed: () {
                addPopup();
              },
              label: Text('ADD MEDIA'),
              icon: Icon(Icons.add),
            ),
          ),
        )
      ],
    );
  }

  List<SavedMedia> getSavedMedia() {
    var allMedia = context.watch<SavedMediaProvider>().savedMedia;
    var filteredMedia = List<SavedMedia>.from(allMedia.where((element) => mediaFilter(element)));
    if (_mediaSearchController.text.isNotEmpty) {
      var lowercaseSearch = _mediaSearchController.text.toLowerCase();
      return filteredMedia.where((element) => element.title!.toLowerCase().contains(lowercaseSearch)).toList();
    } else {
      return filteredMedia;
    }
  }

  Widget movieCount() {
    return FilterChip(
      label: Text(
        '${context.watch<SavedMediaProvider>().savedMedia.where((element) => element.mediaType == MediaType.Movie).length} movies',
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      selected: _showMovies,
      onSelected: (bool value) {
        setState(() {
          _showMovies = value;
        });
      },
    );
  }

  Widget tvCount() {
    return FilterChip(
      label: Text(
        '${context.watch<SavedMediaProvider>().savedMedia.where((element) => element.mediaType == MediaType.TV).length} TV shows',
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      selected: _showTV,
      onSelected: (bool value) {
        setState(() {
          _showTV = value;
        });
      },
    );
  }

  String formattedMovieTitle(SavedMedia savedMedia) {
    return '${savedMedia.title} (${formatDateYearOnly(savedMedia.releaseDate)})';
  }

  void onSortSelected(SortValue result) {
    if (_sortValue != result) {
      _sortValue = result;
      context.read<SavedMediaProvider>().setSort(_sortValue);
    }
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
    hideKeyboard();
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
                  suggestionsCallback: (query) => MediaService.searchMulti(context, query, showSavedMedia: false),
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
      hideKeyboard();
    });
  }

  bool modalShowing() {
    return ModalRoute.of(context)?.isCurrent != true;
  }

  void rowClicked(SavedMedia media) {
    var loading = false;
    hideKeyboard();

    showModalBottomSheet<void>(
      context: context,
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
        );
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
        );
      }
    } catch (e) {
      showSnackbar('There was a problem loading the media', context);
      if (modalShowing()) {
        closePopup(context);
      }
    }
  }

  Future<void> onMediaSelected(SearchMediaResult selected) async {
    var savedMedia = context.read<SavedMediaProvider>().savedMedia;
    if (savedMedia.any((element) => element.mediaId == selected.id && element.mediaType == selected.mediaType)) {
      showSnackbar('You already have added this media to your list.', context);
    } else {
      var savedMedia = new SavedMedia(selected.id, selected.mediaType,
          title: selected.title, posterPath: selected.posterPath, releaseDate: selected.releaseDate);
      await SavedMediaService.add(context, savedMedia);
      showSnackbar('${selected.mediaType == MediaType.Movie ? 'Movie' : 'TV Show'} Added', context);
      setState(() {
        _mediaAddController.text = '';
        _addMediaFocusNode.requestFocus();
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
                var success = await SavedMediaService.remove(context, mediaToDelete.id!);
                if (!success) {
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
