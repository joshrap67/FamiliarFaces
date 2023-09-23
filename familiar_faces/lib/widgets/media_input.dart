// import 'package:familiar_faces/domain/search_media_result.dart';
// import 'package:familiar_faces/imports/utils.dart';
// import 'package:familiar_faces/services/media_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
//
// class MediaInput extends StatefulWidget {
//   const MediaInput({super.key});
//
//   @override
//   State<MediaInput> createState() => _MediaInputState();
// }
//
// class _MediaInputState extends State<MediaInput> {
// 	final _mediaAddController = TextEditingController();
// 	FocusNode _addMediaFocusNode = new FocusNode();
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
// 		alignment: Alignment.centerRight,
// 		children: [
// 			TypeAheadField<SearchMediaResult>(
// 				textFieldConfiguration: TextFieldConfiguration(
// 					controller: _mediaAddController,
// 					onChanged: (_) {
// 						// so x button can properly be hidden
// 						setState(() {});
// 					},
// 					focusNode: _addMediaFocusNode,
// 					decoration: const InputDecoration(
// 						prefixIcon: const Icon(Icons.add),
// 						border: const OutlineInputBorder(),
// 						labelText: 'Add Media',
// 						hintText: 'Add Movie or TV Show'),
// 				),
// 				hideOnLoading: true,
// 				hideOnEmpty: true,
// 				hideOnError: true,
// 				hideSuggestionsOnKeyboardHide: false,
// 				debounceDuration: Duration(milliseconds: 300),
// 				keepSuggestionsOnSuggestionSelected: true,
// 				onSuggestionSelected: (media) => onMediaSelected(media),
// 				suggestionsCallback: (query) => MediaService.searchMulti(query, showSavedMedia: false),
// 				itemBuilder: (context, SearchMediaResult result) {
// 					return ListTile(
// 						title: Text('${result.title} (${formatDateYearOnly(result.releaseDate)})'),
// 						leading: Container(
// 							height: 50,
// 							width: 50,
// 							child: Image.network(
// 								getTmdbPicture(result.posterPath),
// 								fit: BoxFit.cover,
// 							),
// 						),
// 					);
// 				},
// 			),
// 			if (!isStringNullOrEmpty(_mediaAddController.text))
// 				IconButton(
// 					icon: const Icon(Icons.clear),
// 					tooltip: 'Clear media',
// 					onPressed: () => onMediaInputCleared(),
// 				),
// 		],
// 	);
//   }
//
//   onMediaInputCleared() {}
//
//   onMediaSelected(SearchMediaResult media) {}
// }
