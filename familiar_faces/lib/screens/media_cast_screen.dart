import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/domain/cast.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/domain/movie.dart';
import 'package:familiar_faces/domain/tv_show.dart';
import 'package:familiar_faces/domain/saved_media.dart';
import 'package:familiar_faces/providers/saved_media_provider.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/widgets/media_cast_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../imports/utils.dart';

class MediaCastScreen extends StatefulWidget {
  final List<Cast> cast;
  final TvShow? tvShow;
  final Movie? movie;

  MediaType mediaType() => movie != null ? MediaType.Movie : MediaType.TV;

  const MediaCastScreen({Key? key, required this.cast, this.movie, this.tvShow}) : super(key: key);

  @override
  _MediaCastScreenState createState() => _MediaCastScreenState();
}

class _MediaCastScreenState extends State<MediaCastScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getAppBarTitle(),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        scrolledUnderElevation: 0,
        actions: [
          if (!isSeen())
            TextButton(
              onPressed: () => setMediaSeen(),
              child: const Text('SET SEEN'),
            )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: Container(
              child: Scrollbar(
                child: ListView.builder(
                  key: new PageStorageKey<String>('media_cast_screen:list'),
                  itemCount: widget.cast.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MediaCastCard(
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
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
        ],
      ),
    );
  }

  Widget getAppBarTitle() {
    if (widget.movie != null) {
      return ListTile(
        title: AutoSizeText(
          widget.movie!.title!,
          minFontSize: 10,
          maxLines: 1,
        ),
        subtitle: Text('Released ${formatDateYearOnly(widget.movie!.releaseDate!)}'),
        contentPadding: EdgeInsets.zero,
      );
    } else {
      return ListTile(
        title: AutoSizeText(
          widget.tvShow!.title!,
          minFontSize: 10,
          maxLines: 1,
        ),
        subtitle: Text('First Aired ${formatDateYearOnly(widget.tvShow!.firstAirDate!)}'),
        contentPadding: EdgeInsets.zero,
      );
    }
  }

  void setMediaSeen() async {
    var mediaType = widget.mediaType();
    var id = widget.movie != null ? widget.movie!.id : widget.tvShow!.id;
    var title = widget.movie != null ? widget.movie!.title : widget.tvShow!.title;
    var releaseDate = widget.movie != null ? widget.movie!.releaseDate : widget.tvShow!.firstAirDate;
    var posterPath = widget.movie != null ? widget.movie!.posterImagePath : widget.tvShow!.posterPath;
    await SavedMediaService.add(
        context, new SavedMedia(id, mediaType, title: title, releaseDate: releaseDate, posterPath: posterPath));
  }

  Future<void> actorClicked(Cast castMember) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      var actor = await MediaService.getActor(context, castMember.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActorDetails(
            actor: actor,
          ),
        ),
      );
    } catch (e) {
      showSnackbar('There was a problem loading the actor', context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  bool isSeen() {
    var seenMedia = context.watch<SavedMediaProvider>().savedMedia;
    var currentId = widget.mediaType() == MediaType.Movie ? widget.movie!.id : widget.tvShow!.id;
    return seenMedia.any((element) => element.mediaId == currentId);
  }
}
