import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/screens/actor_filmography.dart';
import 'package:familiar_faces/screens/media_cast_row.dart';
import 'package:flutter/material.dart';

class MediaCastScreen extends StatefulWidget {
  const MediaCastScreen({Key? key, required this.cast, required this.actors, required this.title}) : super(key: key);

  final List<CastResponse> cast;
  final List<PersonResponse> actors;
  final String title;

  @override
  _MediaCastScreenState createState() => _MediaCastScreenState();
}

class _MediaCastScreenState extends State<MediaCastScreen> {
  // todo give warning that tv show shows all seasons and could have a spoiler in terms of who is in the show
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${widget.title} Cast',
          minFontSize: 12,
          style: TextStyle(fontSize: 26),
        ),
      ),
      body: Container(
        child: Scrollbar(
          child: ListView.separated(
            key: new GlobalKey(),
            separatorBuilder: (BuildContext context, int index) => Divider(height: 15),
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
    );
  }

  actorClicked(CastResponse actor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActorFilmography(
          actor: widget.actors.firstWhere((element) => element.id == actor.id),
        ),
      ),
    );
  }
}
