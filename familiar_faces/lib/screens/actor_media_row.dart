import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/media_type.dart';
import 'package:familiar_faces/contracts/actor_credit.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

import '../imports/globals.dart';

class ActorMediaRow extends StatelessWidget {
  const ActorMediaRow(
      {Key? key,
      required this.media,
      required this.rowClicked,
      required this.addToSeenClicked,
      required this.removeFromSeenClicked})
      : super(key: key);
  final ActorCredit media;
  final Function(ActorCredit) rowClicked;
  final Function(ActorCredit) addToSeenClicked;
  final Function(ActorCredit) removeFromSeenClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: media.isSeen ? Color(0xff009257) : Globals.TILE_COLOR,
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
                    imageUrl: getTmdbPicture(media.posterPath),
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
                                    text: '${media.title} (${formatDateYearOnly(media.releaseDate)})',
                                    style: TextStyle(
                                      color: getAccentColor(),
                                    )),
                                TextSpan(
                                    text: '\n${media.characterName}',
                                    style:
                                        TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: getAccentColor())),
                              ],
                            ),
                            minFontSize: 12,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    if (media.isSeen)
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => removeFromSeenClicked(media),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                '${media.mediaType == MediaType.Movie ? 'MOVIE' : 'SHOW'} SEEN',
                                minFontSize: 5,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: getAccentColor(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!media.isSeen)
                      Expanded(
                        child: TextButton(
                          onPressed: () => addToSeenClicked(media),
                          child: Text(
                            'SET ${media.mediaType == MediaType.Movie ? 'MOVIE' : 'SHOW'} AS SEEN',
                            style: TextStyle(
                              color: getAccentColor(),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 36,
                color: getAccentColor(),
                tooltip: 'Full Cast',
                onPressed: () => rowClicked(media),
              )
            ]),
          )
        ],
      ),
    );
  }

  Color getAccentColor() {
    return media.isSeen ? Colors.white : Colors.black;
  }
}
