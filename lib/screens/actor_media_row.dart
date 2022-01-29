import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/actor_credit.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class ActorMediaRow extends StatefulWidget {
  const ActorMediaRow(
      {Key? key, required this.media, this.rowClicked, this.addToSeenClicked, this.removeFromSeenClicked})
      : super(key: key);

  final ActorCredit media;
  final Function(ActorCredit)? rowClicked;
  final Function(ActorCredit)? addToSeenClicked;
  final Function(ActorCredit)? removeFromSeenClicked;

  @override
  _ActorMediaRowState createState() => _ActorMediaRowState();
}

class _ActorMediaRowState extends State<ActorMediaRow> {
  late String url;
  late bool showImage;
  static const String placeholderUrl = 'https://picsum.photos/200'; // todo remove and make this stateless

  @override
  void initState() {
    url = 'https://image.tmdb.org/t/p/w500/${widget.media.posterPath}';
    showImage = widget.media.posterPath != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: widget.media.isSeen ? Color(0xff009257) : Color(0xff2a2f38),
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
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 100,
                  height: 140,
                  child: CachedNetworkImage(
                    imageUrl: showImage ? url : placeholderUrl,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        child: const CircularProgressIndicator(),
                        height: 50,
                        width: 50,
                      ),
                    ),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 2.0, 0.0, 8.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.media.title} (${formatDateYearOnly(widget.media.releaseDate)})',
                                ),
                                if (Globals.settings.showCharacters)
                                  TextSpan(
                                      text: '\n${widget.media.characterName}',
                                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            minFontSize: 12,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    if (widget.media.isSeen)
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => widget.removeFromSeenClicked!(widget.media),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                "${widget.media.mediaType == MediaType.Movie ? 'MOVIE' : 'SHOW'} SEEN",
                                minFontSize: 5,
                                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!widget.media.isSeen)
                      Expanded(
                        child: TextButton(
                          onPressed: () => widget.addToSeenClicked!(widget.media),
                          child: Text('SET ${widget.media.mediaType == MediaType.Movie ? 'MOVIE' : 'SHOW'} AS SEEN'),
                        ),
                      )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 36,
                color: Color(0xe1ffffff),
                tooltip: 'Full Cast',
                onPressed: () => widget.rowClicked!(widget.media),
              )
            ]),
          )
        ],
      ),
    );
  }
}
