import 'package:familiar_faces/imports/globals.dart';
import 'package:familiar_faces/imports/utils.dart';
import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final SortingValues sortValue;
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
        hideKeyboard(context);
        return <PopupMenuEntry<SortingValues>>[
          PopupMenuItem<SortingValues>(
            value: SortingValues.ReleaseDateDescending,
            child: Text('Release Date Descending'),
          ),
          PopupMenuItem<SortingValues>(
            value: SortingValues.ReleaseDateAscending,
            child: Text('Release Date Ascending'),
          ),
          PopupMenuItem<SortingValues>(
            value: SortingValues.AlphaDescending,
            child: Text('Alpha Descending'),
          ),
          PopupMenuItem<SortingValues>(
            value: SortingValues.AlphaAscending,
            child: Container(
              child: Text('Alpha Ascending'),
            ),
          ),
        ];
      },
      onSelected: (SortingValues result) => onSelected(result),
    );
  }
}
