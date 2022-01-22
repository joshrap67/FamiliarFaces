import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/search_media_response.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/tmdb_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddMediaScreen extends StatefulWidget {
  const AddMediaScreen({Key? key}) : super(key: key);

  @override
  _AddMediaScreenState createState() => _AddMediaScreenState();
}

class _AddMediaScreenState extends State<AddMediaScreen> {
  SearchMediaResponse? _selectedSearch;
  final TextEditingController _mediaSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TypeAheadFormField<SearchMediaResponse>(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _mediaSearchController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                                labelText: 'Media',
                                hintText: 'Search Movie or TV Show'),
                          ),
                          debounceDuration: Duration(milliseconds: 300),
                          suggestionsCallback: (query) => TmdbService.searchMulti(query),
                          itemBuilder: (context, SearchMediaResponse result) {
                            return ListTile(
                              title: Text('${result.title}'),
                              leading: Container(
                                height: 50,
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: getImageUrl(result.posterPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          onSuggestionSelected: onMediaSelected),
                      IconButton(
                        icon: Icon(Icons.clear),
                        tooltip: 'Clear media',
                        onPressed: onMediaInputCleared,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  onMediaInputCleared() {
    setState(() {
      _mediaSearchController.text = "";
      _selectedSearch = null;
      hideKeyboard(context);
    });
  }

  onMediaSelected(SearchMediaResponse selected) async {
    // todo handle tv
    setState(() {
      _selectedSearch = selected;
      _mediaSearchController.text = selected.title!;
      // todo change button text to say "Where have i seen this actor"
    });
    // todo write to sql
  }
}
