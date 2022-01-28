import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SavedMediaListScreen extends StatefulWidget {
  const SavedMediaListScreen({Key? key}) : super(key: key);

  @override
  _SavedMediaListScreenState createState() => _SavedMediaListScreenState();
}

class _SavedMediaListScreenState extends State<SavedMediaListScreen> {
  List<SavedMedia> _allSavedMedia = <SavedMedia>[];
  List<SavedMedia> _displayedSavedMedia = <SavedMedia>[];
  final TextEditingController _mediaSearchController = TextEditingController();
  SortingValues _sortValue = SortingValues.ReleaseDateDescending;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    getSavedMedia();
    super.initState();
  }

  @override
  void dispose() {
    _mediaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => onBackPressed(),
        child: Stack(
          children: [
            Column(
              children: [
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                          child: TextField(
                            onChanged: searchSavedMedia,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                labelText: 'Search my media',
                                hintText: 'Search Movie or TV Show'),
                          ),
                        ),
                      ),
                      sortIcon(),
                      IconButton(
                        icon: Icon(Icons.add),
                        tooltip: 'Add',
                        onPressed: () => setEditing(false),
                      ),
                    ],
                  ),
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TypeAheadFormField<SearchMediaResponse>(
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: _mediaSearchController,
                                    onChanged: (_) {
                                      // need to do this for x button to hide when text is empty on controller
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search),
                                        border: OutlineInputBorder(),
                                        labelText: 'Add Movie/TV Show',
                                        hintText: 'Search Movie or TV Show'),
                                  ),
                                  debounceDuration: Duration(milliseconds: 300),
                                  suggestionsCallback: (query) =>
                                      MediaService.searchMulti(query, showSavedMedia: false),
                                  noItemsFoundBuilder: (context) {
                                    return Text('');
                                  },
                                  itemBuilder: (context, SearchMediaResponse result) {
                                    return ListTile(
                                      title: Text('${result.title}'),
                                      leading: Container(
                                        height: 50,
                                        width: 50,
                                        child: CachedNetworkImage(
                                          imageUrl: getImageUrl(result.posterPath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  onSuggestionSelected: onMediaSelected),
                              if (!isStringNullOrEmpty(_mediaSearchController.text))
                                IconButton(
                                  icon: Icon(Icons.clear),
                                  tooltip: 'Clear media',
                                  onPressed: onMediaInputCleared,
                                ),
                            ],
                          ),
                        ),
                        sortIcon(),
                        IconButton(
                          icon: Icon(Icons.mode_edit),
                          tooltip: 'Edit',
                          onPressed: () => setEditing(true),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _displayedSavedMedia.length > 0
                      ? Scrollbar(
                          child: ListView.separated(
                            separatorBuilder: (BuildContext context, int index) => Divider(height: 10),
                            itemCount: _displayedSavedMedia.length,
                            key: GlobalKey(),
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: AutoSizeText(
                                  '${_displayedSavedMedia[index].title} (${formatDateYearOnly(_displayedSavedMedia[index].releaseDate)})',
                                  minFontSize: 12,
                                ),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: CachedNetworkImage(
                                    imageUrl: getImageUrl(_displayedSavedMedia[index].posterPath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                trailing: _isEditing
                                    ? PopupMenuButton(
                                        icon: Icon(Icons.more_vert),
                                        tooltip: 'Edit Options',
                                        itemBuilder: (context) => <PopupMenuEntry<int>>[
                                          PopupMenuItem<int>(
                                            value: 0,
                                            child: Text('REMOVE'),
                                          ),
                                        ],
                                        onSelected: (int result) {
                                          if (result == 0) {
                                            deleteSavedMedia(_displayedSavedMedia[index]);
                                          }
                                        },
                                      )
                                    : null,
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            'No saved media',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget sortIcon() {
    return PopupMenuButton(
      icon: Icon(Icons.sort_rounded),
      tooltip: 'Sort Media',
      itemBuilder: (context) => <PopupMenuEntry<SortingValues>>[
        PopupMenuItem<SortingValues>(
          value: SortingValues.AlphaAscending,
          child: Container(
            child: Text(
              'Alpha Ascending',
              style:
                  TextStyle(decoration: _sortValue == SortingValues.AlphaAscending ? TextDecoration.underline : null),
            ),
          ),
        ),
        PopupMenuItem<SortingValues>(
          value: SortingValues.AlphaDescending,
          child: Text(
            'Alpha Descending',
            style: TextStyle(decoration: _sortValue == SortingValues.AlphaDescending ? TextDecoration.underline : null),
          ),
        ),
        PopupMenuItem<SortingValues>(
          value: SortingValues.ReleaseDateAscending,
          child: Text(
            'Release Date Ascending',
            style: TextStyle(
                decoration: _sortValue == SortingValues.ReleaseDateAscending ? TextDecoration.underline : null),
          ),
        ),
        PopupMenuItem<SortingValues>(
          value: SortingValues.ReleaseDateDescending,
          child: Text(
            'Release Date Descending',
            style: TextStyle(
                decoration: _sortValue == SortingValues.ReleaseDateDescending ? TextDecoration.underline : null),
          ),
        ),
      ],
      onSelected: (SortingValues result) {
        if (_sortValue != result) {
          _sortValue = result;
          setState(() {
            sortDisplayedMedia();
          });
        }
      },
    );
  }

  void sortDisplayedMedia() {
    // todo save sort value to shared prefs?
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

  Future<void> getSavedMedia() async {
    _allSavedMedia = await SavedMediaService.getAll();
    _displayedSavedMedia = List.from(_allSavedMedia);
    setState(() {
      sortDisplayedMedia();
    });
  }

  Future<void> onMediaSelected(SearchMediaResponse selected) async {
    if (_allSavedMedia.any((element) => element.mediaId == selected.id)) {
      showSnackbar('You already have added this media to your list.', context);
    } else {
      var savedMedia = new SavedMedia(selected.id,
          title: selected.title, posterPath: selected.posterPath, releaseDate: selected.releaseDate);
      var created = await SavedMediaService.add(savedMedia);
      setState(() {
        _allSavedMedia.add(created);
        _displayedSavedMedia.add(created);
        sortDisplayedMedia();
      });
    }
  }

  Future<void> deleteSavedMedia(SavedMedia mediaToDelete) async {
    await SavedMediaService.remove(mediaToDelete.id!);
    setState(() {
      _allSavedMedia.removeWhere((element) => mediaToDelete.id == element.id!);
      _displayedSavedMedia.removeWhere((element) => mediaToDelete.id == element.id!);
      sortDisplayedMedia();
    });
  }

  onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      hideKeyboard(context);
    });
  }

  setEditing(bool isEditing) {
    setState(() {
      _isEditing = isEditing;
      _displayedSavedMedia = List.from(_allSavedMedia);
      sortDisplayedMedia();
    });
  }

  searchSavedMedia(String searchText) {
    setState(() {
      _displayedSavedMedia = List.from(_allSavedMedia.where((element) {
        if (element.title == null) {
          return false;
        }
        return element.title!.toLowerCase().contains(searchText.toLowerCase());
      }));
      sortDisplayedMedia();
    });
  }

  Future<bool> onBackPressed() async {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild!.unfocus();
      return false;
    } else {
      return true;
    }
  }
}
