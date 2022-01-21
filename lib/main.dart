import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/grouped_movie_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/screens/movie_filter_screen.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'contracts/cast_response.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GroupedMovieResponse? _groupedMovies;
  int _selectedIndex = 1;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => hideKeyboard(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_selectedSearch != null)
                Container(
                  height: 250,
                  width: 250,
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(_selectedSearch!.posterPath),
                    fit: BoxFit.cover,
                  ),
                ),
              if (_selectedSearch != null)
                Text(
                  '${_selectedSearch!.title} (${filterDate(_selectedSearch!.releaseDate)})',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TypeAheadFormField<SearchMediaResponse>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _mediaSearchController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                labelText: 'Media',
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
                    ),
                    Expanded(
                      flex: 0,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        tooltip: 'Clear media',
                        onPressed: onMediaInputCleared,
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
                      child: TypeAheadFormField<CastResponse>(
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
                        onSuggestionSelected: onCharacterSelected,
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Visibility(
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
                    ),
                  ],
                ),
              ),
              RoundedLoadingButton(
                controller: _btnController,
                onPressed: onButtonPressed,
                child: Text(_buttonText()),
                color: Colors.greenAccent,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF23606D),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'My Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      // todo change button text to say "Where have i seen this actor"
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
      _groupedMovies = await TmdbService.getGroupedMovieResponse(_selectedSearch!.id);

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
            groupedMovieResponse: _groupedMovies!,
            movieResponse: movie,
          ),
        ),
      );
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
