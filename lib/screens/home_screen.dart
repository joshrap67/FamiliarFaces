import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/contracts/tv_show.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/screens/media_cast_screen.dart';
import 'package:familiar_faces/screens/saved_media_list_screen.dart';
import 'package:familiar_faces/screens/settings_screen.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// todo force portrait mode

class _HomeScreenState extends State<HomeScreen> {
  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    updateGlobalSettings();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  child: Tooltip(
                    message: 'Photo by Alex Litvin on Unsplash',
                    child: Image.asset(
                      'assets/images/drawer_background.jpg',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.movie),
                  title: Text('My Media'),
                  onTap: () {
                    hideKeyboard(context);
                    // close the drawer menu when clicked
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SavedMediaListScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings & App Info'),
                  onTap: () {
                    hideKeyboard(context);
                    // close the drawer menu when clicked
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('Familiar Faces'),
        ),
        body: Stack(
          children: [
            if (_selectedSearch?.posterPath != null)
              Container(
                height: double.infinity,
                width: double.infinity,
                child: Image.network(
                  getImageUrl(_selectedSearch?.posterPath),
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  colorBlendMode: BlendMode.dstATop,
                  fit: BoxFit.fill,
                ),
              ),
            if (_selectedSearch?.posterPath == null)
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  child: Image.asset(
                    'assets/icon/foreground.png',
                    colorBlendMode: BlendMode.dstATop,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
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
                              suggestionsCallback: (query) => MediaService.searchMulti(query),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            TypeAheadFormField<Cast>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _characterSearchController,
                                onChanged: (_) {
                                  // so x button can properly be hidden
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    labelText: 'Character',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
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
                                      getImageUrl(result.profilePath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (!isStringNullOrEmpty(_characterSearchController.text))
                              IconButton(
                                icon: Icon(Icons.clear),
                                tooltip: 'Clear character',
                                onPressed: onCharacterInputCleared,
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
                                  '${_selectedSearch!.title} (${formatDateYearOnly(_selectedSearch!.releaseDate)})',
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
                            child: Container(
                              height: 50,
                              width: 300,
                              child: !_isLoading
                                  ? OutlinedButton(
                                      onPressed: onMainButtonPressed,
                                      style: OutlinedButton.styleFrom(
                                          shape: StadiumBorder(),
                                          backgroundColor: Color(0xff5a9e6c),
                                          primary: Colors.black),
                                      child: Text(
                                        _buttonText(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xff5a9e6c)),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
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
    if (FocusScope.of(context).hasFocus) {
      hideKeyboard(context);
      return false;
    } else {
      return true;
    }
  }

  Future<void> updateGlobalSettings() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      Globals.settings.showCharacters = prefs.getBool(Globals.showCharacterKey) ?? true;
    });
  }
}
