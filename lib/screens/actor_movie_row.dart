import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/person_credit_response.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class ActorMovieRow extends StatefulWidget {
  const ActorMovieRow({Key? key, required this.movie}) : super(key: key);

  final PersonCreditResponse movie;

  @override
  _ActorMovieRowState createState() => _ActorMovieRowState();
}

class _ActorMovieRowState extends State<ActorMovieRow> {
  late String url;
  late bool showImage;
  static const String placeholderUrl = 'https://picsum.photos/200';

  @override
  void initState() {
    url = 'https://image.tmdb.org/t/p/w500/${widget.movie.posterPath}';
    showImage = widget.movie.posterPath != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Color(0xff2a2f38),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 140,
                  child: CachedNetworkImage(
                    imageUrl: showImage ? url : placeholderUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${widget.movie.title} (${filterDate(widget.movie.releaseDate)})',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AutoSizeText(
                              '${widget.movie.characterName}',
                              minFontSize: 10,
                              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ),
                      if (widget.movie.isSeen)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                "SEEN",
                                minFontSize: 5,
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
