import 'package:familiar_faces/domain/cast_member.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class CharacterSelector extends StatefulWidget {
  final void Function(CastMember? selection) onSelected;
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<CastMember> options;

  const CharacterSelector({
    super.key,
    required this.onSelected,
    required this.options,
    this.labelText,
    this.hintText,
    this.controller,
    this.focusNode,
  });

  @override
  State<CharacterSelector> createState() => _CharacterSelectorState();
}

class _CharacterSelectorState extends State<CharacterSelector> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maxOptionsHeight = MediaQuery.sizeOf(context).height * .35;
    return RawAutocomplete<CastMember>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (cast) => cast.characterName ?? "",
      optionsBuilder: (TextEditingValue textEditingValue) async {
        var query = textEditingValue.text;
        return widget.options.where((character) {
          var characterLower = character.characterName!.toLowerCase();
          var queryLower = query.toLowerCase();
          return characterLower.contains(queryLower);
        }).toList();
      },
      onSelected: (CastMember castMember) {
        widget.onSelected.call(castMember);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              scrollPadding: EdgeInsets.only(bottom: maxOptionsHeight + 50),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.hintText,
                labelText: widget.labelText,
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => setState(() {
                          widget.onSelected(null);
                          _controller.clear();
                        }),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              controller: _controller,
              focusNode: focusNode,
              onTapOutside: (_) => hideKeyboard(),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 15,
            child: Scrollbar(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  final CastMember castMember = options.elementAt(index);
                  return InkWell(
                    onTap: () => selectCastMember(castMember),
                    child: ListTile(
                      title: Text('${castMember.characterName}'),
                      leading: Container(
                        height: 50,
                        width: 50,
                        child: Image.network(getTmdbPicture(castMember.profilePath), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void selectCastMember(CastMember? castMember) {
    setState(() {
      widget.onSelected(castMember);
      _controller.text = castMember?.characterName ?? "";
    });
    hideKeyboard();
  }
}
