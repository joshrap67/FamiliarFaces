import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/screens/actor_filmography.dart';
import 'package:familiar_faces/screens/movie_filter_screen.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MediaInputScreen extends StatefulWidget {
  const MediaInputScreen({Key? key}) : super(key: key);

  @override
  _MediaInputScreenState createState() => _MediaInputScreenState();
}

class _MediaInputScreenState extends State<MediaInputScreen> with AutomaticKeepAliveClientMixin<MediaInputScreen> {
  @override
  bool get wantKeepAlive => true; // ensures the tab is not disposed when clicking around

  SearchMediaResponse? _selectedSearch;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  CastResponse? _selectedCharacter;
  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  MovieResponse? _castForSelectedMedia;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mediaSearchController.dispose();
	_characterSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: [
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
							transitionBuilder: (context, suggestionsBox, controller) {
								return suggestionsBox;
							},
							noItemsFoundBuilder: (context){
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
                        IconButton(
                          icon: Icon(Icons.clear),
                          tooltip: 'Clear media',
                          onPressed: onMediaInputCleared,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TypeAheadFormField<CastResponse>(
                          textFieldConfiguration: TextFieldConfiguration(
                            enabled: _selectedSearch != null,
                            controller: _characterSearchController,
                            decoration: InputDecoration(
                                labelText: 'Character',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                hintText: 'Search Character (optional)'),
                          ),
                          suggestionsCallback: (query) => getCharacterResults(query),
                          itemBuilder: (context, CastResponse result) {
                            return ListTile(
                              title: Text('${result.characterName}'),
                              leading: Container(
                                height: 50,
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: getImageUrl(result.profilePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          hideSuggestionsOnKeyboardHide: false,
                          onSuggestionSelected: onCharacterSelected,
                        ),
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainInteractivity: true,
                          maintainState: true,
                          visible: _selectedSearch != null,
                          child: IconButton(
                            icon: Icon(Icons.clear),
                            tooltip: 'Clear character',
                            onPressed: onCharacterInputCleared,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_selectedSearch != null)
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .3,
                width: 250,
                child: CachedNetworkImage(
                  imageUrl: getImageUrl(_selectedSearch!.posterPath),
                  fit: BoxFit.scaleDown,
                ),
              ),
              if (_selectedSearch != null)
                AutoSizeText(
                  '${_selectedSearch!.title} (${filterDate(_selectedSearch!.releaseDate)})',
                  minFontSize: 10,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
            ],
          ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RoundedLoadingButton(
                controller: _btnController,
                onPressed: onButtonPressed,
                child: Text(_buttonText()),
                color: Colors.greenAccent,
              ),
            ),
          ),
        )
      ],
    );
  }

  onMediaInputFocusChange(bool focusGained) {
    // todo keep title if they lose focus and already have movie selected?
  }

  onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      _selectedSearch = null;
      _castForSelectedMedia = null;
      _characterSearchController.text = "";
      _selectedCharacter = null;
      hideKeyboard(context);
    });
  }

  onCharacterInputCleared() {
    setState(() {
      _characterSearchController.text = "";
      _selectedCharacter = null;
      hideKeyboard(context);
    });
  }

  onCharacterSelected(CastResponse character) {
    setState(() {
      _selectedCharacter = character;
      _characterSearchController.text = character.characterName!;
      hideKeyboard(context);
    });
  }

  onMediaSelected(SearchMediaResponse selected) async {
    // todo handle tv
    setState(() {
      _selectedSearch = selected;
      _mediaSearchController.text = selected.title!;
    });
    // new media so clear any character inputs
    _castForSelectedMedia = null;
    _characterSearchController.text = "";
    _selectedCharacter = null;
    _castForSelectedMedia = await TmdbService.getMovieWithCastAsync(_selectedSearch!.id);
  }

  List<CastResponse> getCharacterResults(String query) {
    if (_castForSelectedMedia != null) {
      // todo if name is "Himself" or "herself" just return actor name?
      return _castForSelectedMedia!.cast.where((character) {
        var characterLower = character.characterName!.toLowerCase();
        var queryLower = query.toLowerCase();
        return characterLower.contains(queryLower);
      }).toList();
    } else {
      return [];
    }
  }

  onButtonPressed() {
    hideKeyboard(context);
    if (_selectedSearch != null) {
      getGroupedMovies();
    } else {
      showSnackbar('Must search and select a valid media', context);
      _btnController.stop();
    }
  }

  Future getGroupedMovies() async {
    if (_selectedSearch == null) {
      _btnController.stop();
      return;
    }

    try {
      if (_selectedCharacter != null) {
        var actorCredits = await TmdbService.getPersonCreditsAsync(_selectedCharacter!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorFilmography(
              actor: actorCredits,
            ),
          ),
        );
      } else {
        var groupedMovies = await TmdbService.getGroupedMovieResponse(_selectedSearch!.id);

        var movie;
        if (_castForSelectedMedia != null && _castForSelectedMedia!.id == _selectedSearch!.id) {
          // earlier query already has results, no need to waste API call
          movie = _castForSelectedMedia!;
        } else {
          movie = await TmdbService.getMovieWithCastAsync(_selectedSearch!.id);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieFilterScreen(
              movieCast: groupedMovies,
              movieResponse: movie,
            ),
          ),
        );
        // no character specified so get credits of all cast of the movie
      }
    } catch (e) {
      print(e);
      showSnackbar('Error searching for actors', context);
    } finally {
      setState(() {
        _btnController.success();
        _btnController.stop();
      });
    }
  }
}
