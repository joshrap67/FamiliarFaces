import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/domain/cast_member.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/screens/media_cast_screen.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/widgets/character_selector.dart';
import 'package:familiar_faces/widgets/media_selector.dart';
import 'package:familiar_faces/widgets/painters.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _mediaSearchController = TextEditingController();
  final TextEditingController _characterSearchController = TextEditingController();

  SearchMediaResult? _selectedSearch;
  List<CastMember> _castForSelectedMedia = <CastMember>[];
  CastMember? _selectedCastMember;
  bool _isLoading = false;

  String _buttonText() =>
      _selectedCastMember == null ? 'WHERE HAVE I SEEN THIS CAST?' : 'WHERE HAVE I SEEN THIS ACTOR?';

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
                        child: CustomPaint(painter: FilmStrip(Theme.of(context).colorScheme.onTertiaryContainer)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: .fromLTRB(8.0, 8.0, 8.0, 8.0),
                  child: MediaSelector(
                    onSelected: onMediaSelected,
                    controller: _mediaSearchController,
                    labelText: 'Media Title *',
                    hintText: 'Search Movie or TV show',
                    debounceDuration: Duration(milliseconds: 300),
                  ),
                ),
                Padding(
                  padding: const .fromLTRB(8.0, 8.0, 8.0, 0.0),
                  child: CharacterSelector(
                    key: ValueKey(_castForSelectedMedia),
                    onSelected: onCharacterSelected,
                    options: _castForSelectedMedia,
                    labelText: 'Character',
                    hintText: 'Search Character (optional)',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                  child: Container(
                    child: ClipRect(
                      child: Container(
                        width: double.infinity,
                        height: 15,
                        child: CustomPaint(painter: FilmStrip(Theme.of(context).colorScheme.onTertiaryContainer)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer),
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
                      Expanded(child: Image.network(getTmdbPicture(_selectedSearch!.posterPath), fit: BoxFit.contain)),
                      Visibility(
                        visible: _selectedCastMember != null,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: AutoSizeText(
                          '${_selectedCastMember?.characterName}',
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(_buttonText(), style: const TextStyle(color: Colors.white)),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: const Center(
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  onCharacterSelected(CastMember? castMember) {
    setState(() {
      _selectedCastMember = castMember;
    });
  }

  onMediaSelected(SearchMediaResult? selected) async {
    setState(() {
      _selectedSearch = selected;
      // new media so clear any character inputs
      _castForSelectedMedia = [];
      _selectedCastMember = null;
      _characterSearchController.text = '';
    });
    if (selected == null) {
      return;
    }

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
      if (_selectedCastMember != null) {
        var actorCredits = await MediaService.getActor(context, _selectedCastMember!.id);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ActorDetails(actor: actorCredits)));
      } else if (_selectedSearch!.mediaType == MediaType.Movie) {
        var movie = await MediaService.getMovieWithCast(_selectedSearch!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(cast: movie.cast, movie: movie),
          ),
        );
      } else if (_selectedSearch!.mediaType == MediaType.TV) {
        var tvShow = await MediaService.getTvShowWithCast(_selectedSearch!.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaCastScreen(cast: tvShow.cast, tvShow: tvShow),
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

  // to keep state when page view scrolls to another page
  @override
  bool get wantKeepAlive => true;
}
