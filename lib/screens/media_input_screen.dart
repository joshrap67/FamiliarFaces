import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
import 'package:familiar_faces/screens/actor_filmography.dart';
import 'package:familiar_faces/screens/media_cast_screen.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:palette_generator/palette_generator.dart';
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
  List<CastResponse> _castForSelectedMedia = <CastResponse>[];
  CastResponse? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  PaletteGenerator? _paletteGenerator;

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

  List<Color> getGradientColors() {
    Color topColor = Colors.transparent;
    if (_paletteGenerator?.darkMutedColor?.color != null) {
      topColor = _paletteGenerator!.darkMutedColor!.color.withOpacity(0.4);
    } else if (_paletteGenerator?.darkVibrantColor?.color != null) {
      topColor = _paletteGenerator!.darkVibrantColor!.color.withOpacity(0.4);
    } else if (_paletteGenerator?.vibrantColor?.color != null) {
      topColor = _paletteGenerator!.vibrantColor!.color.withOpacity(0.4);
    }
    Color bottomColor = _paletteGenerator?.dominantColor?.color.withOpacity(0.4) ?? Colors.transparent;
    return [topColor, bottomColor];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: getGradientColors(),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [
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
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedSearch != null)
                    Column(
                      children: [
                        AutoSizeText(
                          '${_selectedSearch!.title} (${filterDate(_selectedSearch!.releaseDate)})',
                          minFontSize: 10,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        if (_selectedCharacter != null)
                          AutoSizeText(
                            '${_selectedCharacter!.characterName}',
                            minFontSize: 10,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                    child: RoundedLoadingButton(
                      controller: _btnController,
                      onPressed: onMainButtonPressed,
                      child: Text(_buttonText()),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      _selectedSearch = null;
      _castForSelectedMedia = [];
      _paletteGenerator = null;
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
    setState(() {
      _selectedSearch = selected;
      _mediaSearchController.text = selected.title!;
    });

    _updatePaletteGenerator(new Image.network(getImageUrl(_selectedSearch!.posterPath)).image);

    // new media so clear any character inputs
    _castForSelectedMedia = [];
    _characterSearchController.text = "";
    _selectedCharacter = null;
    if (_selectedSearch!.mediaType == MediaType.Movie) {
      MovieResponse movie = await TmdbService.getMovieWithCastAsync(_selectedSearch!.id);
      _castForSelectedMedia = List.from(movie.cast);
    } else {
      TvResponse tv = await TmdbService.getTvShowWithCastAsync(_selectedSearch!.id);
      _castForSelectedMedia = List.from(tv.cast);
    }
  }

  Future<void> _updatePaletteGenerator(ImageProvider image) async {
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
      image,
      maximumColorCount: 20,
    );
    setState(() {});
  }

  List<CastResponse> getCharacterResults(String query) {
    return _castForSelectedMedia.where((character) {
      var characterLower = character.characterName!.toLowerCase();
      var queryLower = query.toLowerCase();
      return characterLower.contains(queryLower);
    }).toList();
  }

  onMainButtonPressed() {
    hideKeyboard(context);
    if (_selectedSearch != null) {
      navigate();
    } else {
      showSnackbar('Must search and select a valid media', context);
      _btnController.stop();
    }
  }

  Future navigate() async {
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
        if (_selectedSearch!.mediaType == MediaType.Movie) {
          var actorsOfMovie = await TmdbService.getGroupedMovieResponse(_selectedSearch!.id);

          MovieResponse movie = await TmdbService.getMovieWithCastAsync(_selectedSearch!.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaCastScreen(
                cast: movie.cast,
                actors: actorsOfMovie,
                title: movie.title!,
              ),
            ),
          );
        } else if (_selectedSearch!.mediaType == MediaType.TV) {
          var actorsOfTvShow = await TmdbService.getGroupedTvResponse(_selectedSearch!.id);

          TvResponse tvShow = await TmdbService.getTvShowWithCastAsync(_selectedSearch!.id);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MediaCastScreen(
                cast: tvShow.cast,
                actors: actorsOfTvShow,
                title: tvShow.name!,
              ),
            ),
          );
        }

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
