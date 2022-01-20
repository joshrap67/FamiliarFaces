import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:flutter/material.dart';

class ActorFilmography extends StatefulWidget {
  const ActorFilmography({Key? key, required this.actor}) : super(key: key);

  final PersonResponse actor;

  @override
  _ActorFilmographyState createState() => _ActorFilmographyState();
}

class _ActorFilmographyState extends State<ActorFilmography> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText('${widget.actor.name} Filmography'),
      ),
      body: Column(
        children: [
        	Text('Wait')
		],
      ),
    );
  }
}
