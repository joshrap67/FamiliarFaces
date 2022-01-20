import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:familiar_faces/contracts/grouped_movie_response.dart';
import 'package:familiar_faces/contracts/movie_response.dart';
import 'package:familiar_faces/screens/actor_filmography.dart';
import 'package:familiar_faces/screens/movie_cast_row.dart';
import 'package:flutter/material.dart';

class MovieFilterScreen extends StatefulWidget {
  const MovieFilterScreen({Key? key, required this.groupedMovieResponse, required this.movieResponse})
      : super(key: key);

  final GroupedMovieResponse groupedMovieResponse;
  final MovieResponse movieResponse;

  @override
  _MovieFilterScreenState createState() => _MovieFilterScreenState();
}

// todo floating search?
class _MovieFilterScreenState extends State<MovieFilterScreen> {
  // todo so what i am going to do is only show this page if they didn't search a specific character.
  // each row will be the name, image, and character name. Clicking on them will open up the page
  // that will be used if they did specify the character name
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
              separatorBuilder: (BuildContext context, int index) => Divider(
                    height: 15,
                  ),
              itemCount: widget.movieResponse.cast.length,
              itemBuilder: (BuildContext context, int index) {
                return MovieCastRow(
                  castMember: widget.movieResponse.cast[index],
                  rowClicked: (actor) => {actorClicked(actor)},
                );
              }),
        ),
      ),
    );
  }

  actorClicked(CastResponse actor) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ActorFilmography(
                actor: widget.groupedMovieResponse.people.firstWhere((element) => element.id == actor.id),
              )),
    );
  }
}
