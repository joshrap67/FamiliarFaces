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
import 'package:familiar_faces/widgets/character_search_row.dart';
import 'package:familiar_faces/widgets/media_search_row.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  FocusNode _searchCharacterFocus = new FocusNode();
  FocusNode _searchMediaFocus = new FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    updateGlobalSettings();
  }

  @override
  Widget build(BuildContext context) {
    // todo warning on tv shows that the search might take a while if they didn't specify a character
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
                  color: Colors.green,
                ),
                ListTile(
                  leading: Icon(Icons.movie),
                  title: Text('My Seen Media'),
                  onTap: () {
                    // close the drawer menu when clicked
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SavedMediaListScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings & App Info'),
                  onTap: () {
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
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  colorBlendMode: BlendMode.dstATop,
                  fit: BoxFit.fill,
                ),
              ),
            if (_selectedSearch?.posterPath == null)
              Center(
                child: Container(
                  // height: double.infinity,
                  // width: double.infinity,
                  child: Image.asset(
                    'assets/icon/foreground.png',
                    // color: Color.fromRGBO(0, 0, 0, 0.4),
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
                        child: MediaSearchRow(
                          key: UniqueKey(),
                          focusNode: _searchMediaFocus,
                          selectedMedia: _selectedSearch,
                          onInputCleared: () => onMediaInputCleared(),
                          onMediaSelected: (media) => onMediaSelected(media),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CharacterSearchRow(
                          key: UniqueKey(),
                          // if this key isn't here all hell breaks lose i love flutter
                          focusNode: _searchCharacterFocus,
                          selectedCharacter: _selectedCharacter,
                          castForSelectedMedia: _castForSelectedMedia,
                          onCharacterCleared: () => onCharacterInputCleared(),
                          onCharacterSelected: (character) => onCharacterSelected(character),
                          enabled: _selectedSearch != null,
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
      _selectedCharacter = null;
      hideKeyboard(context);
    });
  }

  onCharacterInputCleared() {
    setState(() {
      _selectedCharacter = null;
      hideKeyboard(context);
    });
  }

  onCharacterSelected(Cast character) {
    setState(() {
      _selectedCharacter = character;
      hideKeyboard(context);
    });
  }

  onMediaSelected(SearchMediaResult selected) async {
    setState(() {
      _selectedSearch = selected;
      // new media so clear any character inputs
      _castForSelectedMedia = [];
      _selectedCharacter = null;
    });

    if (_selectedSearch!.mediaType == MediaType.Movie) {
      Movie movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(movie.cast);
    } else {
      TvShow tv = await MediaService.getTvShowWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(tv.cast);
    }
    setState(() {});
  }

  Future<void> onMainButtonPressed() async {
    hideKeyboard(context);
    if (_selectedSearch != null) {
      await navigate();
    } else {
      showSnackbar('Movie/show must not be empty', context);
      // throw new Exception('test');
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

        Movie movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
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

        TvShow tvShow = await MediaService.getTvShowWithCast(_selectedSearch!.id);

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
      print(e);
      showSnackbar('Error loading data', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> onBackPressed() async {
    if (_searchCharacterFocus.hasPrimaryFocus) {
      _searchCharacterFocus.unfocus();
      return false;
    } else if (_searchMediaFocus.hasPrimaryFocus) {
      _searchMediaFocus.unfocus();
      return false;
    } else {
      return true;
    }
  }

  // bit of an anti pattern, but i would rather not have async calls everywhere for these global settings
  Future<void> updateGlobalSettings() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      Globals.settings.showCharacters = prefs.getBool(Globals.showCharacterKey) ?? true;
    });
  }
}
