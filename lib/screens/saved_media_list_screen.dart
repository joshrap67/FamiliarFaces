import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';
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
  FocusNode _searchFocusNode = new FocusNode();
  FocusNode _addMediaFocusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    updateSavedMedia();
  }

  @override
  void dispose() {
    _mediaSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: GestureDetector(
        onTap: () => hideKeyboard(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Media' : 'Add Media'),
          ),
          body: Column(
            children: [
              Row(
                children: [
                  if (_isEditing)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                        child: TextField(
                          onChanged: searchSavedMedia,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              labelText: 'Search my media',
                              hintText: 'Search Movie or TV Show'),
                        ),
                      ),
                    ),
                  if (!_isEditing)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            TypeAheadField<SearchMediaResult>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _mediaSearchController,
                                onChanged: (_) {
                                  // so x button can properly be hidden
                                  setState(() {});
                                },
                                focusNode: _addMediaFocusNode,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                    labelText: 'Movie/TV Show',
                                    hintText: 'Search Movie or TV Show'),
                              ),
                              hideOnLoading: true,
                              hideOnEmpty: true,
                              hideOnError: true,
                              hideSuggestionsOnKeyboardHide: false,
                              debounceDuration: Duration(milliseconds: 300),
                              onSuggestionSelected: (media) => onMediaSelected(media),
                              suggestionsCallback: (query) => MediaService.searchMulti(query, showSavedMedia: false),
                              itemBuilder: (context, SearchMediaResult result) {
                                return ListTile(
                                  title: Text('${result.title}'),
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    child: Image.network(
                                      getImageUrl(result.posterPath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (!isStringNullOrEmpty(_mediaSearchController.text))
                              IconButton(
                                icon: Icon(Icons.clear),
                                tooltip: 'Clear media',
                                onPressed: () => onMediaInputCleared(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  sortIcon(),
                  IconButton(
                    icon: _isEditing ? Icon(Icons.add) : Icon(Icons.edit),
                    tooltip: _isEditing ? 'Add' : 'Edit',
                    onPressed: () => setEditing(!_isEditing),
                  ),
                ],
              ),
              Expanded(
                child: _displayedSavedMedia.length > 0
                    ? Scrollbar(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) => Divider(
                            height: 10,
                            color: Colors.white,
                          ),
                          itemCount: _displayedSavedMedia.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: AutoSizeText(
                                '${_displayedSavedMedia[index].title} (${formatDateYearOnly(_displayedSavedMedia[index].releaseDate)})',
                                minFontSize: 12,
                              ),
                              leading: Container(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  getImageUrl(_displayedSavedMedia[index].posterPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              trailing: _isEditing
                                  ? PopupMenuButton(
                                      icon: Icon(Icons.more_vert),
                                      tooltip: 'Options',
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
          value: SortingValues.ReleaseDateDescending,
          child: Text(
            'Release Date Descending',
            style: TextStyle(
                decoration: _sortValue == SortingValues.ReleaseDateDescending ? TextDecoration.underline : null),
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
          value: SortingValues.AlphaDescending,
          child: Text(
            'Alpha Descending',
            style: TextStyle(decoration: _sortValue == SortingValues.AlphaDescending ? TextDecoration.underline : null),
          ),
        ),
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

  Future<void> updateSavedMedia() async {
    _allSavedMedia = await SavedMediaService.getAll();
    _displayedSavedMedia = List.from(_allSavedMedia);
    setState(() {
      sortDisplayedMedia();
    });
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
        _displayedSavedMedia.add(created);
        sortDisplayedMedia();
      });
    }
  }

  Future<void> deleteSavedMedia(SavedMedia mediaToDelete) async {
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
  }

  void onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      hideKeyboard(context);
    });
  }

  void setEditing(bool isEditing) {
    setState(() {
      _isEditing = isEditing;
    });
  }

  void searchSavedMedia(String searchText) {
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
    if (_searchFocusNode.hasPrimaryFocus) {
      _searchFocusNode.unfocus();
      return false;
    } else if (_addMediaFocusNode.hasPrimaryFocus) {
      _addMediaFocusNode.unfocus();
      return false;
    } else {
      return true;
    }
  }
}
