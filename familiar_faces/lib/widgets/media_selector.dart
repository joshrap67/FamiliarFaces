import 'dart:async';

import 'package:familiar_faces/domain/search_media_result.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:familiar_faces/services/media_service.dart';
import 'package:flutter/material.dart';

class MediaSelector extends StatefulWidget {
  final void Function(SearchMediaResult? selection) onSelected;
  final String? labelText;
  final String? hintText;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool clearOnSelect;

  const MediaSelector({
    super.key,
    required this.onSelected,
    this.labelText,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.focusNode,
    this.clearOnSelect = false,
  });

  @override
  State<MediaSelector> createState() => _MediaSelectorState();
}

class _MediaSelectorState extends State<MediaSelector> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    return RawAutocomplete<SearchMediaResult>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (media) => media.title ?? "",
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Never>.empty();
        }

        _debounceTimer?.cancel();
        final completer = Completer<Iterable<SearchMediaResult>>();
        _debounceTimer = Timer(widget.debounceDuration, () async {
          try {
            final results = await MediaService.searchMulti(context, textEditingValue.text);
            if (!completer.isCompleted) {
              completer.complete(results);
            }
          } catch (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          }
        });

        return completer.future;
      },
      onSelected: (SearchMediaResult selection) {
        widget.onSelected.call(selection);
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
                  final SearchMediaResult media = options.elementAt(index);
                  return InkWell(
                    onTap: () => selectMedia(media),
                    child: ListTile(
                      title: Text('${media.title} (${formatDateYearOnly(media.releaseDate)})'),
                      leading: Container(
                        height: 50,
                        width: 50,
                        child: Image.network(getTmdbPicture(media.posterPath), fit: BoxFit.cover),
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

  void selectMedia(SearchMediaResult? mediaResult) {
    if (!widget.clearOnSelect) {
      _controller.text = mediaResult?.title ?? "";
    }
    widget.onSelected(mediaResult);

    hideKeyboard();
    setState(() {});
  }
}
