import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/domain/cast.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/screens/media_cast_screen.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/widgets/painters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  final FocusNode _searchMediaFocusNode = new FocusNode();
  final FocusNode _searchCharacterFocusNode = new FocusNode();

  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;
  bool _isLoading = false;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: ClipRect(
                      child: Container(
                        width: double.infinity,
                        height: 15,
                        child: CustomPaint(
                          painter: FilmStrip(Theme.of(context).colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
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
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.movie),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Theme.of(context).colorScheme.onTertiaryContainer, width: 1.5),
                              ),
                              border: const OutlineInputBorder(),
                              labelText: 'Media Title',
                              hintText: 'Search Movie or TV Show'),
                        ),
                        hideOnLoading: true,
                        hideOnEmpty: true,
                        hideOnError: true,
                        debounceDuration: Duration(milliseconds: 300),
                        onSuggestionSelected: (media) => onMediaSelected(media),
                        suggestionsCallback: (query) => MediaService.searchMulti(context, query),
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
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
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
                          decoration: InputDecoration(
                              labelText: 'Character',
                              prefixIcon: const Icon(Icons.person),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Theme.of(context).colorScheme.onTertiaryContainer, width: 1.5),
                              ),
                              border: const OutlineInputBorder(),
                              hintText: 'Search Character (optional)'),
                        ),
                        hideOnLoading: true,
                        hideOnEmpty: true,
                        hideOnError: true,
                        onSuggestionSelected: onCharacterSelected,
                        suggestionsCallback: (query) => getCharacterResults(query),
                        itemBuilder: (context, Cast result) {
                          return ListTile(
                            title: Text('${result.characterName}'),
                            leading: Container(
                              height: 50,
                              width: 50,
                              child: Image.network(
                                getTmdbPicture(result.profilePath),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                  child: Container(
                    child: ClipRect(
                      child: Container(
                        width: double.infinity,
                        height: 15,
                        child: CustomPaint(
                          painter: FilmStrip(Theme.of(context).colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
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
                        maxLines: 1,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
                      ),
                      Expanded(
                        child: Image.network(
                          getTmdbPicture(_selectedSearch!.posterPath),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Visibility(
                        visible: _selectedCharacter != null,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: AutoSizeText(
                          '${_selectedCharacter?.characterName}',
                          maxLines: 1,
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
                              backgroundColor: Theme.of(context).colorScheme.primary),
                          child: Text(
                            _buttonText(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
    );
  }

  onMediaInputCleared() {
    setState(() {
      _selectedSearch = null;
      _castForSelectedMedia = [];
      _mediaSearchController.text = '';
      _characterSearchController.text = '';
      _selectedCharacter = null;
      hideKeyboard();
    });
  }

  onCharacterInputCleared() {
    setState(() {
      _selectedCharacter = null;
      _characterSearchController.text = '';
      hideKeyboard();
    });
  }

  onCharacterSelected(Cast character) {
    setState(() {
      _selectedCharacter = character;
      _characterSearchController.text = _selectedCharacter!.characterName!;
      hideKeyboard();
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
    hideKeyboard();
    if (_selectedSearch != null) {
      await navigate();
    } else {
      showSnackbar('Media must not be empty', context);
    }
  }

  Future navigate() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_selectedCharacter != null) {
        var actorCredits = await MediaService.getActor(context, _selectedCharacter!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorDetails(
              actor: actorCredits,
            ),
          ),
        );
      } else if (_selectedSearch!.mediaType == MediaType.Movie) {
        var movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(
              cast: movie.cast,
              movie: movie,
            ),
          ),
        );
      } else if (_selectedSearch!.mediaType == MediaType.TV) {
        var tvShow = await MediaService.getTvShowWithCast(_selectedSearch!.id);
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

  // to keep state when page view scrolls to another page
  @override
  bool get wantKeepAlive => true;
}
