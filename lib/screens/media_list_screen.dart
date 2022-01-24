import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/saved_media_database.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({Key? key}) : super(key: key);

  @override
  _MediaListScreenState createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  List<SavedMedia> _savedMedia = <SavedMedia>[];
  List<SavedMedia> _searchedSavedMedia = <SavedMedia>[];
  final TextEditingController _mediaSearchController = TextEditingController();
  bool _isLoading = true;
  bool _isEditing = false;

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
    return Stack(
      children: [
        Column(
          children: [
            if (!_isEditing)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                  // todo PopupMenuButton
                  IconButton(
                    icon: Icon(Icons.sort),
                    onPressed: () {},
                  )
                ],
              ),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TypeAheadFormField<SearchMediaResponse>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _mediaSearchController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                    labelText: 'Movie/TV Show',
                                    hintText: 'Search Movie or TV Show'),
                              ),
                              debounceDuration: Duration(milliseconds: 300),
                              suggestionsCallback: (query) => TmdbService.searchMulti(query),
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
                          IconButton(
                            icon: Icon(Icons.clear),
                            tooltip: 'Clear media',
                            onPressed: onMediaInputCleared,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.done),
                      onPressed: () => setAdding(false),
                    )
                  ],
                ),
              ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(height: 10),
                itemCount: _savedMedia.length,
                key: GlobalKey(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_savedMedia[index].title ?? "N/A"),
                    tileColor: Colors.white10,
                    leading: Container(
                      height: 50,
                      width: 50,
                      child: CachedNetworkImage(
                        imageUrl: getImageUrl(_savedMedia[index].posterPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                    trailing: _isEditing
                        ? IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.redAccent,
                            onPressed: () => deleteSavedMedia(_savedMedia[index]),
                          )
                        : null,
                  );
                },
              ),
            )
          ],
        ),
        if (!_isEditing)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.greenAccent,
                  shape: CircleBorder(),
                ),
                width: 56,
                height: 56,
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  // iconSize: 56,
                  color: Colors.white,
                  onPressed: () {
                    setAdding(true);
                  },
                ),
              ),
            ),
          )
      ],
    );
  }

  getSavedMedia() async {
    setState(() {
      _isLoading = true;
    });
    _savedMedia = await SavedMediaDatabase.instance.getAll();
    setState(() {
      _isLoading = false;
    });
  }

  onMediaSelected(SearchMediaResponse selected) async {
    if (_savedMedia.any((element) => element.mediaId == selected.id)) {
      showSnackbar('You already have added this media to your list.', context);
    } else {
      var savedMedia = new SavedMedia(selected.id,
          title: selected.title, posterPath: selected.posterPath, releaseDate: selected.releaseDate);
      var created = await SavedMediaDatabase.instance.create(savedMedia);
      setState(() {
        _savedMedia.add(created);
      });
    }
  }

  void deleteSavedMedia(SavedMedia mediaToDelete) async {
    await SavedMediaDatabase.instance.delete(mediaToDelete.id!);
    setState(() {
      _savedMedia.removeWhere((element) => mediaToDelete.id! == element.id!);
    });
  }

  onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      hideKeyboard(context);
    });
  }

  setAdding(bool isAdding) {
    setState(() {
      _isEditing = isAdding;
    });
  }

  searchSavedMedia(String searchText) {
    setState(() {
      _searchedSavedMedia.addAll(_savedMedia.where((element) {
        if (element.title == null) {
          return false;
        }
        return element.title!.toLowerCase().contains(searchText.toLowerCase());
      }));
    });
  }
}
