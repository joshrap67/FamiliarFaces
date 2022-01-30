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
import 'package:familiar_faces/widgets/character_search_row.dart';
import 'package:familiar_faces/widgets/media_search_row.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MediaInputScreen extends StatefulWidget {
  const MediaInputScreen({Key? key}) : super(key: key);

  @override
  _MediaInputScreenState createState() => _MediaInputScreenState();
}

// todo better class name
class _MediaInputScreenState extends State<MediaInputScreen> with AutomaticKeepAliveClientMixin<MediaInputScreen> {
  @override
  bool get wantKeepAlive => true; // ensures the tab is not disposed when clicking around

  SearchMediaResult? _selectedSearch;
  List<Cast> _castForSelectedMedia = <Cast>[];
  Cast? _selectedCharacter;

  String _buttonText() => _selectedCharacter == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  FocusNode _searchCharacterFocus = new FocusNode();

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
                child: Image.network(
                  getImageUrl(_selectedSearch?.posterPath),
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  colorBlendMode: BlendMode.dstATop,
                  fit: BoxFit.fill,
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
                            // todo get rid of this or make my own
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
    // todo this still is not pressed in the right order if i go to index 0 and hit back space it is called from there
    if (_searchCharacterFocus.hasPrimaryFocus) {
      _searchCharacterFocus.unfocus();
      return false;
    } else {
      return true;
    }
  }
}
