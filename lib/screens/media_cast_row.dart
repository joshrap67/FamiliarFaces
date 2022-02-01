import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class MediaCastRow extends StatelessWidget {
  const MediaCastRow({Key? key, required this.castMember, this.rowClicked}) : super(key: key);

  final Cast castMember;
  final Function(Cast)? rowClicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => rowClicked!(castMember),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Color(0xff2a2f38),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                    child: SizedBox(
                      width: 100,
                      height: 140,
                      child: CachedNetworkImage(
                        imageUrl: getImageUrl(castMember.profilePath),
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
                            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${castMember.name}',
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    if (Globals.settings.showCharacters)
                                      TextSpan(
                                          text: '\n${castMember.characterName}',
                                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                                minFontSize: 10,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              iconSize: 36,
              color: Colors.white,
              tooltip: 'Full filmography',
              onPressed: () => rowClicked!(castMember),
            )
          ],
        ),
      ),
    );
  }
}
