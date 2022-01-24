import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/screens/actor_filmography.dart';
import 'package:familiar_faces/screens/movie_cast_row.dart';
import 'package:flutter/material.dart';

class MovieFilterScreen extends StatefulWidget {
  const MovieFilterScreen({Key? key, required this.movieCast, required this.movieResponse}) : super(key: key);

  final List<PersonResponse> movieCast;
  final MovieResponse movieResponse;

  @override
  _MovieFilterScreenState createState() => _MovieFilterScreenState();
}

class _MovieFilterScreenState extends State<MovieFilterScreen> {
  // todo give warning that tv show shows all seasons and could have a spoiler in terms of who is in the show
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${widget.movieResponse.title} Cast',
          minFontSize: 12,
          style: TextStyle(fontSize: 26),
        ),
      ),
      body: Container(
        child: Scrollbar(
          child: ListView.separated(
            key: new GlobalKey(),
            separatorBuilder: (BuildContext context, int index) => Divider(height: 15),
            itemCount: widget.movieResponse.cast.length,
            itemBuilder: (BuildContext context, int index) {
              return MovieCastRow(
                castMember: widget.movieResponse.cast[index],
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
          actor: widget.movieCast.firstWhere((element) => element.id == actor.id),
        ),
      ),
    );
  }
}
