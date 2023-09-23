import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/domain/actor_credit.dart';
import 'package:familiar_faces/domain/media_type.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class ActorMediaCard extends StatelessWidget {
  final ActorCredit media;
  final Function(ActorCredit) arrowClicked;
  final Function(ActorCredit) setSeenClicked;
  final Function(ActorCredit) removeAsSeenClicked;

  const ActorMediaCard(
      {Key? key,
      required this.media,
      required this.arrowClicked,
      required this.setSeenClicked,
      required this.removeAsSeenClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: media.isSeenByUser ? Color(0xff009257) : Theme.of(context).cardColor,
      child: Container(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
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
                                        color: getAccentColor(context),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\n${media.characterName}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: getAccentColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                                minFontSize: 12,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                        if (media.isSeenByUser)
                          Expanded(
                            child: GestureDetector(
                              onLongPress: () => removeAsSeenClicked(media),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AutoSizeText(
                                    '${media.mediaType == MediaType.Movie ? 'MOVIE' : 'TV SHOW'} SEEN',
                                    minFontSize: 5,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: getAccentColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!media.isSeenByUser)
                          Expanded(
                            child: TextButton(
                              onPressed: () => setSeenClicked(media),
                              child: Text(
                                'SET ${media.mediaType == MediaType.Movie ? 'MOVIE' : 'TV SHOW'} AS SEEN',
                                style: TextStyle(
                                  color: getAccentColor(context),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    iconSize: 28,
                    color: getAccentColor(context),
                    tooltip: 'Full Cast',
                    onPressed: () => arrowClicked(media),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Color getAccentColor(BuildContext context) {
    return media.isSeenByUser ? Colors.white : Theme.of(context).colorScheme.onBackground;
  }
}
