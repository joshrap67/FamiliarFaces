import 'package:auto_size_text/auto_size_text.dart';
import 'package:familiar_faces/contracts/cast_response.dart';
import 'package:flutter/material.dart';

class MovieCastRow extends StatefulWidget {
  const MovieCastRow({Key? key, required this.castMember, this.rowClicked}) : super(key: key);

  final CastResponse castMember;
  final Function(CastResponse)? rowClicked;

  @override
  _MovieCastRowState createState() => _MovieCastRowState();
}

class _MovieCastRowState extends State<MovieCastRow> {
  late String url;
  late bool showImage;
  static const String placeholderUrl = 'https://picsum.photos/200';

  @override
  void initState() {
    url = 'https://image.tmdb.org/t/p/w500/${widget.castMember.profilePath}';
    showImage = widget.castMember.profilePath != null;
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
              bottomRight: Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Image.network(
                    showImage ? url : placeholderUrl,
                    fit: BoxFit.fitWidth,
                    width: 100,
                    height: 140,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${widget.castMember.name}',
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
                                '${widget.castMember.characterName}',
                                minFontSize: 10,
                                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                "Seen in 4 other movies",
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
            ),
            IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                iconSize: 36,
                color: Color(0xAB69F0AE),
                tooltip: 'Full filmography',
                onPressed: () => widget.rowClicked!(widget.castMember))
          ],
        ),
      ),
    );
  }
}
