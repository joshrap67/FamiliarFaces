import 'package:cached_network_image/cached_network_image.dart';
import 'package:familiar_faces/contracts/cast.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CharacterSearchRow extends StatefulWidget {
  const CharacterSearchRow(
      {Key? key,
      this.enabled = true,
      this.selectedCharacter,
      required this.focusNode,
      required this.castForSelectedMedia,
      required this.onCharacterSelected,
      required this.onCharacterCleared})
      : super(key: key);

  final List<Cast> castForSelectedMedia;
  final bool enabled;
  final FocusNode focusNode;
  final Function(Cast) onCharacterSelected;
  final VoidCallback onCharacterCleared;
  final Cast? selectedCharacter;

  @override
  _CharacterSearchRowState createState() => _CharacterSearchRowState();
}

class _CharacterSearchRowState extends State<CharacterSearchRow> {
  final TextEditingController _characterSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCharacter != null) {
      _characterSearchController.text = widget.selectedCharacter!.characterName!;
    }
  }

  @override
  void dispose() {
    _characterSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TypeAheadFormField<Cast>(
          textFieldConfiguration: TextFieldConfiguration(
            enabled: widget.enabled,
            focusNode: widget.focusNode,
            controller: _characterSearchController,
            onChanged: (_) {
              // so x button can properly be hidden
              setState(() {});
            },
            decoration: InputDecoration(
                labelText: 'Character',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: 'Search Character (optional)'),
          ),
          hideOnLoading: true,
          hideOnEmpty: true,
          hideOnError: true,
          hideSuggestionsOnKeyboardHide: false,
          onSuggestionSelected: widget.onCharacterSelected,
          suggestionsCallback: (query) => getCharacterResults(query),
          itemBuilder: (context, Cast result) {
            return ListTile(
              title: Text('${result.characterName}'),
              leading: Container(
                height: 50,
                width: 50,
                child: CachedNetworkImage(
                  imageUrl: getImageUrl(result.profilePath),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        if (!isStringNullOrEmpty(_characterSearchController.text))
          IconButton(
            icon: Icon(Icons.clear),
            tooltip: 'Clear character',
            onPressed: widget.onCharacterCleared,
          ),
      ],
    );
  }

  List<Cast> getCharacterResults(String query) {
    return widget.castForSelectedMedia.where((character) {
      var characterLower = character.characterName!.toLowerCase();
      var queryLower = query.toLowerCase();
      return characterLower.contains(queryLower);
    }).toList();
  }
}
