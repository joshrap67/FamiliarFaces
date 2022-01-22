import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/contracts/person_response.dart';
import 'package:familiar_faces/screens/actor_movie_row.dart';
import 'package:flutter/material.dart';

class ActorFilmography extends StatefulWidget {
  const ActorFilmography({Key? key, required this.actor}) : super(key: key);

  final PersonResponse actor;

  @override
  _ActorFilmographyState createState() => _ActorFilmographyState();
}

class _ActorFilmographyState extends State<ActorFilmography> {
  late List<PersonCreditResponse> sortedCredits;
  late String url;
  late bool showImage;
  static const String placeholderUrl = 'https://picsum.photos/200';

  // todo on return re query all saved media in case somewhere down the stack they added a media to their seen list and its on this original page

  @override
  void initState() {
    url = 'https://image.tmdb.org/t/p/w500/${widget.actor.profileImagePath}';
    showImage = widget.actor.profileImagePath != null;
    sortedCredits = List.from(widget.actor.credits);
    sortedCredits.sort((a, b) {
      if (a.releaseDate == null || b.releaseDate == null) {
        return 1;
      } else {
        return b.releaseDate!.compareTo(a.releaseDate!);
      }
    });
    sortedCredits.removeWhere((element) => element.releaseDate == null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText('${widget.actor.name} Filmography'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Image.network(
                showImage ? url : placeholderUrl,
                fit: BoxFit.fitWidth,
                width: 100,
                height: 140,
              ),
              Text('${widget.actor.name}'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Show Only Viewed Media'),
              )
            ],
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) => Divider(
                        height: 15,
                      ),
                  itemCount: sortedCredits.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ActorMovieRow(
                      movie: sortedCredits[index],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
