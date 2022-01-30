import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/search_media_result.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class MediaSearchRow extends StatefulWidget {
  const MediaSearchRow({Key? key, this.selectedMedia, this.showSavedMedia = true, required this.onMediaSelected, required this.onInputCleared})
      : super(key: key);

  final Function(SearchMediaResult) onMediaSelected;
  final Function onInputCleared;
  final SearchMediaResult? selectedMedia;
  final bool showSavedMedia;

  @override
  _MediaSearchRowState createState() => _MediaSearchRowState();
}

class _MediaSearchRowState extends State<MediaSearchRow> {
  final TextEditingController _mediaSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedMedia != null) {
      _mediaSearchController.text = widget.selectedMedia!.title!;
    }
  }

  @override
  void dispose() {
    _mediaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TypeAheadFormField<SearchMediaResult>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _mediaSearchController,
              onChanged: (_) {
                // so x button can properly be hidden
                setState(() {});
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  labelText: 'Movie/TV Show',
                  hintText: 'Search Movie or TV Show'),
            ),
            hideOnLoading: true,
            hideOnEmpty: true,
            hideOnError: true,
            debounceDuration: Duration(milliseconds: 300),
            suggestionsCallback: (query) => MediaService.searchMulti(query, showSavedMedia: widget.showSavedMedia),
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, SearchMediaResult result) {
              return ListTile(
                title: Text('${result.title}'),
                leading: Container(
                  height: 50,
                  width: 50,
                  // todo don't use cached here?
                  child: CachedNetworkImage(
                    imageUrl: getImageUrl(result.posterPath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            onSuggestionSelected: (media) => widget.onMediaSelected(media)),
        if (!isStringNullOrEmpty(_mediaSearchController.text))
          IconButton(
            icon: Icon(Icons.clear),
            tooltip: 'Clear media',
            onPressed: () => widget.onInputCleared(),
          ),
      ],
    );
  }
}
