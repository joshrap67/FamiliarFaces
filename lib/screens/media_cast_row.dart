import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:flutter/material.dart';

class MediaCastRow extends StatefulWidget {
  const MediaCastRow({Key? key, required this.castMember, this.rowClicked}) : super(key: key);

  final CastResponse castMember;
  final Function(CastResponse)? rowClicked;

  @override
  _MediaCastRowState createState() => _MediaCastRowState();
}

class _MediaCastRowState extends State<MediaCastRow> {
  // todo make this stateless?
  late String _url;
  late bool _showImage;
  static const String placeholderUrl = 'https://picsum.photos/200';

  @override
  void initState() {
    _url = 'https://image.tmdb.org/t/p/w500/${widget.castMember.profilePath}';
    _showImage = widget.castMember.profilePath != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.rowClicked!(widget.castMember),
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
                  SizedBox(
                    width: 100,
                    height: 140,
                    child: CachedNetworkImage(
                      imageUrl: _showImage ? _url : placeholderUrl,
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
                                      text: '${widget.castMember.name}',
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    TextSpan(
                                        text: '\n${widget.castMember.characterName}',
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
              onPressed: () => widget.rowClicked!(widget.castMember),
            )
          ],
        ),
      ),
    );
  }
}
