import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/contracts/tv_show.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/screens/media_cast_screen.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../imports/globals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  bool _isLoading = false;
  final FocusNode _searchMediaFocusNode = new FocusNode();
  final FocusNode _searchCharacterFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Familiar Faces',
              style: TextStyle(fontSize: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 8.0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TypeAheadField<SearchMediaResult>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _mediaSearchController,
                              focusNode: _searchMediaFocusNode,
                              onChanged: (_) {
                                // so x button can properly be hidden
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  border: const OutlineInputBorder(),
                                  labelText: 'Media Title',
                                  hintText: 'Search Movie or TV Show'),
                            ),
                            hideOnLoading: true,
                            hideOnEmpty: true,
                            hideOnError: true,
                            hideSuggestionsOnKeyboardHide: false,
                            debounceDuration: Duration(milliseconds: 300),
                            onSuggestionSelected: (media) => onMediaSelected(media),
                            suggestionsCallback: (query) => MediaService.searchMulti(query),
                            itemBuilder: (context, SearchMediaResult result) {
                              return ListTile(
                                title: Text('${result.title} (${formatDateYearOnly(result.releaseDate)})'),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.network(
                                    getProfilePictureUrl(result.posterPath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (!isStringNullOrEmpty(_mediaSearchController.text))
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear media',
                              onPressed: () => onMediaInputCleared(),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 32.0),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TypeAheadFormField<Cast>(
                            textFieldConfiguration: TextFieldConfiguration(
                              controller: _characterSearchController,
                              focusNode: _searchCharacterFocusNode,
                              onChanged: (_) {
                                // so x button can properly be hidden
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Character',
                                  prefixIcon: const Icon(Icons.person),
                                  border: const OutlineInputBorder(),
                                  hintText: 'Search Character (optional)'),
                            ),
                            hideOnLoading: true,
                            hideOnEmpty: true,
                            hideOnError: true,
                            hideSuggestionsOnKeyboardHide: false,
                            onSuggestionSelected: onCharacterSelected,
                            suggestionsCallback: (query) => getCharacterResults(query),
                            itemBuilder: (context, Cast result) {
                              return ListTile(
                                title: Text('${result.characterName}'),
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  child: Image.network(
                                    getProfilePictureUrl(result.profilePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (!isStringNullOrEmpty(_characterSearchController.text))
                            IconButton(
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear character',
                              onPressed: onCharacterInputCleared,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Globals.TILE_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedSearch != null)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AutoSizeText(
                            '${_selectedSearch!.title} (${formatDateYearOnly(_selectedSearch!.releaseDate)})',
                            minFontSize: 10,
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                          ),
                          Expanded(
                            child: Container(
                              height: 1000,
                              width: 220,
                              child: Image.network(
                                getProfilePictureUrl(_selectedSearch!.posterPath),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          if (_selectedCharacter != null)
                            Container(
                              child: AutoSizeText(
                                '${_selectedCharacter!.characterName}',
                                minFontSize: 10,
                                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                    child: Container(
                      height: 50,
                      width: 300,
                      child: !_isLoading
                          ? OutlinedButton(
                              onPressed: onMainButtonPressed,
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  shape: const StadiumBorder(),
                                  backgroundColor: const Color(0xFFBB4F4F)),
                              child: Text(
                                _buttonText(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFBB4F4F)),
                              child: const Center(
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  onMediaInputCleared() {
    setState(() {
      _selectedSearch = null;
      _castForSelectedMedia = [];
      _mediaSearchController.text = '';
      _characterSearchController.text = '';
      _selectedCharacter = null;
      hideKeyboard(context);
    });
  }

  onCharacterInputCleared() {
    setState(() {
      _selectedCharacter = null;
      _characterSearchController.text = '';
      hideKeyboard(context);
    });
  }

  onCharacterSelected(Cast character) {
    setState(() {
      _selectedCharacter = character;
      _characterSearchController.text = _selectedCharacter!.characterName!;
      hideKeyboard(context);
    });
  }

  onMediaSelected(SearchMediaResult selected) async {
    setState(() {
      _selectedSearch = selected;
      _mediaSearchController.text = _selectedSearch!.title!;
      // new media so clear any character inputs
      _castForSelectedMedia = [];
      _selectedCharacter = null;
      _characterSearchController.text = '';
    });

    if (_selectedSearch!.mediaType == MediaType.Movie) {
      Movie movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(movie.cast);
    } else {
      TvShow tv = await MediaService.getTvShowWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(tv.cast);
    }
  }

  Future<void> onMainButtonPressed() async {
    hideKeyboard(context);
    if (_selectedSearch != null) {
      await navigate();
    } else {
      showSnackbar('Movie/show must not be empty', context);
    }
  }

  Future navigate() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_selectedCharacter != null) {
        var actorCredits = await MediaService.getActor(_selectedCharacter!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorDetails(
              actor: actorCredits,
            ),
          ),
        );
      } else if (_selectedSearch!.mediaType == MediaType.Movie) {
        var actorsOfMovie = await MediaService.getActorsFromMovie(_selectedSearch!.id);

        var movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: movie.cast,
              actors: actorsOfMovie,
              movie: movie,
            ),
          ),
        );
      } else if (_selectedSearch!.mediaType == MediaType.TV) {
        var actorsOfTvShow = await MediaService.getActorsFromTv(_selectedSearch!.id);

        var tvShow = await MediaService.getTvShowWithCast(_selectedSearch!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: tvShow.cast,
              actors: actorsOfTvShow,
              tvShow: tvShow,
            ),
          ),
        );
      }
    } catch (e) {
      showSnackbar('Error loading data', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Cast> getCharacterResults(String query) {
    return _castForSelectedMedia.where((character) {
      var characterLower = character.characterName!.toLowerCase();
      var queryLower = query.toLowerCase();
      return characterLower.contains(queryLower);
    }).toList();
  }

  Future<bool> onBackPressed() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_searchMediaFocusNode.hasPrimaryFocus) {
      _searchMediaFocusNode.unfocus();
      return false;
    } else if (_searchCharacterFocusNode.hasPrimaryFocus) {
      _searchCharacterFocusNode.unfocus();
      return false;
    } else {
      return true;
    }
  }

  // to keep state when page view scrolls to another page
  @override
  bool get wantKeepAlive => true;
}
