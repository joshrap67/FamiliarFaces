import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/movie.dart';
import 'package:familiar_faces/contracts/tv_show.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/widgets/media_cast_row.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/contracts_sql/saved_media.dart';
import 'package:flutter/material.dart';

import '../imports/utils.dart';

class MediaCastScreen extends StatefulWidget {
  const MediaCastScreen({Key? key, required this.cast, this.movie, this.tvShow}) : super(key: key);

  final List<Cast> cast;
  final TvShow? tvShow;
  final Movie? movie;

  MediaType mediaType() => movie != null ? MediaType.Movie : MediaType.TV;

  @override
  _MediaCastScreenState createState() => _MediaCastScreenState();
}

class _MediaCastScreenState extends State<MediaCastScreen> {
  bool _isSeen = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    updateMediaSeen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${getTitle()}',
          minFontSize: 10,
          maxLines: 1,
        ),
        actions: [
          if (!_isSeen)
            TextButton(
              onPressed: () => setMediaSeen(),
              child: const Text(
                'SET SEEN',
                style: const TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: Container(
              child: Scrollbar(
                child: ListView.separated(
                  key: new PageStorageKey<String>('media_cast_screen:list'),
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 15,
                    color: Colors.transparent,
                  ),
                  itemCount: widget.cast.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MediaCastRow(
                      castMember: widget.cast[index],
                      rowClicked: (actor) => {actorClicked(actor)},
                    );
                  },
                ),
              ),
            ),
          ),
          Visibility(
            visible: _isLoading,
            child: const LinearProgressIndicator(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  String? getTitle() {
    return widget.movie != null ? widget.movie!.title : widget.tvShow!.title;
  }

  void setMediaSeen() async {
    var mediaType = widget.mediaType();
    var id = widget.movie != null ? widget.movie!.id : widget.tvShow!.id;
    var title = widget.movie != null ? widget.movie!.title : widget.tvShow!.title;
    var releaseDate = widget.movie != null ? widget.movie!.releaseDate : widget.tvShow!.firstAirDate;
    var posterPath = widget.movie != null ? widget.movie!.posterImagePath : widget.tvShow!.posterPath;
    await SavedMediaService.add(
        new SavedMedia(id, mediaType, title: title, releaseDate: releaseDate, posterPath: posterPath));
    setState(() {
      _isSeen = true;
    });
  }

  Future<void> actorClicked(Cast castMember) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      var actor = await MediaService.getActor(castMember.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActorDetails(
            actor: actor,
          ),
        ),
      ).then((value) => updateMediaSeen());
    } catch (e) {
      showSnackbar('There was a problem loading the actor', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> updateMediaSeen() async {
    var seenMedia = await SavedMediaService.getAll();

    var currentId = widget.mediaType() == MediaType.Movie ? widget.movie!.id : widget.tvShow!.id;

    setState(() {
      _isSeen = seenMedia.any((element) => element.mediaId == currentId);
    });
  }
}
