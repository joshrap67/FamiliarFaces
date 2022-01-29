import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/contracts/tv_response.dart';
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

  SearchMediaResponse? _selectedSearch;
  List<CastResponse> _castForSelectedMedia = <CastResponse>[];
  CastResponse? _selectedCharacter;

  static const String placeholderUrl = 'https://picsum.photos/500'; // todo remove

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

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
    // todo warning on tv shows that the search might take a while if they didn't specify a character
    super.build(context);
    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        decoration: _selectedSearch?.posterPath != null
            ? BoxDecoration(
                image: DecorationImage(
                  colorFilter: new ColorFilter.mode(Color(0x48000000), BlendMode.dstATop),
                  image: FadeInImage.assetNetwork(
                    image: getImageUrl(_selectedSearch?.posterPath),
                    placeholder: placeholderUrl,
                  ).image,
                  fit: BoxFit.fill,
                ),
              )
            : BoxDecoration(),
        child: Container(
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
                              TypeAheadFormField<SearchMediaResponse>(
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
                              TypeAheadFormField<CastResponse>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  enabled: _selectedSearch != null,
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

    // new media so clear any character inputs
    _castForSelectedMedia = [];
    _characterSearchController.text = "";
    _selectedCharacter = null;
    if (_selectedSearch!.mediaType == MediaType.Movie) {
      MovieResponse movie = await MediaService.getMovieWithCastAsync(_selectedSearch!.id);
      _castForSelectedMedia = List.from(movie.cast);
    } else {
      TvResponse tv = await MediaService.getTvShowWithCastAsync(_selectedSearch!.id);
      _castForSelectedMedia = List.from(tv.cast);
    }
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
        var actorCredits = await MediaService.getSingleActorCredits(_selectedCharacter!.id);
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
          var actorsOfMovie = await MediaService.getGroupedMovieResponse(_selectedSearch!.id);

          MovieResponse movie = await MediaService.getMovieWithCastAsync(_selectedSearch!.id);
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
          var actorsOfTvShow = await MediaService.getGroupedTvResponse(_selectedSearch!.id);

          TvResponse tvShow = await MediaService.getTvShowWithCastAsync(_selectedSearch!.id);

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
