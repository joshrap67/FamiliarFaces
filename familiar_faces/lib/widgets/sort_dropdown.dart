import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final SortValue sortValue;
  final Function onSelected;

  const SortDropdown({required this.sortValue, required this.onSelected, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.sort_rounded),
      tooltip: 'Sort Media',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      initialValue: sortValue,
      itemBuilder: (context) {
        hideKeyboard();
        return <PopupMenuEntry<SortValue>>[
          PopupMenuItem<SortValue>(
            value: SortValue.ReleaseDateDescending,
            child: Text('Release Date Descending'),
          ),
          PopupMenuItem<SortValue>(
            value: SortValue.ReleaseDateAscending,
            child: Text('Release Date Ascending'),
          ),
          PopupMenuItem<SortValue>(
            value: SortValue.AlphaDescending,
            child: Text('Alpha Descending'),
          ),
          PopupMenuItem<SortValue>(
            value: SortValue.AlphaAscending,
            child: Container(
              child: Text('Alpha Ascending'),
            ),
          ),
        ];
      },
      onSelected: (SortValue result) => onSelected(result),
    );
  }
}
