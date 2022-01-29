import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MediaInputScreen extends StatefulWidget {
  const MediaInputScreen({Key? key}) : super(key: key);

  @override
  _MediaInputScreenState createState() => _MediaInputScreenState();
}

class _MediaInputScreenState extends State<MediaInputScreen> with AutomaticKeepAliveClientMixin<MediaInputScreen> {
  @override
  bool get wantKeepAlive => true; // ensures the tab is not disposed when clicking around

  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  late FocusNode _searchCharacterFocus;

  @override
  void initState() {
    _searchCharacterFocus = new FocusNode();
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
    // todo warning on tv shows that the search might take a while if they didn't specify a character
    super.build(context);
    return WillPopScope(
      onWillPop: () => onBackPressed(),
      child: SafeArea(
        child: Stack(
          children: [
            if (_selectedSearch?.posterPath != null)
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: new ColorFilter.mode(Color(0x48000000), BlendMode.dstATop),
                    image: Image.network(getImageUrl(_selectedSearch?.posterPath)).image,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            Container(
              color: _selectedSearch?.posterPath != null ? Color(0x4b000000) : null,
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
                                  TypeAheadFormField<SearchMediaResult>(
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
                                      debounceDuration: Duration(milliseconds: 300),
                                      suggestionsCallback: (query) => MediaService.searchMulti(query),
                                      transitionBuilder: (context, suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      noItemsFoundBuilder: (context) {
                                        return Text('');
                                      },
                                      itemBuilder: (context, SearchMediaResult result) {
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
                                  TypeAheadFormField<Cast>(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      enabled: _selectedSearch != null,
                                      focusNode: _searchCharacterFocus,
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
                                    suggestionsCallback: (query) => getCharacterResults(query),
                                    itemBuilder: (context, Cast result) {
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
                            child: RoundedLoadingButton(
                              controller: _btnController,
                              onPressed: onMainButtonPressed,
                              child: Text(_buttonText()),
                              color: Color(0xff5a9e6c),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
      _mediaSearchController.text = "";
      _selectedSearch = null;
      _castForSelectedMedia = [];
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

  onCharacterSelected(Cast character) {
    setState(() {
      _selectedCharacter = character;
      _characterSearchController.text = character.characterName!;
      hideKeyboard(context);
    });
  }

  onMediaSelected(SearchMediaResult selected) async {
    setState(() {
      _selectedSearch = selected;
      _mediaSearchController.text = selected.title!;
    });

    // new media so clear any character inputs
    _castForSelectedMedia = [];
    _characterSearchController.text = "";
    _selectedCharacter = null;
    if (_selectedSearch!.mediaType == MediaType.Movie) {
      Movie movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(movie.cast);
    } else {
      TvShow tv = await MediaService.getTvShowWithCast(_selectedSearch!.id);
      _castForSelectedMedia = List.from(tv.cast);
    }
  }

  List<Cast> getCharacterResults(String query) {
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
        var actorCredits = await MediaService.getActor(_selectedCharacter!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActorDetails(
              actor: actorCredits,
            ),
          ),
        );
      } else {
        if (_selectedSearch!.mediaType == MediaType.Movie) {
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

  Future<bool> onBackPressed() async {
    if (_searchCharacterFocus.hasPrimaryFocus) {
      _searchCharacterFocus.unfocus();
      return false;
    } else {
      return true;
    }
  }
}
