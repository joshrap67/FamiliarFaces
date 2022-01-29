import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/screens/actor_details.dart';
import 'package:familiar_faces/screens/media_cast_row.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:familiar_faces/services/saved_media_service.dart';
import 'package:familiar_faces/sql_contracts/saved_media.dart';
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
  // todo add a button to mark as seen from here?
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${widget.title}',
          minFontSize: 12,
          maxLines: 1,
          style: TextStyle(fontSize: 26),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Set as seen',
            color: Colors.greenAccent,
            icon: Icon(Icons.add),
          )
        ],
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

  void actorClicked(CastResponse actor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActorDetails(
          actor: widget.actors.firstWhere((element) => element.id == actor.id),
        ),
      ),
    ).then((value) => updateSeenCreditsAsync());
  }

  Future<void> updateSeenCreditsAsync() async {
    List<SavedMedia> seenMedia = await SavedMediaService.getAll();
    widget.actors.forEach((element) {
      MediaService.applySeenMedia(element.credits, seenMedia);
    });
  }
}
